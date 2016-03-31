//
//  FNBUsersArtistsTableViewController.h
//  FanBase
//
//  Created by Andy Novak on 3/31/16.
//  Copyright © 2016 Angelica Bato. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FNBFirebaseClient.h"

@interface FNBUsersArtistsTableViewController : UITableViewController
@property (strong, nonatomic) FNBUser *currentUser;
@end
