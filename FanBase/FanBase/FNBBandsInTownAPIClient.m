//
//  FNBBandsInTownAPIClient.m
//  FanBase
//
//  Created by Angelica Bato on 4/4/16.
//  Copyright © 2016 Angelica Bato. All rights reserved.
//

#import "FNBBandsInTownAPIClient.h"

@implementation FNBBandsInTownAPIClient

+(void)generateEventsForArtist:(NSString *)artistName completion:(void (^)(NSArray *))completionBlock {
    
    NSString *escapedArtistName = [artistName stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/%@/%@",BandsInTownBaseURL,escapedArtistName,BandsInTownEventsURL];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    [manager GET:urlString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        completionBlock(responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Oh No! Something went wrong in the BandsInTown GET request!");
    }];
    
}

@end
