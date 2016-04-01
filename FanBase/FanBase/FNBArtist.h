//
//  FNBArtist.h
//  FanBase
//
//  Created by Andy Novak on 3/30/16.
//  Copyright © 2016 Angelica Bato. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FNBArtist : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *spotifyID;
@property (strong, nonatomic) NSString *twitterHandle;
@property (strong, nonatomic) NSMutableDictionary *subscribedUsers;
@property (strong, nonatomic) NSString *imageURLSize640;
@property (strong, nonatomic) NSString *imageURLSize64;



-(instancetype) initWithName:(NSString *)name;


@end
