//
//  DrawSelectionView.m
//  computer
//
//  Created by Nate Parrott on 5/13/16.
//  Copyright © 2016 Nate Parrott. All rights reserved.
//

#import "DrawSelectionView.h"

@interface DrawSelectionView () {
    BOOL _setupYet;
    
    CGPoint _initialTouchPoint;
    CGPoint _prevTouchPoint;
    CGPoint _currentTouchPoint;
    UIBezierPath *_touchPath;
    
    UIButton *_undoButton, *_additiveButton, *_subtractiveButton;
}

@property (nonatomic) UIImageView *imageView;
@property (nonatomic) BOOL drawInProgress;
@property (nonatomic) NSMutableArray *previousMasks;

@end

@implementation DrawSelectionView

#pragma mark Lifecycle

- (void)willMoveToWindow:(UIWindow *)newWindow {
    [super willMoveToWindow:newWindow];
    [self _setup];
}

- (void)_setup {
    if (_setupYet) return;
    // UIPanGestureRecognizer *panRec = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panned:)];
    // [self addGestureRecognizer:panRec];

    self.imageView = [UIImageView new];
    [self addSubview:self.imageView];
    self.brushWidth = self.brushWidth ? : 30;
    
    _additiveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _subtractiveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    for (UIButton *b in @[_additiveButton, _subtractiveButton]) {
        [self addSubview:b];
    }
    [_additiveButton addTarget:self action:@selector(_setAdditive) forControlEvents:UIControlEventTouchUpInside];
    [_subtractiveButton addTarget:self action:@selector(_setSubtractive) forControlEvents:UIControlEventTouchUpInside];
    _undoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_undoButton addTarget:self action:@selector(_undo) forControlEvents:UIControlEventTouchUpInside];
    [_undoButton setImage:[UIImage imageNamed:@"SelectionUndo"] forState:UIControlStateNormal];
    [self addSubview:_undoButton];
    [self setSubtractive:_subtractive];
    
    if (!self.mask) self.mask = [UIImage new];
    
    _setupYet = YES;
}

#pragma mark Data

- (void)setMask:(UIImage *)mask {
    _mask = mask;
    [self redraw];
    if (self.onStatusChanged) self.onStatusChanged();
}

- (void)clearMask {
    [self.previousMasks removeAllObjects];
    [self setMask:nil];
}

- (void)pushNewMask:(UIImage *)image {
    if (!_previousMasks) _previousMasks = [NSMutableArray new];
    if (_mask) [_previousMasks addObject:_mask];
    while (_previousMasks.count > 10) {
        [_previousMasks removeObjectAtIndex:0];
    }
    self.mask = image;
}

- (void)setSubtractive:(BOOL)subtractive {
    _subtractive = subtractive;
    [_additiveButton setImage:[UIImage imageNamed:subtractive ? @"SelectionAdd" : @"SelectionAddHighlighted"] forState:UIControlStateNormal];
    [_subtractiveButton setImage:[UIImage imageNamed:subtractive ? @"SelectionSubtractHighlighted" : @"SelectionSubtract"] forState:UIControlStateNormal];
}

- (BOOL)hasSelection {
    return self.mask && self.mask.size.width;
}

#pragma mark Interaction

/*- (void)panned:(UIPanGestureRecognizer *)panRec {
    CGPoint p = [panRec locationInView:self.imageView];
    if (panRec.state == UIGestureRecognizerStateBegan) {
        [self beginDrawSessionAtPoint:p];
    } else if (panRec.state == UIGestureRecognizerStateChanged) {
        [self continueDrawSessionWithNewPoint:p];
    } else if (panRec.state == UIGestureRecognizerStateEnded) {
        [self commitDrawSession];
    } else {
        self.drawInProgress = NO;
        [self redraw];
    }
}*/

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self beginDrawSessionAtPoint:[touches.anyObject locationInView:self.imageView]];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self continueDrawSessionWithNewPoint:[touches.anyObject locationInView:self.imageView]];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self commitDrawSession];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self cancelDrawSession];
}

- (void)beginDrawSessionAtPoint:(CGPoint)p {
    self.drawInProgress = YES;
    _prevTouchPoint = p;
    _initialTouchPoint = p;
    _currentTouchPoint = p;
    _touchPath = [UIBezierPath bezierPath];
    [_touchPath moveToPoint:p];
    [_touchPath addLineToPoint:p];
    [self redraw];
}

- (void)continueDrawSessionWithNewPoint:(CGPoint)p {
    _currentTouchPoint = p;
    [_touchPath addLineToPoint:p];
    [self redraw];
    _prevTouchPoint = p;
}

- (void)commitDrawSession {
    UIImage *newMask = [self drawFullImage];
    self.drawInProgress = NO;
    _touchPath = nil;
    [self pushNewMask:newMask];
}

- (void)cancelDrawSession {
    self.drawInProgress = NO;
    _touchPath = nil;
    [self redraw];
}

#pragma mark Buttons

- (void)_undo {
    UIImage *image = [self.previousMasks lastObject];
    if (image) {
        [self.previousMasks removeLastObject];
        self.mask = image;
    }
}

- (void)_setAdditive {
    self.subtractive = NO;
}

- (void)_setSubtractive {
    self.subtractive = YES;
}

#pragma mark Drawing

- (void)redraw {
    self.imageView.image = [self drawFullImage];
}

- (UIImage *)drawFullImage {
    CGSize size = self.imageView.bounds.size;
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    
    if (self.disableAntialiasing) CGContextSetShouldAntialias(UIGraphicsGetCurrentContext(), NO);
    
    [self.mask drawInRect:CGRectMake(0, 0, size.width, size.height)];
    if (self.drawInProgress) {
        UIColor *color = self.subtractive && self.subtractiveStrokeColor ? self.subtractiveStrokeColor : (self.additiveStrokeColor ? : self.tintColor);
        [color setFill];
        [color setStroke];
        CGBlendMode mode = self.subtractive && !self.subtractiveStrokeColor ? kCGBlendModeClear : kCGBlendModeNormal;
        
        if (self.mode == DrawSelectionModeRectangular || self.mode == DrawSelectionModeElliptical) {
            CGRect rect = CGRectMake(_initialTouchPoint.x, _initialTouchPoint.y, _currentTouchPoint.x - _initialTouchPoint.x, _currentTouchPoint.y - _initialTouchPoint.y);
            if (self.mode == DrawSelectionModeRectangular) {
                [[UIBezierPath bezierPathWithRect:rect] fillWithBlendMode:mode alpha:1];
            } else {
                [[UIBezierPath bezierPathWithOvalInRect:rect] fillWithBlendMode:mode alpha:1];
            }
        } else if (self.mode == DrawSelectionModeDrawOutline) {
            [_touchPath fillWithBlendMode:mode alpha:1];
        } else if (self.mode == DrawSelectionModeDrawBrush) {
            _touchPath.lineWidth = self.brushWidth;
            _touchPath.lineCapStyle = kCGLineCapRound;
            _touchPath.lineJoinStyle = kCGLineJoinRound;
            [_touchPath strokeWithBlendMode:mode alpha:1];
        }
    }
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}

#pragma mark Layout

- (void)setAspectRatio:(CGFloat)aspectRatio {
    _aspectRatio = aspectRatio;
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize fullContentSize = CGSizeMake(self.aspectRatio, 1);
    CGFloat scale = MIN(self.bounds.size.width / fullContentSize.width, self.bounds.size.height / fullContentSize.height);
    CGSize contentSize = CGSizeMake(fullContentSize.width * scale, fullContentSize.height * scale);
    CGRect contentFrame = CGRectMake((self.bounds.size.width - contentSize.width)/2, (self.bounds.size.height - contentSize.height)/2, contentSize.width, contentSize.height);
    
    self.imageView.frame = contentFrame;
    
    CGFloat padding = 10;
    NSArray *leftButtons = @[_additiveButton, _subtractiveButton];
    NSArray *rightButtons = @[_undoButton];
    CGFloat x = padding;
    CGFloat y = padding;
    for (UIButton *b in leftButtons) {
        [b sizeToFit];
        b.frame = CGRectMake(x, y, b.frame.size.width, b.frame.size.height);
        x += b.frame.size.width + padding;
    }
    
    x = self.bounds.size.width - padding;
    for (UIButton *b in rightButtons) {
        [b sizeToFit];
        b.frame = CGRectMake(x - b.frame.size.width, y, b.frame.size.width, b.frame.size.height);
        x -= b.frame.size.width + padding;
    }
}

#pragma mark Extras

- (void)setHideUndoButton:(BOOL)hideUndoButton {
    _hideUndoButton = hideUndoButton;
    [self _setup];
    _undoButton.hidden = hideUndoButton;
}

- (void)setHideSubtractiveOption:(BOOL)hideSubtractiveOption {
    _hideSubtractiveOption = hideSubtractiveOption;
    _subtractiveButton.hidden = _additiveButton.hidden = hideSubtractiveOption;
}

@end
