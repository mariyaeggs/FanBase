//
//  EventPostTableViewCell.m
//  FanBase
//
//  Created by Angelica Bato on 4/5/16.
//  Copyright © 2016 Angelica Bato. All rights reserved.
//

#import "EventPostTableViewCell.h"

@implementation EventPostTableViewCell

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
    self.artistImage.layer.cornerRadius = self.artistImage.frame.size.height /2;
    self.artistImage.layer.masksToBounds = YES;
    
}

@end
