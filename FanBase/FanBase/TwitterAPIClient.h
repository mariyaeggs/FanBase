//
//  TwitterAPIClient.h
//  FanBase
//
//  Created by Angelica Bato on 3/29/16.
//  Copyright © 2016 Angelica Bato. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <STTwitter/STTwitter.h>


@interface TwitterAPIClient : NSObject

+(void)generateTweetsWithCompletion:(void(^)(NSArray *))block;


@end
