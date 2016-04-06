//
//  FNBUser.h
//  FirebaseGettingUserInfo
//
//  Created by Andy Novak on 3/29/16.
//  Copyright © 2016 Andy Novak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Firebase/Firebase.h>


@interface FNBUser : NSObject
@property (strong, nonatomic) NSMutableDictionary *artistsDictionary;
@property (strong, nonatomic) NSString *userID;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) NSString *profileImageURL;
@property (strong, nonatomic) NSArray *detailedArtistInfoArray;


-(instancetype)init;
//-(instancetype)initWithAuthData:(FAuthData *)authData;

@end
