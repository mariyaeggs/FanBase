//
//  EULAViewController.h
//  FanBase
//
//  Created by Mariya Eggensperger on 4/28/16.
//  Copyright © 2016 Angelica Bato. All rights reserved.
//

#import "ViewController.h"
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@interface EULAViewController : ViewController
@property (strong, nonatomic) FBSDKLoginManagerLoginResult *authdata;

@end
