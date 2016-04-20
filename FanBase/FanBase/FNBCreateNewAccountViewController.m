//
//  CreateNewAccountViewController.m
//  FirebaseGettingUserInfo
//
//  Created by Andy Novak on 3/29/16.
//  Copyright © 2016 Andy Novak. All rights reserved.
//

#import "FNBCreateNewAccountViewController.h"
#import "FNBColorConstants.h"

@interface FNBCreateNewAccountViewController ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@end

@implementation FNBCreateNewAccountViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    // round corners
    self.submitButton.layer.cornerRadius = 5;
    self.submitButton.layer.masksToBounds = YES;
    
    self.cancelButton.layer.cornerRadius = 5;
    self.cancelButton.layer.masksToBounds = YES;
    
    self.containerView.layer.cornerRadius = 7.5;
    self.containerView.layer.masksToBounds = YES;
    
    
    //colors
    self.submitButton.backgroundColor = FNBDarkGreenColor;
    [self.submitButton setTitleColor:FNBLightGreenColor forState:UIControlStateNormal];
    self.cancelButton.backgroundColor = FNBDarkGreenColor;
    [self.cancelButton setTitleColor:FNBLightGreenColor forState:UIControlStateNormal];
    self.titleLabel.textColor = FNBDarkGreyColor;
    
    //Gradient
    self.view.tintColor = [UIColor colorWithRed:230.0/255.0 green:255.0/255.0 blue:247.0/255.0 alpha:1.0];
    UIColor *gradientMaskLayer = [UIColor colorWithRed:184.0/255.0 green:204.0/255.0 blue:198.0/255.0 alpha:1.0];
    CAGradientLayer *gradientMask = [CAGradientLayer layer];
    gradientMask.frame = self.view.bounds;
    gradientMask.colors = @[(id)gradientMaskLayer.CGColor,(id)[UIColor clearColor].CGColor];

    [self.view.layer insertSublayer:gradientMask atIndex:0];
    
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [FNBFirebaseClient checkUntilUserisAuthenticatedWithCompletionBlock:^(BOOL isAuthenticUser) {
        if (isAuthenticUser) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"UserDidLogInNotification" object:nil];
            [self dismissViewControllerAnimated:YES completion:nil];
//            [self performSegueWithIdentifier:@"loginSuccessfulSegue" sender:nil];
        }
    }];
}

- (IBAction)submitTapped:(id)sender {

    [FNBFirebaseClient createANewUserInDatabaseWithEmail:self.emailField.text Password:self.passwordField.text];

}

- (IBAction)cancelTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
