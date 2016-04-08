//
//  DetailViewController.m
//  spotifytop10
//
//  Created by Rodrigo on 4/1/16.
//  Copyright © 2016 Rodrigo. All rights reserved.
//

#import "FNBTopTrackDetailViewController.h"
#import <UIImageView+AFNetworking.h>


@interface FNBTopTrackDetailViewController ()

@property (strong, nonatomic) AVPlayer *player;
@property (nonatomic) BOOL  isMusicPlaying;

@end

@implementation FNBTopTrackDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isMusicPlaying = NO;
    self.AlbumTitleDetailView.text = self.albumName;
    self.TrackNameDetailView.text = self.trackName;
    [self.LargeImageDetailView setImageWithURL:[NSURL URLWithString:self.albumArtURL]];
    // create an AV player with the URL
    
    NSURL *url = [NSURL URLWithString:self.trackSampleURL];
    self.player = [AVPlayer playerWithURL:url];
    

}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)playbutton:(id)sender {
    
    self.isMusicPlaying = !self.isMusicPlaying;
    if(self.isMusicPlaying){
        [self.playButton setTitle:@"Pause" forState:UIControlStateNormal];
 
        [self.player play];
    }
    else {
        
        [self.playButton setTitle:@"Play" forState:UIControlStateNormal];
        [self.player pause];
    }
    
    

    
   
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(songEnded) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player];
}

-(void) songEnded {
    [self.player seekToTime:kCMTimeZero ];

}


@end
