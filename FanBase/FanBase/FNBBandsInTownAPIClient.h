//
//  FNBBandsInTownAPIClient.h
//  FanBase
//
//  Created by Angelica Bato on 4/4/16.
//  Copyright © 2016 Angelica Bato. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import "Secrets.h"

@interface FNBBandsInTownAPIClient : NSObject

+(void)generateEventsForArtist:(NSString *)artistName completion:(void(^)(NSArray *))completionBlock;

@end
