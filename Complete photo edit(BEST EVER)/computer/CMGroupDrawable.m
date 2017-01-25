//
//  CMGroupDrawable.m
//  computer
//
//  Created by Nate Parrott on 12/16/15.
//  Copyright © 2015 Nate Parrott. All rights reserved.
//

#import "CMGroupDrawable.h"
#import "PropertyViewTableCell.h"
#import "EditorViewController.h"
#import "CMTransaction.h"
#import "CMPhotoDrawable.h"

@implementation CMGroupDrawable

- (NSString *)drawableTypeDisplayName {
    return NSLocalizedString(@"Group", @"A group object");
}

- (CGFloat)aspectRatio {
    CGRect contentBounds = [self contentBoundingBox];
    return contentBounds.size.width / contentBounds.size.height;
}

- (id<UICoordinateSpace>)childCoordinateSpace:(CMRenderContext *)ctx {
    CGRect contentBounds = [self contentBoundingBox];
    
    CanvasCoordinateSpace *space = [CanvasCoordinateSpace new];
    space.canvasView = ctx.canvasView;
    space.screenSpan = contentBounds.size;
    space.center = CGPointMake(CGRectGetMidX(contentBounds), CGRectGetMidY(contentBounds));
    
    return space;
}

- (NSArray<PropertyModel*>*)uniqueObjectPropertiesWithEditor:(CanvasEditor *)editor {
    PropertyModel *editGroup = [PropertyModel new];
    editGroup.buttonSelectorNames = @[@"editGroup:"];
    editGroup.buttonTitles = @[NSLocalizedString(@"Edit Group", nil)];
    editGroup.type = PropertyModelTypeButtons;
    PropertyModel *flatten = [PropertyModel new];
    flatten.buttonSelectorNames = @[@"flatten:", @"smoothBlendFlatten:"];
    flatten.buttonTitles = @[NSLocalizedString(@"Flatten", nil), NSLocalizedString(@"Flatten + blend", nil)];
    flatten.type = PropertyModelTypeButtons;
    return [@[editGroup, flatten] arrayByAddingObjectsFromArray:[super uniqueObjectPropertiesWithEditor:editor]];
}

- (void)editGroup:(PropertyViewTableCell *)cell {
    [self editGroupWithEditor:cell.editor];
}

- (void)editGroupWithEditor:(EditorViewController *)editor {
    [self editGroupWithEditor:editor callback:^{
        
    }];
}

- (void)editGroupWithEditor:(EditorViewController *)editor callback:(void(^)())callback {
    __weak CMGroupDrawable *weakSelf = self;
    EditorViewController *editorVC = [EditorViewController modalEditorForCanvas:self callback:^(CMCanvas *edited) {
        [weakSelf.contents removeAllObjects];
        [weakSelf.contents addObjectsFromArray:edited.contents];
        if (self.contents.count == 0) {
            [editor.canvas deleteDrawable:weakSelf];
        }
        if (callback) callback();
    }];
    editorVC.editPrompt = NSLocalizedString(@"Edit Group", @"");
    [editor presentViewController:editorVC animated:YES completion:nil];
}

- (BOOL)performDefaultEditActionWithEditor:(EditorViewController *)editor {
    [self editGroupWithEditor:editor];
    return YES;
}

- (void)flatten:(PropertyViewTableCell *)cell {
    [self renderSnapshot:^(UIImage *snapshot) {
        [self replaceSelfWithImage:snapshot editor:cell.editor];
    }];
}

- (void)smoothBlendFlatten:(PropertyViewTableCell *)cell {
    if (self.contents.count >= 2) {
        CMDrawable *topObject = self.contents.lastObject;
        NSArray *bottomObjects = [self.contents subarrayWithRange:NSMakeRange(0, self.contents.count-1)];
        self.viewDisplaySuppressionBlock = ^BOOL(CMDrawable *d) {
            return d != topObject;
        };
        [self renderSnapshot:^(UIImage *top) {
            self.viewDisplaySuppressionBlock = ^BOOL(CMDrawable *d) {
                return ![bottomObjects containsObject:d];
            };
            [self renderSnapshot:^(UIImage *bottom) {
                self.viewDisplaySuppressionBlock = nil;
                
                UIGraphicsBeginImageContextWithOptions(top.size, NO, top.scale);
                [bottom drawAtPoint:CGPointZero blendMode:kCGBlendModeNormal alpha:1];
                [top drawAtPoint:CGPointZero blendMode:kCGBlendModeNormal alpha:0.5];
                UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                [self replaceSelfWithImage:snapshot editor:cell.editor];
            }];
        }];
    }
}

- (void)renderSnapshot:(void(^)(UIImage *))callback {
    [self getRenderedView:^(CMDrawableView *rendered) {
        
        UIGraphicsBeginImageContextWithOptions(rendered.bounds.size, NO, 0);
        [rendered drawViewHierarchyInRect:rendered.bounds afterScreenUpdates:YES];
        UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        callback(snapshot);
    }];
}

- (void)replaceSelfWithImage:(UIImage *)snapshot editor:(EditorViewController *)editor {
    CMDrawableKeyframe *oldKeyframe = [self.keyframeStore interpolatedKeyframeAtTime:editor.canvas.time];
    
    CMPhotoDrawable *photo = [CMPhotoDrawable new];
    [photo setImage:snapshot withTransactionStack:nil];
    [photo.keyframeStore storeKeyframe:[oldKeyframe copy]];
    __weak EditorViewController *weakEditor = editor;
    
    [editor.canvas.transactionStack doTransaction:[[CMTransaction alloc] initWithTarget:nil action:^(id target) {
        NSMutableArray *contents = weakEditor.canvas.canvas.contents;
        NSInteger index = [contents indexOfObject:self];
        [contents replaceObjectAtIndex:index withObject:photo];
        [weakEditor.canvas setSelectedItems:[NSSet setWithObject:photo]];
    } undo:^(id target) {
        NSMutableArray *contents = weakEditor.canvas.canvas.contents;
        NSInteger index = [contents indexOfObject:photo];
        [contents replaceObjectAtIndex:index withObject:self];
    }]];
}

@end
