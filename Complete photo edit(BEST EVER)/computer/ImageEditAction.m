//
//  ImageEditAction.m
//  computer
//
//  Created by Nate Parrott on 5/15/16.
//  Copyright © 2016 Nate Parrott. All rights reserved.
//

#import "ImageEditAction.h"
#import "UIImage+InPaint.h"
#import "UIImage+Trim.h"
#import <GPUImage/GPUImage.h>

@implementation ImageEditAction

- (void)run {
    /*
     ImageSelectionEditActionDeleteBackground,
     ImageSelectionEditActionSplitFromBackground,
     ImageSelectionEditActionSplitFromBackgroundAndInpaint,
     ImageSelectionEditActionInpaint
     */
    if (self.mode == ImageSelectionEditActionDeleteBackground) {
        self.output1 = [[self maskedObject] imageByTrimmingTransparentPixels];
    } else if (self.mode == ImageSelectionEditActionSplitFromBackground) {
        self.output1 = self.inputImage;
        self.output2 = [[self maskedObject] imageByTrimmingTransparentPixels];
    } else if (self.mode == ImageSelectionEditActionSplitFromBackgroundAndInpaint) {
        self.output1 = [self inpaintedBackground];
        self.output2 = [[self maskedObject] imageByTrimmingTransparentPixels];
    } else if (self.mode == ImageSelectionEditActionInpaint) {
        self.output1 = [self inpaintedBackground];
    }
}

- (UIImage *)maskedObject {
    return [self image:self.inputImage maskedWith:self.mask];
}

- (UIImage *)image:(UIImage *)image maskedWith:(UIImage *)alphaMask {
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 1);
    CGContextClipToMask(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, image.size.width, image.size.height), [self flipMaskVertically:alphaMask].CGImage);
    [image drawAtPoint:CGPointZero];
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}

- (UIImage *)flipMaskVertically:(UIImage *)image {
    // via http://stackoverflow.com/a/24799281/778450
    UIGraphicsBeginImageContext(image.size);
    CGContextDrawImage(UIGraphicsGetCurrentContext(),CGRectMake(0.,0., image.size.width, image.size.height),image.CGImage);
    UIImage *i = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return i;
}

- (UIImage *)createBlackWhiteMaskFromAlphaMask:(UIImage *)alphaMask {
    UIGraphicsBeginImageContext(alphaMask.size);
    [[UIColor blackColor] setFill];
    [[UIBezierPath bezierPathWithRect:CGRectMake(0, 0, alphaMask.size.width, alphaMask.size.height)] fill];
    CGContextClipToMask(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, alphaMask.size.width, alphaMask.size.height), [self flipMaskVertically:alphaMask].CGImage);
    [[UIColor whiteColor] setFill];
    [[UIBezierPath bezierPathWithRect:CGRectMake(0, 0, alphaMask.size.width, alphaMask.size.height)] fill];
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}

- (UIImage *)image:(UIImage *)image resizedToMaxDimension:(CGFloat)maxDim {
    CGFloat scale = MIN(maxDim / image.size.width, maxDim / image.size.height);
    if (scale > 1) {
        return image;
    } else {
        return [self image:image resizedToSize:CGSizeMake(image.size.width * scale, image.size.height * scale)];
    }
}

- (UIImage *)image:(UIImage *)image resizedToSize:(CGSize)size {
    UIGraphicsBeginImageContextWithOptions(size, NO, 1);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}

- (UIImage *)dilateMask:(UIImage *)mask {
    GPUImageDilationFilter *filter = [[GPUImageDilationFilter alloc] initWithRadius:3];
    return [filter imageByFilteringImage:mask];
}

- (UIImage *)inpaintedBackground {
    CGFloat size = 300;
    UIImage *resizedBg = [self image:self.inputImage resizedToMaxDimension:size];
    UIImage *resizedMask = [self createBlackWhiteMaskFromAlphaMask:[self image:self.mask resizedToSize:resizedBg.size]];
    resizedMask = [self dilateMask:resizedMask];
    UIImage *inpainted = [resizedBg inpaintWithMask:resizedMask];
    return [self image:inpainted maskedWith:resizedBg];
}

@end
