//
//  FNBCollectionViewCell.m
//  FanBase
//
//  Created by Mariya Eggensperger on 4/7/16.
//  Copyright © 2016 Angelica Bato. All rights reserved.
//

#import "FNBCollectionViewCell.h"

@interface FNBCollectionViewCell ()

@property (nonatomic,strong) UIImageView *imageView;
@property (nonatomic,strong) UILabel *label;


@end

@implementation FNBCollectionViewCell


-(id)initWithFrame:(CGRect)frame {
    
    NSLog(@"init frame of collection view cell");
    if (!(self=[super initWithFrame:frame])) return nil;
    
    self.imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    self.imageView.clipsToBounds = YES;
    
    self.label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    self.label.textAlignment = NSTextAlignmentCenter;
    
    [self.contentView addSubview:self.imageView];
    [self.contentView addSubview:self.label];
    
    return self;
}

-(void)setImage:(UIImage *)image {
    
    _image = image;
    self.imageView.image = image;
}

-(void)setArtist:(NSString *)artist {
    
    _artist = artist;
    self.label.text = artist;
    
}

//-(void)setLabel:(UILabel *)label {
//    
//    _label = label;
//    self.label =label;
//}


@end
