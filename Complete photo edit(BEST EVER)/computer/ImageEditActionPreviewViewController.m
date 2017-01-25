//
//  ImageEditActionPreviewViewController.m
//  computer
//
//  Created by Nate Parrott on 5/15/16.
//  Copyright © 2016 Nate Parrott. All rights reserved.
//

#import "ImageEditActionPreviewViewController.h"

@interface ImageEditActionPreviewViewController ()

@property (nonatomic) UIActivityIndicatorView *loader;
@property (nonatomic) UIImageView *output1, *output2;

@end

@implementation ImageEditActionPreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.output1 = [UIImageView new];
    [self.view addSubview:self.output1];
    self.output1.contentMode = UIViewContentModeScaleAspectFit;
    
    self.output2 = [UIImageView new];
    [self.view addSubview:self.output2];
    self.output2.contentMode = UIViewContentModeScaleAspectFit;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.loader = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.view addSubview:self.loader];
    
    [self.loader startAnimating];
    
    __weak ImageEditActionPreviewViewController *weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.edit run];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf doneProcessing];
        });
    });
    
    self.output2.transform = CGAffineTransformTranslate(CGAffineTransformMakeScale(0.7, 0.7), 0, -7);
    [UIView animateWithDuration:0.33 delay:0 options:UIViewAnimationOptionAutoreverse | UIViewAnimationCurveEaseOut | UIViewAnimationOptionRepeat | UIViewAnimationOptionAllowUserInteraction animations:^{
        self.output2.transform = CGAffineTransformTranslate(CGAffineTransformMakeScale(0.7, 0.7), 0, 7);
        self.output2.alpha = 0.6;
    } completion:nil];
}

- (void)doneProcessing {
    self.loader.hidden = YES;
    self.output1.image = self.edit.output1;
    self.output2.image = self.edit.output2;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGRect contentFrame = CGRectMake(0, [[self topLayoutGuide] length], self.view.bounds.size.width, self.view.bounds.size.height - [[self topLayoutGuide] length]);
    
    self.output1.bounds = CGRectMake(0, 0, contentFrame.size.width, contentFrame.size.height);
    self.output1.center = CGPointMake(contentFrame.origin.x + contentFrame.size.width/2, contentFrame.origin.y + contentFrame.size.height/2);
    
    self.output2.bounds = self.output1.bounds;
    self.output2.center = self.output1.center;
    
    self.loader.center = self.output1.center;
}

- (void)done {
    self.onDone(self.edit);
}

@end
