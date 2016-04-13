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
//this is to segue to the ArtistTop10
#import "FNBArtistTop10TableViewController.h"
#import "FNBBandsInTownAPIClient.h"
#import "FNBArtistEvent.h"
#import "FNBEventInfoVC.h"

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

// users info
@property (weak, nonatomic) IBOutlet UILabel *youSubscribedLabel;
@property (weak, nonatomic) IBOutlet UIButton *clickToAddArtistButton;
@property (weak, nonatomic) IBOutlet UILabel *numberOfSubscribedUsersLabel;

// tweet section
@property (strong, nonatomic) NSArray *arrayOfTweetContentLabels;
@property (strong, nonatomic) NSArray *arrayOfTweetDateLabels;
@property (weak, nonatomic) IBOutlet UITextView *tweet1ContentTextView;
@property (weak, nonatomic) IBOutlet UILabel *tweet1DateLabel;
@property (weak, nonatomic) IBOutlet UITextView *tweet2ContentTextView;
@property (weak, nonatomic) IBOutlet UILabel *tweet2DateLabel;
@property (weak, nonatomic) IBOutlet UITextView *tweet3ContentTextView;
@property (weak, nonatomic) IBOutlet UILabel *tweet3DateLabel;

// upcoming events section

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


@end

@implementation FNBArtistMainPageTableViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    
    // dummy data for testing
//    self.receivedArtistName = @"Adele";

    // load page assuming user is not logged in and not subscribed
    self.isUserSubscribedToArtist = NO;
    self.isUserLoggedIn = NO;
   
    
    // make FNBUser for this VC
    self.currentUser = [[FNBUser alloc] init];
    // check if user is Guest or Authentic User
    [FNBFirebaseClient checkOnceIfUserIsAuthenticatedWithCompletionBlock:^(BOOL isAuthenticUser) {
        if (isAuthenticUser) {
            NSLog(@"you are an auth user");
            self.isUserLoggedIn = YES;
            //Set the properties of this user
            [FNBFirebaseClient setPropertiesOfLoggedInUserToUser:self.currentUser withCompletionBlock:^(BOOL updateHappened) {
                if (updateHappened) {
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
    
    
    // set the tweetsLabels
    self.arrayOfTweetContentLabels = @[self.tweet1ContentTextView, self.tweet2ContentTextView, self.tweet3ContentTextView];
    self.arrayOfTweetDateLabels = @[self.tweet1DateLabel, self.tweet2DateLabel, self.tweet3DateLabel];
    
    // make artist image circular
    self.artistImageView.layer.cornerRadius = self.artistImageView.frame.size.height /2 ,
    self.artistImageView.layer.masksToBounds = YES;
    
    // create FNBArtist from receivedName
    self.currentArtist = [[FNBArtist alloc] initWithName:self.receivedArtistName];
    [FNBFirebaseClient setPropertiesOfArtist:self.currentArtist FromDatabaseWithCompletionBlock:^(BOOL setPropertiesCompleted) {
        if (setPropertiesCompleted) {
            [self.artistImageView setImageWithURL:[NSURL URLWithString:self.currentArtist.imagesArray[0][@"url"]]];
            self.artistNameLabel.text = self.currentArtist.name;
            
            // get tweets
            [FNBTwitterAPIClient generateTweetsOfUsername:self.currentArtist.name completion:^(NSArray *returnedArray) {
                
                [self setTwitterCellsWithTweetsArray:returnedArray];
            }];
        }
    }];
    
    [FNBBandsInTownAPIClient generateEventsForArtist:self.currentArtist.name
                                          completion:^(NSArray *events) {
                                              
                                              self.events = events;
                                              
                                             [self setEventCellsWithEventsArray:self.events];
                                              
                                          }];
    
    
    
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
        NSLog(@"ARTIST CHANGED this is the new value for artist: %@, and this is the key: %@", snapshot.value, snapshot.key);
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
        [self performSegueWithIdentifier:@"goToLoginVCSegue" sender:nil];
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"UserDidLogOutNotification" object:nil];
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


- (void) setTwitterCellsWithTweetsArray:(NSArray *)tweetsArray {
//    NSLog(@"these are the tweets array: %@", tweetsArray);
    
    if (tweetsArray.count == 0) {
        NSLog(@"received no tweets for this artist");
    }
    // number of tweets received is less than or equal number of labels
    else if (tweetsArray.count <= self.arrayOfTweetContentLabels.count) {
        for (NSInteger i = 0; i < tweetsArray.count; i++) {
            ((UITextView *)self.arrayOfTweetContentLabels[i]).text = tweetsArray[i][@"text"];
            ((UILabel *)self.arrayOfTweetDateLabels[i]).text = tweetsArray[i][@"created_at"];
        }
    }
    // number of tweets received is greater than number of labels
    else {
        for (NSInteger i = 0; i < self.arrayOfTweetContentLabels.count; i++) {
            ((UITextView *)self.arrayOfTweetContentLabels[i]).text = tweetsArray[i][@"text"];
            ((UILabel *)self.arrayOfTweetDateLabels[i]).text = tweetsArray[i][@"created_at"];
        }
    }

}

-(void) setEventCellsWithEventsArray: (NSArray *)events {
    
    
    if (events.count > 0) {
        // set up first event
        FNBArtistEvent *event = events[0];
        self.eventLabel1.text = event.eventTitle;
        self.eventLabelDate1.text = event.dateOfConcert;
        NSURL *imageURL1 = [NSURL URLWithString:event.artistImageURL];
        NSData *dataImage1 = [NSData dataWithContentsOfURL:imageURL1];
        self.eventImageView1.image = [UIImage imageWithData:dataImage1];
    }
    
    if (events.count > 1) {
        // set up second event
        FNBArtistEvent *event1 = events[1];
        self.eventLabel2.text = event1.eventTitle;
        self.eventLabelDate2.text = event1.dateOfConcert;
        NSURL *imageURL2 = [NSURL URLWithString:event1.artistImageURL];
        NSData *dataImage2 = [NSData dataWithContentsOfURL:imageURL2];
        self.eventImageView2.image = [UIImage imageWithData:dataImage2];
    }
    
    if (events.count > 2) {
        // set up third event
        FNBArtistEvent *event2 = events[2];
        self.eventLabel3.text = event2.eventTitle;
        self.eventLabelDate3.text = event2.dateOfConcert;
        NSURL *imageURL3 = [NSURL URLWithString:event2.artistImageURL];
        NSData *dataImage3 = [NSData dataWithContentsOfURL:imageURL3];
        self.eventImageView3.image = [UIImage imageWithData:dataImage3];
    }
    
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Get the section number to determine what section has been selected
    NSInteger section = indexPath.section;
    
    // Get the header section text
    NSString *sectionHeaderTitle = [tableView headerViewForSection:section].textLabel.text;
    
    // Check to see if selection is in section, "Upcoming Concerts"
    if ([sectionHeaderTitle isEqualToString:@"Upcoming Concerts"]) {
        
        // Reach into self.events property array and get FNBArtistEvent object at index path for row
        FNBArtistEvent *event = self.events[indexPath.row];
        
        // Create an instance of FNBEventInfoVC (view controller)
        // Use UIStoryboard class/type to create the instance
        FNBEventInfoVC *eventInfoVC = [[UIStoryboard storyboardWithName:@"FNBArtistNews" bundle:nil] instantiateViewControllerWithIdentifier:@"eventInfo"];
        
        // Assign event value to property on eventInfoVC
        eventInfoVC.event = event;
        
        // Present eventInfoVC in my window
        [self.navigationController pushViewController:eventInfoVC animated:YES];
    
    
    }
    
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"artistTop10Segue"]) {
        FNBArtistTop10TableViewController *nextVC = [segue destinationViewController];
        nextVC.recievedArtistSpotifyID = self.currentArtist.spotifyID;
    }
}

@end
