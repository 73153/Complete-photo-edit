//
//  GrabcutSelectionViewControllerStage2.h
//  computer
//
//  Created by Nate Parrott on 5/19/16.
//  Copyright © 2016 Nate Parrott. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GrabcutSelectionViewControllerStage2 : UIViewController

@property (nonatomic) UIImage *image;
@property (nonatomic) CGRect cropRect;
@property (nonatomic,copy) void (^onDone)(UIImage *mask);

@end
