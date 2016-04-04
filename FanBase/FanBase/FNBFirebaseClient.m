//
//  FNBFirebaseClient.m
//  FirebaseGettingUserInfo
//
//  Created by Andy Novak on 3/29/16.
//  Copyright © 2016 Andy Novak. All rights reserved.
//

#import "FNBFirebaseClient.h"

@implementation FNBFirebaseClient

#pragma mark - Firebase Constant Methods

+ (Firebase *) setupBaseFirebase{
    return [[Firebase alloc] initWithUrl:ourFirebaseURL];
}

+ (Firebase *) setupUserFirebase {
    Firebase *ref = [self setupBaseFirebase];
    return [ref childByAppendingPath:@"users"];
}

+ (Firebase *) setupArtistFirebase {
    Firebase *ref = [self setupBaseFirebase];
    return [ref childByAppendingPath:@"artists"];
}

#pragma mark - User Login Methods

+ (void) loginWithEmail:(NSString *)email Password:(NSString *)password {
    Firebase *ref = [self setupBaseFirebase];
    [ref authUser:email password:password withCompletionBlock:^(NSError *error, FAuthData *authData) {
        if (error) {
            // There was an error logging in to this account
            NSLog(@"There was an error logging in to this account");
        } else {
            // We are now logged in
            NSLog(@"We are now logged in");
        }

    }];
}

+ (void) logoutUser {
    Firebase *ref =  [self setupBaseFirebase];
    [ref unauth];
}

// This method sets the properties of the FNBUser based on the logged in user.
+ (void) checkOnceIfUserIsAuthenticatedWithCompletionBlock: (void (^) (BOOL isAuthenticUser))blockOfAuthUserCheck{
    Firebase *ref = [self setupBaseFirebase];
    if (ref.authData != nil) {
        NSLog(@"this is a logged in user");
        blockOfAuthUserCheck(YES);
    }
    else {
        NSLog(@"This is a guest");
        blockOfAuthUserCheck(NO);
    }
}

+ (void) checkUntilUserisAuthenticatedWithCompletionBlock:(void  (^)(BOOL isAuthenticatedUser))block {
    Firebase *ref = [self setupBaseFirebase];
    [ref observeAuthEventWithBlock:^(FAuthData *authData) {
        if (authData != nil) {
            //say we are logged in as authenticated user
            NSLog(@"we are logged in as an authenticated user");
            //tell the caller user is authenticated
            block(YES);
        }
        else {
            NSLog(@"not an authenticated user");
            block(NO);
        }
    }];
}


#pragma mark - User Methods


// helper method for creating a new user
// this method creates new user, and passes email, password, UID, and a completion bool to the block
+ (void) createNewUserInDatabaseWithEmail:(NSString *)email Password:(NSString *)password WithBlockIfSuccessful:(void (^) (BOOL successfulCreationOfNewUser, NSString *receivedEmail, NSString *receivedPassword, NSString *createdUID)) successBlock {
    Firebase *ref = [self setupBaseFirebase];
    
    [ref createUser:email password:password withValueCompletionBlock:^(NSError *error, NSDictionary *result) {
        if (error) {
            // There was an error creating the account
            NSLog(@"There was an error creating the account. error : %@", error);
            successBlock(NO, nil, nil, nil);
        }
        else {
            NSString *uid = [result objectForKey:@"uid"];
            NSLog(@"Successfully created user account with uid: %@", uid);
            successBlock(YES, email, password, uid);
        }
    }];
}

// helper method for creating a new user
+ (void) addNewUserToDatabaseWithEmail:(NSString *)email Password:(NSString *)password UID:(NSString *)uid {
    Firebase *usersRef = [self setupUserFirebase];
    Firebase *newUserRef = [usersRef childByAppendingPath:uid];
    
    // this is what the initial user gets as values
    NSDictionary *initialUserValues = @{@"UID" : uid, @"email": email , @"password": password, @"artistsDictionary" : [NSMutableDictionary new]};
    [newUserRef setValue:initialUserValues];
    NSLog(@"Added user to database");
}

+ (void) createANewUserInDatabaseWithEmail:(NSString *)email Password:(NSString *)password {
    [self createNewUserInDatabaseWithEmail:email Password:password WithBlockIfSuccessful:^(BOOL successfulCreationOfNewUser, NSString *receivedEmail, NSString *receivedPassword, NSString *createdUID) {
        //if successfully created new user, add them to database and login that user
        if (successfulCreationOfNewUser) {
            NSLog(@"created user!!!!! emails: %@", receivedEmail);
            
            // add user to database
            [self addNewUserToDatabaseWithEmail:receivedEmail Password:receivedPassword UID:createdUID];
            
            // login user
            [self loginWithEmail:receivedEmail Password:receivedPassword];
            NSLog(@"logged in user");
        }
    }];
}

// Helper method for setPropertiesOfLoggedInUserToUser.
// This method sets the properties of the FNBUser whenever an update happens.
+ (void) setPropertiesOfUser: (FNBUser *)user WithUID:(NSString *)uid withCompletionBlock: (void (^) (BOOL updateHappened))updateBlock {
//    NSLog(@"this is the uid: %@", uid);
    Firebase *usersRef = [self setupUserFirebase];
    Firebase *newUserRef = [usersRef childByAppendingPath:uid];
    
    // This block gets called for any change in this users data
    [newUserRef observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
//        NSLog(@"Snapshot of Users values: %@", snapshot.value);
        user.email = snapshot.value[@"email"];
        user.userID = snapshot.value[@"UID"];
        user.password = snapshot.value[@"password"];
        user.artistsDictionary = snapshot.value[@"artistsDictionary"];
        updateBlock(YES);
        
    } withCancelBlock:^(NSError *error) {
        NSLog(@"%@", error.description);
    }];
}

// This method sets the properties of the FNBUser based on the logged in user.
+ (void) setPropertiesOfLoggedInUserToUser: (FNBUser *)user withCompletionBlock: (void (^) (BOOL updateHappened))updateBlockOfLoggedInUser{
    Firebase *ref = [self setupBaseFirebase];
    [ref observeAuthEventWithBlock:^(FAuthData *authData) {
        NSLog(@"this is the authData of getpropofLoggedInUser: %@", authData);
        if (authData != nil) {
            [self setPropertiesOfUser:user WithUID:authData.uid withCompletionBlock:^(BOOL updateHappened) {
                updateBlockOfLoggedInUser(YES);
            }];
        }
        else {
            NSLog(@"authData is nil");
        }
    }];
}



#pragma mark - Artist Methods

//+ (void) createNewArtistDatabaseEntry:(NSString *)artistName createdByUser:(FNBUser *)user {
//    Firebase *artistsRef = [self setupArtistFirebase];
//    Firebase *newArtistRef = [artistsRef childByAppendingPath:artistName];
//    // this is what the initial artist gets as values
//    NSDictionary *initialArtistValues = @{@"name" : artistName, @"spotifyID": artist.spotifyID , @"twitterHandle": artist.twitterHandle, @"subscribedUsers" : @{user.userID : @0}};
//    [newArtistRef setValue:initialArtistValues];
//    NSLog(@"Added artist to database");
//    
//}


//+ (void) checkDatabaseEntryForArtist:(FNBArtist *) artist withCompletionBlock: (void (^) (BOOL artistDatabaseExists))block {
//    Firebase *artistsRef = [self setupArtistFirebase];
//    Firebase *newArtistRef = [artistsRef childByAppendingPath:artist.name];
//    [newArtistRef observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
//        if ([snapshot.value isKindOfClass:[NSMutableDictionary class]]) {
////            NSLog(@"value true");
//            block(TRUE);
//        }
//        else {
////            NSLog(@"value false");
//            block(FALSE);
//        }
//    }];
//}

+ (void) checkExistanceOfDatabaseEntryForArtistName:(NSString *) artistName withCompletionBlock: (void (^) (BOOL artistDatabaseExists))block {
    Firebase *artistsRef = [self setupArtistFirebase];
    Firebase *newArtistRef = [artistsRef childByAppendingPath:artistName];
    [newArtistRef observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        if ([snapshot.value isKindOfClass:[NSMutableDictionary class]]) {
            //            NSLog(@"value true");
            block(TRUE);
        }
        else {
            //            NSLog(@"value false");
            block(FALSE);
        }
    }];
}

+ (void) setPropertiesOfArtist:(FNBArtist *)artist FromDatabaseWithCompletionBlock: (void (^) (BOOL setPropertiesUpdated)) setArtistPropertiesUpdatedBlock {
    Firebase *artistsRef = [self setupArtistFirebase];
    Firebase *specificArtistRef = [artistsRef childByAppendingPath:artist.name];
    
    // This block gets called for any change in this artists data
    [specificArtistRef observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
//        NSLog(@"Snapshot of Users values: %@", snapshot.value);
        artist.name = snapshot.value[@"name"];
        artist.spotifyID = snapshot.value[@"spotifyID"];
        artist.twitterHandle = snapshot.value[@"twitterHandle"];
        artist.subscribedUsers = snapshot.value[@"subscribedUsers"];
        artist.genres = snapshot.value[@"genres"];
        setArtistPropertiesUpdatedBlock(YES);
        
    } withCancelBlock:^(NSError *error) {
        NSLog(@"%@", error.description);
    }];

}

+ (void) makeDatabaseEntryForArtistFromSpotifyDictionary: (NSDictionary *)artistSpotifyDictionary {
    Firebase *artistsRef = [self setupArtistFirebase];
    Firebase *currentArtistRef = [artistsRef childByAppendingPath:artistSpotifyDictionary[@"name"]];
    NSLog(@"%@", artistSpotifyDictionary[@"name"]);
    
    NSDictionary *initialArtistValues = @{@"name" : artistSpotifyDictionary[@"name"],
                                          @"spotifyID": artistSpotifyDictionary[@"id"] ,
                                          @"twitterHandle": @"", @"subscribedUsers" : [NSMutableDictionary new],
                                          @"images" : artistSpotifyDictionary[@"images"],
//                                          @"imageURLSize200" : artistSpotifyDictionary[@"images"][2][@"url"],
//                                          @"imageURLSize64" : artistSpotifyDictionary[@"images"][3][@"url"],
                                          @"genres" : artistSpotifyDictionary[@"genres"]};
    [currentArtistRef setValue:initialArtistValues];
    NSLog(@"Added Spotify artist to database");
}

//+ (void) checkIfArtistDatabaseExists:(NSString *)artistName withCompletionBlock: (void (^) (BOOL databaseExists)) completionBlock{
//    Firebase *artistsRef = [self setupArtistFirebase];
//    Firebase *currentArtistRef = [artistsRef childByAppendingPath:artistName];
//    
//}

#pragma mark - User and Artist Methods

// helper method for addCurrentUser:(FNBUser *)currentUser andArtistToEachOthersDatabases
+ (void) addArtist:(NSString *)artistName ToDatabaseOfUser:(FNBUser *)user {
    Firebase *usersRef = [self setupUserFirebase];
    Firebase *currentUserRef = [usersRef childByAppendingPath:user.userID];
    Firebase *usersArtistRef = [currentUserRef childByAppendingPath:@"artistsDictionary"];
    
    NSDictionary *newArtistDictionary = @{artistName : @0};
    [usersArtistRef updateChildValues:newArtistDictionary];
}

// helper method for deleteCurrentUser:(FNBUser *)currentUser andArtistFromEachOthersDatabases:(FNBArtist *)newArtist
+ (void) deleteArtist:(NSString *)artistName FromUser:(FNBUser *)user {
    Firebase *usersRef = [self setupUserFirebase];
    Firebase *currentUserRef = [usersRef childByAppendingPath:user.userID];
    Firebase *usersArtistRef = [currentUserRef childByAppendingPath:@"artistsDictionary"];
    Firebase *specificArtistRef = [usersArtistRef childByAppendingPath:artistName];
    
    [specificArtistRef removeValue];
}

// helper method for addCurrentUser:(FNBUser *)currentUser andArtistToEachOthersDatabases
+ (void) addUser: (FNBUser *)inputtedUser ToArtistDatabase:(NSDictionary *)artistDictionaryFromSpotify {
    NSString *artistName = artistDictionaryFromSpotify[@"name"];
    [self checkExistanceOfDatabaseEntryForArtistName:artistName withCompletionBlock:^(BOOL artistDatabaseExists) {
        if (artistDatabaseExists) {
            NSLog(@"Artist database already exists");
            // add user to existing artist database
            [self addUser:inputtedUser ToExistingArtistDatabase:artistName];
        }
        else {
            NSLog(@"Artist database does not exist");
            [self makeDatabaseEntryForArtistFromSpotifyDictionary:artistDictionaryFromSpotify];
            [self addCurrentUser:inputtedUser andArtistToEachOthersDatabases:artistDictionaryFromSpotify];
//            [self createNewArtistDatabaseEntry:artistName createdByUser:inputtedUser];
        }
    }];
}

// helper method for addCurrentUser andArtistToEachOthersDatabase
+ (void) addUser:(FNBUser *)user ToExistingArtistDatabase:(NSString *)artistName {
    Firebase *artistsRef = [self setupArtistFirebase];
    Firebase *currentArtistRef = [artistsRef childByAppendingPath:artistName];
    Firebase *artistsSubscribedUsersRef = [currentArtistRef childByAppendingPath:@"subscribedUsers"];
    NSDictionary *newUserDictionary = @{user.userID : @0};
    [artistsSubscribedUsersRef updateChildValues:newUserDictionary];
}

// helper method for deleteCurrentUser:(FNBUser *)currentUser andArtistFromEachOthersDatabases:(FNBArtist *)newArtist
+ (void) deleteUser:(FNBUser *)user FromArtist:(NSString *)artistName{
    Firebase *artistsRef = [self setupArtistFirebase];
    Firebase *currentArtistRef = [artistsRef childByAppendingPath:artistName];
    Firebase *artistsSubscribedUsersRef = [currentArtistRef childByAppendingPath:@"subscribedUsers"];
    Firebase *specificUserRef = [artistsSubscribedUsersRef childByAppendingPath:user.userID];
    [specificUserRef removeValue];
}

+ (void) addCurrentUser:(FNBUser *)currentUser andArtistToEachOthersDatabases:(NSDictionary *)newArtistDictionary {
    NSString *artistName = newArtistDictionary[@"name"];

    [self addUser:currentUser ToArtistDatabase:newArtistDictionary];
    NSLog(@"added user to artist database");
    [self addArtist:artistName ToDatabaseOfUser:currentUser];
    NSLog(@"added artist to users database");
}
+ (void) deleteCurrentUser:(FNBUser *)currentUser andArtistFromEachOthersDatabases:(NSString *)newArtistName {
    
    [self deleteUser:currentUser FromArtist:newArtistName];
    [self deleteArtist:newArtistName FromUser:currentUser];
}

#pragma mark - Methods For Us to Test App

// helper method for makeDummyUser
+ (void) getUIDFromEmail:(NSString *)email withCompletionBlock: (void (^) (BOOL foundUID, NSString *UID))block{
    Firebase *usersRef = [self setupUserFirebase];
    //    NSMutableString *UID = [@"" mutableCopy];
    [usersRef observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        NSLog(@"trying to get the users UID from email");
        for (NSDictionary *usersDictionary in snapshot.value) {
            NSDictionary *subDictionary = [snapshot.value objectForKey:usersDictionary];
            if ([subDictionary[@"email"] isEqualToString:email]) {
                block(YES, subDictionary[@"UID"]);
            }
        }
        NSLog(@"couldn't find stuff in getUIDmethod");
    }];
}

// get array of all artists from database
+ (void) getArrayOfAllArtistsInDatabaseWithCompletionBlock: (void (^) (BOOL completed, NSArray *artistsArray))block{
    Firebase *artistsRef = [self setupArtistFirebase];
    [artistsRef observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
//        NSLog(@"%@", snapshot.value);
        block(YES, snapshot.value);
    }];
    
}


// run this once to fill data
+ (void) fillDatabaseWithArrayOfArtists:(NSArray *)artistNames {
    // This is the user that gets added to every artist
    FNBUser *firebaseFred = [[FNBUser alloc] init];
    for (NSString *artistName in artistNames) {
        //get array of search results and pick first
        [FNBSpotifySearch getArrayOfMatchingArtistsFromSearch:artistName withCompletionBlock:^(BOOL gotMatchingArtists, NSArray *matchingArtistsArray) {
            if (gotMatchingArtists && matchingArtistsArray.count>0) {
                //select first artist in array (could cause problems down the road with selecting the wrong artist
                [FNBFirebaseClient addCurrentUser:firebaseFred andArtistToEachOthersDatabases:matchingArtistsArray[0]];
            }
            else {
                NSLog(@"could not get matching artists for artist named: %@",artistName);
            }
        }];
    }
}


//+ (void)fillUser:(FNBUser *)user WithDummyDataWithCompletionBlock: (void (^) (BOOL madeDummyUser))completionBlock{
//    // create random new user on database
//    NSUInteger randomNumber = arc4random() %100000;
//    NSString *usersEmail = [NSString stringWithFormat: @"iAmDummy%lu@email.com", (unsigned long)randomNumber];
//    NSString *usersPassword = @"dummyPassword";
//    
//    //create users database entry
//    [self createNewUserInDatabaseWithEmail:usersEmail Password:usersPassword WithBlockIfSuccessful:^(BOOL successfulCreationOfNewUser, NSString *receivedEmail, NSString *receivedPassword, NSString *createdUID) {
//        //if successfully created new user, add them to database and login that user
//        if (successfulCreationOfNewUser) {
//            NSLog(@"created user!!!!! emails: %@", receivedEmail);
//            
//            // add user to database
//            [self addNewUserToDatabaseWithEmail:receivedEmail Password:receivedPassword UID:createdUID];
//            [self getUIDFromEmail:usersEmail withCompletionBlock:^(BOOL foundUID, NSString *UID) {
//                if (foundUID) {
//                    NSLog(@"found UID: %@", UID);
//                    // create new FNBUser from database
//                    [self setPropertiesOnceOfUser:user withUID:UID withCompletionBlock:^(BOOL completedSettingUsersProperties) {
//                        // add some artists to user
//                        FNBArtist *artist1 = [[FNBArtist alloc] initWithName:@"Adele"];
//                        FNBArtist *artist2 = [[FNBArtist alloc] initWithName:@"Nsync"];
//                        FNBArtist *artist3 = [[FNBArtist alloc] initWithName:@"Backstreet Boys"];
//                        [self addCurrentUser:user andArtistToEachOthersDatabases:artist1];
//                        [self addCurrentUser:user andArtistToEachOthersDatabases:artist2];
//                        [self addCurrentUser:user andArtistToEachOthersDatabases:artist3];
//                        [self setPropertiesOnceOfUser:user withUID:UID withCompletionBlock:^(BOOL completedSettingUsersProperties) {
//                            completionBlock(YES);
//                        }];
//                    }];
//                }
//                else {
//                    NSLog(@"could not find users UID from email");
//                }
//            }];
//        }
//    }];
//}
//
//// helper method for making Dummy Data method
//+ (void) setPropertiesOnceOfUser:(FNBUser *)user withUID:uid withCompletionBlock: (void (^) (BOOL completedSettingUsersProperties))setPropCompletionBlock {
//    Firebase *usersRef = [self setupUserFirebase];
//    Firebase *newUserRef = [usersRef childByAppendingPath:uid];
//    
//    // This block gets called for any change in this users data
//    [newUserRef observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
//        //        NSLog(@"Snapshot of Users values: %@", snapshot.value);
//        user.email = snapshot.value[@"email"];
//        user.userID = snapshot.value[@"UID"];
//        user.password = snapshot.value[@"password"];
//        user.artistsDictionary = snapshot.value[@"artistsDictionary"];
//        setPropCompletionBlock(YES);
//        
//    } withCancelBlock:^(NSError *error) {
//        NSLog(@"%@", error.description);
//    }];
//}



@end
