//
//  CMFilterWrapper.m
//  computer
//
//  Created by Nate Parrott on 2/23/16.
//  Copyright © 2016 Nate Parrott. All rights reserved.
//

#import "CMFilterWrapper.h"
#import "FilterPickerFilterInfo.h"

@interface CMFilterWrapper () {
    UIImageView *_imageView;
}

@end

@implementation CMFilterWrapper

- (void)setChild:(CMDrawableView *)child {
    if (child == _child) return;
    _child = child;
    self.bounds = CGRectMake(0, 0, child.bounds.size.width, child.bounds.size.height);
    child.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    [self redraw];
}

- (void)setFilter:(FilterPickerFilterInfo *)filter {
    if (filter == _filter) return;
    _filter = filter;
    [self redraw];
}

- (void)redraw {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self addSubview:_imageView];
    }
    if (self.child) {
        UIImage *image = [self imageFromChild];
        if (self.filter) {
            image = [self.filter.createFilter imageByFilteringImage:image];
        }
        _imageView.image = image;
    }
}

- (UIImage *)imageFromChild {
    UIGraphicsBeginImageContext(self.child.bounds.size);
    [self.child drawViewHierarchyInRect:self.child.bounds afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
