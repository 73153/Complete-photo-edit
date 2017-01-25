//
//  CMPixelArtDrawable.m
//  computer
//
//  Created by Nate Parrott on 3/9/16.
//  Copyright © 2016 Nate Parrott. All rights reserved.
//

#import "CMPixelArtDrawable.h"
#import "computer-Swift.h"

@interface _CMPixelArtDrawableView : CMDrawableView

@property (nonatomic) NSDictionary *rows;
@property (nonatomic) NSArray *colors;
@property (nonatomic) CGRect extentsRect;

@end

@implementation _CMPixelArtDrawableView

- (void)setRows:(NSDictionary *)rows {
    if (![_rows isEqualToDictionary:rows]) {
        _rows = rows;
        [self setNeedsDisplay];
    }
}

- (void)setColors:(NSArray *)colors {
    if (![_colors isEqualToArray:colors]) {
        _colors = colors;
        [self setNeedsDisplay];
    }
}

- (void)setExtentsRect:(CGRect)extentsRect {
    if (!CGRectEqualToRect(_extentsRect, extentsRect)) {
        _extentsRect = extentsRect;
        [self setNeedsDisplay];
    }
}

- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGSize pixelSize = CGSizeMake(self.bounds.size.width / (self.extentsRect.size.width + 1), self.bounds.size.height / (self.extentsRect.size.height + 1));
    for (NSNumber *y in _rows) {
        NSDictionary *row = _rows[y];
        for (NSNumber *x in row) {
            UIColor *color = _colors[[row[x] integerValue]];
            CGContextSetFillColorWithColor(ctx, color.CGColor);
            CGContextFillRect(ctx, CGRectMake((x.integerValue - _extentsRect.origin.x) * pixelSize.width, (y.integerValue - _extentsRect.origin.y) * pixelSize.height, pixelSize.width + 1, pixelSize.height + 1));
        }
    }
}

@end





@implementation CMPixelArtDrawable

- (NSArray<NSString*>*)keysForCoding {
    return [[super keysForCoding] arrayByAddingObjectsFromArray:@[@"drawing"]];
}

- (__kindof CMDrawableView *)renderToView:(__kindof CMDrawableView *)existingOrNil context:(CMRenderContext *)ctx {
    _CMPixelArtDrawableView *v = [existingOrNil isKindOfClass:[_CMPixelArtDrawableView class]] ? (id)existingOrNil : [_CMPixelArtDrawableView new];
    [super renderToView:v context:ctx];
    v.opaque = NO;
    v.extentsRect = [self.drawing extentsRect];
    v.rows = self.drawing.rows;
    v.colors = self.drawing.colors;
    v.contentScaleFactor = [UIScreen mainScreen].scale * 4;
    return v;
}

- (CGFloat)aspectRatio {
    CGRect r = [self.drawing extentsRect];
    if (r.size.width > 0 && r.size.height > 0) {
        return r.size.width / r.size.height;
    } else {
        return 1;
    }
}

- (BOOL)performDefaultEditActionWithEditor:(EditorViewController *)editor {
    PixelEditorViewController *editorVC = [[UIStoryboard storyboardWithName:@"PixelEditor" bundle:nil] instantiateInitialViewController];
    [editorVC loadViewIfNeeded];
    if (self.drawing) {
        editorVC.editor.drawing = self.drawing;
    }
    __weak CMPixelArtDrawable *weakSelf = self;
    [editorVC setCallback:^(PixelDrawing *drawing) {
        PixelDrawing *oldDrawing = weakSelf.drawing;
        [editor.canvas.transactionStack doTransaction:[[CMTransaction alloc] initWithTarget:nil action:^(id target) {
            weakSelf.drawing = drawing;
        } undo:^(id target) {
            weakSelf.drawing = oldDrawing;
        }]];
    }];
    [editor presentViewController:editorVC animated:YES completion:nil];
    return YES;
}

@end
