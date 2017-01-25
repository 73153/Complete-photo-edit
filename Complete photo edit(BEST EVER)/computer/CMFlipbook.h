//
//  CMFlipbook.h
//  computer
//
//  Created by Nate Parrott on 2/23/16.
//  Copyright © 2016 Nate Parrott. All rights reserved.
//

#import "CMDrawable.h"

@interface CMFlipbook : CMDrawable

@property (nonatomic) NSArray<CMGroupDrawable *> *pages;
@property (nonatomic) NSTimeInterval frameTime;

@end
