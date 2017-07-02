//
//  MoviePickerCView.m
//  CatEyeMovieScroll
//
//  Created by Sinno on 2017/5/20.
//  Copyright © 2017年 sinno. All rights reserved.
//
// 以collectionView方式实现的电影选择视图
#import "MoviePickerCView.h"
#import "movieCollectionCell.h"
#import "UIView+NIMDemo.h"
#import "MovieCollectionViewFlowLayout.h"

#define REUSEID @"cellReuseId"
@interface MoviePickerCView ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property(nonatomic,strong)UICollectionView* collectionView;
@property(nonatomic,strong)MovieCollectionViewFlowLayout *layout;
@property(nonatomic,strong)NSArray<NSString*>* imageArray;
@property(nonatomic,strong)UIImageView* backgroundImageView;
@property(nonatomic,strong)UIVisualEffectView *effectView;

@property(nonatomic,assign)BOOL userDragging;// 用户是否在拖动
@end

@implementation MoviePickerCView
#pragma mark - 初始化方法
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.maxItemSize = CGSizeMake(1, 1);
        [self addSubview:self.backgroundImageView];
        [self addSubview:self.collectionView];
    }
    return self;
}
-(void)refreshWithImageArray:(NSArray<NSString*>*)imageArray{
    NSArray *newImageArray = [imageArray copy];
    if ([self.imageArray isEqualToArray:newImageArray]) {
        return;
    }
    self.imageArray = newImageArray;
    [self.collectionView reloadData];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.selectedIndex inSection:0];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
    });
    if (0 == self.selectedIndex) {
        [self movieSlectedWithIndex:0];
    }
    
}
#pragma mark - collectionView代理


//每个section的item个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.imageArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    movieCollectionCell *cell = (movieCollectionCell*)[collectionView dequeueReusableCellWithReuseIdentifier:REUSEID forIndexPath:indexPath];
    NSString *imageName = self.imageArray[indexPath.row];
    [cell refreshWithImageName:imageName];
    return cell;
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    NSLog(@"offsetx-%f",scrollView.contentOffset.x);
    CGFloat offsetX = scrollView.contentOffset.x;
    CGFloat singleWidth = self.maxItemSize.width + self.itemHorizontalSpace;
    CGFloat yu = fmodf(offsetX, singleWidth); // 取余
    if (fabs(yu)<0.0001) {
        CGFloat mo  = offsetX / singleWidth; // 取模
        NSInteger index = mo;
        // 进到这里说明该cell的中点对齐了
        if (!self.userDragging) {
            [self movieSlectedWithIndex:index];
            
        }
        
    }
}
// 视图将要开始拖动
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    self.userDragging = YES;
}
// 视图停止拖动
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    self.userDragging = NO;
}

// 视图结束滚动动画
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    scrollView.scrollEnabled = YES;
}

//设置每个item间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return self.itemHorizontalSpace;
}

////点击item方法
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    collectionView.scrollEnabled = NO;
    [collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
}

-(void)movieSlectedWithIndex:(NSUInteger)index{
    NSString *imageName = self.imageArray[index];
    self.backgroundImageView.image = [UIImage imageNamed:imageName];
    self.selectedIndex = index;
    if (self.delegate && [self.delegate respondsToSelector:@selector(moviePickerView:didSelectIndex:)]) {
        [self.delegate moviePickerView:self didSelectIndex:index];
    }
}

#pragma mark - 子视图布局
-(void)layoutSubviews{
    self.backgroundImageView.frame = self.bounds;
    self.collectionView.frame = self.bounds;
    self.effectView.frame = self.backgroundImageView.bounds;
    
}

#pragma mark - getter && setter
-(UICollectionView*)collectionView{
    if (!_collectionView) {
        // 初始化collectionView
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:self.layout];
        // 注册collectionViewCell
        UINib *nib = [UINib nibWithNibName:NSStringFromClass(movieCollectionCell.class) bundle:nil];
        [collectionView registerNib:nib forCellWithReuseIdentifier:REUSEID];
        collectionView.delegate = self;
        collectionView.dataSource = self;
        collectionView.backgroundColor = [UIColor clearColor];
        collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView = collectionView;
    }
    return _collectionView;
}
-(MovieCollectionViewFlowLayout*)layout{
    if (!_layout) {
        // 1.初始化layout
        MovieCollectionViewFlowLayout *layout = [[MovieCollectionViewFlowLayout alloc]init];
        // 设置滚动方向
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.itemSize = CGSizeMake(self.maxItemSize.width, self.maxItemSize.height);
        CGFloat insetLeft = (kScreenWidth - self.maxItemSize.width)/2.0f;
        layout.sectionInset = UIEdgeInsetsMake(0, insetLeft, 0, insetLeft);
        layout.minScale = self.minScale;
        layout.itemToBottom = self.itemToBottom;
        _layout = layout;
    }
    return _layout;
}
// 磨砂图片视图
-(UIImageView*)backgroundImageView{
    if (!_backgroundImageView) {
        _backgroundImageView = [[UIImageView alloc]init];
        _backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
        _backgroundImageView.backgroundColor = [UIColor redColor];
        _backgroundImageView.clipsToBounds = YES;
        
        UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
        self.effectView = effectView;
        
        [_backgroundImageView addSubview:effectView];
    }
    return _backgroundImageView;
}
-(void)setMaxItemSize:(CGSize)maxItemSize{
    _maxItemSize = maxItemSize;
    self.layout.itemSize = self.maxItemSize;
    CGFloat insetLeft = (kScreenWidth - self.maxItemSize.width)/2.0f;
    self.layout
    .sectionInset = UIEdgeInsetsMake(0, insetLeft, 0, insetLeft);
    [self.collectionView reloadData];
}
-(void)setMinScale:(CGFloat)minScale{
    _minScale = minScale;
    self.layout.minScale = self.minScale;
    [self.collectionView reloadData];
}
-(void)setItemToBottom:(CGFloat)itemToBottom{
    _itemToBottom = itemToBottom;
    self.layout.itemToBottom = itemToBottom;
    [self.collectionView reloadData];
}
@end
