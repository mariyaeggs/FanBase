//
//  TopTracks.m
//  spotifytop10
//
//  Created by Rodrigo on 3/31/16.
//  Copyright © 2016 Rodrigo. All rights reserved.
//

#import "FNBSpotifyTopTracks.h"

@implementation FNBSpotifyTopTracks

-(id)initWithName:(NSString *)albumName trackName:(NSString *)trackName imageURL:(NSString *)imageURL trackSampleURL:(NSString *) trackSampleURL {
    
    self = [super init];
    
    if (self)
    {
        _albumName = albumName;
        _trackName = trackName;
        _imageURL  = imageURL;
        _trackSampleURL = trackSampleURL;
    }
    return self; 
}

@end
