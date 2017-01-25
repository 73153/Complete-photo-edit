//
//  GrabcutSelectionViewController.m
//  computer
//
//  Created by Nate Parrott on 5/19/16.
//  Copyright © 2016 Nate Parrott. All rights reserved.
//

#import "GrabcutSelectionViewController.h"
#import "Grabcut.h"
#import "DrawSelectionView.h"
#import "UIImage+Trim.h"
#import "GrabcutSelectionViewControllerStage2.h"

@interface GrabcutSelectionViewController ()

@property (nonatomic) UIImage *image;
@property (nonatomic) DrawSelectionView *rectDrawView;
@property (nonatomic) UIImageView *imageView;

@end

@implementation GrabcutSelectionViewController

- (NSString *)iconName {
    return @"GrabcutSelectTool";
}

#pragma mark Views
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Quick Select", @"");
    self.navigationItem.prompt = NSLocalizedString(@"Draw a box around the object", @"");
    
    self.imageView = [[UIImageView alloc] initWithImage:self.image];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.imageView];
    
    self.rectDrawView = [DrawSelectionView new];
    self.rectDrawView.aspectRatio = self.image.size.width / self.image.size.height;
    self.rectDrawView.alpha = 0.5;
    [self.view addSubview:self.rectDrawView];
    self.rectDrawView.mode = DrawSelectionModeRectangular;
    __weak GrabcutSelectionViewController *weakSelf = self;
    self.rectDrawView.onStatusChanged = ^{
        [weakSelf nextStage];
    };
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.rectDrawView clearMask];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGRect f = CGRectMake(0, [[self topLayoutGuide] length], self.view.bounds.size.width, self.view.bounds.size.height - [[self topLayoutGuide] length]);
    self.rectDrawView.frame = f;
    self.imageView.frame = f;
}

- (void)nextStage {
    if (self.rectDrawView.hasSelection) {
        CGRect cropRect = UIEdgeInsetsInsetRect(CGRectMake(0, 0, self.image.size.width, self.image.size.height), [self.rectDrawView.mask transparencyInsetsRequiringFullOpacity:NO]);
        if (cropRect.size.width * cropRect.size.height > 0) {
            GrabcutSelectionViewControllerStage2 *s2 = [GrabcutSelectionViewControllerStage2 new];
            s2.image = self.image;
            s2.cropRect = cropRect;
            __weak GrabcutSelectionViewController *weakSelf = self;
            s2.onDone = ^(UIImage *mask) {
                weakSelf.onGotMask(mask);
            };
            [self.navigationController pushViewController:s2 animated:YES];
        }
    }
}

@end
