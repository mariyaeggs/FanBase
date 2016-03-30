//
//  TwitterPostTableViewCell.h
//  FanBase
//
//  Created by Angelica Bato on 3/30/16.
//  Copyright © 2016 Angelica Bato. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TwitterPostTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *userPicture;
@property (strong, nonatomic) IBOutlet UILabel *userName;
@property (strong, nonatomic) IBOutlet UILabel *userTweet;

@end
