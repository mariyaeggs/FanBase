//
//  ViewController.m
//  FirebaseGettingUserInfo
//
//  Created by Andy Novak on 3/29/16.
//  Copyright © 2016 Andy Novak. All rights reserved.
//

#import "FNBLoginViewController.h"
#import "FNBColorConstants.h"

@interface FNBLoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *createAccountButton;
@property (weak, nonatomic) IBOutlet UIButton *continueAsGuestButton;
@property (weak, nonatomic) IBOutlet UILabel *userLoginLabel;

@end

@implementation FNBLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // round corners of container view
    self.containerView.layer.cornerRadius = 7.5;
    self.containerView.layer.masksToBounds = YES;
    
    // round corners of loginButton
    self.loginButton.layer.cornerRadius = 5;
    self.loginButton.layer.masksToBounds = YES;
    
    // colors
    self.loginButton.backgroundColor = FNBDarkGreenColor;
    [self.loginButton setTitleColor:FNBLightGreenColor forState:UIControlStateNormal];
    self.userLoginLabel.textColor = FNBDarkGreyColor;
     
    //Gradient
    self.view.tintColor = [UIColor colorWithRed:230.0/255.0 green:255.0/255.0 blue:247.0/255.0 alpha:1.0];
    UIColor *gradientMaskLayer = [UIColor colorWithRed:184.0/255.0 green:204.0/255.0 blue:198.0/255.0 alpha:1.0];
    CAGradientLayer *gradientMask = [CAGradientLayer layer];
    gradientMask.frame = self.view.bounds;
    gradientMask.colors = @[(id)gradientMaskLayer.CGColor,(id)[UIColor clearColor].CGColor];
    
    [self.view.layer insertSublayer:gradientMask atIndex:0];
    
    
}
- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [FNBFirebaseClient checkUntilUserisAuthenticatedWithCompletionBlock:^(BOOL isAuthenticUser) {
        //if the user is an authenticated user, segue to next screen
        if (isAuthenticUser) {
            NSLog(@"isAuthenticUser");
//            [self performSegueWithIdentifier:@"loginSuccessfulSegue" sender:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"UserDidLogInNotification" object:nil];
        }
    }];

}

- (IBAction)loginTapped:(id)sender {
    NSLog(@"Login button tapped");
    [FNBFirebaseClient loginWithEmail:self.emailField.text Password:self.passwordField.text];

}

// hide nav bar
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

// show nav bar before leaving page
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

- (IBAction)continueAsGuestTapped:(id)sender {
    //Just transition to next VC
//    [self performSegueWithIdentifier:@"loginSuccessfulSegue" sender:nil];
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"UserDidLogInNotification" object:nil];

}


@end
