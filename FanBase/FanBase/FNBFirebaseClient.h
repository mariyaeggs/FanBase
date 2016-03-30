//
//  FNBFirebaseClient.h
//  FirebaseGettingUserInfo
//
//  Created by Andy Novak on 3/29/16.
//  Copyright © 2016 Andy Novak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Firebase/Firebase.h>
#import "Secrets.h"
#import "FNBUser.h"

@interface FNBFirebaseClient : NSObject
//@property (strong, nonatomic) Firebase *ref;

+ (void) loginWithEmail:(NSString *)email Password:(NSString *)password;
+ (void) isUserAuthenticatedWithCompletionBlock:(void  (^)(BOOL isAuthenticatedUser))block;
+ (void) createNewUserWithEmail:(NSString *)email Password:(NSString *)password WithBlockIfSuccessful:(void (^) (BOOL successfulCreationOfNewUser, NSString *receivedEmail, NSString *receivedPassword, NSString *createdUID)) successBlock;
+ (void) addNewUserToDatabaseWithEmail:(NSString *)email Password:(NSString *)password UID:(NSString *)uid;
//+ (void) getPropertiesOfUserWithUID:(NSString *)uid;
//+ (void) getPropertiesOfLoggedInUser;

+ (void) setPropertiesOfUser: (FNBUser *)user WithUID:(NSString *)uid withCompletionBlock: (void (^) (BOOL updateHappened))updateBlock;
+ (void) setPropertiesOfLoggedInUserToUser: (FNBUser *)user withCompletionBlock: (void (^) (BOOL updateHappened))updateBlockOfLoggedInUser;
@end
