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
    [FNBFirebaseClient loginWithEmail:self.emailField.text Password:self.passwordField.text];

}


- (IBAction)continueAsGuestTapped:(id)sender {
    //Just transition to next VC
//    [self performSegueWithIdentifier:@"loginSuccessfulSegue" sender:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UserDidLogInNotification" object:nil];

}


@end
