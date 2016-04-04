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
@end

@implementation FNBCreateNewAccountViewController

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [FNBFirebaseClient checkUntilUserisAuthenticatedWithCompletionBlock:^(BOOL isAuthenticUser) {
        if (isAuthenticUser) {
            [self performSegueWithIdentifier:@"loginSuccessfulSegue" sender:nil];
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
