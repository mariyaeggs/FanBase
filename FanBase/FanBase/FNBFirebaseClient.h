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

+ (void) loginWithEmail:(NSString *)email Password:(NSString *)password;
+ (void) isUserAuthenticatedWithCompletionBlock:(void  (^)(BOOL isAuthenticatedUser))block;
+ (void) createANewUserWithEmail:(NSString *)email Password:(NSString *)password;

+ (void) setPropertiesOfLoggedInUserToUser: (FNBUser *)user withCompletionBlock: (void (^) (BOOL updateHappened))updateBlockOfLoggedInUser;
+ (void) logoutUser;

//User and Artist methods
+ (void) addCurrentUser:(FNBUser *)currentUser andArtistToEachOthersDatabases:(FNBArtist *)newArtist;
+ (void) deleteCurrentUser:(FNBUser *)currentUser andArtistFromEachOthersDatabases:(FNBArtist *)newArtist;

#pragma mark - Methods For Us to Test App
+ (void)fillUser:(FNBUser *)user WithDummyDataWithCompletionBlock: (void (^) (BOOL madeDummyUser))completionBlock;
@end
