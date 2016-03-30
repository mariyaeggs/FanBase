//
//  TwitterAPIClient.m
//  FanBase
//
//  Created by Angelica Bato on 3/29/16.
//  Copyright © 2016 Angelica Bato. All rights reserved.
//

#import "FNBTwitterAPIClient.h"
#import "FNBSecrets.h"

@implementation FNBTwitterAPIClient

+ (void) generateTweetsForKeyword:(NSString *)keyword completion:(void(^)(NSArray *))completionBlock {
    
    STTwitterAPI *twitterAPI = [STTwitterAPI twitterAPIWithOAuthConsumerKey:STTwitterClientID consumerSecret:STTwitterSecret];
    
    [twitterAPI getSearchTweetsWithQuery:keyword successBlock:^(NSDictionary *searchMetadata, NSArray *statuses) {
        completionBlock(statuses);
    } errorBlock:nil];
    
}

+ (void) generateTweetsOfUsername:(NSString *)username completion:(void(^)(NSArray *))completionBlock {
    STTwitterAPI *twitterAPI = [STTwitterAPI twitterAPIWithOAuthConsumerKey:STTwitterClientID consumerSecret:STTwitterSecret];
    [twitterAPI getUserTimelineWithScreenName:username
                              successBlock:^(NSArray *statuses) {
                                  completionBlock(statuses);
                                  
                              } errorBlock:^(NSError *error) {
                                  NSLog(@"Something went wrong when generating a user's posts.");
                              }];

}


@end
