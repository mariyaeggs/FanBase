//
//  FNBSeeAllNearbyEventsTableViewCell.m
//  FanBase
//
//  Created by Andy Novak on 4/18/16.
//  Copyright © 2016 Angelica Bato. All rights reserved.
//

#import "FNBSeeAllNearbyEventsTableViewCell.h"

@implementation FNBSeeAllNearbyEventsTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

// make images circular
-(void)layoutSubviews
{
    [super layoutSubviews];
    self.eventImage.layer.cornerRadius = self.eventImage.frame.size.height /2;
    self.eventImage.layer.masksToBounds = YES;
    
}

@end
