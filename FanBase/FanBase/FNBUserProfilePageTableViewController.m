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
#import "FNBArtistEvent.h"
#import "FanBase-Bridging-Header.h"

#import "FNBArtistMainPageTableViewController.h"
#import "FNBBandsInTownAPIClient.h"
#import "FNBSeeAllNearbyEventsTableViewController.h"
#import "FNBEventInfoVC.h"
#import "FNBColorConstants.h"

@interface FNBUserProfilePageTableViewController () <SideBarDelegate>

@property (strong, nonatomic) FNBUser *currentUser;

@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *blurredUserImageView;

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

@property (weak, nonatomic) IBOutlet UIImageView *concert1Image;
@property (weak, nonatomic) IBOutlet UILabel *concert1TitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *concert1Date;

@property (weak, nonatomic) IBOutlet UIImageView *concert2Image;
@property (weak, nonatomic) IBOutlet UILabel *concert2TitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *concert2Date;

@property (weak, nonatomic) IBOutlet UIImageView *concert3Image;
@property (weak, nonatomic) IBOutlet UILabel *concert3TitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *concert3Date;

@property (weak, nonatomic) IBOutlet UIImageView *concert4Image;
@property (weak, nonatomic) IBOutlet UILabel *concert4TitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *concert4Date;

@property (weak, nonatomic) IBOutlet UITableViewCell *concert1TableViewCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *concert2TableViewCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *concert3TableViewCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *concert4TableViewCell;

@property (strong, nonatomic) NSArray *arrayOfArtistLabels;
@property (strong, nonatomic) NSArray *arrayOfArtistImageViews;
@property (strong, nonatomic) NSArray *arrayOfArtistRankingLabels;

@property (strong, nonatomic) NSArray *arrayOfConcertTitles;
@property (strong, nonatomic) NSArray *arrayOfConcertDates;
@property (strong, nonatomic) NSArray *arrayOfConcertImages;

@property (strong, nonatomic) NSArray *sortedArrayOfUsersConcerts;

@property (strong, nonatomic) Firebase *userRef;

@property (nonatomic, strong) SideBar *sideBar;

@property (strong, nonatomic) NSString *selectedArtistSpotifyIDToSendToNextVC;
@end

@implementation FNBUserProfilePageTableViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    

    //Gradient
    self.view.tintColor = FNBOffWhiteColor;
    UIColor *gradientMaskLayer = FNBLightGreenColor;
    CAGradientLayer *gradientMask = [CAGradientLayer layer];
    gradientMask.frame = self.view.bounds;
    gradientMask.colors = @[(id)gradientMaskLayer.CGColor,(id)[UIColor clearColor].CGColor];
    
    [self.view.layer insertSublayer:gradientMask atIndex:0];
    
    // Call the sidebar menu function

//    //Initializes hamburger bar menu button
//    UIBarButtonItem *hamburgerButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu"] style:UIBarButtonSystemItemDone target:self action:@selector(hamburgerButtonTapped:)];
//    hamburgerButton.tintColor = [UIColor blackColor];
//    self.navigationItem.rightBarButtonItem = hamburgerButton;
//
//    
//    // Initialize side bar
//    self.sideBar = [[SideBar alloc] initWithSourceView:self.view sideBarItems:@[@"Profile", @"Discover", @"Events"]];
//    self.sideBar.delegate = self;


    // create the artistLabels and artistImageViews of the cells

    self.arrayOfArtistLabels = @[self.artist1NameLabel, self.artist2NameLabel, self.artist3NameLabel, self.artist4NameLabel];
    self.arrayOfArtistImageViews = @[self.artist1ImageView, self.artist2ImageView, self.artist3ImageView, self.artist4ImageView];
    self.arrayOfArtistRankingLabels = @[self.artist1XOfTotalFans, self.artist2XOfTotalFans, self.artist3XOfTotalFans, self.artist4XOfTotalFans];

    // create the concert arrays
    self.arrayOfConcertTitles = @[self.concert1TitleLabel, self.concert2TitleLabel, self.concert3TitleLabel, self.concert4TitleLabel];
    self.arrayOfConcertDates = @[self.concert1Date, self.concert2Date, self.concert3Date, self.concert4Date];
    self.arrayOfConcertImages = @[self.concert1Image, self.concert2Image, self.concert3Image, self.concert4Image];
    
    
    // make user image circular
    self.userImageView.layer.cornerRadius = self.userImageView.frame.size.height / 2;
    self.userImageView.layer.masksToBounds = YES;
    // make artist images circular
    for (UIImageView *artistImage in self.arrayOfArtistImageViews) {
        artistImage.layer.cornerRadius = artistImage.frame.size.height / 2;
        artistImage.layer.masksToBounds = YES;
    }
    // make concert images circular
    for (UIImageView *concertImage in self.arrayOfConcertImages) {
        concertImage.layer.cornerRadius = concertImage.frame.size.height / 2;
        concertImage.layer.masksToBounds = YES;
    }
}

//// If bar menu is tapped
//-(void)hamburgerButtonTapped:(id)sender {
//    
//    if (self.sideBar.isSideBarOpen) {
//        [self.sideBar showSideBarMenu:NO];
//    } else {
//        [self.sideBar showSideBarMenu:YES];
//    }
//    
//}
//// Side bar delegate method implementation
//-(void)didSelectButtonAtIndex:(NSInteger)index {
//    
//    NSLog(@"%ld", (long)index);
//    
//    if ((long)index == 0) {
//        FNBUserProfilePageTableViewController *userProfileVC = [[UIStoryboard storyboardWithName:@"Firebase" bundle:nil] instantiateViewControllerWithIdentifier:@"UserPageID"];
//        // Push eventInfoVC in my window
//        [self.navigationController pushViewController:userProfileVC animated:YES];
//    } else if ((long)index == 1) {
//        FNBUserProfilePageTableViewController *discoverPageVC = [[UIStoryboard storyboardWithName:@"Discover2" bundle:nil]instantiateViewControllerWithIdentifier:@"DiscoverPageID"];
//        // Push eventInfoVC in my window
//        [self.navigationController pushViewController:discoverPageVC animated:YES];
//    } else if ((long)index == 2) {
//        FNBUserProfilePageTableViewController *eventsVC = [[UIStoryboard storyboardWithName:@"FNBArtistNews" bundle:nil]instantiateViewControllerWithIdentifier:@"eventInfo"];
//        // Push eventInfoVC in my window
//        [self.navigationController pushViewController:eventsVC animated:YES];
//        
//    }
//}




-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

    // check if user is logged in or guest
    [FNBFirebaseClient checkOnceIfUserIsAuthenticatedWithCompletionBlock:^(BOOL isAuthenticUser) {
        if (isAuthenticUser) {
            // set user info, and then get a detailed array of the artists the user is subscribed to
            
            self.currentUser = [[FNBUser alloc] init];
            [FNBFirebaseClient setPropertiesOfLoggedInUserToUser:self.currentUser withCompletionBlock:^(BOOL completedSettingUsersProperties) {
                if (completedSettingUsersProperties) {
                    [self getConcerts];
                    [self addListenersForLoggedInUser];
                    [self updateUserPicNameAndNumberOfArtists];
//                    [self.tableView reloadData];
                }
            }];
            
        }
        
        else {
            NSLog(@"This is a guest in the User Profile Page");
        }
    }];
}

// sets height of each section header
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0 || section == 1) {
        // cannot be 0 for some reason
        return 0.1;
    }
    return 15;
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
//    [FNBFirebaseClient logoutUser];
    
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
    [self.blurredUserImageView setImageWithURL:[NSURL URLWithString:self.currentUser.profileImageURL]];
    self.numberOfSubscribedArtistsLabel.text = [NSString stringWithFormat: @"Number of Artists: %lu", self.currentUser.artistsDictionary.count];
    [self.tableView reloadData];
    [self.view bringSubviewToFront:self.sideBar.sideBarContainerView];


}

- (void) updateUI {
    [self updateUserPicNameAndNumberOfArtists];
    [self setLabelsAndImagesOfArtistCells:self.currentUser.rankingAndImagesForEachArtist];

    self.tableView.tableFooterView = [UIView new];
    [self.tableView reloadData];
    [self.view bringSubviewToFront:self.sideBar.sideBarContainerView];

}

- (void) getConcerts {
    [FNBBandsInTownAPIClient getUpcomingConcertsOfUser:self.currentUser withCompletion:^(NSArray *sortedConcertsArray) {
        if (sortedConcertsArray.count > 0) {
            self.sortedArrayOfUsersConcerts = sortedConcertsArray;
            [self setLabelsAndImagesOfConcertCells:sortedConcertsArray];

        }
    }];
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
    [self.tableView reloadData];
    [self.view bringSubviewToFront:self.sideBar.sideBarContainerView];


}


- (void)setLabelsAndImagesOfConcertCells:(NSArray *)concertArray {
    NSUInteger numberOfConcerts = concertArray.count;
    if (numberOfConcerts == 0) {
        NSLog(@"there are no events for your subscribed artists");
    }
    // number of events to less than or equal number of artists than there are labels
    else if (numberOfConcerts <= self.arrayOfConcertTitles.count) {
        for (NSInteger i = 0; i < numberOfConcerts; i++) {
            ((UILabel *)self.arrayOfConcertTitles[i]).text = ((FNBArtistEvent *)concertArray[i]).eventTitle;
            [((UIImageView *)self.arrayOfConcertImages[i]) setImageWithURL:[NSURL URLWithString:((FNBArtistEvent *)concertArray[i]).artistImageURL]];
            ((UILabel *)self.arrayOfConcertDates[i]).text = ((FNBArtistEvent *)concertArray[i]).dateOfConcert;
        }
    }
    // number of events is more than there are labels
    else {
        for (NSInteger i = 0; i < self.arrayOfConcertTitles.count; i++) {
            ((UILabel *)self.arrayOfConcertTitles[i]).text = ((FNBArtistEvent *)concertArray[i]).eventTitle;
            [((UIImageView *)self.arrayOfConcertImages[i]) setImageWithURL:[NSURL URLWithString:((FNBArtistEvent *)concertArray[i]).artistImageURL]];
            ((UILabel *)self.arrayOfConcertDates[i]).text = ((FNBArtistEvent *)concertArray[i]).dateOfConcert;
        }
    }
    [self.tableView reloadData];
    [self.view bringSubviewToFront:self.sideBar.sideBarContainerView];


}

// makes height 0 of empty cells
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    
    // Subscribed Artist Section
    if(cell == self.artist1TableViewCell && self.currentUser.detailedArtistInfoArray.count < 1)
        return 0; //set the hidden cell's height to 0
    if(cell == self.artist2TableViewCell && self.currentUser.detailedArtistInfoArray.count < 2)
        return 0; //set the hidden cell's height to 0
    if(cell == self.artist3TableViewCell && self.currentUser.detailedArtistInfoArray.count < 3)
        return 0; //set the hidden cell's height to 0
    if(cell == self.artist4TableViewCell && self.currentUser.detailedArtistInfoArray.count < 4)
        return 0; //set the hidden cell's height to 0
    
    // Upcoming Concerts Section
    if(cell == self.concert1TableViewCell && self.sortedArrayOfUsersConcerts.count < 1)
        return 0; //set the hidden cell's height to 0
    if(cell == self.concert2TableViewCell && self.sortedArrayOfUsersConcerts.count < 2)
        return 0; //set the hidden cell's height to 0
    if(cell == self.concert3TableViewCell && self.sortedArrayOfUsersConcerts.count < 3)
        return 0; //set the hidden cell's height to 0
    if(cell == self.concert4TableViewCell && self.sortedArrayOfUsersConcerts.count < 4)
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

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 3 && indexPath.row < self.arrayOfConcertTitles.count) {
        FNBArtistEvent *selectedEvent = self.sortedArrayOfUsersConcerts[indexPath.row];
        
        
        // Create an instance of FNBEventInfoVC (view controller)
        // Use UIStoryboard class/type to create the instance
        FNBEventInfoVC *eventInfoVC = [[UIStoryboard storyboardWithName:@"FNBArtistNews" bundle:nil] instantiateViewControllerWithIdentifier:@"eventInfo"];
        
        // Assign event value to property on eventInfoVC
        eventInfoVC.event = selectedEvent;
        
        // Push eventInfoVC in my window
        [self.navigationController pushViewController:eventInfoVC animated:YES];
        
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
    
    if ([segue.identifier isEqualToString:@"SeeAllConcertsSegue"]) {
        FNBSeeAllNearbyEventsTableViewController *nextVC = segue.destinationViewController;
        nextVC.receivedConcertsArray = self.sortedArrayOfUsersConcerts;
    }
    
}
@end
