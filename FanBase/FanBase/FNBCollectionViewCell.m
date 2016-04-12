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
@property (nonatomic, strong) UIButton *quickAddButton;


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

-(void)setIsUserLoggedIn:(BOOL)isUserLoggedIn {
    // have quickAddButton only if user is loggedIn
    _isUserLoggedIn = isUserLoggedIn;
    if (isUserLoggedIn) {
        // add the quickAddButton
        self.quickAddButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.quickAddButton addTarget:self action:@selector(quickAddButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        // TODO: add button image
        [self.quickAddButton setTitle:@"QuickAdd" forState:UIControlStateNormal];
        self.quickAddButton.frame = CGRectMake(0, 0, 44, 44);
        self.quickAddButton.backgroundColor = [UIColor whiteColor];
        
        [self.quickAddButton setAlpha:0.75];
        [self.contentView addSubview:self.quickAddButton];
    }
}

-(void)setIsUserSubscribedToArtist:(BOOL)isUserSubscribedToArtist {
    _isUserSubscribedToArtist = isUserSubscribedToArtist;
    if (self.isUserLoggedIn) {
        // make text green if user is not subscribed, and grey if user is already subscribed
        if (isUserSubscribedToArtist) {
            // make text grey
            [self.quickAddButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        }
        else {
            // make text green
            [self.quickAddButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
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
