//
//  CanvasViewerLite.h
//  computer
//
//  Created by Nate Parrott on 12/3/15.
//  Copyright © 2015 Nate Parrott. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CMCanvas, FrameTime, CanvasCoordinateSpace;

@interface CanvasViewerLite : UIView

@property (nonatomic) CMCanvas *canvas;
@property (nonatomic) FrameTime *time;
@property (nonatomic) CanvasCoordinateSpace *coordinateSpace; // can be nil
@property (nonatomic) BOOL resizeToFitContent;

@end
