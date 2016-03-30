//
//  FNBInstagramAPIClient.m
//  FanBase
//
//  Created by Angelica Bato on 3/30/16.
//  Copyright © 2016 Angelica Bato. All rights reserved.
//

#import "FNBInstagramAPIClient.h"
#import <AFNetworking/AFNetworking.h>
#import <AFOAuth2Manager/AFOAuth2Manager.h>
#import <AFOAuth2Manager/AFHTTPRequestSerializer+OAuth2.h>


@implementation FNBInstagramAPIClient

//https://api.instagram.com/oauth/authorize/?client_id=CLIENT-ID&redirect_uri=REDIRECT-URI&response_type=code instagram API OAuth Req

-(void)fetchUserDetails {
    NSString *urlString = [NSString stringWithFormat:@"https://api.instagram.com/oauth/authorize/?client_id=%@&redirect_uri=%@&response_type=code ", ];
}

@end
