//
//  APIClient.m
//  spotifytop10
//
//  Created by Rodrigo on 3/31/16.
//  Copyright © 2016 Rodrigo. All rights reserved.
//

#import "FNBSpotifyAPIclient.h"
//#import "TopTrack.h"
//#import <AFNetworking.h>
#import <AVFoundation/AVFoundation.h>



@implementation FNBSpotifyAPIclient

+(void)getTopTracksOfSpotifyID:(NSString *)spotifyID WithCompletionBlock:(void (^) (BOOL success, NSArray *topTracks))block {
    
    NSMutableArray *topTracksFolder = [NSMutableArray new];

//    NSString *topTracksUrl = @"https://api.spotify.com/v1/artists/6olE6TJLqED3rqDCT0FyPh/top-tracks?country=US";
     NSString *topTracksUrl = [NSString stringWithFormat:@"https://api.spotify.com/v1/artists/%@/top-tracks?country=US", spotifyID];
    AFHTTPSessionManager *manager =[AFHTTPSessionManager manager];
    
   
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    [manager GET:topTracksUrl
      parameters:nil
        progress:nil
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             
             NSDictionary *response = (NSDictionary *)responseObject;
             
             
             
             NSArray *topTracks = response[@"tracks"];
             
             // for each dictionary in topTracks
             for (NSDictionary *myTop10 in topTracks) {
                 
                 NSString *albumName = myTop10[@"album"][@"name"];
                 NSArray *albumImages = myTop10[@"album"][@"images"];
                 NSString *albumImageURL = albumImages[1][@"url"];
                 NSString *trackName = myTop10[@"name"];
                 NSString *trackSampleURL = myTop10[@"preview_url"];
                 NSString *trackUrl = myTop10[@"external_urls"][@"spotify"];
                 
                 
                 
                 NSDictionary *currentSongDictionry = @{ @"nameTrack" : trackName ,
                                                         @"albumImageURL" : albumImageURL,
                                                         @"albumName" : albumName,
                                                         @"previewSong" : trackSampleURL,
                                                         @"trackUrl" : trackUrl};
                                                         
                 [topTracksFolder addObject:currentSongDictionry];
                 NSLog(@"tracksample %@",currentSongDictionry);
    
             }
             NSLog(@"objects");
             block(YES,topTracksFolder);
             
             

             
         } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {

             //BUT if the data did not load successfully, send error to NSLOG
             
             NSLog(@"ERROR what are you %@", error.localizedDescription);
             block(NO,nil);
         }];
}

@end
