//
//  ViewController.m
//  FirebaseGettingUserInfo
//
//  Created by Andy Novak on 3/29/16.
//  Copyright © 2016 Andy Novak. All rights reserved.
//

#import "FNBLoginViewController.h"


@interface FNBLoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

@end

@implementation FNBLoginViewController


- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [FNBFirebaseClient isUserAuthenticatedWithCompletionBlock:^(BOOL isAuthenticatedUser) {
        //if the user is an authenticated user, segue to next screen
        if (isAuthenticatedUser) {
            [self performSegueWithIdentifier:@"loginSuccessfulSegue" sender:nil];
        }
    }];
    
}

- (IBAction)loginTapped:(id)sender {
    [FNBFirebaseClient loginWithEmail:self.emailField.text Password:self.passwordField.text];

}
- (IBAction)continueAsDummyTapped:(id)sender {
    FNBUser *myDummyUser = [[FNBUser alloc] init];
    [FNBFirebaseClient fillUser:myDummyUser WithDummyDataWithCompletionBlock:^(BOOL madeDummyUser) {
        if (madeDummyUser) {
            // THIS IS WHERE YOU CAN GET THE DUMMY USER DATA
            NSLog(@"Filled user with dummy data");
            NSLog(@"myDummyUser: %@", myDummyUser.artistsDictionary);
            [FNBFirebaseClient loginWithEmail:myDummyUser.email Password:myDummyUser.password];
        }
    }];
}
- (IBAction)continueAsGuestTapped:(id)sender {
    //Just transition to next VC
    [self performSegueWithIdentifier:@"loginSuccessfulSegue" sender:nil];   
}


@end
