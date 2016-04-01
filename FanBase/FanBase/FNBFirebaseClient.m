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

+ (void) isUserAuthenticatedWithCompletionBlock:(void  (^)(BOOL isAuthenticatedUser))block {
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

// helper method for creating a new user
// this method creates new user, and passes email, password, UID, and a completion bool to the block
+ (void) createNewUserWithEmail:(NSString *)email Password:(NSString *)password WithBlockIfSuccessful:(void (^) (BOOL successfulCreationOfNewUser, NSString *receivedEmail, NSString *receivedPassword, NSString *createdUID)) successBlock {
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

+ (void) createANewUserWithEmail:(NSString *)email Password:(NSString *)password {
    [self createNewUserWithEmail:email Password:password WithBlockIfSuccessful:^(BOOL successfulCreationOfNewUser, NSString *receivedEmail, NSString *receivedPassword, NSString *createdUID) {
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

+ (void) logoutUser {
    Firebase *ref =  [self setupBaseFirebase];
    [ref unauth];
}

#pragma mark - User Methods

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

// This method sets the properties of the FNBUser based on the logged in user.
+ (void) checkIfUserIsAuthenticatedWithCompletionBlock: (void (^) (BOOL isAuthenticUser))blockOfAuthUserCheck{
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

+ (void) addArtist:(FNBArtist *)artist ToDatabaseOfUser:(FNBUser *)user {
    Firebase *usersRef = [self setupUserFirebase];
    Firebase *currentUserRef = [usersRef childByAppendingPath:user.userID];
    Firebase *usersArtistRef = [currentUserRef childByAppendingPath:@"artistsDictionary"];
    
    NSDictionary *newArtistDictionary = @{artist.name : @0};
    [usersArtistRef updateChildValues:newArtistDictionary];
}

+ (void) deleteArtist:(FNBArtist *)artist FromUser:(FNBUser *)user {
    Firebase *usersRef = [self setupUserFirebase];
    Firebase *currentUserRef = [usersRef childByAppendingPath:user.userID];
    Firebase *usersArtistRef = [currentUserRef childByAppendingPath:@"artistsDictionary"];
    Firebase *specificArtistRef = [usersArtistRef childByAppendingPath:artist.name];
    
    [specificArtistRef removeValue];
}

#pragma mark - Artist Methods

+ (void) createNewArtistDatabaseEntry:(FNBArtist *)artist createdByUser:(FNBUser *)user {
    Firebase *artistsRef = [self setupArtistFirebase];
    Firebase *newArtistRef = [artistsRef childByAppendingPath:artist.name];
    // this is what the initial artist gets as values
    NSDictionary *initialArtistValues = @{@"name" : artist.name, @"spotifyID": artist.spotifyID , @"twitterHandle": artist.twitterHandle, @"subscribedUsers" : @{user.userID : @0}};
    [newArtistRef setValue:initialArtistValues];
    NSLog(@"Added artist to database");
    
}

+ (void) addUser:(FNBUser *)user ToExistingArtistDatabase:(FNBArtist *)artist {
    Firebase *artistsRef = [self setupArtistFirebase];
    Firebase *currentArtistRef = [artistsRef childByAppendingPath:artist.name];
    Firebase *artistsSubscribedUsersRef = [currentArtistRef childByAppendingPath:@"subscribedUsers"];
    NSDictionary *newUserDictionary = @{user.userID : @0};
    [artistsSubscribedUsersRef updateChildValues:newUserDictionary];
}

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

+ (void) setPropertiesOfArtist:(FNBArtist *)artist withCompletionBlock: (void (^) (BOOL setPropertiesUpdated)) setArtistPropertiesUpdatedBlock {
    Firebase *artistsRef = [self setupArtistFirebase];
    Firebase *specificArtistRef = [artistsRef childByAppendingPath:artist.name];
    
    // This block gets called for any change in this artists data
    [specificArtistRef observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
//        NSLog(@"Snapshot of Users values: %@", snapshot.value);
        artist.name = snapshot.value[@"name"];
        artist.spotifyID = snapshot.value[@"spotifyID"];
        artist.twitterHandle = snapshot.value[@"twitterHandle"];
        artist.subscribedUsers = snapshot.value[@"subscribedUsers"];
        setArtistPropertiesUpdatedBlock(YES);
        
    } withCancelBlock:^(NSError *error) {
        NSLog(@"%@", error.description);
    }];

}


+ (void) addUser: (FNBUser *)inputtedUser ToArtistDatabase:(FNBArtist *)artist {
    [self checkExistanceOfDatabaseEntryForArtistName:artist.name withCompletionBlock:^(BOOL artistDatabaseExists) {
        if (artistDatabaseExists) {
            NSLog(@"Artist database already exists");
            // add user to existing artist database
            [self addUser:inputtedUser ToExistingArtistDatabase:artist];
        }
        else {
            NSLog(@"Artist database does not exist");
            [self createNewArtistDatabaseEntry:artist createdByUser:inputtedUser];
        }
    }];
}

+ (void) deleteUser:(FNBUser *)user FromArtist:(FNBArtist *)artist{
    Firebase *artistsRef = [self setupArtistFirebase];
    Firebase *currentArtistRef = [artistsRef childByAppendingPath:artist.name];
    Firebase *artistsSubscribedUsersRef = [currentArtistRef childByAppendingPath:@"subscribedUsers"];
    Firebase *specificUserRef = [artistsSubscribedUsersRef childByAppendingPath:user.userID];
    [specificUserRef removeValue];
}

#pragma mark - Spotify Related Methods

+ (void) makeDatabaseEntryForArtistFromSpotifyDictionary: (NSDictionary *)artistSpotifyDictionary {
    Firebase *artistsRef = [self setupArtistFirebase];
    Firebase *currentArtistRef = [artistsRef childByAppendingPath:artistSpotifyDictionary[@"name"]];
    NSDictionary *initialArtistValues = @{@"name" : artistSpotifyDictionary[@"name"],
                                          @"spotifyID": artistSpotifyDictionary[@"id"] ,
                                          @"twitterHandle": @"", @"subscribedUsers" : [NSMutableDictionary new],
                                          @"imageURLSize640" : artistSpotifyDictionary[@"images"][1][@"url"],
                                          @"imageURLSize64" : artistSpotifyDictionary[@"images"][3][@"url"]};
    [currentArtistRef setValue:initialArtistValues];
    NSLog(@"Added Spotify artist to database");
}

//+ (void) checkIfArtistDatabaseExists:(NSString *)artistName withCompletionBlock: (void (^) (BOOL databaseExists)) completionBlock{
//    Firebase *artistsRef = [self setupArtistFirebase];
//    Firebase *currentArtistRef = [artistsRef childByAppendingPath:artistName];
//    
//}

#pragma mark - User and Artist Methods

+ (void) addCurrentUser:(FNBUser *)currentUser andArtistToEachOthersDatabases:(FNBArtist *)newArtist {
    [self addUser:currentUser ToArtistDatabase:newArtist];
    NSLog(@"added user to artist database");
    [self addArtist:newArtist ToDatabaseOfUser:currentUser];
    NSLog(@"added artist to users database");
}
+ (void) deleteCurrentUser:(FNBUser *)currentUser andArtistFromEachOthersDatabases:(FNBArtist *)newArtist {
    [self deleteUser:currentUser FromArtist:newArtist];
    [self deleteArtist:newArtist FromUser:currentUser];
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

+ (void)fillUser:(FNBUser *)user WithDummyDataWithCompletionBlock: (void (^) (BOOL madeDummyUser))completionBlock{
    // create random new user on database
    NSUInteger randomNumber = arc4random() %100000;
    NSString *usersEmail = [NSString stringWithFormat: @"iAmDummy%lu@email.com", (unsigned long)randomNumber];
    NSString *usersPassword = @"dummyPassword";
    
    //create users database entry
    [self createNewUserWithEmail:usersEmail Password:usersPassword WithBlockIfSuccessful:^(BOOL successfulCreationOfNewUser, NSString *receivedEmail, NSString *receivedPassword, NSString *createdUID) {
        //if successfully created new user, add them to database and login that user
        if (successfulCreationOfNewUser) {
            NSLog(@"created user!!!!! emails: %@", receivedEmail);
            
            // add user to database
            [self addNewUserToDatabaseWithEmail:receivedEmail Password:receivedPassword UID:createdUID];
            [self getUIDFromEmail:usersEmail withCompletionBlock:^(BOOL foundUID, NSString *UID) {
                if (foundUID) {
                    NSLog(@"found UID: %@", UID);
                    // create new FNBUser from database
                    [self setPropertiesOnceOfUser:user withUID:UID withCompletionBlock:^(BOOL completedSettingUsersProperties) {
                        // add some artists to user
                        FNBArtist *artist1 = [[FNBArtist alloc] initWithName:@"Adele"];
                        FNBArtist *artist2 = [[FNBArtist alloc] initWithName:@"Nsync"];
                        FNBArtist *artist3 = [[FNBArtist alloc] initWithName:@"Backstreet Boys"];
                        [self addCurrentUser:user andArtistToEachOthersDatabases:artist1];
                        [self addCurrentUser:user andArtistToEachOthersDatabases:artist2];
                        [self addCurrentUser:user andArtistToEachOthersDatabases:artist3];
                        [self setPropertiesOnceOfUser:user withUID:UID withCompletionBlock:^(BOOL completedSettingUsersProperties) {
                            completionBlock(YES);
                        }];
                    }];
                }
                else {
                    NSLog(@"could not find users UID from email");
                }
            }];
        }
    }];
}

// helper method for making Dummy Data method
+ (void) setPropertiesOnceOfUser:(FNBUser *)user withUID:uid withCompletionBlock: (void (^) (BOOL completedSettingUsersProperties))setPropCompletionBlock {
    Firebase *usersRef = [self setupUserFirebase];
    Firebase *newUserRef = [usersRef childByAppendingPath:uid];
    
    // This block gets called for any change in this users data
    [newUserRef observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        //        NSLog(@"Snapshot of Users values: %@", snapshot.value);
        user.email = snapshot.value[@"email"];
        user.userID = snapshot.value[@"UID"];
        user.password = snapshot.value[@"password"];
        user.artistsDictionary = snapshot.value[@"artistsDictionary"];
        setPropCompletionBlock(YES);
        
    } withCancelBlock:^(NSError *error) {
        NSLog(@"%@", error.description);
    }];
}



@end
