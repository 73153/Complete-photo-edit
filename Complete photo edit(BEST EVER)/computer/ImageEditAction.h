//
//  ImageEditAction.h
//  computer
//
//  Created by Nate Parrott on 5/15/16.
//  Copyright © 2016 Nate Parrott. All rights reserved.
//

@import UIKit;
#import "ImageSelectionAndEditViewController.h"

@interface ImageEditAction : NSObject

@property (nonatomic) UIImage *inputImage, *mask;
@property (nonatomic) ImageSelectionEditAction mode;

- (void)run;
@property (nonatomic) UIImage *output1, *output2;

@end
