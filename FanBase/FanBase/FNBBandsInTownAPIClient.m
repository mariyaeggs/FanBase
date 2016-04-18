//
//  FNBBandsInTownAPIClient.m
//  FanBase
//
//  Created by Angelica Bato on 4/4/16.
//  Copyright © 2016 Angelica Bato. All rights reserved.
//

#import "FNBBandsInTownAPIClient.h"
#import "FNBUser.h"
#import "FNBArtistEvent.h"

@implementation FNBBandsInTownAPIClient

+(void)generateEventsForArtist:(NSString *)artistName completion:(void (^)(NSArray *))completionBlock {
    
    NSString *escapedArtistName = [artistName stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/%@/%@",BandsInTownBaseURL,escapedArtistName,BandsInTownEventsURL];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    [manager GET:urlString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        NSMutableArray *collectionOfEventObjects = [NSMutableArray new];
        
        for (NSDictionary *dict in responseObject) {
//            FNBArtistEvent *event = [[FNBArtistEvent alloc] initWithEventTitle:dict[@"title"] date:dict[@"formatted_datetime"] availability:YES venue:dict[@"venue"] star:YES];
            FNBArtistEvent *event = [[FNBArtistEvent alloc] initWithEventTitle:dict[@"title"] date:dict[@"formatted_datetime"] availability:YES venue:dict[@"venue"] star:YES image:dict[@"artists"][0][@"image_url"]];
            [collectionOfEventObjects addObject:event];
        
        
        }
        
        NSLog(@"THIS IS MY EVENT INFO %@",collectionOfEventObjects);
        completionBlock(collectionOfEventObjects);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Oh No! Something went wrong in the BandsInTown GET request!");
        NSLog(@"%@",error.description);
    }];
    
}

+(void)generateEventsForArtist:(NSString *)artistName nearLocation:(nullable NSString *)location withinRadius:(nullable NSString *)radius completion:(void (^)(NSArray *))completionBlock {

    // if no specified location, use ip address location
    NSString *userLocation = [NSString new];
    if (!location) {
        userLocation = @"use_geoip";
    }
    else {
        userLocation = [location stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    }
    
    NSString *escapedArtistName = [artistName stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    
    NSString *urlString = [NSString new];
    
    // if no radius, default is 25 miles
    if (!radius) {
        urlString = [NSString stringWithFormat:@"%@/%@/%@&location=%@",BandsInTownBaseURL,escapedArtistName,BandsInTownEventsNearbyURL, userLocation];
    }
    else {
        urlString = [NSString stringWithFormat:@"%@/%@/%@&location=%@&rasius=%@",BandsInTownBaseURL,escapedArtistName,BandsInTownEventsNearbyURL, userLocation, radius];
    }
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    [manager GET:urlString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        NSMutableArray *collectionOfEventObjects = [NSMutableArray new];
        
        for (NSDictionary *dict in responseObject) {
            FNBArtistEvent *event = [[FNBArtistEvent alloc] initWithEventTitle:dict[@"title"] date:dict[@"formatted_datetime"] availability:YES venue:dict[@"venue"] star:YES image:dict[@"artists"][0][@"image_url"] unformattedDate:dict[@"datetime"]];
            [collectionOfEventObjects addObject:event];
        }
        
//        NSLog(@"%@",collectionOfEventObjects);
        completionBlock(collectionOfEventObjects);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Oh No! Something went wrong in the BandsInTown GET nearby artists request for artist %@!", artistName);
        NSLog(@"%@",error.description);
        if (error.code == -1011) {
            completionBlock(@[]);
        }
    }];
    
}

+(void)generateEventsForArtists:(NSArray *)artistNamesArray nearLocation:(nullable NSString *)location withinRadius:(nullable NSString *)radius completion:(void (^)(NSArray *))completionBlock {
    NSMutableArray *allUpcomingConcerts = [NSMutableArray new];
    __block NSUInteger counter = 0;
    for (NSString *artistName in artistNamesArray) {
        [self generateEventsForArtist:artistName nearLocation:location withinRadius:radius completion:^(NSArray *specificArtistEventsArray) {
            counter ++;
            if (specificArtistEventsArray.count > 0) {
                // add all events to allUpcomingConcerts array
                for (FNBArtistEvent *event in specificArtistEventsArray) {
                    [allUpcomingConcerts addObject:event];
                }
            }
            if (counter == artistNamesArray.count) {
//                NSLog(@"ALL UPCOMING CONCERTS%@", ((FNBArtistEvent *)allUpcomingConcerts[0]).unformattedDateOfConcert);
                completionBlock(allUpcomingConcerts);
            }
        }];
    }
}


@end
