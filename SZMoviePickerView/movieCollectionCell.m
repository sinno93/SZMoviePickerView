//
//  movieCollectionCell.m
//  CatEyeMovieScroll
//
//  Created by Sinno on 2017/5/20.
//  Copyright © 2017年 sinno. All rights reserved.
//

#import "movieCollectionCell.h"

@interface movieCollectionCell ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation movieCollectionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
-(void)refreshWithImageName:(NSString*)imageName{
    self.imageView.image = [UIImage imageNamed:imageName];
}
@end
