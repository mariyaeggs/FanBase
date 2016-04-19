//
//  FNBCollectionViewCell.m
//  FanBase
//
//  Created by Mariya Eggensperger on 4/7/16.
//  Copyright © 2016 Angelica Bato. All rights reserved.
//

#import "FNBCollectionViewCell.h"
#import "FNBColorConstants.h"

@interface FNBCollectionViewCell ()

@property (nonatomic,strong) UIImageView *imageView;
@property (nonatomic,strong) UILabel *label;


@end

@implementation FNBCollectionViewCell


-(id)initWithFrame:(CGRect)frame {
    
//    NSLog(@"init frame of collection view cell");
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
    self.label.backgroundColor = FNBOffWhiteColor;
    self.label.textColor = FNBDarkGreyColor;
    //Right, bottom corner alighnment
    self.label.textAlignment = NSTextAlignmentRight;
    
    
    //Adds the image and label
    [self.contentView addSubview:self.imageView];
    [self.contentView addSubview:self.label];
    
    return self;
}

-(void)setIsUserLoggedIn:(BOOL)isUserLoggedIn {
    // have quickAddButton only if user is loggedIn
    _isUserLoggedIn = isUserLoggedIn;
    if (isUserLoggedIn) {
        // add the quickAddButton
        self.quickAddButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.quickAddButton addTarget:self action:@selector(quickAddButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        self.quickAddButton.frame = CGRectMake(0, 0, 44, 44);
        self.quickAddButton.backgroundColor = FNBOffWhiteColor;
        // make it a circle
        self.quickAddButton.layer.cornerRadius = self.quickAddButton.frame.size.height/2;
        self.quickAddButton.layer.masksToBounds = YES;
        
        [self.contentView addSubview:self.quickAddButton];
    }
}

-(void)setIsUserSubscribedToArtist:(BOOL)isUserSubscribedToArtist {
    _isUserSubscribedToArtist = isUserSubscribedToArtist;
    [self.quickAddButton setImage:nil forState:UIControlStateNormal];
    if (self.isUserLoggedIn) {
        
        // make text green if user is not subscribed, and grey if user is already subscribed
        if (isUserSubscribedToArtist) {
            [self.quickAddButton setImage:[UIImage imageNamed:@"trash"] forState:UIControlStateNormal];
            self.quickAddButton.tintColor = FNBDarkGreyColor;
        }
        else {
            [self.quickAddButton setImage:[UIImage imageNamed:@"person-add"]  forState:UIControlStateNormal];
            self.quickAddButton.tintColor = FNBDarkGreyColor;
            
        }
    }
}

-(void)setImage:(UIImage *)image {
    
    self.imageView.image = image;
}

-(void)setArtist:(NSString *)artist {
    
    _artist = artist;
    self.label.text = artist;
    
}

-(void)quickAddButtonTapped {
    //this gets triggered when QuickAddButton tapped
    NSLog(@"quick add button tapped");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"userTappedQuickAddButton" object:@[self.artist, self.artistSpotifyID]];
}

@end
