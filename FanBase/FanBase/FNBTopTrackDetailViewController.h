//
//  DetailViewController.h
//  spotifytop10
//
//  Created by Rodrigo on 4/1/16.
//  Copyright © 2016 Rodrigo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "FNBSpotifyAPIclient.h"
#import "FNBSpotifyTopTracks.h"

@interface FNBTopTrackDetailViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *LargeImageDetailView;


@property (weak, nonatomic) IBOutlet UILabel *AlbumTitleDetailView;


@property (weak, nonatomic) IBOutlet UILabel *TrackNameDetailView;

@property (weak, nonatomic) IBOutlet UIButton *playButton;


@property (weak, nonatomic) IBOutlet UIButton *StopButton;


@property (nonatomic,strong) NSArray *results;

@property (nonatomic, strong) NSString *albumArtURL;

@property (nonatomic, strong) NSString *albumName;

@property (nonatomic, strong) NSString *trackName;

@property (nonatomic, strong) NSString * trackSampleURL;

@property (nonatomic, strong) NSString * trackUrl;
@end
