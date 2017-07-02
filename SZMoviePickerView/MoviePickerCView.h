//
//  MoviePickerCView.h
//  CatEyeMovieScroll
//
//  Created by Sinno on 2017/5/20.
//  Copyright © 2017年 sinno. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MoviePickerCView;
@protocol MoviePickerViewDelegate <NSObject>


/**
 选中item回调
 
 @param pickerView 视图
 @param index 选中的index
 */
-(void)moviePickerView:(MoviePickerCView*)pickerView didSelectIndex:(NSInteger)index;

@end
@interface MoviePickerCView : UIView

-(void)refreshWithImageArray:(NSArray<NSString*>*)imageArray;

/*item的最大尺寸，即当item到最中心时的大小*/
@property(nonatomic,assign)CGSize maxItemSize;
/*item最小的缩放大小，0-1之间*/
@property(nonatomic,assign)CGFloat minScale;
/*item底部距离下面的距离*/
@property(nonatomic,assign)CGFloat itemToBottom;
/*水平间距*/
@property(nonatomic,assign)CGFloat itemHorizontalSpace;


/* 当前选中的index 默认是0*/
@property(nonatomic,assign)NSInteger selectedIndex;
@property(nonatomic,weak)id<MoviePickerViewDelegate> delegate;
@end
