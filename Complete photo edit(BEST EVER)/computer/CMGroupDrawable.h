//
//  CMGroupDrawable.h
//  computer
//
//  Created by Nate Parrott on 12/16/15.
//  Copyright © 2015 Nate Parrott. All rights reserved.
//

#import "CMCanvas.h"

@interface CMGroupDrawable : CMCanvas

- (void)editGroupWithEditor:(EditorViewController *)editor;
- (void)editGroupWithEditor:(EditorViewController *)editor callback:(void(^)())callback;

@end
