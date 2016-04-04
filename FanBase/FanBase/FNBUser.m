//
//  FNBUser.m
//  FirebaseGettingUserInfo
//
//  Created by Andy Novak on 3/29/16.
//  Copyright © 2016 Andy Novak. All rights reserved.
//
#import "FNBUser.h"

@implementation FNBUser

//initialize existing user from Firebase
//-(instancetype)initWithAuthData:(FAuthData *)authData {
//    self = [super init];
//    if (self) {
//        _userID = authData.uid;
//        _email = authData.providerData[@"email"];
//        _artistsDictionary = [[NSDictionary alloc] init];
//    }
//    return self;
//}

-(instancetype)init{
    self = [super init];
    if (self) {
        _artistsDictionary = [[NSMutableDictionary alloc] init];
        _userID = @"firebaseFred";
        _email = @"";
        _password = @"";
    }
    return self;
}

@end
