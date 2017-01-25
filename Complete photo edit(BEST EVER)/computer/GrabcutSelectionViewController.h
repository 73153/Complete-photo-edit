//
//  GrabcutSelectionViewController.h
//  computer
//
//  Created by Nate Parrott on 5/19/16.
//  Copyright © 2016 Nate Parrott. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageSelectionAndEditViewController.h"

@interface GrabcutSelectionViewController : UIViewController <ImageSelectionTabViewController>

@property (nonatomic) ImageSelectionGotMaskCallback onGotMask;

@end
