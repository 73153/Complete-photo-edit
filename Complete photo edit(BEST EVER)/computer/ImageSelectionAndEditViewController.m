//
//  ImageSelectionAndEditViewController.m
//  computer
//
//  Created by Nate Parrott on 5/14/16.
//  Copyright © 2016 Nate Parrott. All rights reserved.
//

#import "ImageSelectionAndEditViewController.h"
#import "DrawSelectionViewController.h"
#import "ConvenienceCategories.h"
#import "ImageEditActionPreviewViewController.h"
#import "UIImage+Trim.h"
#import "GrabcutSelectionViewController.h"

@interface ImageSelectionAndEditViewController ()

@property (nonatomic) NSArray<UIViewController<ImageSelectionTabViewController> *> *tabs;
@property (nonatomic) UIViewController<ImageSelectionTabViewController> *selectedTab;
@property (nonatomic) NSArray<UIButton *> *tabButtons;
@property (nonatomic) UINavigationController *navVC;

@end

@implementation ImageSelectionAndEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navVC = [UINavigationController new];
    [self addChildViewController:self.navVC];
    [self.view addSubview:self.navVC.view];
    self.view.backgroundColor = [UIColor colorWithWhite:0.99 alpha:1];
    
    DrawSelectionViewController *rect = [DrawSelectionViewController new];
    rect.mode = DrawSelectionModeRectangular;
    DrawSelectionViewController *ellipse = [DrawSelectionViewController new];
    ellipse.mode = DrawSelectionModeElliptical;
    GrabcutSelectionViewController *grabcut = [GrabcutSelectionViewController new];
    DrawSelectionViewController *outline = [DrawSelectionViewController new];
    outline.mode = DrawSelectionModeDrawOutline;
    DrawSelectionViewController *brush = [DrawSelectionViewController new];
    brush.mode = DrawSelectionModeDrawBrush;
    self.tabs = @[rect, ellipse, grabcut, outline, brush];
    self.selectedTab = grabcut;
}

- (void)setTabs:(NSArray<UIViewController<ImageSelectionTabViewController> *> *)tabs {
    _tabs = tabs;
    self.tabButtons = [tabs map:^id(id obj) {
        UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
        NSString *iconName = [obj iconName];
        NSString *onIconName = [iconName stringByAppendingString:@"-On"];
        [b setImage:[UIImage imageNamed:iconName] forState:UIControlStateNormal];
        [b setImage:[UIImage imageNamed:onIconName] forState:UIControlStateSelected];
        [b addTarget:self action:@selector(selectTab:) forControlEvents:UIControlEventTouchUpInside];
        return b;
    }];
}

- (void)selectTab:(UIButton *)tabButton {
    self.selectedTab = self.tabs[[self.tabButtons indexOfObject:tabButton]];
}

- (void)setTabButtons:(NSArray<UIButton *> *)tabButtons {
    for (UIButton *b in _tabButtons) [b removeFromSuperview];
    _tabButtons = tabButtons;
    for (UIButton *b in tabButtons) [self.view addSubview:b];
}

- (void)setSelectedTab:(UIViewController<ImageSelectionTabViewController> *)selectedTab {
    
    _selectedTab = selectedTab;
    [self.selectedTab setImage:self.image];
    [self.navVC setViewControllers:@[selectedTab]];
    
    for (NSInteger i=0; i<self.tabs.count; i++) {
        self.tabButtons[i].selected = (self.tabs[i] == selectedTab);
    }
    
    self.selectedTab.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
    self.navVC.navigationItem.title = selectedTab.title;
    
    __weak ImageSelectionAndEditViewController *weakSelf = self;
    selectedTab.onGotMask = ^(UIImage *mask){
        [weakSelf gotMask:mask];
    };
}

- (void)gotMask:(UIImage *)mask {
    ImageEditAction *edit = [ImageEditAction new];
    edit.inputImage = self.image;
    edit.mask = mask;
    edit.mode = self.editAction;
    ImageEditActionPreviewViewController *preview = [ImageEditActionPreviewViewController new];
    preview.edit = edit;
    __weak ImageSelectionAndEditViewController *weakSelf = self;
    preview.onDone = ^(ImageEditAction *action){
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
        weakSelf.onFinish(action);
    };
    [self.navVC pushViewController:preview animated:YES];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGFloat tabBarHeight = 44;
    if (self.tabs.count > 0) {
        CGFloat tabWidth = self.view.bounds.size.width / self.tabs.count;
        for (NSInteger i=0; i<self.tabButtons.count; i++) {
            self.tabButtons[i].frame = CGRectMake(tabWidth * i, self.view.bounds.size.height-tabBarHeight, tabWidth, tabBarHeight);
        }
    }
    self.navVC.view.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - tabBarHeight);
}

- (void)cancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
