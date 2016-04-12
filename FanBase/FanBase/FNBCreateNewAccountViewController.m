//
//  CreateNewAccountViewController.m
//  FirebaseGettingUserInfo
//
//  Created by Andy Novak on 3/29/16.
//  Copyright © 2016 Andy Novak. All rights reserved.
//

#import "FNBCreateNewAccountViewController.h"


@interface FNBCreateNewAccountViewController ()
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
