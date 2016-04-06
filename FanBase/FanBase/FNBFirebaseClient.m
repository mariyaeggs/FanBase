//
//  FNBFirebaseClient.m
//  FirebaseGettingUserInfo
//
//  Created by Andy Novak on 3/29/16.
//  Copyright © 2016 Andy Novak. All rights reserved.
//

#import "FNBFirebaseClient.h"

@implementation FNBFirebaseClient

#pragma mark - Firebase Constants

+ (Firebase *) getBaseFirebaseRef{
    return [[Firebase alloc] initWithUrl:ourFirebaseURL];
}

+ (Firebase *) getUserFirebaseRef {
    Firebase *ref = [self getBaseFirebaseRef];
    return [ref childByAppendingPath:@"users"];
}

+ (Firebase *) getArtistFirebaseRef {
    Firebase *ref = [self getBaseFirebaseRef];
    return [ref childByAppendingPath:@"artists"];
}

#pragma mark - User Login Methods

+ (void) loginWithEmail:(NSString *)email Password:(NSString *)password {
    Firebase *ref = [self getBaseFirebaseRef];
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
    Firebase *ref =  [self getBaseFirebaseRef];
    [ref unauth];
}

// This method sets the properties of the FNBUser based on the logged in user.
+ (void) checkOnceIfUserIsAuthenticatedWithCompletionBlock: (void (^) (BOOL isAuthenticUser))blockOfAuthUserCheck{
    Firebase *ref = [self getBaseFirebaseRef];
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
    Firebase *ref = [self getBaseFirebaseRef];
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
    Firebase *ref = [self getBaseFirebaseRef];
    
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
    Firebase *usersRef = [self getUserFirebaseRef];
    Firebase *newUserRef = [usersRef childByAppendingPath:uid];
    
    // this is what the initial user gets as values
    NSDictionary *initialUserValues = @{@"UID" : uid, @"email": email , @"userName" : @"defaultUsername", @"profileImageURL" : @"https://ww.deluxe.com/blog/wp-content/uploads/2014/02/cheering-fans_cropped.jpg", @"artistsDictionary" : [NSMutableDictionary new]};
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
// This method sets the properties of the FNBUser once.
+ (void) setPropertiesOfUser: (FNBUser *)user WithUID:(NSString *)uid withCompletionBlock: (void (^) (BOOL finishedSettingUsersProperties))completionBlock {
//    NSLog(@"this is the uid: %@", uid);
    Firebase *usersRef = [self getUserFirebaseRef];
    Firebase *newUserRef = [usersRef childByAppendingPath:uid];
    
    // This block gets called once for this users data
    [newUserRef observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
//        NSLog(@"Snapshot of Users values: %@", snapshot.value);
        user.email = snapshot.value[@"email"];
        user.userID = snapshot.value[@"UID"];
//        user.password = snapshot.value[@"password"];
        user.artistsDictionary = snapshot.value[@"artistsDictionary"];
        user.profileImageURL = snapshot.value[@"profileImageURL"];
        user.userName = snapshot.value[@"userName"];
        completionBlock(YES);
        
    } withCancelBlock:^(NSError *error) {
        NSLog(@"%@", error.description);
    }];
}

// This method sets the properties of the FNBUser based on the logged in user.
+ (void) setPropertiesOfLoggedInUserToUser: (FNBUser *)user withCompletionBlock: (void (^) (BOOL completedSettingUsersProperties))completionBlockOfLoggedInUser{
    Firebase *ref = [self getBaseFirebaseRef];
    [ref observeAuthEventWithBlock:^(FAuthData *authData) {
        NSLog(@"this is the authData of getpropofLoggedInUser: %@", authData);
        if (authData != nil) {
            [self setPropertiesOfUser:user WithUID:authData.uid withCompletionBlock:^(BOOL finishedSettingUsersProperties) {
                completionBlockOfLoggedInUser(YES);
            }];
        }
        else {
            NSLog(@"authData is nil");
        }
    }];
}

+ (void) changeUserNameOfUser: (FNBUser *)user toName:(NSString *)inputtedUserName withCompletionBlock: (void (^) (BOOL completedChangingUserName))completionBlockOfChangeUserName {
    Firebase *usersRef = [self getUserFirebaseRef];
    Firebase *currentUserRef = [usersRef childByAppendingPath:user.userID];
    NSDictionary *newUsername = @{ @"userName" : inputtedUserName};
    [currentUserRef updateChildValues:newUsername withCompletionBlock:^(NSError *error, Firebase *ref) {
        if (!error) {
            completionBlockOfChangeUserName(YES);
        }
    }];
}

+ (void) changeProfilePictureURLOfUser: (FNBUser *)user toURL:(NSString *)inputtedURL withCompletionBlock: (void (^) (BOOL completedChangingProfilePicURL))completionBlockOfChangeProfilePicture {
    Firebase *usersRef = [self getUserFirebaseRef];
    Firebase *currentUserRef = [usersRef childByAppendingPath:user.userID];
    NSDictionary *newProfilePictureURL = @{ @"profileImageURL" : inputtedURL};
    [currentUserRef updateChildValues:newProfilePictureURL withCompletionBlock:^(NSError *error, Firebase *ref) {
        if (!error) {
            completionBlockOfChangeProfilePicture(YES);
        }
    }];
}

+ (void) getADetailedArtistArrayFromUserArtistDictionary:(NSDictionary *)userArtistDictionary withCompletionBlock: (void (^) (BOOL gotDetailedArray, NSArray *arrayOfArtists)) completionBlock {
    NSMutableArray *arrayOfArtists = [NSMutableArray new];
    
    __block NSUInteger count = 0;
    for (NSString *artistName in userArtistDictionary) {
        NSDictionary *specificArtist = [userArtistDictionary objectForKey:artistName];
        NSLog(@"This is the number of points: %@  for artist: %@", specificArtist, artistName);
        FNBArtist *artist = [[FNBArtist alloc] initWithName:artistName];
        [FNBFirebaseClient setPropertiesOfArtist:artist FromDatabaseWithCompletionBlock:^(BOOL setPropertiesCompleted) {
            if (setPropertiesCompleted){
                [arrayOfArtists addObject:artist];
                count ++;
                // if it is the last one, then say it is completed and send the array of artists
                if (count == userArtistDictionary.count) {
                    completionBlock(YES, arrayOfArtists);
                }
            }
        }];
    }
}

#pragma mark - Artist Methods

+ (void) checkExistanceOfDatabaseEntryForArtistName:(NSString *) artistName withCompletionBlock: (void (^) (BOOL artistDatabaseExists))block {
//    NSLog(@"checking existance of database. aristName = %@", artistName);
    Firebase *artistsRef = [self getArtistFirebaseRef];
    Firebase *newArtistRef = [artistsRef childByAppendingPath:artistName];
    [newArtistRef observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        if ([snapshot.value isKindOfClass:[NSMutableDictionary class]]) {
//                        NSLog(@"value true");
            block(TRUE);
        }
        else {
//                        NSLog(@"value false");
            block(FALSE);
        }
    }];
}

+ (void) setPropertiesOfArtist:(FNBArtist *)artist FromDatabaseWithCompletionBlock: (void (^) (BOOL setPropertiesCompleted)) setArtistPropertiesCompletionBlock {
    Firebase *artistsRef = [self getArtistFirebaseRef];
    Firebase *specificArtistRef = [artistsRef childByAppendingPath:[self formatedArtistName:artist.name]];
    NSLog(@"QUEING UP A SINGLE EVENT OBSERVATION FOR: %@", artist.name);
    // This block gets called for a single in this artists data
    [specificArtistRef observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        NSLog(@"OBSERVED SINGLE EVENT FOR: %@", artist.name);
//        NSLog(@"Snapshot of Artist: %@ values: %@", artist.name, snapshot.value);
        if (![snapshot.value isKindOfClass:[NSNull class]]) {
            artist.name = snapshot.value[@"name"];
            artist.spotifyID = snapshot.value[@"spotifyID"];
            artist.twitterHandle = snapshot.value[@"twitterHandle"];
            artist.subscribedUsers = snapshot.value[@"subscribedUsers"];
            artist.genres = snapshot.value[@"genres"];
            artist.imagesArray = snapshot.value[@"images"];
            setArtistPropertiesCompletionBlock(YES);
        }
        else {
            NSLog(@"ERROR: tried to add someone not in our database");
            // snapshot doesnt have a value, meaning its not a part of our database
            // TODO: handle this somehow
        }
        
    } withCancelBlock:^(NSError *error) {
        NSLog(@"%@", error.description);
    }];

}

+ (void) makeDatabaseEntryForArtistFromSpotifyDictionary: (NSDictionary *)artistSpotifyDictionary withCompletionBlock: (void (^) (BOOL artistDatabaseCreated)) makeDatabaseCompletionBlock  {
    NSLog(@"making artist database");

    //get rid of .#$[] characters in artist's name
    NSString *formatedArtistName = [self formatedArtistName:artistSpotifyDictionary[@"name"] ];
    
    Firebase *artistsRef = [self getArtistFirebaseRef];
    Firebase *currentArtistRef = [artistsRef childByAppendingPath:formatedArtistName];
    
    
//    NSLog(@"%@", artistSpotifyDictionary[@"name"]);
    
    NSDictionary *initialArtistValues = @{@"name" : artistSpotifyDictionary[@"name"],
                                          @"spotifyID": artistSpotifyDictionary[@"id"] ,
                                          @"twitterHandle": @"", @"subscribedUsers" : [NSMutableDictionary new],
                                          @"images" : artistSpotifyDictionary[@"images"],
                                          @"genres" : artistSpotifyDictionary[@"genres"]};
    [currentArtistRef setValue:initialArtistValues];
    NSLog(@"Added Spotify artist to database");
    makeDatabaseCompletionBlock(YES);
}


#pragma mark - User and Artist Methods

// helper method for addCurrentUser:(FNBUser *)currentUser andArtistToEachOthersDatabases
+ (void) addArtist:(NSString *)artistName ToDatabaseOfUser:(FNBUser *)user {
    Firebase *usersRef = [self getUserFirebaseRef];
    Firebase *currentUserRef = [usersRef childByAppendingPath:user.userID];
    Firebase *usersArtistRef = [currentUserRef childByAppendingPath:@"artistsDictionary"];
    
    NSDictionary *newArtistDictionary = @{artistName : @0};
    [usersArtistRef updateChildValues:newArtistDictionary];
}

// helper method for addCurrentUser:(FNBUser *)currentUser andArtistToEachOthersDatabases
+ (void) addUser: (FNBUser *)inputtedUser ToArtistDatabase:(NSDictionary *)artistDictionaryFromSpotify {
    NSString *artistName = [self formatedArtistName:artistDictionaryFromSpotify[@"name"]];
    [self checkExistanceOfDatabaseEntryForArtistName:artistName withCompletionBlock:^(BOOL artistDatabaseExists) {
        if (artistDatabaseExists) {
            NSLog(@"Artist database already exists");
            // add user to existing artist database
            [self addUser:inputtedUser ToExistingArtistDatabase:artistName];
        }
        else {
            NSLog(@"Artist database does not exist");
            [self makeDatabaseEntryForArtistFromSpotifyDictionary:artistDictionaryFromSpotify withCompletionBlock:^(BOOL artistDatabaseCreated) {
                if (artistDatabaseCreated) {
                    NSLog(@"Artist database created");
                    [self addUser:inputtedUser ToExistingArtistDatabase:artistDictionaryFromSpotify[@"name"]];
                }
            }];
//            [self addCurrentUser:inputtedUser andArtistToEachOthersDatabases:artistDictionaryFromSpotify];
//            [self createNewArtistDatabaseEntry:artistName createdByUser:inputtedUser];
        }
    }];
}

// helper method for addCurrentUser andArtistToEachOthersDatabase
+ (void) addUser:(FNBUser *)user ToExistingArtistDatabase:(NSString *)artistName {
    Firebase *artistsRef = [self getArtistFirebaseRef];
    Firebase *currentArtistRef = [artistsRef childByAppendingPath:[self formatedArtistName:artistName]];
    Firebase *artistsSubscribedUsersRef = [currentArtistRef childByAppendingPath:@"subscribedUsers"];
    NSDictionary *newUserDictionary = @{user.userID : @0};
    [artistsSubscribedUsersRef updateChildValues:newUserDictionary];
}

// helper method for deleteCurrentUser:(FNBUser *)currentUser andArtistFromEachOthersDatabases:(FNBArtist *)newArtist
+ (void) deleteUser:(FNBUser *)user FromArtist:(NSString *)artistName{
    Firebase *artistsRef = [self getArtistFirebaseRef];
    Firebase *currentArtistRef = [artistsRef childByAppendingPath:artistName];
    Firebase *artistsSubscribedUsersRef = [currentArtistRef childByAppendingPath:@"subscribedUsers"];
    Firebase *specificUserRef = [artistsSubscribedUsersRef childByAppendingPath:user.userID];
    [specificUserRef removeValue];
}

// helper method for deleteCurrentUser:(FNBUser *)currentUser andArtistFromEachOthersDatabases:(FNBArtist *)newArtist
+ (void) deleteArtist:(NSString *)artistName FromUser:(FNBUser *)user {
    Firebase *usersRef = [self getUserFirebaseRef];
    Firebase *currentUserRef = [usersRef childByAppendingPath:user.userID];
    Firebase *usersArtistRef = [currentUserRef childByAppendingPath:@"artistsDictionary"];
    Firebase *specificArtistRef = [usersArtistRef childByAppendingPath:artistName];
    
    [specificArtistRef removeValue];
}



+ (void) addCurrentUser:(FNBUser *)currentUser andArtistToEachOthersDatabases:(NSDictionary *)newArtistDictionary {
    NSString *artistName = [self formatedArtistName:newArtistDictionary[@"name"]];

    [self addUser:currentUser ToArtistDatabase:newArtistDictionary];
    [self addArtist:artistName ToDatabaseOfUser:currentUser];
}

+ (void) deleteCurrentUser:(FNBUser *)currentUser andArtistFromEachOthersDatabases:(NSString *)newArtistName {
    NSString *artistName = [self formatedArtistName:newArtistName];
    
    [self deleteUser:currentUser FromArtist:artistName];
    [self deleteArtist:artistName FromUser:currentUser];
}

#pragma mark - Methods For Us to Test App

// helper method for makeDummyUser
+ (void) getUIDFromEmail:(NSString *)email withCompletionBlock: (void (^) (BOOL foundUID, NSString *UID))block{
    Firebase *usersRef = [self getUserFirebaseRef];
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
    Firebase *artistsRef = [self getArtistFirebaseRef];
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
                NSLog(@"working on artist %@", artistName),

                //select first artist in array (could cause problems down the road with selecting the wrong artist
                [FNBFirebaseClient addCurrentUser:firebaseFred andArtistToEachOthersDatabases:matchingArtistsArray[0]];
            }
            else {
                NSLog(@"could not get matching artists for artist named: %@",artistName);
            }
        }];
    }
}

+ (NSString *) formatedArtistName: (NSString *)artistName {
    //get rid of .#$[] characters in artist's name
    NSCharacterSet *doNotWant = [NSCharacterSet characterSetWithCharactersInString:@".#$[]"];
    NSLog(@"%@", [[artistName componentsSeparatedByCharactersInSet:doNotWant] componentsJoinedByString:@""]);
    return [[artistName componentsSeparatedByCharactersInSet:doNotWant] componentsJoinedByString:@""];
}

@end
