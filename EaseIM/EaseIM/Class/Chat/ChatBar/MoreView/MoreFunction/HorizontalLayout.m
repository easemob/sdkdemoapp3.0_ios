//
//  HorizontalLayout.m
//  EaseIM
//
//  Created by 娜塔莎 on 2020/5/7.
//  Copyright © 2020 娜塔莎. All rights reserved.
//

#import "HorizontalLayout.h"

#define edgeDis  [UIScreen mainScreen].bounds.size.width / 17;

@interface HorizontalLayout()

@property (nonatomic,strong) NSMutableArray *attrs;
@property (nonatomic,strong) NSMutableDictionary *pageDict;

@end

@implementation HorizontalLayout

#pragma mark - life cycle
- (instancetype)init {
    if (self = [super init]) {
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
    return self;
}

- (void)prepareLayout {
    [super prepareLayout];
    // 获取section数量
    NSInteger section = [self.collectionView numberOfSections];
    for (int i = 0; i < section; i++) {
        // 获取当前分区的item数量
        NSInteger items = [self.collectionView numberOfItemsInSection:i];
        for (int j = 0; j < items; j++) {
            // 设置item位置
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:j inSection:i];
            UICollectionViewLayoutAttributes *attr = [self layoutAttributesForItemAtIndexPath:indexPath];
            [self.attrs addObject:attr];
        }
    }
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attr = [super layoutAttributesForItemAtIndexPath:indexPath].copy;
    [self resetItemLocation:attr];
    return attr;
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    return self.attrs;
}

- (CGSize)collectionViewContentSize {
    // 将所有section页面数量相加
    NSInteger allPagesCount = 0;
    for (NSString *page in [self.pageDict allKeys]) {
        allPagesCount += allPagesCount + [self.pageDict[page] integerValue];
    }
    CGFloat width = allPagesCount * self.collectionView.bounds.size.width;
    CGFloat hegith = self.collectionView.bounds.size.height;
    return CGSizeMake(width, hegith);
}

#pragma mark - private method
// 设置item布局属性
- (void)resetItemLocation:(UICollectionViewLayoutAttributes *)attr {
    if(attr.representedElementKind != nil) {
        return;
    }
    // 获取当前item的大小
    CGFloat itemW = self.itemSize.width;
    CGFloat itemH = self.itemSize.height;
    // 获取当前section的item数量
    NSInteger itemCount = [self.collectionView numberOfItemsInSection:attr.indexPath.section];
    // 获取横排item数量
    CGFloat width = self.collectionView.bounds.size.width;
    // 获取行间距和item最小间距
    CGFloat lineDis = self.minimumLineSpacing;
    CGFloat itemDis = self.minimumInteritemSpacing;
    // 获取当前item的索引index
    NSInteger index = attr.indexPath.item;
    // 获取每页item数量
    NSInteger allCount = self.rowCount * self.columCount;
    // 获取item在当前section的页码
    NSInteger page = index / allCount;
    // 获取item x y方向偏移量
    NSInteger xIndex = index % self.rowCount;
    NSInteger yIndex = (index - page * allCount)/self.rowCount;
    // 获取x y方向偏移距离
    CGFloat xOffset = xIndex * (itemW + lineDis) + edgeDis;//x方向偏移量
    CGFloat yOffset = yIndex * (itemH + itemDis) + 8;//y方向偏移量
    // 获取每个item占了几页
    NSInteger sectionPage = (itemCount % allCount == 0) ? itemCount/allCount : (itemCount/allCount + 1);
    // 保存每个section的page数量
    [self.pageDict setObject:@(sectionPage) forKey:[NSString stringWithFormat:@"%lu",attr.indexPath.section]];
    // 将所有section页面数量相加
    NSInteger allPagesCount = 0;
    for (NSString *page in [self.pageDict allKeys]) {
        allPagesCount += allPagesCount + [self.pageDict[page] integerValue];
    }
    // 获取到的数减去最后一页的页码数
    NSInteger lastIndex = self.pageDict.allKeys.count - 1;
    allPagesCount -= [self.pageDict[[NSString stringWithFormat:@"%lu",lastIndex]] integerValue];
    xOffset += page * width + allPagesCount * width;
    
    attr.frame = CGRectMake(xOffset, yOffset, itemW, itemH);
}
#pragma mark - getter and setter
- (NSMutableArray *)attrs {
    if (!_attrs) {
        _attrs = [NSMutableArray array];
    }
    return _attrs;
}

- (NSMutableDictionary *)pageDict {
    if (!_pageDict) {
        _pageDict = [NSMutableDictionary dictionary];
    }
    return _pageDict;
}
@end
