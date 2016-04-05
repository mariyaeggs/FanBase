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

@interface FNBUserProfilePageTableViewController ()

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

@property (strong, nonatomic) Firebase *userRef;

@end

@implementation FNBUserProfilePageTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // get user info
    self.currentUser = [[FNBUser alloc] init];
    [FNBFirebaseClient setPropertiesOfLoggedInUserToUser:self.currentUser withCompletionBlock:^(BOOL completedSettingUsersProperties) {
        
        if (completedSettingUsersProperties) {
            [self.userImageView setImageWithURL:[NSURL URLWithString:self.currentUser.profileImageURL]];
            self.userNameLabel.text = self.currentUser.userName;
            
            self.numberOfSubscribedArtistsLabel.text = [NSString stringWithFormat: @"Number of Subscribed Artists: %lu", self.currentUser.artistsDictionary.count];
            // TODO: put in the biggest fan label here
            
            // make an array of detailed artists user is subscribed to and set it to users array property ******************
            
            self.currentUser.detailedArtistInfoArray = [NSMutableArray new];
            for (NSString *artistName in self.currentUser.artistsDictionary) {
                NSDictionary *specificArtist = [self.currentUser.artistsDictionary objectForKey:artistName];
                NSLog(@"This is the number of points: %@  for artist: %@", specificArtist, artistName);
                FNBArtist *artist = [[FNBArtist alloc] initWithName:artistName];
                [FNBFirebaseClient setPropertiesOfArtist:artist FromDatabaseWithCompletionBlock:^(BOOL setPropertiesUpdated) {
                    [self.currentUser.detailedArtistInfoArray addObject:artist];
                    if (setPropertiesUpdated) {
                        
                        
                        switch (self.currentUser.detailedArtistInfoArray.count) {
                            case 0:
                                NSLog(@"there are no artists in currentUser.detailedArtistInfoArray");
                                break;
                                
                            case 1:
                                self.artist1NameLabel.text = ((FNBArtist *)self.currentUser.detailedArtistInfoArray[0]).name;
                                [self.artist1ImageView setImageWithURL:[NSURL URLWithString:((FNBArtist *)self.currentUser.detailedArtistInfoArray[0]).imagesArray[0][@"url"]]];
                                
                                
                                [self.tableView reloadData];
                                break;
                                
                            case 2:
                                self.artist1NameLabel.text = ((FNBArtist *)self.currentUser.detailedArtistInfoArray[0]).name;
                                self.artist2NameLabel.text = ((FNBArtist *)self.currentUser.detailedArtistInfoArray[1]).name;
                                [self.artist1ImageView setImageWithURL:[NSURL URLWithString:((FNBArtist *)self.currentUser.detailedArtistInfoArray[0]).imagesArray[0][@"url"]]];
                                [self.artist2ImageView setImageWithURL:[NSURL URLWithString:((FNBArtist *)self.currentUser.detailedArtistInfoArray[1]).imagesArray[0][@"url"]]];
                                
                                
                                [self.tableView reloadData];

                                break;
                            case 3:
                                self.artist1NameLabel.text = ((FNBArtist *)self.currentUser.detailedArtistInfoArray[0]).name;
                                self.artist2NameLabel.text = ((FNBArtist *)self.currentUser.detailedArtistInfoArray[1]).name;
                                self.artist3NameLabel.text = ((FNBArtist *)self.currentUser.detailedArtistInfoArray[2]).name;
                                [self.artist1ImageView setImageWithURL:[NSURL URLWithString:((FNBArtist *)self.currentUser.detailedArtistInfoArray[0]).imagesArray[0][@"url"]]];
                                [self.artist2ImageView setImageWithURL:[NSURL URLWithString:((FNBArtist *)self.currentUser.detailedArtistInfoArray[1]).imagesArray[0][@"url"]]];
                                [self.artist3ImageView setImageWithURL:[NSURL URLWithString:((FNBArtist *)self.currentUser.detailedArtistInfoArray[2]).imagesArray[0][@"url"]]];
                                
                                [self.tableView reloadData];
                                break;
                                
                            // if 4 or more
                            default:
                                self.artist1NameLabel.text = ((FNBArtist *)self.currentUser.detailedArtistInfoArray[0]).name;
                                self.artist2NameLabel.text = ((FNBArtist *)self.currentUser.detailedArtistInfoArray[1]).name;
                                self.artist3NameLabel.text = ((FNBArtist *)self.currentUser.detailedArtistInfoArray[2]).name;
                                self.artist4NameLabel.text = ((FNBArtist *)self.currentUser.detailedArtistInfoArray[3]).name;
                                [self.artist1ImageView setImageWithURL:[NSURL URLWithString:((FNBArtist *)self.currentUser.detailedArtistInfoArray[0]).imagesArray[0][@"url"]]];
                                [self.artist2ImageView setImageWithURL:[NSURL URLWithString:((FNBArtist *)self.currentUser.detailedArtistInfoArray[1]).imagesArray[0][@"url"]]];
                                [self.artist3ImageView setImageWithURL:[NSURL URLWithString:((FNBArtist *)self.currentUser.detailedArtistInfoArray[2]).imagesArray[0][@"url"]]];
                                [self.artist4ImageView setImageWithURL:[NSURL URLWithString:((FNBArtist *)self.currentUser.detailedArtistInfoArray[3]).imagesArray[0][@"url"]]];

                                
                                [self.tableView reloadData];
                                break;
                        }
                        
                    }
                }];
                
//                [self.tableView reloadData];
            }
            self.tableView.tableFooterView = [UIView new];
            [self.tableView reloadData];
        }
      
        
    }];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    // start listening to changes in the username, userProfileImage, or deleting (or adding?) an artist
    [self.userRef observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        
    }];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.userRef removeAllObservers];
}
// TODO: add a long tap to the username to change their name
// TODO: sort subscribed artists by number of points

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
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //add code here for when you hit delete
        NSString *selectedArtistName = ((FNBArtist *)self.currentUser.detailedArtistInfoArray[indexPath.row]).name;
        
        [FNBFirebaseClient deleteCurrentUser:self.currentUser andArtistFromEachOthersDatabases:selectedArtistName];
        NSLog(@"you deleted %@", selectedArtistName);
        [self.tableView reloadData];
    }
}
@end
