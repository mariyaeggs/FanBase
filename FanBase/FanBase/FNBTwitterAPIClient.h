//
//  TwitterAPIClient.h
//  FanBase
//
//  Created by Angelica Bato on 3/29/16.
//  Copyright © 2016 Angelica Bato. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <STTwitter/STTwitter.h>



@interface FNBTwitterAPIClient : NSObject

+ (void) generateTweetsForKeyword:(NSString *)keyword completion:(void(^)(NSArray *))completionBlock;

+ (void) generateTweetsOfUsername:(NSString *)username completion:(void(^)(NSArray *))completionBlock;



@end
