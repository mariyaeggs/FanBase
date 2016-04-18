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

@end
