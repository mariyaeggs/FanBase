//
//  NSURL+QueryString.m
//  FanBase
//
//  Created by Angelica Bato on 3/31/16.
//  Copyright © 2016 Angelica Bato. All rights reserved.
//

#import "NSURL+QueryString.h"

@implementation NSURL (QueryString)

- (NSString *) valueForFragment {
    NSURLComponents *urlComps = [NSURLComponents componentsWithURL:self resolvingAgainstBaseURL:nil];
    NSString *fragmentItems = urlComps.fragment;
    
    NSLog(@"What is fragmentItems: %@",fragmentItems);
    NSString *key = @"access_token=";
    NSString *fragmentWithoutKey = [fragmentItems substringFromIndex:key.length];
    NSLog(@"fragment: %@",fragmentWithoutKey);
    
    return fragmentWithoutKey;
}

//-(NSString *)valueForFirstQueryItemNamed:(NSString *)name
//{
//    NSURLComponents *urlComps = [NSURLComponents componentsWithURL:self resolvingAgainstBaseURL:nil];
//    NSString *fragmentItems = urlComps.fragment;
//    
//    NSLog(@"What is fragmentItems: %@",fragmentItems);
////    NSArray *queryItems = urlComps.queryItems;
//    
//    NSLog(@"What is urlComps: %@", urlComps)    ;
////    NSLog(@"What is queryItems: %@", queryItems)    ;
//    
////    for(NSURLQueryItem *queryItem in queryItems) {
////        
////        NSLog(@"queryItem: %@", queryItem);
////        NSLog(@"name of QueryItem: %@", queryItem.name);
////        NSLog(@"value of query iTem: %@", queryItem.value);
////        
////        if([queryItem.name isEqualToString:name]) {
////            return queryItem.value;
////        }
////    }
//    
//    return nil;
//}

@end
