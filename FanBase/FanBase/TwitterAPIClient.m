//
//  TwitterAPIClient.m
//  FanBase
//
//  Created by Angelica Bato on 3/29/16.
//  Copyright © 2016 Angelica Bato. All rights reserved.
//

#import "TwitterAPIClient.h"
#import "Secrets.h"

@implementation TwitterAPIClient

+(void)generateTweetsWithCompletion:(void(^)(NSArray *))block {
    
    STTwitterAPI *twitterAPI = [STTwitterAPI twitterAPIWithOAuthConsumerKey:STTwitterClientID consumerSecret:STTwitterSecret];
    
    [twitterAPI getSearchTweetsWithQuery:@"Adele" successBlock:^(NSDictionary *searchMetadata, NSArray *statuses) {
        block(statuses);
    } errorBlock:nil];
    
}


@end
