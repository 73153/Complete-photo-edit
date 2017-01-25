//
//  CMFlipbook.m
//  computer
//
//  Created by Nate Parrott on 2/23/16.
//  Copyright © 2016 Nate Parrott. All rights reserved.
//

#import "CMFlipbook.h"
#import "VideoConstants.h"
#import "CMCanvas.h"
#import "CMGroupDrawable.h"

@implementation CMFlipbook

- (instancetype)init {
    self = [super init];
    self.frameTime = 8.0 / VC_GIF_FPS; // half a second
    return self;
}

- (NSArray<NSString*>*)keysForCoding {
    return [[super keysForCoding] arrayByAddingObjectsFromArray:@[@"pages", @"frameTime"]];
}

- (NSArray<PropertyModel *> *)uniqueObjectPropertiesWithEditor:(CanvasEditor *)editor {
    PropertyModel *pages = [PropertyModel new];
    pages.title = NSLocalizedString(@"Pages", @"");
    pages.type = PropertyModelTypeListOfGroups;
    pages.key = @"pages";
    
    PropertyModel *frameTime = [PropertyModel new];
    frameTime.title = NSLocalizedString(@"Frame time", @"");
    frameTime.valueMin = 1.0 / VC_GIF_FPS;
    frameTime.valueMax = 1;
    frameTime.key = @"frameTime";
    frameTime.type = PropertyModelTypeSlider;
    
    return [@[pages, frameTime] arrayByAddingObjectsFromArray:[super uniqueObjectPropertiesWithEditor:editor]];
}

- (NSString *)displayName {
    return NSLocalizedString(@"Flipbook", @"");
}

- (__kindof CMDrawableView *)renderToView:(__kindof CMDrawableView *)existingOrNil context:(CMRenderContext *)ctx {
    NSArray *pages = [self pagesToShow];
    if (pages.count > 0) {
        NSTimeInterval time = ctx.useFrameTimeForStaticAnimations ? ctx.time.time : CFAbsoluteTimeGetCurrent();
        NSInteger pageIndex = ((NSInteger)floor(time / self.frameTime)) % pages.count;
        return [pages[pageIndex] renderToView:existingOrNil context:ctx];
    }
    return [super renderToView:existingOrNil context:ctx];
}

- (FrameTime *)maxTime {
    return [[FrameTime alloc] initWithFrame:[self pagesToShow].count * self.frameTime * 1000 atFPS:1000];
}

- (NSArray <CMGroupDrawable *> *)pagesToShow {
    NSInteger lastFullPage = 0;
    for (NSInteger i=0; i<self.pages.count; i++) {
        if (self.pages[i].contents.count > 0) {
            lastFullPage = i;
        }
    }
    return [self.pages subarrayWithRange:NSMakeRange(0, lastFullPage + 1)];
}

@end
