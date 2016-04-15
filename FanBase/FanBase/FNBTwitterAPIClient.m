//
//  TwitterAPIClient.m
//  FanBase
//
//  Created by Angelica Bato on 3/29/16.
//  Copyright © 2016 Angelica Bato. All rights reserved.
//

#import "FNBTwitterAPIClient.h"
#import "Secrets.h"

@implementation FNBTwitterAPIClient

+ (void) generateTweetsForKeyword:(NSString *)keyword completion:(void(^)(NSArray *))completionBlock {
    
    STTwitterAPI *twitterAPI = [STTwitterAPI twitterAPIWithOAuthConsumerKey:TwitterClientID consumerSecret:TwitterSecret];
    
    [twitterAPI getSearchTweetsWithQuery:keyword successBlock:^(NSDictionary *searchMetadata, NSArray *statuses) {
//        NSLog(@"these are the statuses: %@", statuses);
        completionBlock(statuses);
    } errorBlock:nil];
    
}

+ (void) generateTweetsOfUsername:(NSString *)username completion:(void(^)(NSArray *))completionBlock {
    STTwitterAPI *twitterAPI = [STTwitterAPI twitterAPIWithOAuthConsumerKey:TwitterClientID consumerSecret:TwitterSecret];
    [twitterAPI getUserTimelineWithScreenName:username
     
                              successBlock:^(NSArray *statuses) {
                                  completionBlock(statuses);
                                  
                              } errorBlock:^(NSError *error) {
                                  NSLog(@"Something went wrong when generating a user's tweets.");
                                  //send an empty array
                                  completionBlock(@[]);
                              }];

}




@end
