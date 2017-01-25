//
//  DrawSelectionViewController.h
//  computer
//
//  Created by Nate Parrott on 5/13/16.
//  Copyright © 2016 Nate Parrott. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DrawSelectionView.h"
#import "ImageSelectionAndEditViewController.h"

@interface DrawSelectionViewController : UIViewController <ImageSelectionTabViewController>

@property (nonatomic) DrawSelectionMode mode;
@property (nonatomic) UIImage *image;
@property (nonatomic) ImageSelectionGotMaskCallback onGotMask;

@end
