//
//  FNBInstagramAPIClient.h
//  FanBase
//
//  Created by Angelica Bato on 3/30/16.
//  Copyright © 2016 Angelica Bato. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FNBInstagramAPIClient : NSObject

+(void) generateInstagramPostsByKeyword:(NSString *)keyword completion:(void (^)(NSDictionary *))completionBlock;

+(void) generateInstagramPostsByUser:(NSString *)userName completion:(void (^)(NSDictionary *))completionBlock;

@end
