//
//  FNBViewAllArtistsTableViewCell.h
//  FanBase
//
//  Created by Andy Novak on 4/7/16.
//  Copyright © 2016 Angelica Bato. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FNBViewAllArtistsTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *artistImageView;
@property (weak, nonatomic) IBOutlet UILabel *usersRankLabel;
@property (weak, nonatomic) IBOutlet UILabel *artistNameLabel;

@end
