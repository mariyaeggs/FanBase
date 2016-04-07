//
//  FNBViewAllArtistsTableViewCell.m
//  FanBase
//
//  Created by Andy Novak on 4/7/16.
//  Copyright © 2016 Angelica Bato. All rights reserved.
//

#import "FNBViewAllArtistsTableViewCell.h"

@implementation FNBViewAllArtistsTableViewCell

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
    self.artistImageView.layer.cornerRadius = self.artistImageView.frame.size.height /2;
    self.artistImageView.layer.masksToBounds = YES;
 
}

@end
