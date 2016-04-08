//
//  FBSTableViewController.m
//  spotifytop10
//
//  Created by Rodrigo on 3/31/16.
//  Copyright © 2016 Rodrigo. All rights reserved.
//

#import "FNBArtistTop10TableViewController.h"
#import "FNBArtistTop10Cell.h"
#import <UIImageView+AFNetworking.h>
#import "FNBSpotifyAPIclient.h"
#import "FNBTopTrackDetailViewController.h"

@interface FNBArtistTop10TableViewController ()

@property (nonatomic,strong) NSArray *topTrackCellFolder;

@end

@implementation FNBArtistTop10TableViewController

-(void) viewDidAppear:(BOOL)animated {
    
   [super viewDidAppear:animated];
    [self.tableView reloadData];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // dummy data (this is AC/DC Sptify ID)
//    self.recievedArtistSpotifyID = @"711MCceyCBcFnzjGY4Q7Un";
   self.topTrackCellFolder = [NSMutableArray new];
    [FNBSpotifyAPIclient getTopTracksOfSpotifyID:self.recievedArtistSpotifyID WithCompletionBlock:^(BOOL success, NSArray *topTracks) {
        NSLog(@"Inside API CLIENT");
        if (success) {
            self.topTrackCellFolder = topTracks;
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self.tableView reloadData];
            }];
        }   }];
}

//   [FNBSpotifyAPIclient getTopTracksWithCompletionBlock:^(BOOL success, NSArray *topTracks) {
//      NSLog(@"Inside API CLIENT");
//             if (success) {
//                 self.topTrackCellFolder = topTracks;
//          
//           [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//            [self.tableView reloadData];
//           }];
//      }   }];
//}
-(BOOL)prefersStatusBarHidden {
    
    return YES;
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Incomplete implementation, return the number of sections
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
////#warning Incomplete implementation, return the number of rows
//    TopTrack *arraySize = [TopTrack new];
//    
//
//    NSLog(@"self.topTrackCellFolder.count %@",arraySize.trackName);
    return self.topTrackCellFolder.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"Anybody here?");

    NSString *reuseIdentifier = @"Cell";

    FNBArtistTop10Cell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    cell.TrackNameLabel.text = self.topTrackCellFolder[indexPath.row][@"nameTrack"];
    cell.AlbumNameLabel.text = self.topTrackCellFolder[indexPath.row][@"albumName"];
    
    NSDictionary *topTrack = self.topTrackCellFolder[indexPath.row];
    NSString *trackString = topTrack[@"albumImageURL"];
    [cell.AlbumImageView setImageWithURL: [NSURL URLWithString:trackString]];
    
    
    return cell;
}
-(void)getImageForAlbumCell:(UITableViewCell *)cell indexPath:(NSIndexPath *)path {
    
    

}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
    NSDictionary *song =  self.topTrackCellFolder[selectedIndexPath.row];
    FNBTopTrackDetailViewController *detailVC = segue.destinationViewController;
    detailVC.albumArtURL = song[@"albumImageURL"];
    detailVC.albumName = song[@"albumName"];
    detailVC.trackName = song[@"nameTrack"];
    detailVC.trackSampleURL = song[@"previewSong"];
    
    
}



@end
