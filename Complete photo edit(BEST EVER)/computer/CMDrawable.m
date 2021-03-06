//
//  CMDrawable.m
//  computer
//
//  Created by Nate Parrott on 11/29/15.
//  Copyright © 2015 Nate Parrott. All rights reserved.
//

#import "CMDrawable.h"
#import "computer-Swift.h"
#import "PropertyViewTableCell.h"
#import "StaticAnimation.h"
#import "CGPointExtras.h"
#import "NSMutableArray+Utility.h"
#import "CMRepeatingWrapper.h"
#import "CMCanvas.h"
#import "VideoConstants.h"
#import "CMFilterWrapper.h"
#import "CMGroupDrawable.h"

NSString * const CMDrawableArrayPasteboardType = @"com.nateparrott.content57.CMDrawableArrayPasteboardType";

@interface CMDrawable ()

@property (nonatomic) KeyframeStore *keyframeStore;
@property (nonatomic) NSMutableArray<CMDrawableRenderingCallback> *renderingCallbacks;

@end

@implementation CMDrawable

- (instancetype)init {
    self = [super init];
    self.keyframeStore = [KeyframeStore new];
    self.keyframeStore.keyframeClass = [self keyframeClass];
    self.boundsDiagonal = 200;
    self.xRepeat = 1;
    self.xRepeatGap = 1;
    self.yRepeat = 1;
    self.yRepeatGap = 1;
    self.key = [NSUUID UUID].UUIDString;
    self.renderingCallbacks = [NSMutableArray new];
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    for (NSString *key in [self keysForCoding]) {
        [self setValue:[aDecoder decodeObjectForKey:key] forKey:key];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    for (NSString *key in [self keysForCoding]) {
        [aCoder encodeObject:[self valueForKey:key] forKey:key];
    }
}

- (NSArray<NSString*>*)keysForCoding {
    return @[@"boundsDiagonal", @"keyframeStore", @"key", @"xRepeat", @"xRepeatGap", @"yRepeat", @"yRepeatGap", @"filter", @"fillGroup"];
}

- (Class)keyframeClass {
    return [CMDrawableKeyframe class];
}

- (__kindof CMDrawableView *)renderToView:(CMDrawableView *)existingOrNil context:(CMRenderContext *)ctx {
    CMDrawableView *v = [existingOrNil isKindOfClass:[CMDrawableView class]] ? existingOrNil : [CMDrawableView new];
    
    CGSize size = CMSizeWithDiagonalAndAspectRatio(self.boundsDiagonal, self.aspectRatio);
    v.bounds = CGRectMake(0, 0, size.width, size.height); // TODO: is math
    
    return v;
}

- (void)getRenderedView:(CMDrawableRenderingCallback)callback {
    [self.renderingCallbacks addObject:callback];
}

- (FrameTime *)maxTime {
    return self.keyframeStore.maxTime;
}

- (CGFloat)aspectRatio {
    return 1;
}

- (BOOL)showResizeHandleWhenSelected {
    return [self respondsToSelector:@selector(setAspectRatio:)];
}

#pragma mark New Options UI

- (NSArray<PropertyGroupModel*>*)propertyGroupsWithEditor:(CanvasEditor *)editor {
    PropertyGroupModel *animatable = [PropertyGroupModel new];
    animatable.title = NSLocalizedString(@"Properties", @"");
    animatable.properties = [self animatablePropertiesWithEditor:editor];
    
    PropertyGroupModel *unique = [PropertyGroupModel new];
    unique.title = [self drawableTypeDisplayName];
    unique.properties = [self uniqueObjectPropertiesWithEditor:editor];
    
    PropertyGroupModel *repeating = [self repeatingPropertiesGroupModel];
    
    return @[unique, animatable, [self staticAnimationGroup], repeating, [self effectsPropertyGroupModel]];
}

- (PropertyGroupModel *)staticAnimationGroup {
    PropertyGroupModel *staticAnimation = [PropertyGroupModel new];
    staticAnimation.title = NSLocalizedString(@"Animation", @"");
    staticAnimation.singleView = YES;
    PropertyModel *staticAnimationProp = [PropertyModel new];
    staticAnimationProp.isKeyframeProperty = YES;
    staticAnimationProp.type = PropertyModelTypeStaticAnimation;
    staticAnimationProp.key = @"staticAnimation";
    staticAnimation.properties = @[staticAnimationProp];
    return staticAnimation;
}

- (NSString *)drawableTypeDisplayName {
    return NSLocalizedString(@"Object", @"");
}

- (NSString *)displayName {
    return [self drawableTypeDisplayName];
}

- (NSArray<PropertyModel*>*)animatablePropertiesWithEditor:(CanvasEditor *)editor {
    PropertyModel *opacity = [PropertyModel new];
    opacity.title = NSLocalizedString(@"Opacity", @"");
    opacity.type = PropertyModelTypeSlider;
    opacity.valueMin = 0;
    opacity.valueMax = 1;
    opacity.isKeyframeProperty = YES;
    opacity.key = @"alpha";
    
    return @[opacity];
}

- (NSArray<PropertyModel*>*)uniqueObjectPropertiesWithEditor:(CanvasEditor *)editor {
    return @[];
}

- (PropertyGroupModel *)repeatingPropertiesGroupModel {
    PropertyModel *xRepeat = [PropertyModel new];
    xRepeat.title = NSLocalizedString(@"Horizontal repeat", @"");
    xRepeat.type = PropertyModelTypeSlider;
    xRepeat.valueMin = 1;
    xRepeat.valueMax = 7;
    xRepeat.key = @"xRepeat";
    
    PropertyModel *xGap = [PropertyModel new];
    xGap.title = NSLocalizedString(@"Horizontal spacing", @"");
    xGap.type = PropertyModelTypeSlider;
    xGap.valueMax = 3;
    xGap.key = @"xRepeatGap";
    
    PropertyModel *yRepeat = [PropertyModel new];
    yRepeat.title = NSLocalizedString(@"Vertical repeat", @"");
    yRepeat.type = PropertyModelTypeSlider;
    yRepeat.valueMin = 1;
    yRepeat.valueMax = 7;
    yRepeat.key = @"yRepeat";
    
    PropertyModel *yGap = [PropertyModel new];
    yGap.title = NSLocalizedString(@"Vertical spacing", @"");
    yGap.type = PropertyModelTypeSlider;
    yGap.valueMax = 3;
    yGap.key = @"yRepeatGap";
    
    PropertyGroupModel *group = [PropertyGroupModel new];
    group.title = NSLocalizedString(@"Repeat", @"");
    group.properties = @[xRepeat, xGap, yRepeat, yGap];
    
    return group;
}

- (PropertyGroupModel *)effectsPropertyGroupModel {
    PropertyModel *fillGroup = [PropertyModel new];
    fillGroup.type = PropertyModelTypeButtons;
    fillGroup.buttonTitles = @[NSLocalizedString(@"Edit…", @"")];
    fillGroup.buttonSelectorNames = @[@"editFillGroup:"];
    fillGroup.key = @"fillGroup";
    fillGroup.title = NSLocalizedString(@"Fill content", @"");
    
    PropertyGroupModel *model = [PropertyGroupModel new];
    model.title = NSLocalizedString(@"Effects", @"");
    model.properties = @[fillGroup];
    return model;
}

- (id)copy {
    CMDrawable *d = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:self]];
    d.key = [NSUUID UUID].UUIDString;
    return d;
}

- (id)copyWithZone:(NSZone *)zone {
    return [self copy];
}

#pragma mark Wrappers

- (__kindof CMDrawableView *)renderFullyWrappedWithView:(__kindof CMDrawableView *)existingOrNil context:(CMRenderContext *)ctx {
    NSMutableArray *stackOfOldViews = [NSMutableArray new];
    CMDrawableView *v = existingOrNil;
    while (v) {
        // [stackOfOldViews insertObject:v atIndex:0];
        [stackOfOldViews addObject:v];
        v = v.wrapsView;
    }
    
    CMDrawableView *result = [self renderToView:stackOfOldViews.pop context:ctx];
    
    NSArray *callbacks = self.renderingCallbacks;
    self.renderingCallbacks = [NSMutableArray new];
    for (CMDrawableRenderingCallback callback in callbacks) {
        callback(result);
    }
        
    for (CMDrawableWrapperFunction fn in [self wrappersWithContext:ctx]) {
        CMDrawableView *wrapped = result;
        wrapped.transform = CGAffineTransformIdentity;
        result = fn(wrapped, stackOfOldViews.pop);
        result.wrapsView = wrapped;
    }
    
    CMDrawableKeyframe *keyframe = [self.keyframeStore interpolatedKeyframeAtTime:ctx.time];
    CGPoint center = keyframe.center;
    CGFloat scale = keyframe.scale;
    CGFloat rotation = keyframe.rotation;
    CGFloat alpha = keyframe.alpha;
    
    CMLayoutBase *layoutBase = ctx.layoutBasesForObjectsWithKeys[self.key];
    if (layoutBase) {
        center = CGPointMake(center.x + layoutBase.center.x, center.y + layoutBase.center.y);
        scale *= layoutBase.scale;
        rotation += layoutBase.rotation;
        alpha = layoutBase.visible ? alpha : 0;
    }
    
    CGFloat canvasScale = 1;
    if (ctx.coordinateSpace) canvasScale = [ctx.coordinateSpace convertRect:CGRectMake(center.x, center.y, canvasScale, canvasScale) toCoordinateSpace:ctx.canvasView].size.width;
    // NSLog(@"%@: %f", NSStringFromClass([self class]), canvasScale);
    
    CGAffineTransform transform = CGAffineTransformScale(CGAffineTransformMakeRotation(rotation), scale * canvasScale, scale * canvasScale);
    
    NSTimeInterval staticAnimationTime = ctx.useFrameTimeForStaticAnimations ? ctx.time.time : (NSTimeInterval)CFAbsoluteTimeGetCurrent();
    alpha = [keyframe.staticAnimation adjustAlpha:alpha time:staticAnimationTime];
    transform = [keyframe.staticAnimation adjustTransform:transform time:staticAnimationTime];
    
    result.alpha = alpha;
    result.transform = transform;
    
    if (ctx.coordinateSpace) {
        result.center = [ctx.coordinateSpace convertPoint:center toCoordinateSpace:ctx.canvasView];
    } else {
        // CanvasViewerLite doesn't have a coordinate space...
        result.center = center;
    }
    
    if (keyframe.transition) {
        CGFloat progress = (ctx.time.time - keyframe.transition.startTime.time) / keyframe.transition.duration.time;
        progress = [keyframe.transition computeTimingCurve:progress];
        [keyframe.transition apply:self view:result context:ctx progress:progress];
    }
    
    return result;
}

- (NSArray<CMDrawableWrapperFunction>*)wrappersWithContext:(CMRenderContext *)ctx {
    NSMutableArray *wrappers = [NSMutableArray new];
    
    if (self.fillGroup.contents.count > 0) {
        CMDrawableWrapperFunction fn = ^CMDrawableView*(CMDrawableView *child, CMDrawableView *old) {
            CMGroupFillWrapper *wrapper = [old isKindOfClass:[CMGroupFillWrapper class]] ? (id)old : [CMGroupFillWrapper new];
            wrapper.childView = child;
            wrapper.fillView = [self.fillGroup renderToView:wrapper.fillView context:ctx];
            [wrapper setNeedsLayout];
            return wrapper;
        };
        [wrappers addObject:fn];
    }
    
    if (self.xRepeat > 1) {
        NSInteger repeat = self.xRepeat;
        CGFloat gap = self.xRepeatGap;
        CMDrawableWrapperFunction fn = ^CMDrawableView*(CMDrawableView *child, CMDrawableView *old) {
            CMRepeatingWrapper *v = [old isKindOfClass:[CMRepeatingWrapper class]] ? (id)old : [CMRepeatingWrapper new];
            v.count = repeat;
            v.gap = gap;
            v.vertical = NO;
            v.child = child;
            return v;
        };
        [wrappers addObject:fn];
    }
    
    if (self.yRepeat > 1) {
        NSInteger repeat = self.yRepeat;
        CGFloat gap = self.yRepeatGap;
        CMDrawableWrapperFunction fn = ^CMDrawableView*(CMDrawableView *child, CMDrawableView *old) {
            CMRepeatingWrapper *v = [old isKindOfClass:[CMRepeatingWrapper class]] ? (id)old : [CMRepeatingWrapper new];
            v.count = repeat;
            v.gap = gap;
            v.vertical = YES;
            v.child = child;
            return v;
        };
        [wrappers addObject:fn];
    }
    
    if (self.filter) {
        CMDrawableWrapperFunction fn = ^CMDrawableView*(CMDrawableView *child, CMDrawableView *old) {
            CMFilterWrapper *v = [old isKindOfClass:[CMFilterWrapper class]] ? (id)old : [CMFilterWrapper new];
            v.child = child;
            v.filter = self.filter;
            return v;
        };
        [wrappers addObject:fn];
    }
    
    return wrappers;
}

#pragma mark Keyframe actions

- (BOOL)canDeleteKeyframeAtTime:(FrameTime *)time {
    return self.keyframeStore.allKeyframes.count > 1 && [self.keyframeStore keyframeAtTime:time] != nil;
}

- (void)deleteCurrentKeyframe:(PropertyViewTableCell *)cell {
    if ([self canDeleteKeyframeAtTime:cell.time]) {
        CMDrawableKeyframe *oldKeyframe = [self.keyframeStore keyframeAtTime:cell.time];
        FrameTime *time = cell.time;
        [cell.transactionStack doTransaction:[[CMTransaction alloc] initWithTarget:self action:^(id target) {
            [self.keyframeStore removeKeyframeAtTime:time];
        } undo:^(id target) {
            [self.keyframeStore storeKeyframe:oldKeyframe];
        }]];
    }
}

#pragma mark Relative layouts

- (NSDictionary<NSString*,CMLayoutBase*>*)layoutBasesForViewsWithKeysInRenderContext:(CMRenderContext *)ctx {
    return nil;
}

#pragma mark Bounding boxes

- (CGRect)boundingBoxForAllTime {
    CGSize size = CMSizeWithDiagonalAndAspectRatio(self.boundsDiagonal, self.aspectRatio);
    CGRect box = CGRectNull;
    for (CMDrawableKeyframe *keyframe in self.keyframeStore.allKeyframes) {
        CGRect keyframeBox = [keyframe outerBoundingBoxWithBounds:size];
        if (CGRectIsNull(box)) {
            box = keyframeBox;
        } else {
            box = CGRectUnion(box, keyframeBox);
        }
    }
    return box;
}

#pragma mark Actions

- (BOOL)performDefaultEditActionWithEditor:(EditorViewController *)editor {
    return NO;
}

- (void)editFillGroup:(PropertyViewTableCell *)cell {
    if (!self.fillGroup) {
        self.fillGroup = [CMGroupDrawable new];
        [self.fillGroup.keyframeStore createKeyframeAtTimeIfNeeded:cell.time];
    }
    [self.fillGroup editGroupWithEditor:cell.editor];
}

@end

@implementation CMDrawableKeyframe

- (instancetype)init {
    self = [super init];
    self.center = CGPointMake(100, 100);
    self.alpha = 1;
    self.scale = 1;
    self.rotation = 0;
    self.staticAnimation = [StaticAnimation new];
    return self;
}

- (NSArray<NSString*>*)keys {
    return @[@"center", @"scale", @"rotation", @"alpha", @"frameTime", @"staticAnimation", @"transition"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    for (NSString *key in [self keys]) {
        [self setValue:[aDecoder decodeObjectForKey:key] forKey:key];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    for (NSString *key in [self keys]) {
        [aCoder encodeObject:[self valueForKey:key] forKey:key];
    }
}

- (NSComparisonResult)compare:(id)other {
    return [self.frameTime compare:[other frameTime]];
}

- (instancetype)interpolatedWith:(id)other progress:(CGFloat)progress {
    return [self interpolatedWith:other progress:progress previousVal:nil nextVal:nil];
}

- (instancetype)interpolatedWith:(id)other progress:(CGFloat)progress previousVal:(id)prev nextVal:(id)next {
    prev = prev ? : self;
    next = next ? : other;
    
    CMDrawableKeyframe *i = [[self class] new];
    for (NSString *key in [self keys]) {
        
        if ([key isEqualToString:@"transition"]) {
            // pass
        } else if ([key isEqualToString:@"rotation"]) {
            CGFloat prev = [[self valueForKey:key] floatValue];
            CGFloat next = [[other valueForKey:key] floatValue];
            CGFloat val = CMInterpolateAngles(prev, next, progress);
            [i setValue:@(val) forKey:key];
        } else {
            id from = [self valueForKey:key];
            id to = [other valueForKey:key];
            id result;
            if ([from respondsToSelector:@selector(interpolatedWith:progress:previousVal:nextVal:)]) {
                result = [from interpolatedWith:to progress:progress previousVal:[prev valueForKey:key] nextVal:[next valueForKey:key]];
            } else {
                result = [from interpolatedWith:to progress:progress];
            }
            [i setValue:result forKey:key];
        }
    }
    return i;
}

- (id)copy {
    return [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:self]];
}

- (id)copyWithZone:(NSZone *)zone {
    return [self copy];
}

- (CGRect)outerBoundingBoxWithBounds:(CGSize)bounds {
    // TODO: better
    CGRect box = CGRectMake( - bounds.width/2, - bounds.height/2, bounds.width, bounds.height);
    CGAffineTransform transform = CGAffineTransformScale(CGAffineTransformMakeRotation(self.rotation), self.scale, self.scale);
    box = CGRectApplyAffineTransform(box, transform);
    box.origin.x += self.center.x;
    box.origin.y += self.center.y;
    return box;
}

@end

@implementation CMDrawableView

- (instancetype)init {
    self = [super init];
    return self;
}

- (CGRect)unrotatedBoundingBox {
    return self.frame; // TODO: math
}

@end
