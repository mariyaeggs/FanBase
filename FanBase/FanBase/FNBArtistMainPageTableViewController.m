//
//  ArtistMainPageTableViewController.m
//  FanBase
//
//  Created by Andy Novak on 4/7/16.
//  Copyright © 2016 Angelica Bato. All rights reserved.
//

#import "FNBArtistMainPageTableViewController.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "FNBTwitterAPIClient.h"
#import "FNBColorConstants.h"
//this is to segue to the ArtistTop10
#import "FNBArtistTop10TableViewController.h"
#import "FNBBandsInTownAPIClient.h"
#import "FNBArtistEvent.h"
#import "FNBEventInfoVC.h"
//this is to segue to the fanFeedVC
#import "FNBFanFeedViewController.h"
//this is to segue to the fanFeedVC
#import "FNBSeeMoreTweetsTableViewController.h"
#import "FNBArtistNewsTableViewController.h"

//Side bar menu import files
#import "FanBase-Bridging-Header.h"
#import "FanBase-Swift.h"

@interface FNBArtistMainPageTableViewController ()

@property (strong, nonatomic) FNBArtist *currentArtist;
@property (strong, nonatomic) FNBUser  *currentUser;
@property (nonatomic) BOOL isUserLoggedIn;
@property (nonatomic) BOOL isUserSubscribedToArtist;

@property (strong, nonatomic) Firebase *artistRef;
@property (strong, nonatomic) NSArray *artistEvents;



// artist Top info
@property (weak, nonatomic) IBOutlet UIImageView *artistImageView;
@property (weak, nonatomic) IBOutlet UILabel *artistNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *blurredArtistImageView;

// users info
@property (weak, nonatomic) IBOutlet UILabel *youSubscribedLabel;
@property (weak, nonatomic) IBOutlet UIButton *clickToAddArtistButton;
@property (weak, nonatomic) IBOutlet UILabel *numberOfSubscribedUsersLabel;
@property (strong, nonatomic) IBOutlet UIButton *chatButton;

// tweet section
@property (strong, nonatomic) NSArray *arrayOfTweetContentLabels;
@property (strong, nonatomic) NSArray *arrayOfTweetDateLabels;
@property (weak, nonatomic) IBOutlet UITextView *tweet1ContentTextView;
@property (weak, nonatomic) IBOutlet UILabel *tweet1DateLabel;
@property (weak, nonatomic) IBOutlet UITextView *tweet2ContentTextView;
@property (weak, nonatomic) IBOutlet UILabel *tweet2DateLabel;
@property (weak, nonatomic) IBOutlet UITextView *tweet3ContentTextView;
@property (weak, nonatomic) IBOutlet UILabel *tweet3DateLabel;

// tweets continued
@property (weak, nonatomic) IBOutlet UITableViewCell *twitterFirstViewCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *twitterSecondViewCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *twitterThirdViewCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *twitterFourthViewCell;


// upcoming events section
@property (strong,nonatomic) NSArray *arrayOfEventImageViews;
@property (weak, nonatomic) IBOutlet UIImageView *eventImageView1;
@property (weak, nonatomic) IBOutlet UILabel *eventLabel1;
@property (weak, nonatomic) IBOutlet UIImageView *eventImageView2;
@property (weak, nonatomic) IBOutlet UILabel *eventLabel2;
@property (weak, nonatomic) IBOutlet UIImageView *eventImageView3;
@property (weak, nonatomic) IBOutlet UILabel *eventLabel3;

@property (weak, nonatomic) IBOutlet UILabel *eventLabelDate1;
@property (weak, nonatomic) IBOutlet UILabel *eventLabelDate2;
@property (weak, nonatomic) IBOutlet UILabel *eventLabelDate3;
@property (strong,nonatomic) NSArray *events;


//Concert cells
@property (weak, nonatomic) IBOutlet UITableViewCell *upConcertsFirstCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *upConcertsSecondCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *upConcertsThirdCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *upConcertsFourthCell;


@end

@implementation FNBArtistMainPageTableViewController

static NSInteger const minimumArtistImageHeightForLabels = 200;


- (void)viewDidLoad {
    [super viewDidLoad];
    [self.chatButton setEnabled:NO];
    
    
    //Gradient
    self.tableView.tintColor = [UIColor colorWithRed:230.0/255.0 green:255.0/255.0 blue:247.0/255.0 alpha:1.0];
    UIColor *gradientMaskLayer = [UIColor colorWithRed:184.0/255.0 green:204.0/255.0 blue:198.0/255.0 alpha:1.0];
    CAGradientLayer *gradientMask = [CAGradientLayer layer];
    gradientMask.frame = self.tableView.bounds;
    gradientMask.colors = @[(id)gradientMaskLayer.CGColor,(id)[UIColor clearColor].CGColor];
    
    [self.tableView.layer insertSublayer:gradientMask atIndex:0];

    
    // load page assuming user is not logged in and not subscribed
    self.isUserSubscribedToArtist = NO;
    self.isUserLoggedIn = NO;
    
    // make FNBUser for this VC
    self.currentUser = [[FNBUser alloc] init];
    // check if user is Guest or Authentic User
    [FNBFirebaseClient checkOnceIfUserIsAuthenticatedWithCompletionBlock:^(BOOL isAuthenticUser) {
        if (isAuthenticUser) {
            NSLog(@"you are an auth user");
            //Initializes hamburger bar menu button
            UIBarButtonItem *hamburgerButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu"] style:UIBarButtonItemStyleDone target:self action:@selector(hamburgerButtonTapped:)];
            self.navigationItem.rightBarButtonItem = hamburgerButton;
            self.isUserLoggedIn = YES;
            //Set the properties of this user
            [FNBFirebaseClient setPropertiesOfLoggedInUserToUser:self.currentUser withCompletionBlock:^(BOOL updateHappened) {
                if (updateHappened) {
                    
                    //set the self.user userImage from the url
                    NSData *userProfileImageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.currentUser.profileImageURL]];
                    self.currentUser.userImage = [UIImage imageWithData:userProfileImageData];
                    
                    NSLog(@"Update happened to User");
                    // check if user is subscribed to artist
                    [self checkIfUser:self.currentUser isSubscribedToArtistName:self.receivedArtistName];
                    [self setUserLabels];
                }
            }];
            
        }
        else {
            NSLog(@"GUEST");
            self.isUserLoggedIn = NO;
        }
    }];
    
    if (self.isUserLoggedIn) {
        [self.chatButton setEnabled:YES];
    }

    
    // set the tweetsLabels
    self.arrayOfTweetContentLabels = @[self.tweet1ContentTextView, self.tweet2ContentTextView, self.tweet3ContentTextView];
    self.arrayOfTweetDateLabels = @[self.tweet1DateLabel, self.tweet2DateLabel, self.tweet3DateLabel];
    
    // make artist image circular
    self.artistImageView.layer.cornerRadius = self.artistImageView.frame.size.height /2 ,
    self.artistImageView.layer.masksToBounds = YES;
    
    // Set event images array
    self.arrayOfEventImageViews = @[self.eventImageView1, self.eventImageView2, self.eventImageView3];
    

    // create FNBArtist from receivedName
    self.currentArtist = [[FNBArtist alloc] initWithName:self.receivedArtistName];
    [FNBFirebaseClient setPropertiesOfArtist:self.currentArtist FromDatabaseWithCompletionBlock:^(BOOL setPropertiesCompleted) {
        if (setPropertiesCompleted) {
            // get smallest image that is minimum height
            NSMutableDictionary *selectedImage = [NSMutableDictionary new];
            for (NSDictionary *imageDescription in self.currentArtist.imagesArray) {
                if ([imageDescription[@"height"] integerValue] > minimumArtistImageHeightForLabels) {
                    selectedImage = [imageDescription mutableCopy];
                }
            }
            NSString *imageURL = selectedImage[@"url"];

            [self.artistImageView setImageWithURL:[NSURL URLWithString:imageURL]];
            [self.blurredArtistImageView setImageWithURL:[NSURL URLWithString:imageURL]];
            self.artistNameLabel.text = self.currentArtist.name;
            
            [FNBTwitterAPIClient generateTweetsForKeyword:self.currentArtist.name completion:^(NSArray *receivedTweetsArray) {
               self.currentArtist.tweetsArray = receivedTweetsArray;

                [self setTwitterCellsWithTweetsArray:self.currentArtist.tweetsArray];


               
            }];
            
            [FNBBandsInTownAPIClient generateEventsForArtist:self.currentArtist.name
                                                  completion:^(NSArray *events) {
                                                      
                                                      self.events = events;
                                                      
                                                      
                                                      [self.tableView reloadData];
//                                                      [self.view bringSubviewToFront:self.sideBar.sideBarContainerView];

                                                  }];
        }
    }];
    
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    // Make event images circular
    self.eventImageView1.layer.cornerRadius = self.eventImageView1.frame.size.width/2;
    self.eventImageView1.layer.masksToBounds = YES;
    
    self.eventImageView2.layer.cornerRadius = self.eventImageView2.frame.size.height/2,
    self.eventImageView2.layer.masksToBounds = YES;
    
    self.eventImageView3.layer.cornerRadius = self.eventImageView3.frame.size.height/2,
    self.eventImageView3.layer.masksToBounds = YES;
}

-(void)hamburgerButtonTapped:(id)sender {
    NSLog(@"Hamburger pressed and posting notification");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HamburgerButtonNotification" object:nil];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    // start listening to changes in the artist's database
    
    // first format the artistName to as it appears in our database
    NSString *formattedArtistName = [self formatedArtistName:self.currentArtist.name];

    NSString *urlOfArtist= [NSString stringWithFormat:@"%@/artists/%@", ourFirebaseURL, formattedArtistName];
    NSLog(@"url of artist: %@", urlOfArtist);

    self.artistRef = [[Firebase alloc] initWithUrl:urlOfArtist];
    [self.artistRef observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
//        NSLog(@"ARTIST CHANGED this is the new value for artist: %@, and this is the key: %@", snapshot.value, snapshot.key);
        [FNBFirebaseClient setPropertiesOfArtist:self.currentArtist FromDatabaseWithCompletionBlock:^(BOOL setPropertiesCompleted) {
            if (setPropertiesCompleted) {
                [self checkIfUser:self.currentUser isSubscribedToArtistName:self.receivedArtistName];
                [self setUserLabels];
            }
            else {
                NSLog(@"there was a problem in setting the currentArtist's properties once they changed");
            }
        }];
        
    }];
    
}
// stop listening to changes for the artist when view disappears
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.artistRef removeAllObservers];
}
- (void) checkIfUser:(FNBUser *)user isSubscribedToArtistName:(NSString *)receivedArtistName {
    // check if artist has user as a subscribed Users
    // start with no (if subscribed artists is nil)
    self.isUserSubscribedToArtist = NO;
    
    for (NSString *userID in self.currentArtist.subscribedUsers) {
        if ([userID isEqualToString:self.currentUser.userID]) {
            self.isUserSubscribedToArtist = YES;
            NSLog(@"User is subscribed to this artist");
            return;
        }
        else {
            NSLog(@"User is NOT subscribed to this artist");
            self.isUserSubscribedToArtist = NO;
        }
    }
}

- (NSString *) formatedArtistName: (NSString *)artistName {
    //get rid of .#$[] characters in artist's name
    NSCharacterSet *doNotWant = [NSCharacterSet characterSetWithCharactersInString:@".#$[]/"];
    NSLog(@"%@", [[artistName componentsSeparatedByCharactersInSet:doNotWant] componentsJoinedByString:@""]);
    return [[artistName componentsSeparatedByCharactersInSet:doNotWant] componentsJoinedByString:@""];
}

- (void) setUserLabels {
    // have the label say "person" instead of "people" if there is only 1 person
    if (self.currentArtist.subscribedUsers.count == 1) {
        self.numberOfSubscribedUsersLabel.text = [NSString stringWithFormat:@"%li Person Subscribed", self.currentArtist.subscribedUsers.count];
    }
    else {
        self.numberOfSubscribedUsersLabel.text = [NSString stringWithFormat:@"%li People Subscribed", self.currentArtist.subscribedUsers.count];
    }
    

    if (self.isUserLoggedIn) {
        // if user is subscribed
        if (self.isUserSubscribedToArtist) {
            self.youSubscribedLabel.text = @"You Are Subscribed";
            [self.clickToAddArtistButton setTitle:@"Click To Unsubscribe" forState:UIControlStateNormal];
            [self.clickToAddArtistButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            
        }

        // if user isn't subscribed
        else {
            self.youSubscribedLabel.text = @"You Are Not Subscribed";
            [self.clickToAddArtistButton setTitle:@"Click To Subscribe" forState:UIControlStateNormal];
            [self.clickToAddArtistButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        }
    }
    
    // if user is guest (not signed in)
    else {
        self.youSubscribedLabel.text = @"You Are Not Logged In";
        [self.clickToAddArtistButton setTitle:@"Click To Login" forState:UIControlStateNormal];
        [self.clickToAddArtistButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    }
    
}

// this method depends on the YouAreSubscribed label's text
- (IBAction)clickToAddTapped:(id)sender {
    if ([self.youSubscribedLabel.text isEqualToString:@"You Are Not Logged In"]) {
        NSLog(@"button tapped and you were not logged in");
//        [self performSegueWithIdentifier:@"goToLoginVCSegue" sender:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UserDidLogOutNotification" object:nil];
    }
    else if ([self.youSubscribedLabel.text isEqualToString:@"You Are Not Subscribed"]) {
//        NSLog(@"button tapped and you were not subscribed in");
        NSMutableDictionary *addArtistDictionary = [NSMutableDictionary new];
        // if there are no subscribedUsers yet, create an empty dictionary
        if (self.currentArtist.subscribedUsers) {
            addArtistDictionary = [@{ @"name" : self.currentArtist.name ,
                                                   @"spotifyID" : self.currentArtist.spotifyID,
                                                   @"subscribedUsers" : self.currentArtist.subscribedUsers ,
                                                   @"images" : self.currentArtist.imagesArray,
                                                   @"genres" : self.currentArtist.genres
                                                   } mutableCopy];

        }
        else {
            addArtistDictionary = [@{ @"name" : self.currentArtist.name ,
                                      @"spotifyID" : self.currentArtist.spotifyID,
                                      @"subscribedUsers" : [NSMutableDictionary new],
                                      @"images" : self.currentArtist.imagesArray,
                                      @"genres" : self.currentArtist.genres
                                      } mutableCopy];
        }

        
        [FNBFirebaseClient addCurrentUser:self.currentUser andArtistToEachOthersDatabases:addArtistDictionary];
    }
    else if ([self.youSubscribedLabel.text isEqualToString:@"You Are Subscribed"]) {
//        NSLog(@"button tapped and you were subscribed");
        // present alert to confirm
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Are You Sure?" message:[NSString stringWithFormat: @"Do you want to unsubscribe from %@", self.currentArtist.name]  preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *submit = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [FNBFirebaseClient deleteCurrentUser:self.currentUser andArtistFromEachOthersDatabases:self.currentArtist.name withCompletionBlock:^(BOOL deletedArtistAndUserCompleted) {
            }];
        }];
        
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:nil];
        [alert addAction:cancel];
        [alert addAction:submit];
        [self presentViewController:alert animated:YES completion:nil];
    }
}


- (IBAction)chatRoomTapped:(id)sender {

}


- (void) setTwitterCellsWithTweetsArray:(NSArray *)tweetsArray {
//    NSLog(@"these are the tweets array: %@", tweetsArray);
    
    if (tweetsArray.count == 0) {
        NSLog(@"received no tweets for this artist");
    }
    // number of tweets received is less than or equal number of labels
    else if (tweetsArray.count <= self.arrayOfTweetContentLabels.count) {
        for (NSInteger i = 0; i < tweetsArray.count; i++) {
            ((UITextView *)self.arrayOfTweetContentLabels[i]).text = tweetsArray[i][@"text"];
            // get rid of the +000 2016 at the end of the tweet date
            NSString *createdAtDateUnformatted = tweetsArray[i][@"created_at"];
            NSString *createdAtDateFormatted = [createdAtDateUnformatted componentsSeparatedByString:@"+"][0];
            ((UILabel *)self.arrayOfTweetDateLabels[i]).text = [NSString stringWithFormat:@"%@ : %@", tweetsArray[i][@"user"][@"name"] , createdAtDateFormatted];
        }
    }
    // number of tweets received is greater than number of labels
    else {
        for (NSInteger i = 0; i < self.arrayOfTweetContentLabels.count; i++) {
            ((UITextView *)self.arrayOfTweetContentLabels[i]).text = tweetsArray[i][@"text"];
            // get rid of the +000 2016 at the end of the tweet date
            NSString *createdAtDateUnformatted = tweetsArray[i][@"created_at"];
            NSString *createdAtDateFormatted = [createdAtDateUnformatted componentsSeparatedByString:@"+"][0];
            ((UILabel *)self.arrayOfTweetDateLabels[i]).text = [NSString stringWithFormat:@"%@ : %@", tweetsArray[i][@"user"][@"name"] , createdAtDateFormatted];
        }
    }
    [self.tableView reloadData];
//    [self.view bringSubviewToFront:self.sideBar.sideBarContainerView];

}

-(void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    UITableViewHeaderFooterView *v = (UITableViewHeaderFooterView *)view;
    v.backgroundView.backgroundColor = FNBLightGreenColor;
}

 - (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath

{
    UITableViewCell* cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    
    if (indexPath.section == 3){
            if(cell == self.twitterFirstViewCell && self.currentArtist.tweetsArray.count < 1){
            
            
            self.twitterFourthViewCell.textLabel.text = @"No tweets.";
            return 0;
       }
        
                        else if (cell == self.twitterSecondViewCell && self.currentArtist.tweetsArray.count < 2){
            return 0;
        }
        
        else if (cell == self.twitterThirdViewCell && self.currentArtist.tweetsArray.count < 3){
            return 0;
        }
       
        
        else if (self.currentArtist.tweetsArray.count > 0 && self.currentArtist.tweetsArray.count < 4){
            
            self.twitterFourthViewCell.textLabel.text = @"                    ";
        }
        else if (self.currentArtist.tweetsArray.count >= 4){
            
            self.twitterFourthViewCell.textLabel.text = @"  See more...   ";
            
        }
        
        if (cell == self.twitterFourthViewCell) {
            return 44;
        }
        else {
            return 75;
        }
        

    
    }
    
    
    //Upcoming concert table view dimensions
    else if (indexPath.section == 4) {
        if (cell == self.upConcertsFirstCell && self.events.count < 1) {
            self.upConcertsFourthCell.textLabel.text = @"No Upcoming Events.";
            self.upConcertsFourthCell.accessoryType = UITableViewCellAccessoryNone;

           self.upConcertsFourthCell.userInteractionEnabled = NO;
            return 0;
        }
        
        else if (cell == self.upConcertsSecondCell && self.events.count < 2) {
            
            return 0;
            
        }
        
        else if (cell == self.upConcertsThirdCell &&  self.events.count < 3) {
            
            
            
            return 0;
            }
        
        
        
        
        else if (cell == self.upConcertsFirstCell && self.events.count > 0){
        
//            self.upConcertsFourthCell.textLabel.text = @"See more...";
            
            FNBArtistEvent *event = self.events[0];
            self.eventLabel1.text = event.eventTitle;
            self.eventLabelDate1.text = event.dateOfConcert;
            NSURL *imageURL1 = [NSURL URLWithString:event.artistImageURL];
            NSData *dataImage1 = [NSData dataWithContentsOfURL:imageURL1];
            self.eventImageView1.image = [UIImage imageWithData:dataImage1];
            //Height
            
            // CHANGE HERE

            return 44;
            
        }
        
        
        
        else if (cell == self.upConcertsSecondCell && self.events.count > 1){
            
//            self.upConcertsFourthCell.textLabel.text = @" See more...";
            FNBArtistEvent *event1 = self.events[1];
            self.eventLabel2.text = event1.eventTitle;
            self.eventLabelDate2.text = event1.dateOfConcert;
            NSURL *imageURL2 = [NSURL URLWithString:event1.artistImageURL];
            NSData *dataImage2 = [NSData dataWithContentsOfURL:imageURL2];
            self.eventImageView2.image = [UIImage imageWithData:dataImage2];

            return 44;
            
        }
        
        
        else if (cell == self.upConcertsThirdCell && self.events.count > 2){
//            self.upConcertsFourthCell.userInteractionEnabled = YES;
//            self.upConcertsFourthCell.textLabel.text = @" See more...";
            FNBArtistEvent *event2 = self.events[2];
            self.eventLabel3.text = event2.eventTitle;
            self.eventLabelDate3.text = event2.dateOfConcert;
            NSURL *imageURL3 = [NSURL URLWithString:event2.artistImageURL];
            NSData *dataImage3 = [NSData dataWithContentsOfURL:imageURL3];
            self.eventImageView3.image = [UIImage imageWithData:dataImage3];

            return 44;
            
            
                
            
        }
        else if (cell == self.upConcertsFourthCell && self.events.count > 3){
            self.upConcertsFourthCell.textLabel.text = @" See more...";
            self.upConcertsFourthCell.userInteractionEnabled = YES;
            self.upConcertsFourthCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

            return 44;

        }
        else if (cell == self.upConcertsFourthCell && self.events.count <= 3 && self.events.count > 0){
            self.upConcertsFourthCell.userInteractionEnabled = YES;
            self.upConcertsFourthCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return 0;
            
        }
    
    }
    
    // height of top cell with main artist page
    else if (indexPath.section == 0){
        return 200;
    }
    
    return 44;

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Get the section number to determine what section has been selected
    NSInteger section = indexPath.section;
   
    // Get the header section text
    NSString *sectionHeaderTitle = [tableView headerViewForSection:section].textLabel.text;
    
    
    // Check to see if selection is in section, "Upcoming Concerts"
    
    // IF section header text is equal to "Upcoming Conerts" AND row index is less than or equal to 2,
    // THEN proceed with preparing to go to next VC
    
    if ([sectionHeaderTitle isEqualToString:@"Upcoming Concerts"] && indexPath.row <= 2) {
        
        // Check to see if there is an event object at indexPath.row selected
        if (self.events[indexPath.row] != nil) {
            
            // Reach into self.events property array and get FNBArtistEvent object at index path for row
            FNBArtistEvent *event = self.events[indexPath.row];
            
            NSLog(@"printing indexPath.row: %li",indexPath.row);
            
            // Create an instance of FNBEventInfoVC (view controller)
            // Use UIStoryboard class/type to create the instance
            FNBEventInfoVC *eventInfoVC = [[UIStoryboard storyboardWithName:@"FNBArtistNews" bundle:nil] instantiateViewControllerWithIdentifier:@"eventInfo"];
            eventInfoVC.isUserLoggedIn = self.isUserLoggedIn;
            // Assign event value to property on eventInfoVC
            eventInfoVC.event = event;
            
            // Push eventInfoVC in my window
            [self.navigationController pushViewController:eventInfoVC animated:YES];
        }
        
    } else if ([sectionHeaderTitle isEqualToString:@"Upcoming Concerts"] && indexPath.row == 3) {
        
        
        FNBArtistNewsTableViewController *eventsViewController = [[UIStoryboard storyboardWithName:@"FNBArtistNews" bundle:nil] instantiateViewControllerWithIdentifier:@"artistNews"];
        // Assign event value to property on eventInfoVC
        eventsViewController.eventsArray = self.events;
        eventsViewController.isUserLoggedIn = self.isUserLoggedIn;
        // Push eventInfoVC in my windows
        
        [self.navigationController pushViewController:eventsViewController animated:YES];
    


}

}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"artistTop10Segue"]) {
        FNBArtistTop10TableViewController *nextVC = [segue destinationViewController];
        nextVC.isUserLoggedIn = self.isUserLoggedIn;
        nextVC.recievedArtistSpotifyID = self.currentArtist.spotifyID;
    }
    else if ([segue.identifier isEqualToString:@"fanFeedSegue"]) {
        FNBFanFeedViewController *nextVC = [segue destinationViewController];
        nextVC.artist = self.currentArtist;
        nextVC.user = self.currentUser;
    }
    else if ([segue.identifier isEqualToString:@"seeMoreTweetsSegue"]) {
        FNBSeeMoreTweetsTableViewController *nextVC = [segue destinationViewController];
        nextVC.receivedArtist = self.currentArtist;
        nextVC.isUserLoggedIn = self.isUserLoggedIn;
    }
}

@end
