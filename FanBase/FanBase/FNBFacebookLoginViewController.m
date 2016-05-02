//
//  FNBFacebookLoginViewController.m
//  FanBase
//
//  Created by Andy Novak on 5/2/16.
//  Copyright © 2016 Angelica Bato. All rights reserved.
//

#import "FNBFacebookLoginViewController.h"
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "FNBLoginContainerViewController.h"
#import "FNBFirebaseClient.h"

@interface FNBFacebookLoginViewController () <FBSDKLoginButtonDelegate>

@end

@implementation FNBFacebookLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //Gradient
    self.view.tintColor = [UIColor colorWithRed:230.0/255.0 green:255.0/255.0 blue:247.0/255.0 alpha:1.0];
    UIColor *gradientMaskLayer = [UIColor colorWithRed:184.0/255.0 green:204.0/255.0 blue:198.0/255.0 alpha:1.0];
    CAGradientLayer *gradientMask = [CAGradientLayer layer];
    gradientMask.frame = self.view.bounds;
    gradientMask.colors = @[(id)gradientMaskLayer.CGColor,(id)[UIColor clearColor].CGColor];
    
    [self.view.layer insertSublayer:gradientMask atIndex:0];
    
    FBSDKLoginButton *loginButton = [[FBSDKLoginButton alloc] init];
    
    // Optional: Place the button in the center of your view.
    loginButton.center = self.view.center;
    [self.view addSubview:loginButton];

    loginButton.delegate = self;
}

-(void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UserDidLogOutNotification" object:nil];
}

-(void)loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:
(FBSDKLoginManagerLoginResult *)result error:(NSError *)error {
    [FNBFirebaseClient handleFacebookLoginWithResult:result error:error withCompletion:^(BOOL finishedFBLogin, BOOL isANewUser) {
        if (finishedFBLogin) {
            if (isANewUser) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"NewUserNotification" object:nil];
            }
            else {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"UserDidLogInNotification" object:nil];
            }
        }
        else {
            NSLog(@"There was an error handlingFBLogin");
        }
    }];
}

@end
