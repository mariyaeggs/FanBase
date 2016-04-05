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
#import "FNBSpotifySearch.h"

@interface FNBFirebaseClient : NSObject

#pragma mark - User Login Methods
+ (void) loginWithEmail:(NSString *)email Password:(NSString *)password;
+ (void) logoutUser;
// use when you transition to a new VC and want to see if user or guest
+ (void) checkOnceIfUserIsAuthenticatedWithCompletionBlock: (void (^) (BOOL isAuthenticUser))blockOfAuthUserCheck;
// use when waiting for a user to sign in
+ (void) checkUntilUserisAuthenticatedWithCompletionBlock:(void  (^)(BOOL isAuthenticatedUser))block;

#pragma mark - User Methods
+ (void) createANewUserInDatabaseWithEmail:(NSString *)email Password:(NSString *)password;
+ (void) setPropertiesOfLoggedInUserToUser: (FNBUser *)user withCompletionBlock: (void (^) (BOOL completedSettingUsersProperties))completionBlockOfLoggedInUser;

#pragma mark - Artist Methods
+ (void) setPropertiesOfArtist:(FNBArtist *)artist FromDatabaseWithCompletionBlock: (void (^) (BOOL setPropertiesUpdated)) setArtistPropertiesUpdatedBlock;
+ (void) makeDatabaseEntryForArtistFromSpotifyDictionary: (NSDictionary *)artistSpotifyDictionary withCompletionBlock: (void (^) (BOOL artistDatabaseCreated)) makeDatabaseCompletionBlock;


+ (void) checkExistanceOfDatabaseEntryForArtistName:(NSString *) artistName withCompletionBlock: (void (^) (BOOL artistDatabaseExists))block;

#pragma mark - Adding and Deleting User and Artist Methods
+ (void) addCurrentUser:(FNBUser *)currentUser andArtistToEachOthersDatabases:(NSDictionary *)newArtistDictionary;
+ (void) deleteCurrentUser:(FNBUser *)currentUser andArtistFromEachOthersDatabases:(NSString *)newArtistName;

#pragma mark - Methods For Us to Test App
//+ (void)fillUser:(FNBUser *)user WithDummyDataWithCompletionBlock: (void (^) (BOOL madeDummyUser))completionBlock;

// get array of all artists from database
+ (void) getArrayOfAllArtistsInDatabaseWithCompletionBlock: (void (^) (BOOL completed, NSArray *artistsArray))block;
+ (void) fillDatabaseWithArrayOfArtists:(NSArray *)artistNames;

@end
