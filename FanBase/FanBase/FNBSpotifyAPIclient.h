//
//  APIClient.h
//  spotifytop10
//
//  Created by Rodrigo on 3/31/16.
//  Copyright © 2016 Rodrigo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "FNBSpotifyTopTracks.h"
#import <AFNetworking.h>


@interface FNBSpotifyAPIclient : NSObject

+(void)getTopTracksWithCompletionBlock:(void (^) (BOOL success, NSArray *topTracks))block;

@end
