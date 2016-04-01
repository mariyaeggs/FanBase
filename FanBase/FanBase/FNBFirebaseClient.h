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
#import "FNBArtist.h"

@interface FNBFirebaseClient : NSObject

#pragma mark - User Login Methods
+ (void) loginWithEmail:(NSString *)email Password:(NSString *)password;
+ (void) isUserAuthenticatedWithCompletionBlock:(void  (^)(BOOL isAuthenticatedUser))block;
+ (void) createANewUserWithEmail:(NSString *)email Password:(NSString *)password;
+ (void) logoutUser;
+ (void) checkIfUserIsAuthenticatedWithCompletionBlock: (void (^) (BOOL isAuthenticUser))blockOfAuthUserCheck;

#pragma mark - User Methods
+ (void) setPropertiesOfLoggedInUserToUser: (FNBUser *)user withCompletionBlock: (void (^) (BOOL updateHappened))updateBlockOfLoggedInUser;

#pragma mark - Artist Methods
+ (void) setPropertiesOfArtist:(FNBArtist *)artist withCompletionBlock: (void (^) (BOOL setPropertiesUpdated)) setArtistPropertiesUpdatedBlock;

#pragma mark - User and Artist Methods
+ (void) addCurrentUser:(FNBUser *)currentUser andArtistToEachOthersDatabases:(FNBArtist *)newArtist;
+ (void) deleteCurrentUser:(FNBUser *)currentUser andArtistFromEachOthersDatabases:(FNBArtist *)newArtist;

#pragma mark - Methods For Us to Test App
+ (void)fillUser:(FNBUser *)user WithDummyDataWithCompletionBlock: (void (^) (BOOL madeDummyUser))completionBlock;
@end
