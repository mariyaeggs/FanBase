//
//  CreateNewAccountViewController.m
//  FirebaseGettingUserInfo
//
//  Created by Andy Novak on 3/29/16.
//  Copyright © 2016 Andy Novak. All rights reserved.
//

#import "CreateNewAccountViewController.h"
#import <Firebase/Firebase.h>
#import "Secrets.h"
#import "FNBFirebaseClient.h"

@interface CreateNewAccountViewController ()
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@end

@implementation CreateNewAccountViewController

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
    //create new user
    [FNBFirebaseClient createNewUserWithEmail:self.emailField.text Password:self.passwordField.text WithBlockIfSuccessful:^(BOOL successfulCreationOfNewUser, NSString *receivedEmail, NSString *receivedPassword, NSString *createdUID) {
        //if successfully created new user, add them to database and login that user
            if (successfulCreationOfNewUser) {
                NSLog(@"created user!!!!! emails: %@", receivedEmail);
                
                // add user to database
                [FNBFirebaseClient addNewUserToDatabaseWithEmail:receivedEmail Password:receivedPassword UID:createdUID];
                
//                    Firebase *ref = [[Firebase alloc] initWithUrl:ourFirebaseURL];
//                    Firebase *usersRef = [ref childByAppendingPath:@"users"];
//                    Firebase *newUserRef = [usersRef childByAppendingPath:createdUID];
//                    [newUserRef setValue:@{@"email": receivedEmail , @"password": receivedPassword}];
//                    NSLog(@"Added user to database");
                
                // login user
                [FNBFirebaseClient loginWithEmail:self.emailField.text Password:self.passwordField.text];
                NSLog(@"logged in user");
            }
        }];
}

- (IBAction)cancelTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
