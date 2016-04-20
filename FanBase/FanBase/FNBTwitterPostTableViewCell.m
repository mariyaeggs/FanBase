//
//  TwitterPostTableViewCell.m
//  FanBase
//
//  Created by Angelica Bato on 3/30/16.
//  Copyright © 2016 Angelica Bato. All rights reserved.
//

#import "FNBTwitterPostTableViewCell.h"

@implementation FNBTwitterPostTableViewCell

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
    self.userPicture.layer.cornerRadius = self.userPicture.frame.size.height /2;
    self.userPicture.layer.masksToBounds = YES;
    
}
@end
