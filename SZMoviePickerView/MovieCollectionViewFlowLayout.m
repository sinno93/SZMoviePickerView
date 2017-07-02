//
//  MovieCollectionViewFlowLayout.m
//  CatEyeMovieScroll
//
//  Created by Sinno on 2017/5/21.
//  Copyright © 2017年 sinno. All rights reserved.
//

#import "MovieCollectionViewFlowLayout.h"

@implementation MovieCollectionViewFlowLayout
- (void)prepareLayout
{
    [super prepareLayout];
    // 垂直滚动
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
//    // 设置collectionView里面内容的内边距（上、左、下、右）
//    CGFloat inset = (self.collectionView.frame.size.width - 2*self.itemSize.width) /3;
//    self.sectionInset = UIEdgeInsetsMake(inset, inset, inset, inset);
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    CGFloat minScale = self.minScale;
    // 拿到系统已经帮我们计算好的布局属性数组，然后对其进行拷贝一份，后续用这个新拷贝的数组去操作
    NSArray * originalArray   = [super layoutAttributesForElementsInRect:rect];
    NSArray * curArray = [[NSArray alloc] initWithArray:originalArray copyItems:YES];
    
    // 计算collectionView中心点的y值(这个中心点可不是屏幕的中线点哦，是整个collectionView的，所以是包含在屏幕之外的偏移量的哦)
    CGFloat centerX = self.collectionView.contentOffset.x + self.collectionView.frame.size.width * 0.5;
    
    // 拿到每一个cell的布局属性，在原有布局属性的基础上，进行调整
    for (UICollectionViewLayoutAttributes *attrs in curArray) {
        // cell的中心点y 和 collectionView最中心点的y值 的间距的绝对值
        CGFloat space = ABS(attrs.center.x - centerX);
        if (space > attrs.frame.size.width) {
            attrs.transform = CGAffineTransformMakeScale(minScale, minScale);
        }else{
            // 根据间距值 计算 cell的缩放比例
            // 间距越大，cell离屏幕中心点越远，那么缩放的scale值就小
            CGFloat scale = -(1-minScale)*space/attrs.frame.size.width + 1;
            // 设置缩放比例
            CGFloat height = attrs.bounds.size.height *scale;
            
            CGPoint center = attrs.center;
            center.y = (0.9*attrs.bounds.size.height - height)*0.5 + center.y;
            attrs.center = center;
            attrs.transform = CGAffineTransformMakeScale(scale,scale);

        }
        
    }
    
    return curArray;
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity
{
    // 计算出停止滚动时(不是松手时)最终显示的矩形框
    CGRect rect;
    rect.origin.y = 0;
    rect.origin.x = proposedContentOffset.x;
    rect.size = self.collectionView.frame.size;
    
    // 获得系统已经帮我们计算好的布局属性数组
    NSArray *array = [self layoutAttributesForElementsInRect:rect];
    
    // 计算collectionView最中心点的y值
    // 再啰嗦一下，这个proposedContentOffset是系统帮我们已经计算好的，当我们松手后它惯性完全停止后的偏移量
    CGFloat centerX = proposedContentOffset.x + self.collectionView.frame.size.width * 0.5;
    
    // 当完全停止滚动后，离中点Y值最近的那个cell会通过我们多给出的偏移量回到屏幕最中间
    // 存放最小的间距值
    // 先将间距赋值为最大值，这样可以保证第一次一定可以进入这个if条件，这样可以保证一定能闹到最小间距
    CGFloat minSpace = MAXFLOAT;
    for (UICollectionViewLayoutAttributes *attrs in array) {
//        NSLog(@"centerx:%f",attrs.center.x);
        CGFloat cha = attrs.center.x - centerX;
        if (ABS(minSpace) > ABS(cha)) {
            minSpace = cha;
        }
    }
    // 修改原有的偏移量
    proposedContentOffset.x += minSpace;
//    NSLog(@"minspace:%f",minSpace);
    return proposedContentOffset;
}
@end
