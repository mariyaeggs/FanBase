//
//  UserDetailsViewController.m
//  FirebaseGettingUserInfo
//
//  Created by Andy Novak on 3/29/16.
//  Copyright © 2016 Andy Novak. All rights reserved.
//

#import "FNBUserDetailsViewController.h"
//#import <AFNetworking/AFNetworking.h>
#import "FNBSpotifySearch.h"

@interface FNBUserDetailsViewController()
@property (weak, nonatomic) IBOutlet UILabel *label1;
@property (weak, nonatomic) IBOutlet UILabel *label2;
@property (weak, nonatomic) IBOutlet UILabel *label3;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *addArtistButton;
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;

@property (weak, nonatomic) IBOutlet UIButton *deleteArtistButton;
@property (weak, nonatomic) IBOutlet UITextField *addArtistField;

@end


@implementation FNBUserDetailsViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.label1.text = @"1";
    self.label2.text = @"2";
    self.label3.text = @"3";
    
    
}

- (void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    // initialize user for this ViewController
    // If the user is a guest, it will have these properties
    self.currentUser = [[FNBUser alloc] init];
    
    
    // check if user is Guest or Authentic User
    [FNBFirebaseClient checkIfUserIsAuthenticatedWithCompletionBlock:^(BOOL isAuthenticUser) {
        if (isAuthenticUser) {
            NSLog(@"you are an auth user");
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
        else {
            NSLog(@"GUEST");
            self.titleLabel.text = @"YOU ARE A GUEST";
            self.addArtistButton.enabled = NO;
            self.deleteArtistButton.enabled = NO;
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
        FNBArtist *newArtist = [[FNBArtist alloc] initWithName:self.addArtistField.text];
        [FNBFirebaseClient deleteCurrentUser:self.currentUser andArtistFromEachOthersDatabases:newArtist];
    }
}
- (IBAction)getAdeleFNBArtist:(id)sender {
    // initialize a FNBArtist
    FNBArtist *adele = [[FNBArtist alloc] initWithName:@"Adele"];
    // set the FNBArtist's properties
    [FNBFirebaseClient setPropertiesOfArtist:adele withCompletionBlock:^(BOOL setPropertiesUpdated) {
        //this will run every time the database is changed
        if (setPropertiesUpdated) {
            NSLog(@"Adele Subscribers: %@", adele.subscribedUsers);
        }
    }];
}

- (IBAction)checkIfArtistIsInSpotifyTapped:(id)sender {
    NSString *inputtedArtistName = self.addArtistField.text;
    
    [FNBSpotifySearch getArrayOfMatchingArtistsFromSearch:inputtedArtistName withCompletionBlock:^(BOOL gotMatchingArtists, NSArray *matchingArtistsArray) {
        if (gotMatchingArtists) {
            // make an alert
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Select Artist" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            
            // if there are matching Artists
            if (matchingArtistsArray.count > 0) {
                // add every matched artist to alert
                for (NSDictionary *artist in matchingArtistsArray) {
                    UIAlertAction *artistButton = [UIAlertAction actionWithTitle:artist[@"name"] style:UIAlertActionStyleDefault
                                                                         handler:^(UIAlertAction * action) {
                                                                             [self addArtist:artist];
                                                                         }];
                    [alert addAction:artistButton];
                }
                UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive
                                                               handler:^(UIAlertAction * action) {}];
                [alert addAction:cancel];
            }
            // if matchingArtistsArray has no entries
            else {
                UIAlertAction *noMatchingArtistsButton = [UIAlertAction actionWithTitle:@"No Matching Artists Found" style:UIAlertActionStyleDestructive
                                                               handler:^(UIAlertAction * action) {}];
                [alert addAction:noMatchingArtistsButton];
            }
            
            [self presentViewController:alert animated:YES completion:nil];
            return;
        }
        else {
            NSLog(@"got nothing");
            return;
        }
    }];
}

- (void) addArtist:(NSDictionary *)artist {
    NSLog(@"You selected %@", artist);
    FNBFirebaseClient addCurrentUser:self.currentUser andArtistToEachOthersDatabases:<#(FNBArtist *)#>
    
//    [FNBFirebaseClient checkExistanceOfDatabaseEntryForArtistName:artist[@"name"] withCompletionBlock:^(BOOL artistDatabaseExists) {
//        if (artistDatabaseExists) {
//            NSLog(@"Artist Database already exists");
//        }
//        else {
//            [FNBFirebaseClient makeDatabaseEntryForArtistFromSpotifyDictionary:artist];
//        }
//    }];
}

@end
