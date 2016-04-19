//
//  DetailViewController.m
//  spotifytop10
//
//  Created by Rodrigo on 4/1/16.
//  Copyright © 2016 Rodrigo. All rights reserved.
//

#import "FNBTopTrackDetailViewController.h"
#import "UIImageView+AFNetworking.h"


@interface FNBTopTrackDetailViewController ()

@property (strong, nonatomic) AVPlayer *player;
@property (nonatomic) BOOL  isMusicPlaying;


@end

@implementation FNBTopTrackDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
        self.AlbumTitleDetailView.text = self.albumName;
    self.TrackNameDetailView.text = self.trackName;
    [self.LargeImageDetailView setImageWithURL:[NSURL URLWithString:self.albumArtURL]];
    
    
    //Gradient
    self.view.tintColor = [UIColor colorWithRed:230.0/255.0 green:255.0/255.0 blue:247.0/255.0 alpha:1.0];
    UIColor *gradientMaskLayer = [UIColor colorWithRed:184.0/255.0 green:204.0/255.0 blue:198.0/255.0 alpha:1.0];
    CAGradientLayer *gradientMask = [CAGradientLayer layer];
    gradientMask.frame = self.view.bounds;
    gradientMask.colors = @[(id)gradientMaskLayer.CGColor,(id)[UIColor clearColor].CGColor];
    
    [self.view.layer insertSublayer:gradientMask atIndex:0];

    
    
    
//    [self.playButton setImage:[UIImage imageNamed:@"spotify-icon"] forState:UIControlStateNormal];
//    [self.playButton setImageEdgeInsets:UIEdgeInsetsMake(0, -30, 0, 0)];
//    [self.playButton setTitle:@"Play full song on Spotify" forState:UIControlStateNormal];
    
    
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    UIImage *image = [UIImage imageNamed:@"spotify-logo"];
    
    
    attachment.image = image;
    
    NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
    NSMutableAttributedString *buttonString = [[NSMutableAttributedString alloc] initWithAttributedString:attachmentString];
    NSAttributedString *contentString = [[NSAttributedString alloc] initWithString:@"Play full song on Spotify"];
    [buttonString appendAttributedString:contentString];
    
    [self.playButton setAttributedTitle:buttonString forState:UIControlStateNormal];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)playbutton:(id)sender {
    
    NSString * resultUrl = self.trackUrl;
    
    
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:resultUrl]];
}
    
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(songEnded) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player];


-(void) songEnded {
    [self.player seekToTime:kCMTimeZero ];

}


@end
