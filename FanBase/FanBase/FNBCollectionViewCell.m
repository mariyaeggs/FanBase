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
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.clipsToBounds = YES;
    
    //Programs the label to the view
    // this controls the height of the label, increase and the lable will be shorter
    NSUInteger heightOfLabelConstant = 8;
    self.label = [[UILabel alloc]initWithFrame:CGRectMake(0, frame.size.height * (heightOfLabelConstant -1)/heightOfLabelConstant, frame.size.width, frame.size.height / heightOfLabelConstant)];
    //add background to label
    self.label.backgroundColor = [UIColor lightGrayColor];
    
    //Right, bottom corner alighnment
    self.label.textAlignment = NSTextAlignmentRight;
    
    //Adds the image and label
    [self.contentView addSubview:self.imageView];
    [self.contentView addSubview:self.label];
    
    
    return self;
}

-(void)setImage:(UIImage *)image {
    
    self.imageView.image = image;
}

-(void)setArtist:(NSString *)artist {
    
    _artist = artist;
    self.label.text = artist;
    
}



@end
