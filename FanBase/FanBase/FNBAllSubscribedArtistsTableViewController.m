//
//  FNBAllSubscribedArtistsTableViewController.m
//  FanBase
//
//  Created by Andy Novak on 4/6/16.
//  Copyright © 2016 Angelica Bato. All rights reserved.
//

#import "FNBAllSubscribedArtistsTableViewController.h"
#import "FNBFirebaseClient.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

@interface FNBAllSubscribedArtistsTableViewController ()

@property (strong, nonatomic) FNBUser *currentUser;
@property (strong, nonatomic) Firebase *userRef;

@end

@implementation FNBAllSubscribedArtistsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // set user info, and then get a detailed array of the artists the user is subscribed to
    self.currentUser = [[FNBUser alloc] init];
    [FNBFirebaseClient setPropertiesOfLoggedInUserToUser:self.currentUser withCompletionBlock:^(BOOL completedSettingUsersProperties) {
        if (completedSettingUsersProperties) {
            
            // get an array of artists that the user is subscribed to filled with detailed info
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

-(void)viewDidAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    // start listening to changes of artistDictionary
    
    NSString *urlOfUser= [NSString stringWithFormat:@"%@/users/%@", ourFirebaseURL, self.currentUser.userID];
    NSLog(@"url of user: %@", urlOfUser);
    self.userRef = [[Firebase alloc] initWithUrl:urlOfUser];
    [self.userRef observeEventType:FEventTypeChildChanged withBlock:^(FDataSnapshot *snapshot) {
        NSLog(@"this is the new value: %@, and this is the key: %@", snapshot.value, snapshot.key);
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

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.userRef removeAllObservers];
}



- (void) updateUI {
    
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.currentUser.rankingAndImagesForEachArtist.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    cell.textLabel.text = self.currentUser.rankingAndImagesForEachArtist[indexPath.row][@"artistName"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"#%@ of %@", self.currentUser.rankingAndImagesForEachArtist[indexPath.row][@"usersRank"], self.currentUser.rankingAndImagesForEachArtist[indexPath.row][@"numberOfFollowers"]];
    [cell.imageView setImageWithURL:[NSURL URLWithString:self.currentUser.rankingAndImagesForEachArtist[indexPath.row][@"artistImageURL"]]];

    return cell;
}

// add header to the tableview
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"All Subscribed Artists";
}

// Below two methods adds swipe left to show a delete option
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // when you hit delete
        NSString *selectedArtistName = ((FNBArtist *)self.currentUser.detailedArtistInfoArray[indexPath.row]).name;
        
        // delete appropriate things from database
        [FNBFirebaseClient deleteCurrentUser:self.currentUser andArtistFromEachOthersDatabases:selectedArtistName];
        NSLog(@"you deleted %@", selectedArtistName);
        
    }
}


@end
