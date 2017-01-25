//
//  DrawSelectionViewController.m
//  computer
//
//  Created by Nate Parrott on 5/13/16.
//  Copyright © 2016 Nate Parrott. All rights reserved.
//

#import "DrawSelectionViewController.h"

@interface DrawSelectionViewController ()

@property (nonatomic) DrawSelectionView *drawView;
@property (nonatomic) UIImageView *imageView;

@end

@implementation DrawSelectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.imageView = [[UIImageView alloc] initWithImage:self.image];
    [self.view addSubview:self.imageView];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    self.drawView = [DrawSelectionView new];
    self.drawView.alpha = 0.5;
    [self.view addSubview:self.drawView];
    self.view.backgroundColor = [UIColor whiteColor];
    self.drawView.mode = self.mode;
    self.drawView.aspectRatio = self.image.size.width / self.image.size.height;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Next", @"") style:UIBarButtonItemStyleDone target:self action:@selector(done:)];
    self.navigationItem.rightBarButtonItem.enabled = [self.drawView hasSelection];
    __weak DrawSelectionViewController *weakSelf = self;
    self.drawView.onStatusChanged = ^{
        weakSelf.navigationItem.rightBarButtonItem.enabled = [weakSelf.drawView hasSelection];
    };
}

- (void)done:(id)sender {
    self.onGotMask(self.drawView.mask);
}

- (void)setImage:(UIImage *)image {
    _image = image;
    self.imageView.image = image;
    self.drawView.aspectRatio = image.size.width / image.size.height;
}

- (void)setMode:(DrawSelectionMode)mode {
    _mode = mode;
    switch (self.mode) {
        case DrawSelectionModeDrawBrush: self.title = @"Scribble Select"; break;
        case DrawSelectionModeDrawOutline: self.title = @"Outline Select"; break;
        case DrawSelectionModeElliptical: self.title = @"Oval Select"; break;
        case DrawSelectionModeRectangular: self.title = @"Rectangular Select"; break;
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.imageView.frame = CGRectMake(0, [self.topLayoutGuide length], self.view.bounds.size.width, self.view.bounds.size.height - [self.topLayoutGuide length]);
    self.drawView.frame = self.imageView.frame;
}

- (NSString *)iconName {
    switch (self.mode) {
    case DrawSelectionModeDrawBrush: return @"BrushSelectTool";
    case DrawSelectionModeDrawOutline: return @"OutlineSelectTool";
    case DrawSelectionModeElliptical: return @"EllipseSelectTool";
    case DrawSelectionModeRectangular: return @"RectSelectTool";
    }
}

@end
