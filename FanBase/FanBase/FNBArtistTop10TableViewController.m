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


@interface FNBArtistTop10TableViewController ()

@property (nonatomic,strong) NSArray *topTrackCellFolder;
@property (nonatomic,strong) NSString *previousUrl;
//@property (nonatomic,strong) SideBar *sideBar;

@end

@implementation FNBArtistTop10TableViewController

-(void) viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    [self.tableView reloadData];    

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.isUserLoggedIn) {
        //Initializes hamburger bar menu button
        UIBarButtonItem *hamburgerButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu"] style:UIBarButtonItemStyleDone target:self action:@selector(hamburgerButtonTapped:)];
        self.navigationItem.rightBarButtonItem = hamburgerButton;
    }

    //Gradient
    self.tableView.tintColor = [UIColor colorWithRed:230.0/255.0 green:255.0/255.0 blue:247.0/255.0 alpha:1.0];
    UIColor *gradientMaskLayer = [UIColor colorWithRed:184.0/255.0 green:204.0/255.0 blue:198.0/255.0 alpha:1.0];
    CAGradientLayer *gradientMask = [CAGradientLayer layer];
    gradientMask.frame = self.tableView.bounds;
    gradientMask.colors = @[(id)gradientMaskLayer.CGColor,(id)[UIColor clearColor].CGColor];
    
    [self.tableView.layer insertSublayer:gradientMask atIndex:0];
    
    //Set isMusicPlaying
    
    self.isMusicPlaying = NO;

    self.topTrackCellFolder = [NSMutableArray new];
    [FNBSpotifyAPIclient getTopTracksOfSpotifyID:self.recievedArtistSpotifyID WithCompletionBlock:^(BOOL success, NSArray *topTracks) {
        if (success) {
            self.topTrackCellFolder = topTracks;
            
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self.tableView reloadData];
                
            }];
        }   }];
}

-(void)hamburgerButtonTapped:(id)sender {
    NSLog(@"Hamburger pressed and posting notification");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HamburgerButtonNotification" object:nil];
}



-(void)viewWillDisappear:(BOOL)animated {
    [self.player pause];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.topTrackCellFolder.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *reuseIdentifier = @"Cell";

    FNBArtistTop10Cell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
        NSDictionary *song =  self.topTrackCellFolder[indexPath.row];
    if (self.isMusicPlaying && [self.previousUrl isEqualToString:song[@"previewSong"]]){
        
        [cell.play_pauseButton setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
        
    }
    else {
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
    detailVC.isUserLoggedIn = self.isUserLoggedIn;
}

- (IBAction)play_pauseButton:(id)sender {
    
    UIButton *playButton = sender;
    UIView *cellContentView = [playButton superview];
    FNBArtistTop10Cell *cell = (FNBArtistTop10Cell*)[cellContentView superview];
    NSURL *url = [NSURL URLWithString:cell.trackSampleURL];
    self.playerItem = [AVPlayerItem playerItemWithURL:url];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
    
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    
    if(!self.isMusicPlaying){
        NSLog(@"playing");
        [playButton setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
        [self.player play];
        self.isMusicPlaying = !self.isMusicPlaying;

    }
    else {
//        [playButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
//        [self.player pause];
        
        if ([self.previousUrl isEqualToString:cell.trackSampleURL]){
            NSLog(@"PreviousURL isEqual to trackSampleURL");
            [playButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
            [self.player pause];
            self.isMusicPlaying = !self.isMusicPlaying;
        }
    
        else {
            for (FNBArtistTop10Cell *tableCell in self.tableView.visibleCells){
                [tableCell.play_pauseButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
                
            }
            
            [playButton setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
            [self.player play];
            
        }
    }
    self.previousUrl = cell.trackSampleURL;
}

-(void)itemDidFinishPlaying:(NSNotification *)notification {
    for (FNBArtistTop10Cell *tableCell in self.tableView.visibleCells){
        [self.player pause];
        NSLog(@"pause");
        [tableCell.play_pauseButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    }
}


@end
