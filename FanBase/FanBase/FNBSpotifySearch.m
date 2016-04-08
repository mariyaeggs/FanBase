//
//  FNBSpotifySearch.m
//  FanBase
//
//  Created by Andy Novak on 3/31/16.
//  Copyright © 2016 Angelica Bato. All rights reserved.
//

#import "FNBSpotifySearch.h"
#import <AFNetworking/AFNetworking.h>
#import <AFHTTPSessionManager.h>

@implementation FNBSpotifySearch

+ (void) getArrayOfMatchingArtistsFromSearch:(NSString *)searchString withCompletionBlock: (void (^) (BOOL gotMatchingArtists, NSArray *matchingArtistsArray))block{
    NSString *inputtedStringWithoutSpaces = [searchString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet] ];
    NSString *stringForURL = [NSString stringWithFormat:@"https://api.spotify.com/v1/search?q=%@&type=artist", inputtedStringWithoutSpaces];
    
    AFHTTPSessionManager *sessionManager = [AFHTTPSessionManager manager];
    
    [sessionManager GET:stringForURL parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"no errors from search");
        NSMutableArray *matchingArtists = [NSMutableArray new];
        
        // add every matched artist to array
        for (NSDictionary *artist in responseObject[@"artists"][@"items"]) {
            [matchingArtists addObject:artist];
        }
        block(YES, matchingArtists);
        return;
    }
                failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    NSLog(@"Error: %@", error);
                    return;
                }
     ];

}

@end
