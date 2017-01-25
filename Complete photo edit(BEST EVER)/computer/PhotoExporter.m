//
//  PhotoExporter.m
//  computer
//
//  Created by Nate Parrott on 10/24/15.
//  Copyright © 2015 Nate Parrott. All rights reserved.
//

#import "PhotoExporter.h"
#import "EditorViewController.h"
#import "computer-Swift.h"

@implementation PhotoExporter

- (void)start {
    UIGraphicsBeginImageContextWithOptions(self.cropRect.size, NO, 0);
    [self _askDelegateToRenderFrame:self.defaultTime];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    if (self.saveAsSticker) {
        NSString *uuid = [[NSUUID UUID] UUIDString];
        NSURL *path = [[[StickerStore getShared] directory] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@@3x.png", uuid]];
        [UIImagePNGRepresentation([[self class] imageResizedForSticker:image]) writeToURL:path atomically:YES];
    } else if (self.quickSaveToCameraRoll) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
        [self showAlert:NSLocalizedString(@"Saving photo to camera roll.", @"") title:nil];
    } else {
        UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[image] applicationActivities:nil];
        [self.parentViewController presentViewController:activityVC animated:YES completion:nil];
    }
    [self.delegate exporterDidFinish:self];
}

+ (UIImage *)imageResizedForSticker:(UIImage *)image {
    CGFloat size = 450;
    UIGraphicsBeginImageContext(CGSizeMake(size, size));
    CGFloat scale = MIN(size/image.size.width, size/image.size.height);
    CGSize boxSize = CGSizeMake(image.size.width * scale, image.size.height * scale);
    [image drawInRect:CGRectMake((size - boxSize.width)/2, (size - boxSize.height)/2, boxSize.width, boxSize.height)];
    UIImage *sticker = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return sticker;
}

@end
