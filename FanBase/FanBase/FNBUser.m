//
//  FNBUser.m
//  FirebaseGettingUserInfo
//
//  Created by Andy Novak on 3/29/16.
//  Copyright © 2016 Andy Novak. All rights reserved.
//
#import "FNBUser.h"

@implementation FNBUser


-(instancetype)init{
    self = [super init];
    if (self) {
        _artistsDictionary = [[NSMutableDictionary alloc] init];
        _userID = @"firebaseFred";
        _email = @"";
//        _password = @"";
        _profileImageURL = @"";
        _userName = @"default username";
        _detailedArtistInfoArray = [NSArray new];
        _rankingAndImagesForEachArtist = [NSArray new];
    }
    return self;
}

- (NSArray *) getArtistInfoForLabels {
    // figure out rank for each artist in array
    NSMutableArray *arrayToFill = [NSMutableArray new];
    for (FNBArtist *artist in self.detailedArtistInfoArray) {
        //                        NSLog(@"this is artist %@, and their subscribed Users: %@", artist.name, artist.subscribedUsers);
        // create an array of dictionaries
        NSMutableArray *subscribedUsersArray = [NSMutableArray new];
        for (NSString *key in artist.subscribedUsers) {
            NSDictionary *result = @{ @"userID" : key ,
                                      @"points" : [artist.subscribedUsers objectForKey:key]
                                      };
            [subscribedUsersArray addObject:result];
        }
        // now sort this array by points
        NSSortDescriptor *pointsDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"points" ascending:NO];
        NSArray *sortedArray = [subscribedUsersArray sortedArrayUsingDescriptors:@[pointsDescriptor]];
        //                        NSLog(@"artist: %@ and their array of users: %@", artist.name, sortedArray);
        
        // now find what number current user is in the array
        NSInteger currentUsersRank = [sortedArray indexOfObjectPassingTest:^BOOL(NSDictionary *dict, NSUInteger idx, BOOL * _Nonnull stop) {
            return [[dict objectForKey:@"userID"] isEqual:self.userID];
        }];
        NSDictionary *rankingDictionary = @{
                                            @"artistName" : artist.name ,
                                            @"usersRank" : @(currentUsersRank + 1),
                                            @"numberOfFollowers" : @(sortedArray.count),
                                            @"artistImageURL" : artist.imagesArray[0][@"url"],
                                            @"artistSpotifyID" : artist.spotifyID
                                            };
        [arrayToFill addObject:rankingDictionary];
        //        NSLog(@"users rank for artist: %@ is: %li out of %li", artist.name,currentUsersRank + 1, sortedArray.count);
    }
    
    // sort by user Rank
    NSSortDescriptor *sortByArtistRankDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"usersRank" ascending:YES];
    NSArray *sortedArray = [arrayToFill sortedArrayUsingDescriptors:@[sortByArtistRankDescriptor]];
//    NSLog(@"This is the sorted array of artists for the label: %@", sortedArray);
    
    return sortedArray;
}


@end
