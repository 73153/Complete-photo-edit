//
//  ImageEditActionPreviewViewController.h
//  computer
//
//  Created by Nate Parrott on 5/15/16.
//  Copyright © 2016 Nate Parrott. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageEditAction.h"

@interface ImageEditActionPreviewViewController : UIViewController

@property (nonatomic) ImageEditAction *edit;
@property (nonatomic,copy) void (^onDone)(ImageEditAction *edit);

@end
