//
//  FNBBandsInTownAPIClient.h
//  FanBase
//
//  Created by Angelica Bato on 4/4/16.
//  Copyright © 2016 Angelica Bato. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import "Secrets.h"
#import "FNBUser.h"


@interface FNBBandsInTownAPIClient : NSObject

+(void)generateEventsForArtist:(NSString *)artistName completion:(void(^)(NSArray *))completionBlock;

//+(void)generateEventsForArtist:(NSString *)artistName nearLocation:(nullable NSString *)location withinRadius:(nullable NSString *)radius completion:(void (^)( NSArray *))completionBlock;

+(void)generateEventsForArtists:(nonnull NSArray *)artistNamesArray nearLocation:(nullable NSString *)location withinRadius:(nullable NSString *)radius completion:(nullable void (^)( NSArray * _Nullable ))completionBlock ;


+(void)getUpcomingConcertsOfUser:(FNBUser *)user withCompletion:(void (^)(NSArray *sortedConcertsArray))completionBlock;

@end
