//
//  FNBSeeAllNearbyEventsTableViewCell.h
//  FanBase
//
//  Created by Andy Novak on 4/18/16.
//  Copyright © 2016 Angelica Bato. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FNBSeeAllNearbyEventsTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *eventImage;
@property (weak, nonatomic) IBOutlet UILabel *eventTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventDateLabel;

@end
