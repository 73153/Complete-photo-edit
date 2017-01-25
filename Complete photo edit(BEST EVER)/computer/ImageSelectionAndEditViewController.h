//
//  ImageSelectionAndEditViewController.h
//  computer
//
//  Created by Nate Parrott on 5/14/16.
//  Copyright © 2016 Nate Parrott. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ImageEditAction;

typedef NS_ENUM(NSInteger, ImageSelectionEditAction) {
    ImageSelectionEditActionDeleteBackground,
    ImageSelectionEditActionSplitFromBackground,
    ImageSelectionEditActionSplitFromBackgroundAndInpaint,
    ImageSelectionEditActionInpaint
};

@interface ImageSelectionAndEditViewController : UIViewController

@property (nonatomic) ImageSelectionEditAction editAction;
@property (nonatomic) UIImage *image;
@property (nonatomic,copy) void (^onFinish)(ImageEditAction *finishedAction);

@end

typedef void (^ImageSelectionGotMaskCallback)(UIImage *image);

@protocol ImageSelectionTabViewController <NSObject>

- (NSString *)iconName;
- (void)setImage:(UIImage *)image;
@property (nonatomic) ImageSelectionGotMaskCallback onGotMask;

@end
