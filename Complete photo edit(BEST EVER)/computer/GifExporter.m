//
//  GifExporter.m
//  computer
//
//  Created by Nate Parrott on 11/7/15.
//  Copyright © 2015 Nate Parrott. All rights reserved.
//

#import "GifExporter.h"
#import "ConvenienceCategories.h"
#import "UIImagePixelSource.h"
#import "computer-Swift.h"
#import "GifOptimizer.h"
#import "VideoConstants.h"
#import "Keyframe.h"
#import "EditorViewController+Send.h"
@import ImageIO;
@import MobileCoreServices;
@import Photos;

@interface GifExporter () {
    BOOL _alreadyOfferedToShorten;
}

@end

@implementation GifExporter

- (void)start {
    if (self.endTime.time * (self.rebound ? 2 : 1) > VC_LONGEST_STATIC_ANIMATION_PERIOD * 2 && !_alreadyOfferedToShorten) {
        [self offerToShorten];
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"export.gif"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        }
        NSLog(@"Writing gif to %@", path);
        
        CGSize size = self.cropRect.size;
        size.width *= [UIScreen mainScreen].scale;
        size.height *= [UIScreen mainScreen].scale;
        CGFloat maxDimension = 250;
        CGFloat scale = MIN(1, MIN(maxDimension / size.width, maxDimension / size.height));
        size.width = round(size.width * scale);
        size.height = round(size.height * scale);
        NSInteger fps = VC_GIF_FPS;
        self.fps = fps;
        
        __block NSInteger frameCount = 0;
        [self enumerateFrameTimes:^(FrameTime *time) {
            frameCount++;
        }];
        
        NSDictionary *fileProperties = @{
                                (id)kCGImagePropertyGIFDictionary: @{(id)kCGImagePropertyGIFLoopCount: @0}
                                };
        NSDictionary *frameProps = @{
                                     (id)kCGImagePropertyGIFDictionary: @{(id)kCGImagePropertyGIFDelayTime: @(1.0/fps)}
                                     };
        
        CGImageDestinationRef destination = CGImageDestinationCreateWithURL((__bridge CFURLRef)[NSURL fileURLWithPath:path], kUTTypeGIF, frameCount, NULL);
        CGImageDestinationSetProperties(destination, (__bridge CFDictionaryRef)fileProperties);
        
        [self enumerateFrameTimes:^(FrameTime *time) {
            @autoreleasepool {
                UIImage *frameImage = [self renderFrameAtTime:time size:size];
                CGImageDestinationAddImage(destination, frameImage.CGImage, (__bridge CFDictionaryRef)frameProps);
            }
        }];
        
        if (!CGImageDestinationFinalize(destination)) {
            NSLog(@"failed to finalize image destination");
        }
        CFRelease(destination);
        
        NSLog(@"starting to optimize");
        [GifOptimizer optimizeGifAtPath:path doneBlock:^{
            NSLog(@"done");
            dispatch_async(dispatch_get_main_queue(), ^{
                NSURL *gifURL = [NSURL fileURLWithPath:path];
                if (self.goStraightToURLShare) {
                    [self shareLinkToGIF:gifURL];
                } else {
                    [self promptToShareGIFAtURL:gifURL];
                }
                [self done];
            });
        }];
    });
}

- (void)promptToShareGIFAtURL:(NSURL *)gifURL {
    UIAlertController *actions = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Share GIF", @"") message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    if ([MFMessageComposeViewController canSendAttachments]) {
        [actions addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Send as Message", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            MFMessageComposeViewController *compose = [MFMessageComposeViewController new];
            [compose addAttachmentURL:gifURL withAlternateFilename:@"Content.gif"];
            [self.parentViewController presentMessageComposer:compose];
        }]];
    }
    if ([MFMailComposeViewController canSendMail]) {
        [actions addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Send in Email", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            MFMailComposeViewController *compose = [MFMailComposeViewController new];
            [compose addAttachmentData:[NSData dataWithContentsOfURL:gifURL] mimeType:@"image/gif" fileName:@"Content.gif"];
            [self.parentViewController presentMailComposer:compose];
        }]];
    }
    [actions addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Save to Camera Roll", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusAuthorized) {
                [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                    [PHAssetChangeRequest creationRequestForAssetFromImageAtFileURL:gifURL];
                } completionHandler:^(BOOL success, NSError * _Nullable error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (success) {
                            [self makeUserAwareOfHowGifsWorkInCameraRoll];
                        } else {
                            [self showAlert:NSLocalizedString(@"Failed to save GIF to your camera roll.", @"") title:NSLocalizedString(@"Error!", @"")];
                        }
                    });
                }];
            }
        }];
    }]];
    [actions addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Share Link to GIF", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self shareLinkToGIF:gifURL];
    }]];
    [actions addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Never mind", @"") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }]];
    [self.parentViewController presentViewController:actions animated:YES completion:nil];
}

- (void)shareLinkToGIF:(NSURL *)gifURL {
    [self.parentViewController shareGIFWithFileURL:gifURL callback:^(NSString *shareableURL) {
        NSLog(@"got url: %@", shareableURL);
        if (shareableURL) {
            // NSURL *shareable = [NSURL URLWithString:shareableURL];
            UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[shareableURL] applicationActivities:@[]];
            [self.parentViewController presentViewController:activityVC animated:YES completion:nil];
        }
    }];
}

- (void)makeUserAwareOfHowGifsWorkInCameraRoll {
    NSString *defaultsKey = @"computer.GifExporter.IsUserAwareOfHowGifsWorkInCameraRoll";
    if (![[NSUserDefaults standardUserDefaults] boolForKey:defaultsKey]) {
        [self showAlert:NSLocalizedString(@"Remember, GIFs don't animate in your camera roll. They DO animate if you send them, or insert them into certain other apps.", @"") title:NSLocalizedString(@"Saved GIF to Camera Roll", @"")];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:defaultsKey];
    }
}

- (void)offerToShorten {
    NSString *lengthDesc = [NSString stringWithFormat:(self.rebound ? NSLocalizedString(@"%@ seconds, then reversed", @"") : NSLocalizedString(@"%@ seconds", @"")), @(self.endTime.time)];
    NSString *lengthSuggestion = [NSString stringWithFormat:(self.rebound ? NSLocalizedString(@"Save first %@ seconds, then reverse", @"") : NSLocalizedString(@"Save first %@ seconds", @"")), @(VC_LONGEST_STATIC_ANIMATION_PERIOD)];
    
    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"This GIF is long (%@) and it might take a long time to save.", @""), lengthDesc];
    
    UIAlertController *prompt = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"🚨 Big GIF Alert 🚨", @"") message:message preferredStyle:UIAlertControllerStyleAlert];
    [prompt addAction:[UIAlertAction actionWithTitle:lengthSuggestion style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.endTime = [[FrameTime alloc] initWithFrame:VC_LONGEST_STATIC_ANIMATION_PERIOD * 100 atFPS:100];
        [self start];
    }]];
    [prompt addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Save full GIF", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        _alreadyOfferedToShorten = YES;
        [self start];
    }]];
     [prompt addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
         [self done];
    }]];
    
    [[NPSoftModalPresentationController getViewControllerForPresentation] presentViewController:prompt animated:YES completion:nil];
}

- (void)done {
    // TODO: delete the temp file?
    [self.delegate exporterDidFinish:self];
}

- (UIImage *)renderFrameAtTime:(FrameTime *)time size:(CGSize)size {
    __block UIImage *image = nil;
    dispatch_sync(dispatch_get_main_queue(), ^{
        UIGraphicsBeginImageContextWithOptions(self.cropRect.size, NO, 0);
        [[UIColor whiteColor] setFill];
        [[UIBezierPath bezierPathWithRect:CGRectMake(0, 0, self.cropRect.size.width, self.cropRect.size.height)] fill];
        [self _askDelegateToRenderFrame:time];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    });
    return [image resizeTo:size]; // TODO: do this more efficiently by drawing directly into the correct-sized image
}

- (NSInteger)repeatCount {
    return 1;
}

- (BOOL)respectsRepeatCount {
    return NO;
}

@end
