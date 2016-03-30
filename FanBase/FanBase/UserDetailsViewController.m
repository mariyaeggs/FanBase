//
//  UserDetailsViewController.m
//  FirebaseGettingUserInfo
//
//  Created by Andy Novak on 3/29/16.
//  Copyright © 2016 Andy Novak. All rights reserved.
//

#import "UserDetailsViewController.h"



@interface UserDetailsViewController()
@property (weak, nonatomic) IBOutlet UILabel *label1;
@property (weak, nonatomic) IBOutlet UILabel *label2;
@property (weak, nonatomic) IBOutlet UILabel *label3;
@property (weak, nonatomic) IBOutlet UILabel *label4;
@property (strong, nonatomic) Firebase *ref;

@end


@implementation UserDetailsViewController

-(void)viewDidLoad {
    [super viewDidLoad];

    //initialize ref Firebase
    self.ref = [[Firebase alloc] initWithUrl:ourFirebaseURL];
    
    
    self.label1.text = @"1";
    self.label2.text = @"2";
    self.label3.text = @"3";
    self.label4.text = @"4";
    
}

- (void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

    [FNBFirebaseClient getPropertiesOfLoggedInUser];

    
//    //setup user property
//    [self.ref observeAuthEventWithBlock:^(FAuthData *authData) {
//        if (authData != nil) {
//            self.user = [[FNBUser alloc] initWithAuthData:authData];
//            
//            [FNBFirebaseClient getPropertiesOfUserWithUID:authData.uid];
//            
//            
//            self.label1.text = self.user.email;
//            self.label2.text = self.user.userID;
////            self.label3.text = [self.user.artistsDictionary allKeys][0];
//            self.label4.text = @"4";
//        }
//    }];
}

- (IBAction)logoutTapped:(id)sender {
    [self.ref unauth];
    [self performSegueWithIdentifier:@"LogoutSegue" sender:nil];
}

@end
