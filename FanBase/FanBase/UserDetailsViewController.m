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
@property (weak, nonatomic) IBOutlet UITextField *addArtistField;

@end


@implementation UserDetailsViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.label1.text = @"1";
    self.label2.text = @"2";
    self.label3.text = @"3";
    self.label4.text = @"4";
    
}

- (void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    //initialize user for this ViewController
    self.currentUser = [[FNBUser alloc] init];
    
    //Set the properties of this user
    [FNBFirebaseClient setPropertiesOfLoggedInUserToUser:self.currentUser withCompletionBlock:^(BOOL updateHappened) {
        if (updateHappened) {
            self.label1.text = self.currentUser.email;
            self.label2.text = self.currentUser.userID;
            
            // get all artists in the artistsDictionary
            NSMutableString *allArtistsString = [NSMutableString new];
            for (NSString *artist in [self.currentUser.artistsDictionary allKeys]) {
                [allArtistsString appendString:artist];
            }
            self.label3.text = allArtistsString;
        }
    }];
}

- (IBAction)logoutTapped:(id)sender {
    [FNBFirebaseClient logoutUser];
    [self performSegueWithIdentifier:@"LogoutSegue" sender:nil];
}

- (IBAction)addArtistTapped:(id)sender {
    // if there is text
    if (self.addArtistField.text.length > 0) {
        //create instance of FNBArtist with that name
        //eventually with other stuff too
        FNBArtist *newArtist = [[FNBArtist alloc] initWithName:self.addArtistField.text];
        
        [FNBFirebaseClient addCurrentUser:self.currentUser andArtistToEachOthersDatabases:newArtist];
    }
}
- (IBAction)deleteArtistTapped:(id)sender {
    if (self.addArtistField.text.length > 0) {
        //create instance of FNBArtist with that name
        //eventually with other stuff too
        FNBArtist *newArtist = [[FNBArtist alloc] initWithName:self.addArtistField.text];
//        [FNBFirebaseClient deleteArtist:newArtist FromUser:self.currentUser];
//        [FNBFirebaseClient deleteUser:self.currentUser FromArtist:newArtist];
        [FNBFirebaseClient deleteCurrentUser:self.currentUser andArtistFromEachOthersDatabases:newArtist];
    }
}

@end
