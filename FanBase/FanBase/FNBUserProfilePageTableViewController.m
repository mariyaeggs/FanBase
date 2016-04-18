//
//  FNBUserProfilePageTableViewController.m
//  FanBase
//
//  Created by Andy Novak on 4/5/16.
//  Copyright © 2016 Angelica Bato. All rights reserved.
//

#import "FNBUserProfilePageTableViewController.h"
#import "FNBFirebaseClient.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <QuartzCore/QuartzCore.h>
#import "FanBase-Swift.h"
#import "FanBase-Bridging-Header.h"
//#import "FanBase-Swift.h"

//this is to segue to the ArtistTop10
//#import "FNBArtistTop10TableViewController.h"
// this is to segue to the ArtistMainPage
#import "FNBArtistMainPageTableViewController.h"


@interface FNBUserProfilePageTableViewController () <SideBarDelegate>

@property (strong, nonatomic) FNBUser *currentUser;

@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *numberOfSubscribedArtistsLabel;
@property (weak, nonatomic) IBOutlet UILabel *artistXOfTotalLabel;

@property (weak, nonatomic) IBOutlet UIImageView *artist1ImageView;
@property (weak, nonatomic) IBOutlet UILabel *artist1NameLabel;
@property (weak, nonatomic) IBOutlet UILabel *artist1XOfTotalFans;

@property (weak, nonatomic) IBOutlet UIImageView *artist2ImageView;
@property (weak, nonatomic) IBOutlet UILabel *artist2NameLabel;
@property (weak, nonatomic) IBOutlet UILabel *artist2XOfTotalFans;

@property (weak, nonatomic) IBOutlet UIImageView *artist3ImageView;
@property (weak, nonatomic) IBOutlet UILabel *artist3NameLabel;
@property (weak, nonatomic) IBOutlet UILabel *artist3XOfTotalFans;

@property (weak, nonatomic) IBOutlet UIImageView *artist4ImageView;
@property (weak, nonatomic) IBOutlet UILabel *artist4NameLabel;
@property (weak, nonatomic) IBOutlet UILabel *artist4XOfTotalFans;

@property (weak, nonatomic) IBOutlet UITableViewCell *artist1TableViewCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *artist2TableViewCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *artist3TableViewCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *artist4TableViewCell;

@property (strong, nonatomic) NSArray *arrayOfArtistLabels;
@property (strong, nonatomic) NSArray *arrayOfArtistImageViews;
@property (strong, nonatomic) NSArray *arrayOfArtistRankingLabels;

@property (strong, nonatomic) Firebase *userRef;
@property (nonatomic, strong) SideBar *sideBar;

@property (strong, nonatomic) NSString *selectedArtistSpotifyIDToSendToNextVC;
@end

@implementation FNBUserProfilePageTableViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Call the sidebar menu function
    
    // Initialize side bar 
    self.sideBar = [[SideBar alloc] initWithSourceView:self.view sideBarItems:@[@"Profile", @"Discover", @"Events"]];
    self.sideBar.delegate = self;

    // set the artistLabels and artistImageViews of the cells
    self.arrayOfArtistLabels = @[self.artist1NameLabel, self.artist2NameLabel, self.artist3NameLabel, self.artist4NameLabel];
    self.arrayOfArtistImageViews = @[self.artist1ImageView, self.artist2ImageView, self.artist3ImageView, self.artist4ImageView];
    self.arrayOfArtistRankingLabels = @[self.artist1XOfTotalFans, self.artist2XOfTotalFans, self.artist3XOfTotalFans, self.artist4XOfTotalFans];
    
    // make user image circular
    self.userImageView.layer.cornerRadius = self.userImageView.frame.size.height / 2;
    self.userImageView.layer.masksToBounds = YES;
    // make artist images circular
    for (UIImageView *artistImage in self.arrayOfArtistImageViews) {
        artistImage.layer.cornerRadius = artistImage.frame.size.height / 2;
        artistImage.layer.masksToBounds = YES;
    }
}

// Side bar delegate method implementation
-(void)didSelectButtonAtIndex:(NSInteger)index {
    

}


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

    // check if user is logged in or guest
    [FNBFirebaseClient checkOnceIfUserIsAuthenticatedWithCompletionBlock:^(BOOL isAuthenticUser) {
        if (isAuthenticUser) {
            // set user info, and then get a detailed array of the artists the user is subscribed to
            
            self.currentUser = [[FNBUser alloc] init];
            [FNBFirebaseClient setPropertiesOfLoggedInUserToUser:self.currentUser withCompletionBlock:^(BOOL completedSettingUsersProperties) {
                if (completedSettingUsersProperties) {
                    [self addListenersForLoggedInUser];
                    [self updateUserPicNameAndNumberOfArtists];
                    [self.tableView reloadData];

//                    [self updateUI];
                    // get an array of artists that the user is subscribed to filled with detailed info
//                    [FNBFirebaseClient getADetailedArtistArrayFromUserArtistDictionary:self.currentUser.artistsDictionary withCompletionBlock:^(BOOL gotDetailedArray, NSArray *arrayOfArtists) {
//                        if (gotDetailedArray) {
//                            self.currentUser.detailedArtistInfoArray = arrayOfArtists;
//                            
//                            // get users rankings for each of their subscribed artists
//                            self.currentUser.rankingAndImagesForEachArtist = [self.currentUser getArtistInfoForLabels];
//                            
//                            [self updateUI];
//                        }
//                    }];
                }
            }];
            
        }
        
        else {
            NSLog(@"This is a guest in the User Profile Page");
        }
    }];
}


// hide nav bar
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

// show nav bar before leaving page
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
//    [self.navigationController setNavigationBarHidden:NO];

//    [self.userRef removeAllObservers];
}

- (void) addListenersForLoggedInUser {
    // start listening to changes in the username, userProfileImage, or artistDictionary
    
    NSString *urlOfUser= [NSString stringWithFormat:@"%@/users/%@", ourFirebaseURL, self.currentUser.userID];
    NSLog(@"url of user: %@", urlOfUser);
    self.userRef = [[Firebase alloc] initWithUrl:urlOfUser];
    [self.userRef observeEventType:FEventTypeChildChanged withBlock:^(FDataSnapshot *snapshot) {
        NSLog(@"user changed. from the userprofilepage");
//        NSLog(@"USER CHANGED. this is the new value from FNBUserProfilePageTableViewController: %@, and this is the key: %@", snapshot.value, snapshot.key);
        // change in username
        if ([snapshot.key isEqualToString:@"userName"]) {
            self.currentUser.userName = snapshot.value;
            [self updateUI];
        }
        // change in the profileImageURL
        else if ([snapshot.key isEqualToString:@"profileImageURL"]){
            self.currentUser.profileImageURL = snapshot.value;
            [self updateUI];
        }
        // change in the artistDictionary
        else if ([snapshot.key isEqualToString:@"artistsDictionary"]){
            self.currentUser.artistsDictionary = snapshot.value;
            [FNBFirebaseClient getADetailedArtistArrayFromUserArtistDictionary:self.currentUser.artistsDictionary withCompletionBlock:^(BOOL gotDetailedArray, NSArray *arrayOfArtists) {
                if (gotDetailedArray) {
                    self.currentUser.detailedArtistInfoArray = arrayOfArtists;
                    
                    // get users rankings for each of their subscribed artists
                    self.currentUser.rankingAndImagesForEachArtist = [self.currentUser getArtistInfoForLabels];
                    
                    [self updateUI];
                }
            }];
        }
        
    }];
    
    // listen to child node if last artist deleted, or first artist added
    [self.userRef observeEventType:FEventTypeChildRemoved withBlock:^(FDataSnapshot *snapshot) {
        // change in the artistDictionary
        if ([snapshot.key isEqualToString:@"artistsDictionary"]){
            NSLog(@"last artist deleted from user");
            self.currentUser.artistsDictionary = [NSMutableDictionary new];
            self.currentUser.detailedArtistInfoArray = @[];
            
            // there are no users rankings for each of their subscribed artists because last one is deleted
            self.currentUser.rankingAndImagesForEachArtist = @[];
            [self updateUI];
        }
        
    }];
    [self.userRef observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
        // change in the artistDictionary
        if ([snapshot.key isEqualToString:@"artistsDictionary"]){
            self.currentUser.artistsDictionary = snapshot.value;
            [FNBFirebaseClient getADetailedArtistArrayFromUserArtistDictionary:self.currentUser.artistsDictionary withCompletionBlock:^(BOOL gotDetailedArray, NSArray *arrayOfArtists) {
                if (gotDetailedArray) {
                    self.currentUser.detailedArtistInfoArray = arrayOfArtists;
                    
                    // get users rankings for each of their subscribed artists
                    self.currentUser.rankingAndImagesForEachArtist = [self.currentUser getArtistInfoForLabels];
                    
                    [self updateUI];
                }
            }];
        }
        
    }];
}
- (IBAction)logoutTapped:(id)sender {
    [FNBFirebaseClient logoutUser];
    // TODO: This does not bring up the login VC. IDK why. IT broadcasts successfully
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UserDidLogOutNotification" object:nil];
}

- (IBAction)userNameDoubleTapped:(id)sender {
    // pull up an alert to change userName
    UIAlertController *changeNameAlert = [UIAlertController alertControllerWithTitle:@"Change Username" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [changeNameAlert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = NSLocalizedString(@"Username Placeholder", @"Username");
        [textField addTarget:self action:@selector(alertTextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    }];
    UIAlertAction *submitAction = [UIAlertAction actionWithTitle:@"Submit" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *username = changeNameAlert.textFields.firstObject;
//        NSLog(@"this is the username: %@", username.text);
        // change the userName in the Database
        [FNBFirebaseClient changeUserNameOfUser:self.currentUser toName:username.text withCompletionBlock:^(BOOL completedChangingUserName) {
            if (completedChangingUserName) {
                [self updateUI];
            }
        }];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [changeNameAlert addAction:submitAction];
    [changeNameAlert addAction:cancel];
    submitAction.enabled = NO;
    [self presentViewController:changeNameAlert animated:YES completion:nil];
    
}
// makes Submit button disabled unless there is text in the textField
- (void) alertTextFieldDidChange:(UITextField *)sender {
    UIAlertController *alertController = (UIAlertController *)self.presentedViewController;
    if (alertController) {
        UITextField *userName = alertController.textFields.firstObject;
        UIAlertAction *submitAction = alertController.actions.firstObject;
        submitAction.enabled = userName.text.length > 0;
    }
}
- (IBAction)profilePictureDoubleTapped:(id)sender {
    // pull up an alert to change profilePic
    UIAlertController *changeProfilePictureAlert = [UIAlertController alertControllerWithTitle:@"Change Profile Picture" message:@"Enter URL:" preferredStyle:UIAlertControllerStyleAlert];
    [changeProfilePictureAlert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = NSLocalizedString(@"Image URL Placeholder", @"Image URL (make sure its https");
        [textField addTarget:self action:@selector(alertTextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    }];
    UIAlertAction *submitAction = [UIAlertAction actionWithTitle:@"Submit" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *imageURLTextField = changeProfilePictureAlert.textFields.firstObject;

        // change the profilePicURL in the Database
        [FNBFirebaseClient changeProfilePictureURLOfUser:self.currentUser toURL:imageURLTextField.text withCompletionBlock:^(BOOL completedChangingProfilePicURL) {
            if (completedChangingProfilePicURL) {
                [self updateUI];
            }
        }];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [changeProfilePictureAlert addAction:submitAction];
    [changeProfilePictureAlert addAction:cancel];
    submitAction.enabled = NO;
    [self presentViewController:changeProfilePictureAlert animated:YES completion:nil];
}

-(void) updateUserPicNameAndNumberOfArtists {
    self.userNameLabel.text = self.currentUser.userName;
    [self.userImageView setImageWithURL:[NSURL URLWithString:self.currentUser.profileImageURL]];
    self.numberOfSubscribedArtistsLabel.text = [NSString stringWithFormat: @"Number of Artists: %lu", self.currentUser.artistsDictionary.count];
}

- (void) updateUI {
    [self updateUserPicNameAndNumberOfArtists];
    [self setLabelsAndImagesOfArtistCells:self.currentUser.rankingAndImagesForEachArtist];

    self.tableView.tableFooterView = [UIView new];
    [self.tableView reloadData];
}


- (void)setLabelsAndImagesOfArtistCells:(NSArray *)artistInfoArray {
    NSUInteger numberOfArtists = artistInfoArray.count;
    if (numberOfArtists == 0) {
        NSLog(@"there are no artists for this user according to the detailedArtistArray");
    }
    // user is subscribed to less than or equal number of artists than there are labels
    else if (numberOfArtists <= self.arrayOfArtistLabels.count) {
        for (NSInteger i = 0; i < numberOfArtists; i++) {
            ((UILabel *)self.arrayOfArtistLabels[i]).text = artistInfoArray[i][@"artistName"];
            [((UIImageView *)self.arrayOfArtistImageViews[i]) setImageWithURL:[NSURL URLWithString:artistInfoArray[i][@"artistImageURL"]]];
            ((UILabel *)self.arrayOfArtistRankingLabels[i]).text = [NSString stringWithFormat:@"#%@ of %@", artistInfoArray[i][@"usersRank"], artistInfoArray[i][@"numberOfFollowers" ]];
        }
    }
    // user is subscribed to more artists than there are labels
    else {
        for (NSInteger i = 0; i < self.arrayOfArtistLabels.count; i++) {
            ((UILabel *)self.arrayOfArtistLabels[i]).text = artistInfoArray[i][@"artistName"];
            [((UIImageView *)self.arrayOfArtistImageViews[i]) setImageWithURL:[NSURL URLWithString:artistInfoArray[i][@"artistImageURL"]]];
            ((UILabel *)self.arrayOfArtistRankingLabels[i]).text = [NSString stringWithFormat:@"#%@ of %@", artistInfoArray[i][@"usersRank"], artistInfoArray[i][@"numberOfFollowers" ]];
        }
    }
}




// makes height 0 of empty cells
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    if(cell == self.artist1TableViewCell && self.currentUser.detailedArtistInfoArray.count < 1)
        return 0; //set the hidden cell's height to 0
    if(cell == self.artist2TableViewCell && self.currentUser.detailedArtistInfoArray.count < 2)
        return 0; //set the hidden cell's height to 0
    if(cell == self.artist3TableViewCell && self.currentUser.detailedArtistInfoArray.count < 3)
        return 0; //set the hidden cell's height to 0
    if(cell == self.artist4TableViewCell && self.currentUser.detailedArtistInfoArray.count < 4)
        return 0; //set the hidden cell's height to 0
    
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

// Below two methods adds swipe left to show a delete option
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 2 && indexPath.row < 4) {
        return YES;
    }
    return NO;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // when you hit delete
        NSString *selectedArtistName = self.currentUser.rankingAndImagesForEachArtist[indexPath.row][@"artistName"];
        
        // delete appropriate things from database
        [FNBFirebaseClient deleteCurrentUser:self.currentUser andArtistFromEachOthersDatabases:selectedArtistName withCompletionBlock:^(BOOL deletedArtistAndUserCompleted) {
            if (deletedArtistAndUserCompleted) {
                NSLog(@"you deleted %@", selectedArtistName);
            }
        }];
    }
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
    if(selectedIndexPath.section == 2 && selectedIndexPath.row < self.arrayOfArtistLabels.count) {
        NSString *selectedArist = self.currentUser.rankingAndImagesForEachArtist[selectedIndexPath.row][@"artistName"];
        NSString *selectedArtistSpotifyID = self.currentUser.rankingAndImagesForEachArtist[selectedIndexPath.row][@"artistSpotifyID"];
        NSLog(@"this is the selected artist: %@ and this is their Spotify ID: %@", selectedArist, selectedArtistSpotifyID);

        if (![segue.identifier isEqualToString:@"seeAllSegue"]) {
            FNBArtistMainPageTableViewController *nextVC = [segue destinationViewController];
            nextVC.receivedArtistName = selectedArist;
        }
        
        
        
    }
//    // if any other segue other than from the "See All" button
//    if (![segue.identifier isEqualToString:@"seeAllSegue"]) {
//        FNBArtistTop10TableViewController *nextVC = segue.destinationViewController;
//        nextVC.recievedArtistSpotifyID = selectedArtistSpotifyID;
//    }
}
@end
