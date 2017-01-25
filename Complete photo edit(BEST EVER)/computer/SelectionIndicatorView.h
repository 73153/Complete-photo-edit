//
//  SelectionIndicatorView.h
//  computer
//
//  Created by Nate Parrott on 12/5/15.
//  Copyright © 2015 Nate Parrott. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CMDrawable;

@protocol SelectionIndicatorViewDelegate

- (void)resizeHandleWasPanned:(UIPanGestureRecognizer *)gestureRec drawable:(CMDrawable *)drawable;

@end

@interface SelectionIndicatorView : UIView

@property (nonatomic) BOOL showResizeHandle;
@property (nonatomic) CMDrawable *representsDrawable;
@property (nonatomic,weak) id<SelectionIndicatorViewDelegate> delegate;

@end
