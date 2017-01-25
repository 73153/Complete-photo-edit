//
//  CMFilterWrapper.h
//  computer
//
//  Created by Nate Parrott on 2/23/16.
//  Copyright © 2016 Nate Parrott. All rights reserved.
//

#import "CMDrawable.h"
@class FilterPickerFilterInfo;

@interface CMFilterWrapper : CMDrawableView

@property (nonatomic) FilterPickerFilterInfo *filter;
@property (nonatomic) CMDrawableView *child;

@end
