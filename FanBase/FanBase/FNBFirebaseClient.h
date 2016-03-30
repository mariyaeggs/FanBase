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
//@property (strong, nonatomic) Firebase *ref;

+ (void) loginWithEmail:(NSString *)email Password:(NSString *)password;
+ (void) isUserAuthenticatedWithCompletionBlock:(void  (^)(BOOL isAuthenticatedUser))block;
+ (void) createNewUserWithEmail:(NSString *)email Password:(NSString *)password WithBlockIfSuccessful:(void (^) (BOOL successfulCreationOfNewUser, NSString *receivedEmail, NSString *receivedPassword, NSString *createdUID)) successBlock;
+ (void) addNewUserToDatabaseWithEmail:(NSString *)email Password:(NSString *)password UID:(NSString *)uid;
//+ (void) getPropertiesOfUserWithUID:(NSString *)uid;
//+ (void) getPropertiesOfLoggedInUser;

//+ (void) setPropertiesOfUser: (FNBUser *)user WithUID:(NSString *)uid withCompletionBlock: (void (^) (BOOL updateHappened))updateBlock;
+ (void) setPropertiesOfLoggedInUserToUser: (FNBUser *)user withCompletionBlock: (void (^) (BOOL updateHappened))updateBlockOfLoggedInUser;
+ (void) logoutUser;
//+ (void) addArtist:(FNBArtist *)artist ToDatabaseOfUser:(FNBUser *)user;
//+ (void) deleteArtist:(FNBArtist *)artist FromUser:(FNBUser *)user;

// Private artist methods
//+ (void) createNewArtistDatabaseEntry:(FNBArtist *)artist createdByUser:(FNBUser *)user;
//+ (void) addUser: (FNBUser *)user ToExistingArtistDatabase:(FNBArtist *)artist;
//+ (void) checkDatabaseEntryForArtist:(FNBArtist *) artist withCompletionBlock: (void (^) (BOOL artistDatabaseExists))block;
//+ (void) addUser: (FNBUser *)inputtedUser ToArtistDatabase:(FNBArtist *)artist;
//+ (void) deleteUser:(FNBUser *)user FromArtist:(FNBArtist *)artist;

//User and Artist methods
+ (void) addCurrentUser:(FNBUser *)currentUser andArtistToEachOthersDatabases:(FNBArtist *)newArtist;
+ (void) deleteCurrentUser:(FNBUser *)currentUser andArtistFromEachOthersDatabases:(FNBArtist *)newArtist;
@end
