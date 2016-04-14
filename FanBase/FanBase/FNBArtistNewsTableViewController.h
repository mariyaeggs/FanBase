//
//  FanFeedTableViewController.h
//  FanBase
//
//  Created by Angelica Bato on 3/29/16.
//  Copyright © 2016 Angelica Bato. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <STTwitter/STTwitter.h>
#import "FNBTwitterAPIClient.h"
#import "FNBTwitterPostTableViewCell.h"
#import <AFNetworking/AFNetworking.h>
#import "UIImageView+AFNetworking.h"
#import "FNBBandsInTownAPIClient.h"
#import "EventPostTableViewCell.h"
#import "FNBEventInfoVC.h"

@interface FNBArtistNewsTableViewController : UITableViewController <UIViewControllerPreviewingDelegate>

@property (strong, nonatomic) id previewingContext;
@property (strong, nonatomic) UILongPressGestureRecognizer *longPress;

@end
