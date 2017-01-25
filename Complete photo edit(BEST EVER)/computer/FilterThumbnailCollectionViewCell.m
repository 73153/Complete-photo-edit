//
//  FilterThumbnailCollectionViewCell.m
//  computer
//
//  Created by Nate Parrott on 11/25/15.
//  Copyright © 2015 Nate Parrott. All rights reserved.
//

#import "FilterThumbnailCollectionViewCell.h"

@interface FilterThumbnailCollectionViewCell ()

@property (nonatomic) UIImageView *imageView;

@end

@implementation FilterThumbnailCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    self.imageView = [UIImageView new];
    [self.contentView addSubview:self.imageView];
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.clipsToBounds = YES;
    self.imageView.layer.cornerRadius = 3;
    self.title = [UILabel new];
    [self.contentView addSubview:self.title];
    self.title.textColor = [UIColor whiteColor];
    self.title.font = [UIFont systemFontOfSize:10];
    self.title.textAlignment = NSTextAlignmentCenter;
    self.title.text = @"Filter";
    self.title.alpha = 0.5;
    return self;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    self.title.alpha = selected ? 1 : 0.5;
}

- (void)setFilter:(GPUImageFilter *)filter {
    _customImage = nil;
    _filter = filter;
    [self process];
}

- (void)setInput:(UIImage *)input {
    _input = input;
    [self process];
}

- (void)process {
    if (self.customImage) {
        self.imageView.image = self.customImage;
    } else {
        self.imageView.image = nil;
        UIImage *pic = self.input;
        GPUImageOutput<GPUImageInput> *filter = self.filter;
        if (pic && filter) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                UIImage *result = [filter imageByFilteringImage:pic];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (pic == self.input && filter == self.filter) {
                        self.imageView.image = result;
                    }
                });
            });
        }
    }
}

- (void)setCustomImage:(UIImage *)customImage {
    _customImage = customImage;
    _filter = nil;
    [self process];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat s = self.bounds.size.width;
    self.title.frame = CGRectMake(0, 0, s, self.bounds.size.height-s);
    self.imageView.frame = CGRectMake(0, self.bounds.size.height-s, s, s);
}

@end

