//
//  ArtistMainPageTableViewController.m
//  FanBase
//
//  Created by Andy Novak on 4/7/16.
//  Copyright © 2016 Angelica Bato. All rights reserved.
//

#import "ArtistMainPageTableViewController.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "FNBTwitterAPIClient.h"

@interface ArtistMainPageTableViewController ()
@property (strong, nonatomic) FNBArtist *currentArtist;
@property (strong, nonatomic) FNBUser  *currentUser;
@property (nonatomic) BOOL isUserLoggedIn;
@property (nonatomic) BOOL isUserSubscribedToArtist;

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




@end

@implementation ArtistMainPageTableViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    
    // dummy data for now
    self.receivedArtistName = @"Adele";
    
    
   
    
    // make FNBUser for this VC
    self.currentUser = [[FNBUser alloc] init];
    // check if user is Guest or Authentic User
    [FNBFirebaseClient checkOnceIfUserIsAuthenticatedWithCompletionBlock:^(BOOL isAuthenticUser) {
        if (isAuthenticUser) {
            NSLog(@"you are an auth user");
            //Set the properties of this user
            [FNBFirebaseClient setPropertiesOfLoggedInUserToUser:self.currentUser withCompletionBlock:^(BOOL updateHappened) {
                if (updateHappened) {
                    NSLog(@"Update happened to User");
                    // check if user is subscribed to artist
                    [self checkIfUser:self.currentUser isSubscribedToArtist:self.currentArtist];
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
    [FNBFirebaseClient setPropertiesOfArtist:_currentArtist FromDatabaseWithCompletionBlock:^(BOOL setPropertiesCompleted) {
        if (setPropertiesCompleted) {
            [self.artistImageView setImageWithURL:[NSURL URLWithString:self.currentArtist.imagesArray[0][@"url"]]];
            self.artistNameLabel.text = self.currentArtist.name;
            
//            [self setUserLabels];
            
            // get tweets
            [FNBTwitterAPIClient generateTweetsOfUsername:self.currentArtist.name completion:^(NSArray *returnedArray) {
                
                [self setTwitterCellsWithTweetsArray:returnedArray];
            }];
        }
    }];
    
}

- (void) checkIfUser:(FNBUser *)user isSubscribedToArtist:(FNBArtist *)artist {
    // check if user has artist's Name in subscribed Users
    for (NSString *artistName in user.artistsDictionary) {
        NSLog(@"this is artistName in checkIfUser: %@", artistName);
        
        // if found a match while looping,
        self.isUserSubscribedToArtist = YES;
        return;
    }
    self.isUserSubscribedToArtist = NO;
}

- (void) setUserLabels {
    self.numberOfSubscribedUsersLabel.text = [NSString stringWithFormat:@"%li People Subscribed", self.currentArtist.subscribedUsers.count];
    

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
    NSLog(@"tapped");
    if ([self.youSubscribedLabel.text isEqualToString:@"You Are Not Logged In"]) {
        NSLog(@"button tapped and you were not logged in");
        // TODO: segue to Login Screen
    }
    else if ([self.youSubscribedLabel.text isEqualToString:@"You Are Not Subscribed"]) {
        NSLog(@"button tapped and you were not subscribed in");
        // TODO: subscribe User
//        [FNBFirebaseClient addCurrentUser:self.currentUser andArtistToEachOthersDatabases:<#(NSDictionary *)#>]
    }
    else if ([self.youSubscribedLabel.text isEqualToString:@"You Are Subscribed"]) {
        NSLog(@"button tapped and you were subscribed");
        // present alert to confirm
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Are You Sure?" message:[NSString stringWithFormat: @"Do you want to unsubscribe from %@", self.currentArtist.name]  preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *submit = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [FNBFirebaseClient deleteCurrentUser:self.currentUser andArtistFromEachOthersDatabases:self.currentArtist.name];

        }];
        //TODO: check if this deletes artist
        
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




/*
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Incomplete implementation, return the number of sections
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    return 0;
}
*/
/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
