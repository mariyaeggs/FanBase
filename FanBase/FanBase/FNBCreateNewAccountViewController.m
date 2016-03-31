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
    
    [FNBFirebaseClient isUserAuthenticatedWithCompletionBlock:^(BOOL isAuthenticatedUser) {
        //if the user is an authenticated user, segue to next screen
        if (isAuthenticatedUser) {
            [self performSegueWithIdentifier:@"loginSuccessfulSegue" sender:nil];
        }
    }];
}

- (IBAction)submitTapped:(id)sender {
//    //create new user
//    [FNBFirebaseClient createNewUserWithEmail:self.emailField.text Password:self.passwordField.text WithBlockIfSuccessful:^(BOOL successfulCreationOfNewUser, NSString *receivedEmail, NSString *receivedPassword, NSString *createdUID) {
//        //if successfully created new user, add them to database and login that user
//            if (successfulCreationOfNewUser) {
//                NSLog(@"created user!!!!! emails: %@", receivedEmail);
//                
//                // add user to database
//                [FNBFirebaseClient addNewUserToDatabaseWithEmail:receivedEmail Password:receivedPassword UID:createdUID];
//                
//                // login user
//                [FNBFirebaseClient loginWithEmail:self.emailField.text Password:self.passwordField.text];
//                NSLog(@"logged in user");
//            }
//        }];

    [FNBFirebaseClient createANewUserWithEmail:self.emailField.text Password:self.passwordField.text];

}

- (IBAction)cancelTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
