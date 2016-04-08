//
//  CVCell.m
//  MariyaCollectionView
//
//  Created by Mariya Eggensperger on 4/1/16.
//  Copyright © 2016 Mariya Eggensperger. All rights reserved.
//

#import "CVCell.h"

@implementation CVCell

-(void)awakeFromNib{
    [super awakeFromNib];
    self.artistImageView.clipsToBounds = YES;
    self.artistImageView.contentMode = UIViewContentModeScaleAspectFill;
}

@end
