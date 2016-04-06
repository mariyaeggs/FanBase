//
//  CVCell.h
//  MariyaCollectionView
//
//  Created by Mariya Eggensperger on 4/1/16.
//  Copyright © 2016 Mariya Eggensperger. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CVCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UIImageView *artistImageView;

@end
