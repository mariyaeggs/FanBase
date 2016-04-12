//
//  FNBSpotifySearch.h
//  FanBase
//
//  Created by Andy Novak on 3/31/16.
//  Copyright © 2016 Angelica Bato. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FNBSpotifySearch : NSObject

+ (void) getArrayOfMatchingArtistsFromSearch:(NSString *)searchString withCompletionBlock: (void (^) (BOOL gotMatchingArtists, NSArray *matchingArtistsArray))block;
+ (void) getArtistDictionaryFromSpotifyID:(NSString *)spotifyID withCompletionBlock: (void (^) (BOOL gotMatchingArtist, NSDictionary *artistDictionary))block;

@end
