//
//  Exporter.m
//  computer
//
//  Created by Nate Parrott on 10/24/15.
//  Copyright © 2015 Nate Parrott. All rights reserved.
//

#import "Exporter.h"
#import "computer-Swift.h"

@interface Exporter ()

@property (nonatomic) BOOL wasCancelled;

@end

@implementation Exporter

- (void)_askDelegateToRenderFrame:(FrameTime *)time {
    [self.delegate exporter:self drawFrameAtTime:time inRect:CGRectMake(-self.cropRect.origin.x, -self.cropRect.origin.y, self.canvasSize.width, self.canvasSize.height)];
}

- (void)start {
    
}

- (void)cancel {
    self.wasCancelled = YES;
}

- (void)showAlert:(NSString *)message title:(NSString *)title {
    UIAlertController *c = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    [c addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Okay", @"") style:UIAlertActionStyleDefault handler:nil]];
    [[NPSoftModalPresentationController getViewControllerForPresentation] presentViewController:c animated:YES completion:nil];
}

@end
