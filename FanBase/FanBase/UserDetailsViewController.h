//
//  UserDetailsViewController.h
//  FirebaseGettingUserInfo
//
//  Created by Andy Novak on 3/29/16.
//  Copyright © 2016 Andy Novak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FNBUser.h"
#import <Firebase/Firebase.h>
#import "Secrets.h"
#import "FNBFirebaseClient.h"
#import "FNBArtist.h"

@interface UserDetailsViewController : UIViewController
@property (strong, nonatomic) FNBUser *currentUser;
@end
