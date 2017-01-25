//
//  CMDrawable.h
//  computer
//
//  Created by Nate Parrott on 11/29/15.
//  Copyright © 2015 Nate Parrott. All rights reserved.
//

@import UIKit;
#import "Keyframe.h"
#import "EVInterpolation.h"
@class CMDrawableKeyframe;
@class OptionsViewCellModel;
@class StaticAnimation;
#import "CanvasEditor.h"
#import "QuickCollectionModal.h"
#import "PropertyModel.h"
#import "CMRenderContext.h"
#import "CMLayoutBase.h"
@class FilterPickerFilterInfo;
@class EditorViewController;
@class Transition;
@class CMGroupDrawable;
#import "FilterPickerFilterInfo.h"

extern NSString * const CMDrawableArrayPasteboardType;

@interface CMDrawableView : UIView

- (CGRect)unrotatedBoundingBox;
@property (nonatomic,weak) CMDrawableView *wrapsView;

@end

typedef CMDrawableView* (^CMDrawableWrapperFunction)(CMDrawableView *toWrap, CMDrawableView *oldResult);

typedef void (^CMDrawableRenderingCallback)(CMDrawableView *);

@interface CMDrawable : NSObject <NSCoding, NSCopying>

- (instancetype)init;
- (NSArray<NSString*>*)keysForCoding;
@property (nonatomic) CGFloat boundsDiagonal;
@property (nonatomic,readonly) KeyframeStore *keyframeStore;
- (Class)keyframeClass;
@property (nonatomic) NSString *key;

- (__kindof CMDrawableView *)renderToView:(__kindof CMDrawableView *)existingOrNil context:(CMRenderContext *)ctx;

- (__kindof CMDrawableView *)renderFullyWrappedWithView:(__kindof CMDrawableView *)existingOrNil context:(CMRenderContext *)ctx;

- (FrameTime *)maxTime;

- (CGFloat)aspectRatio;

- (NSArray<PropertyGroupModel*>*)propertyGroupsWithEditor:(CanvasEditor *)editor;
- (NSArray<PropertyModel*>*)animatablePropertiesWithEditor:(CanvasEditor *)editor;
- (NSArray<PropertyModel*>*)uniqueObjectPropertiesWithEditor:(CanvasEditor *)editor;
- (NSString *)drawableTypeDisplayName;
- (NSString *)displayName;

- (BOOL)showResizeHandleWhenSelected;

@property (nonatomic) FilterPickerFilterInfo *filter;

@property (nonatomic) CMGroupDrawable *fillGroup;

- (NSArray<CMDrawableWrapperFunction>*)wrappersWithContext:(CMRenderContext *)ctx;

// repeating:
@property (nonatomic) NSInteger xRepeat;
@property (nonatomic) CGFloat xRepeatGap;
@property (nonatomic) NSInteger yRepeat;
@property (nonatomic) CGFloat yRepeatGap;

- (CGRect)boundingBoxForAllTime;

- (NSDictionary<NSString*,CMLayoutBase*>*)layoutBasesForViewsWithKeysInRenderContext:(CMRenderContext *)cx;

- (BOOL)performDefaultEditActionWithEditor:(EditorViewController *)editor;

- (BOOL)canDeleteKeyframeAtTime:(FrameTime *)time;

- (PropertyGroupModel *)staticAnimationGroup;

// variables for usage by the editor that SHOULDN'T be persisted:
@property (nonatomic) NSString *nameOfLastSelectedPropertiesTab;

- (void)getRenderedView:(CMDrawableRenderingCallback)callback;

@end


@interface CMDrawableKeyframe : NSObject <NSCoding, EVInterpolation, NSCopying>

@property (nonatomic) FrameTime *frameTime;
@property (nonatomic) CGPoint center;
@property (nonatomic) CGFloat scale, rotation, alpha;
@property (nonatomic) StaticAnimation *staticAnimation;
- (NSArray<NSString*>*)keys;
- (CGRect)outerBoundingBoxWithBounds:(CGSize)bounds;
@property (nonatomic) Transition *transition; // optional

@end
