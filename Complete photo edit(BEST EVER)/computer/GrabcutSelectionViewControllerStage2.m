//
//  GrabcutSelectionViewControllerStage2.m
//  computer
//
//  Created by Nate Parrott on 5/19/16.
//  Copyright © 2016 Nate Parrott. All rights reserved.
//

#import "GrabcutSelectionViewControllerStage2.h"
#import "DrawSelectionView.h"
#import "Grabcut.h"
#import "computer-Swift.h"

@interface GrabcutSelectionViewControllerStage2 ()

@property (nonatomic) UIImageView *imageView;
@property (nonatomic) UIImageView *extractedOutput;
@property (nonnull) UIImage *imageForGrabcut;
@property (nonatomic) DrawSelectionView *scribbleView;
@property (nonatomic) UIActivityIndicatorView *loader;
@property (nonatomic) BOOL currentlyRunning;
@property (nonatomic) Grabcut *gc;

@end

@implementation GrabcutSelectionViewControllerStage2

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Quick Select", @"");
    self.navigationItem.prompt = NSLocalizedString(@"Tap or draw on areas to add or remove them", @"");
    
    self.imageView = [[UIImageView alloc] initWithImage:self.image];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.imageView];
    self.extractedOutput = [[UIImageView alloc] init];
    self.extractedOutput.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.extractedOutput];
    
    self.scribbleView = [DrawSelectionView new];
    self.scribbleView.aspectRatio = self.image.size.width / self.image.size.height;
    [self.view addSubview:self.scribbleView];
    self.scribbleView.alpha = 0.5;
    self.scribbleView.mode = DrawSelectionModeDrawBrush;
    __weak GrabcutSelectionViewControllerStage2 *weakSelf = self;
    self.scribbleView.onStatusChanged = ^{
        [weakSelf didDraw];
    };
    self.scribbleView.hideUndoButton = YES;
    self.scribbleView.brushWidth = 12;
    self.scribbleView.additiveStrokeColor = [UIColor colorWithRed:0.4 green:0.5 blue:1 alpha:1];
    self.scribbleView.subtractiveStrokeColor = [UIColor colorWithRed:1 green:0.5 blue:0.5 alpha:1];
    self.scribbleView.disableAntialiasing = YES;
    
    self.loader = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.loader.hidesWhenStopped = YES;
    [self.view addSubview:self.loader];
    
    self.imageForGrabcut = [self resizeImageForGrabcut:self.image];
    self.gc = [[Grabcut alloc] initWithImage:self.imageForGrabcut];
    self.currentlyRunning = YES;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        CGPoint cropRectScale = CGPointMake(self.imageForGrabcut.size.width / self.image.size.width, self.imageForGrabcut.size.height / self.image.size.height);
        CGRect cropRect = CGRectMake(self.cropRect.origin.x * cropRectScale.x, self.cropRect.origin.y * cropRectScale.y, self.cropRect.size.width * cropRectScale.x, self.cropRect.size.height * cropRectScale.y);
        [self.gc maskToRect:cropRect];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.currentlyRunning = NO;
            self.extractedOutput.image = [self.gc extractImage];
            
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Next", @"") style:UIBarButtonItemStyleDone target:self action:@selector(done:)];
            
            [UIView animateWithDuration:0.3 animations:^{
                self.imageView.alpha = 0.3;
            } completion:^(BOOL finished) {
                __weak UIImageView *weakImageView = self.imageView;
                [UIView animateWithDuration:0.7 delay:0 options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat animations:^{
                    weakImageView.alpha = 0.8;
                } completion:nil];
            }];
        });
    });
}

- (void)setCurrentlyRunning:(BOOL)currentlyRunning {
    _currentlyRunning = currentlyRunning;
    if (currentlyRunning) {
        [self.loader startAnimating];
    } else {
        [self.loader stopAnimating];
    }
    self.view.userInteractionEnabled = !currentlyRunning;
}

- (void)didDraw {
    if ([self.scribbleView hasSelection]) {
        self.currentlyRunning = YES;
        UIImage *mask = self.scribbleView.mask;
        [self.scribbleView clearMask];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImage *processedMask = [self applyBlackBackgroundToMask:[mask resizeTo:self.imageForGrabcut.size]];
            [self.gc addMask:processedMask foregroundColor:self.scribbleView.additiveStrokeColor backgroundColor:self.scribbleView.subtractiveStrokeColor];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.extractedOutput.image = [self.gc extractImage];
                self.currentlyRunning = NO;
            });
        });
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGRect f = CGRectMake(0, [[self topLayoutGuide] length], self.view.bounds.size.width, self.view.bounds.size.height - [[self topLayoutGuide] length]);
    self.scribbleView.frame = f;
    self.imageView.frame = f;
    self.extractedOutput.frame = f;
    self.loader.center = self.imageView.center;
}

- (void)done:(id)sender {
    self.onDone([self.gc extractImage]);
}

- (UIImage *)resizeImageForGrabcut:(UIImage *)image {
    return [image resizedWithMaxDimension:500];
}

- (UIImage *)applyBlackBackgroundToMask:(UIImage *)mask {
    UIGraphicsBeginImageContext(mask.size);
    [[UIColor blackColor] setFill];
    [[UIBezierPath bezierPathWithRect:CGRectMake(0, 0, mask.size.width, mask.size.height)] fill];
    [mask drawAtPoint:CGPointZero];
    UIImage *i = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return i;
}

@end
