//
//  FNBCollectionViewCell.h
//  FanBase
//
//  Created by Mariya Eggensperger on 4/7/16.
//  Copyright © 2016 Angelica Bato. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FNBCollectionViewCell : UICollectionViewCell

//@property (weak, nonatomic) IBOutlet UIImageView *interfaceBuilderImageView;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *artist;
@property (nonatomic) BOOL isUserSubscribedToArtist;
@property (nonatomic) BOOL isUserLoggedIn;
@property (nonatomic, strong) NSString *artistSpotifyID;

@end
