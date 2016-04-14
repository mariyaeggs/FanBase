//
//  FNBArtist.m
//  FanBase
//
//  Created by Andy Novak on 3/30/16.
//  Copyright © 2016 Angelica Bato. All rights reserved.
//

#import "FNBArtist.h"


@implementation FNBArtist

-(instancetype)init {
    self = [super init];
    if (self) {
        _name = @"";
        _spotifyID = @"";
        _subscribedUsers = [NSMutableDictionary new];
        _twitterHandle = @"";
        _imagesArray = [NSArray new];
        _genres = [NSArray new];
    }
    return self;
}

-(instancetype) initWithName:(NSString *)name {
    self = [super init];
    if (self) {
        _name = name;
        _spotifyID = @"";
        _subscribedUsers = [NSMutableDictionary new];
        _twitterHandle = @"";
        _imagesArray = [NSArray new];
        _genres = [NSArray new];
        
    }
    return self;
}


-(NSDictionary*)firebaseValue{
    return @{@"name":self.name,
             @"spotifyID":self.spotifyID};
}

@end
