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
    
    //Programs the image view
    self.imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    self.imageView.clipsToBounds = YES;
    
    //Programs the label to the view
    self.label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    self.label.textAlignment = NSTextAlignmentCenter;
    
    //Adds the image and label
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


@end
