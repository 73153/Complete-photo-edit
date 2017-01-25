//
//  ListOfGroupsPropertyTableCell.m
//  computer
//
//  Created by Nate Parrott on 2/23/16.
//  Copyright © 2016 Nate Parrott. All rights reserved.
//

#import "ListOfGroupsPropertyTableCell.h"
#import "CanvasViewerLite.h"
#import "CMGroupDrawable.h"

#define MAX_FRAMES 10

@interface _GroupPreviewCell : UICollectionViewCell {
    CanvasViewerLite *_viewer;
}

@end

@implementation _GroupPreviewCell

- (CanvasViewerLite *)viewer {
    if (!_viewer) {
        _viewer = [CanvasViewerLite new];
        _viewer.resizeToFitContent = YES;
        _viewer.frame = self.bounds;
        _viewer.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self addSubview:_viewer];
    }
    return _viewer;
}

@end


@interface ListOfGroupsPropertyTableCell () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic) UICollectionView *collectionView;

@end

@implementation ListOfGroupsPropertyTableCell

- (void)setup {
    [super setup];
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing = 10;
    layout.minimumInteritemSpacing = 0;
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self addSubview:self.collectionView];
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.collectionView registerClass:[_GroupPreviewCell class] forCellWithReuseIdentifier:@"Cell"];
}

- (void)reloadValue {
    [super reloadValue];
    [self.collectionView reloadData];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    UICollectionViewFlowLayout *layout = (id)self.collectionView.collectionViewLayout;
    layout.itemSize = CGSizeMake(self.bounds.size.height, self.bounds.size.height);
}

+ (CGFloat)heightForModel:(PropertyModel *)model {
    return 88;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return MAX_FRAMES;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    _GroupPreviewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    cell.viewer.userInteractionEnabled = NO;
    NSArray *groups = (id)self.value;
    cell.viewer.canvas = indexPath.item < groups.count ? groups[indexPath.item] : nil;
    cell.backgroundColor = [UIColor whiteColor];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *groups = (id)self.value;
    CMGroupDrawable *group = indexPath.item < groups.count ? groups[indexPath.item] : [self createEmptyGroup];
    [group editGroupWithEditor:self.editor callback:^{
        NSMutableArray *frames = groups.mutableCopy ? : [NSMutableArray new];
        while (frames.count < indexPath.item + 1) {
            [frames addObject:[self createEmptyGroup]];
        }
        [frames replaceObjectAtIndex:indexPath.item withObject:group];
        [self saveValue:frames];
    }];
}

- (CMGroupDrawable *)createEmptyGroup {
    CMGroupDrawable *group = [CMGroupDrawable new];
    [group.keyframeStore createKeyframeAtTimeIfNeeded:self.time];
    return group;
}

@end
