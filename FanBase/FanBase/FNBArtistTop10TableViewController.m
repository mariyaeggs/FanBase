//
//  FBSTableViewController.m
//  spotifytop10
//
//  Created by Rodrigo on 3/31/16.
//  Copyright © 2016 Rodrigo. All rights reserved.
//

#import "FNBArtistTop10TableViewController.h"
#import "FNBArtistTop10Cell.h"
#import "UIImageView+AFNetworking.h"
#import "FNBSpotifyAPIclient.h"
#import "FNBTopTrackDetailViewController.h"
#import "FanBase-Bridging-Header.h"
#import "Fanbase-Swift.h"


@interface FNBArtistTop10TableViewController () <SideBarDelegate>

@property (nonatomic,strong) NSArray *topTrackCellFolder;
@property (nonatomic,strong) NSString *previousUrl;
@property (nonatomic,strong) SideBar *sideBar;

@end

@implementation FNBArtistTop10TableViewController

-(void) viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    [self.tableView reloadData];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Initializes hamburger bar menu button
    UIBarButtonItem *hamburgerButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu"] style:UIBarButtonSystemItemDone target:self action:@selector(hamburgerButtonTapped:)];
    hamburgerButton.tintColor = [UIColor blackColor];
    self.navigationItem.rightBarButtonItem = hamburgerButton;
    

    //Gradient
    self.tableView.tintColor = [UIColor colorWithRed:230.0/255.0 green:255.0/255.0 blue:247.0/255.0 alpha:1.0];
    UIColor *gradientMaskLayer = [UIColor colorWithRed:184.0/255.0 green:204.0/255.0 blue:198.0/255.0 alpha:1.0];
    CAGradientLayer *gradientMask = [CAGradientLayer layer];
    gradientMask.frame = self.tableView.bounds;
    gradientMask.colors = @[(id)gradientMaskLayer.CGColor,(id)[UIColor clearColor].CGColor];
    
    [self.tableView.layer insertSublayer:gradientMask atIndex:0];
    
//    self.tableView.backgroundColor = [UIColor blueColor];

    // Initialize side bar
    self.sideBar = [[SideBar alloc] initWithSourceView:self.view sideBarItems:@[@"Profile", @"Discover", @"Events"]];
    self.sideBar.delegate = self;
    
    self.isMusicPlaying = NO;

    

    // dummy data (this is AC/DC Sptify ID)
    //    self.recievedArtistSpotifyID = @"711MCceyCBcFnzjGY4Q7Un";
    self.topTrackCellFolder = [NSMutableArray new];
    [FNBSpotifyAPIclient getTopTracksOfSpotifyID:self.recievedArtistSpotifyID WithCompletionBlock:^(BOOL success, NSArray *topTracks) {
//        NSLog(@"Inside API CLIENT");
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
//-(BOOL)prefersStatusBarHidden {
//    
//    return YES;
//}
// Side bar delegate method implementation
-(void)didSelectButtonAtIndex:(NSInteger)index {
    
    NSLog(@"%ld", (long)index);
    
    if ((long)index == 0) {
        FNBArtistTop10TableViewController *userProfileVC = [[UIStoryboard storyboardWithName:@"Firebase" bundle:nil] instantiateViewControllerWithIdentifier:@"UserPageID"];
        // Push eventInfoVC in my window
        [self.navigationController pushViewController:userProfileVC animated:YES];
    } else if ((long)index == 1) {
        FNBArtistTop10TableViewController *discoverPageVC = [[UIStoryboard storyboardWithName:@"Discover2" bundle:nil]instantiateViewControllerWithIdentifier:@"DiscoverPageID"];
        // Push eventInfoVC in my window
        [self.navigationController pushViewController:discoverPageVC animated:YES];
    } else if ((long)index == 2) {
        FNBArtistTop10TableViewController *eventsVC = [[UIStoryboard storyboardWithName:@"FNBArtistNews" bundle:nil]instantiateViewControllerWithIdentifier:@"eventInfo"];
        // Push eventInfoVC in my window
        [self.navigationController pushViewController:eventsVC animated:YES];
        
    }
}

// If bar menu is tapped
-(void)hamburgerButtonTapped:(id)sender {
    
    if (self.sideBar.isSideBarOpen) {
        [self.sideBar showSideBarMenu:NO];
    } else {
        [self.sideBar showSideBarMenu:YES];
    }
    
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
    
    

//    NSLog(@"Anybody here?"); 


    NSString *reuseIdentifier = @"Cell";
    
    FNBArtistTop10Cell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
        NSDictionary *song =  self.topTrackCellFolder[indexPath.row];
    if (self.isMusicPlaying && [self.previousUrl isEqualToString:song[@"previewSong"]]){
        
//        [cell.play_pauseButton setTitle:@"Pause" forState:UIControlStateNormal];
        [cell.play_pauseButton setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
        
    }
    else {
//        [cell.play_pauseButton setTitle:@"Play" forState:UIControlStateNormal];
        [cell.play_pauseButton setImage:[UIImage imageNamed:@"play"]
                               forState:UIControlStateNormal];

        
    }
    cell.TrackNameLabel.text = song[@"nameTrack"];
    cell.AlbumNameLabel.text = song[@"albumName"];
    cell.trackSampleURL = song[@"previewSong"];
    NSString *trackString = song[@"albumImageURL"];
    
    cell.backgroundColor = [UIColor clearColor];
    
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
    detailVC.trackUrl = song[@"trackUrl"];
}

- (IBAction)play_pauseButton:(id)sender {
    
    
    UIButton *playButton = sender;
    NSLog(@"Value for sender%@",sender);
    UIView *cellContentView = [playButton superview];
    FNBArtistTop10Cell *cell = (FNBArtistTop10Cell*)[cellContentView superview];
    NSURL *url = [NSURL URLWithString:cell.trackSampleURL];
    self.player = [AVPlayer playerWithURL:url];
    
        if(!self.isMusicPlaying){
        NSLog(@"playing");
        [playButton setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
//        [playButton setTitle:@"Pause" forState:UIControlStateNormal];
        [self.player play];
        self.isMusicPlaying = !self.isMusicPlaying;
    
    }
    else {
        NSLog(@"pausing");
        [playButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
//       [playButton setTitle:@"Play" forState:UIControlStateNormal];
        [self.player pause];
        
        if ([self.previousUrl isEqualToString:cell.trackSampleURL]){
            [playButton setTitle:@"Play" forState:UIControlStateNormal];
            [self.player pause];
        self.isMusicPlaying = !self.isMusicPlaying;
        }
        
        else{
            
            for (FNBArtistTop10Cell *tableCell in self.tableView.visibleCells){
                
                [tableCell.play_pauseButton setTitle:@"Play" forState:(UIControlStateNormal)];
                
                [self.player play];
            
            }
            [playButton setTitle:@"Pause" forState:(UIControlStateNormal)];
        }
//        NSLog(@"pausing");
//       [playButton setTitle:@"Play" forState:UIControlStateNormal];
//        [self.player pause];
//        
    }
    
    self.previousUrl = cell.trackSampleURL;
}

@end
