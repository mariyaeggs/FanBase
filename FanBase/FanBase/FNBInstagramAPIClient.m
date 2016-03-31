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
#import "Secrets.h"
#import <SafariServices/SafariServices.h>


@implementation FNBInstagramAPIClient

+(void) generateInstagramPostsByKeyword:(NSString *)keyword completion:(void (^)(NSDictionary *))completionBlock {
    AFOAuthCredential *credential = [AFOAuthCredential retrieveCredentialWithIdentifier:@"IGCredential"];
    NSString *urlString = [NSString stringWithFormat:@"https://api.instagram.com/v1/tags/%@/media/recent?access_token=%@",keyword,credential.accessToken];
    NSLog(@"%@",credential.accessToken);
    
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:urlString parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        
        completionBlock(responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSLog(@"Something went wrong!");
        NSLog(@"%@", error.description);
        
    }];
}

+(void)generateInstagramPostsByUser:(NSString *)userName completion:(void (^)(NSDictionary *))completionBlock {
    AFOAuthCredential *credential = [AFOAuthCredential retrieveCredentialWithIdentifier:@"IGCredential"];
    NSString *urlString = [NSString stringWithFormat:@"https://api.instagram.com/v1/users/search?q=%@&access_token=%@",userName,credential.accessToken];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:urlString parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        completionBlock(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Something with the user went wrong!");
    }];
}

@end
