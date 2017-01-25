//
//  CMPhotoDrawable.m
//  computer
//
//  Created by Nate Parrott on 12/1/15.
//  Copyright © 2015 Nate Parrott. All rights reserved.
//

#import "CMPhotoDrawable.h"
#import "CMTransaction.h"
#import "FilterPickerViewController.h"
#import "computer-Swift.h"
#import "PropertyViewTableCell.h"
#import "EditorViewController.h"
#import "ImageSelectionAndEditViewController.h"
#import "ImageEditAction.h"

@interface CMPhotoDrawableView : CMDrawableView {
    UIImageView *_imageView;
}

@property (nonatomic) UIImage *image;

@end

@implementation CMPhotoDrawableView

- (void)setImage:(UIImage *)image {
    if (!_imageView) {
        _imageView = [UIImageView new];
        [self addSubview:_imageView];
    }
    _imageView.image = image;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _imageView.frame = self.bounds;
}

- (UIImage *)image {
    return _imageView.image;
}

@end


@interface CMPhotoDrawable ()

@property (nonatomic) NSData *photoData;

@end

@implementation CMPhotoDrawable

- (instancetype)init {
    self = [super init];
    self.image = nil;
    self.aspectRatio = 1;
    return self;
}

- (CGFloat)aspectRatio {
    return _aspectRatio;
}

- (CMDrawableView *)renderToView:(CMDrawableView *)existingOrNil context:(CMRenderContext *)ctx {
    CMPhotoDrawableView *v = [existingOrNil isKindOfClass:[CMPhotoDrawableView class]] ? (id)existingOrNil : [CMPhotoDrawableView new];
    [super renderToView:v context:ctx];
    v.image = self.image;
    return v;
}

- (void)setImage:(UIImage *)image withTransactionStack:(CMTransactionStack *)stack {
    CGFloat oldAspectRatio = self.aspectRatio;
    UIImage *oldImage = self.image;
    
    void (^set)(id) = ^(id target){
        [target setImage:image];
        [target setAspectRatio:image ? image.size.width / image.size.height : 1];
    };
    
    if (stack) {
        [stack doTransaction:[[CMTransaction alloc] initWithTarget:self action:^(id target) {
            set(target);
        } undo:^(id target) {
            [target setImage:oldImage];
            [target setAspectRatio:oldAspectRatio];
        }]];
    } else {
        set(self);
    }
}

- (NSArray<NSString*>*)keysForCoding {
    return [[super keysForCoding] arrayByAddingObjectsFromArray:@[@"photoData", @"aspectRatio"]];
}

- (NSArray<PropertyModel*>*)uniqueObjectPropertiesWithEditor:(CanvasEditor *)editor {
    NSArray *actionTitles = @[NSLocalizedString(@"Filter", @""), NSLocalizedString(@"Cut-out object", @""), NSLocalizedString(@"Separate object from background", @""),  NSLocalizedString(@"Erase object", @""), NSLocalizedString(@"Cut-out and erase object", @"")];
    NSArray *actionSelectors = @[@"filter:", @"cutOut:", @"separateObject:", @"eraseObject:", @"cutOutAndEraseObject:"];
    NSMutableArray *actions = [NSMutableArray new];
    for (NSInteger i=0; i<actionTitles.count; i++) {
        PropertyModel *action = [PropertyModel new];
        if (i == 0) action.title = NSLocalizedString(@"Actions", @"");
        if (i == 1) action.title = NSLocalizedString(@"Modify image", @"");
        action.type = PropertyModelTypeButtons;
        action.buttonTitles = @[actionTitles[i]];
        action.buttonSelectorNames = @[actionSelectors[i]];
        [actions addObject:action];
    }
    
    
    return [[super uniqueObjectPropertiesWithEditor:editor] arrayByAddingObjectsFromArray:actions];
}

- (void)filter:(PropertyViewTableCell *)sender {
    FilterPickerViewController *picker = [FilterPickerViewController filterPickerWithImage:self.image callback:^(UIImage *filtered) {
        if (filtered) {
            [self setImage:filtered withTransactionStack:sender.transactionStack];
        }
    }];
    picker.snapshotsForImagePicker = [sender.editor.canvas snapshotsOfAllDrawables];
    [[NPSoftModalPresentationController getViewControllerForPresentationInWindow:[UIApplication sharedApplication].windows.firstObject] presentViewController:picker animated:YES completion:nil];
}

- (NSString *)drawableTypeDisplayName {
    return NSLocalizedString(@"Image", @"");
}

- (NSData *)photoData {
    return self.image ? UIImagePNGRepresentation(self.image) : nil;
}

- (void)setPhotoData:(NSData *)photoData {
    self.image = [UIImage imageWithData:photoData];
}

- (void)promptToPickPhotoFromImageSearchWithTransactionStack:(CMTransactionStack *)transactionStack {
    ImageSearchViewController *vc = [ImageSearchViewController new];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    __weak UINavigationController *weakNav = nav;
    __weak CMPhotoDrawable *weakSelf = self;
    vc.onImagePicked = ^(UIImage *image) {
        if (image) {
            image = [image resizedWithMaxDimension:[CMPhotoDrawable maxImageSize]];
            [weakSelf setImage:image withTransactionStack:transactionStack];
        }
        [weakNav dismissViewControllerAnimated:YES completion:nil];
    };
    [[NPSoftModalPresentationController getViewControllerForPresentation] presentViewController:nav animated:YES completion:nil];
}

+ (CGFloat)maxImageSize {
    return 1200;
}

#pragma mark Object selection editing
- (void)cutOut:(PropertyViewTableCell *)sender {
    [self beginSelectionEditAction:ImageSelectionEditActionDeleteBackground editor:sender.editor];
    /*StickerExtractViewController *extractVC = (id)[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"StickerExtractVC"];
    extractVC.onExtractedSticker = ^(UIImage *sticker) {
        if (sticker) {
            [self setImage:sticker withTransactionStack:sender.transactionStack];
        }
    };
    extractVC.imageToExtractFrom = self.image;
    [[NPSoftModalPresentationController getViewControllerForPresentationInWindow:[UIApplication sharedApplication].windows.firstObject] presentViewController:extractVC animated:YES completion:nil];*/
}

- (void)separateObject:(PropertyViewTableCell *)sender {
    [self beginSelectionEditAction:ImageSelectionEditActionSplitFromBackground editor:sender.editor];
}

- (void)eraseObject:(PropertyViewTableCell *)sender {
    [self beginSelectionEditAction:ImageSelectionEditActionInpaint editor:sender.editor];
}

- (void)cutOutAndEraseObject:(PropertyViewTableCell *)sender {
    [self beginSelectionEditAction:ImageSelectionEditActionSplitFromBackgroundAndInpaint editor:sender.editor];
}

- (void)beginSelectionEditAction:(ImageSelectionEditAction)action editor:(EditorViewController *)editor {
    ImageSelectionAndEditViewController *vc = [ImageSelectionAndEditViewController new];
    vc.editAction = action;
    vc.image = self.image;
    __weak CMPhotoDrawable *weakSelf = self;
    __weak EditorViewController *weakEditor = editor;
    UIImage *oldImage = self.image;
    vc.onFinish = ^(ImageEditAction *edit) {
        CMPhotoDrawable *extract = nil;
        if (edit.output2) {
            extract = [CMPhotoDrawable new];
            [extract setImage:edit.output2 withTransactionStack:nil];
            extract.boundsDiagonal = weakSelf.boundsDiagonal * 0.7;
        }
        [editor.canvas.transactionStack doTransaction:[[CMTransaction alloc] initWithTarget:nil action:^(id target) {
            if (extract) {
                [weakEditor.canvas insertDrawableAtCurrentTime:extract];
            }
            [weakSelf setImage:edit.output1 withTransactionStack:nil];
        } undo:^(id target) {
            [weakSelf setImage:oldImage withTransactionStack:nil];
            [weakEditor.canvas deleteDrawable:extract];
        }]];
    };
    [[NPSoftModalPresentationController getViewControllerForPresentation] presentViewController:vc animated:YES completion:nil];
}

@end
