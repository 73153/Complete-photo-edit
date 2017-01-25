//
//  DrawSelectionView.h
//  computer
//
//  Created by Nate Parrott on 5/13/16.
//  Copyright © 2016 Nate Parrott. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, DrawSelectionMode) {
    DrawSelectionModeDrawBrush,
    DrawSelectionModeDrawOutline,
    DrawSelectionModeElliptical,
    DrawSelectionModeRectangular
};

@interface DrawSelectionView : UIView

@property (nonatomic) UIImage *mask;
@property (nonatomic) DrawSelectionMode mode;
@property (nonatomic) CGFloat brushWidth;
@property (nonatomic) BOOL subtractive;
@property (nonatomic) CGFloat aspectRatio;
- (BOOL)hasSelection;
@property (nonatomic,copy) void (^onStatusChanged)();

@property (nonatomic) UIColor *subtractiveStrokeColor, *additiveStrokeColor;
@property (nonatomic) BOOL hideUndoButton;
@property (nonatomic) BOOL hideSubtractiveOption;
@property (nonatomic) BOOL disableAntialiasing;

- (void)clearMask;

@end
