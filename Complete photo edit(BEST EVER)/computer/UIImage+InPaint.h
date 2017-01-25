//
//  UIImage+InPaint.h
//  computer
//
//  Created by Nate Parrott on 5/10/16.
//  Copyright © 2016 Nate Parrott. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (InPaint)

+ (void)_testInPainting;
- (UIImage *)inpaintWithMask:(UIImage *)maskUIImage;

@end
