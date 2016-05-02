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

+ (void) showFacebookLoginScreenOnVC:(UIViewController *)VC withCompletion:  (void (^) (BOOL finishedFBLogin, BOOL isANewUser))completionBlock{
    Firebase *ref = [[Firebase alloc] initWithUrl:@"https://fanbaseflatiron.firebaseIO.com"];
    FBSDKLoginManager *facebookLogin = [[FBSDKLoginManager alloc] init];
    [facebookLogin logInWithReadPermissions:@[@"email"] fromViewController:VC handler:^(FBSDKLoginManagerLoginResult *facebookResult, NSError *facebookError) {
        if (facebookError) {
            NSLog(@"Facebook login failed. Error: %@", facebookError);
        } else if (facebookResult.isCancelled) {
            NSLog(@"Facebook login got cancelled.");
        } else {
            NSString *accessToken = [[FBSDKAccessToken currentAccessToken] tokenString];
            [ref authWithOAuthProvider:@"facebook" token:accessToken
                   withCompletionBlock:^(NSError *error, FAuthData *authData) {
                       if (error) {
                           NSLog(@"Login failed. %@", error);
                       } else {
                           NSLog(@"Logged in! %@", authData.providerData[@"displayName"]);
                           // check if user exists in database
                           [self checkIfNewUserWithFacebookAuthData:authData withCompletion:^(BOOL isNewUser) {
                               if (isNewUser) {
                                   [self addNewUserToDatabaseWithFacebookAuthData:authData withCompletion:^(BOOL completed) {
                                       if (completed) {
                                           completionBlock(YES, YES);
                                       }
                                   }];
                               }
                               else {
                                   completionBlock(YES, NO);
                               }
                           }];
                       }
                   }];
        }
    }];
}

// for FB login: check if user exists in database
+ (void) checkIfNewUserWithFacebookAuthData:(FAuthData *)authData withCompletion: (void (^) (BOOL isNewUser))block{
    Firebase *usersRef = [self getUserFirebaseRef];
    Firebase *specificUserRef = [usersRef childByAppendingPath:authData.uid];
    [specificUserRef observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        if ([snapshot.value isKindOfClass:[NSMutableDictionary class]]) {
            NSLog(@"This user already exists in our databse");
            block(FALSE);
        }
        else {
            NSLog(@"this is a new user");
            block(TRUE);
        }
    }];
}

// for FB login: create user in database using FB info
// helper method for creating a new user
+ (void) addNewUserToDatabaseWithFacebookAuthData: (FAuthData *) authData withCompletion: (void (^) (BOOL completed))block{
    Firebase *usersRef = [self getUserFirebaseRef];
    Firebase *newUserRef = [usersRef childByAppendingPath:authData.uid];
    
    // this is what the initial user gets as values
    NSDictionary *initialUserValues = @{@"UID" : authData.uid, @"email": authData.providerData[@"email"] , @"userName" : authData.providerData[@"displayName"], @"profileImageURL" : authData.providerData[@"profileImageURL"], @"artistsDictionary" : [NSMutableDictionary new]};
    [newUserRef setValue:initialUserValues withCompletionBlock:^(NSError *error, Firebase *ref) {
        block(YES);
    }];
}

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

+ (void) checkExistanceOfDatabaseEntryForArtistSpotifyID:(NSString *) artistSpotifyID withCompletionBlock: (void (^) (BOOL artistDatabaseExists, NSString *artistName))block {
    Firebase *artistsRef = [self getArtistFirebaseRef];
    
    [artistsRef observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        NSDictionary *receivedSnapshot = snapshot.value;
        for (NSString *artistName in receivedSnapshot) {
            NSString *spotifyIDOfArtist = receivedSnapshot[artistName][@"spotifyID"];
            if ([spotifyIDOfArtist isEqualToString:artistSpotifyID]) {
                
                block(YES, artistName);
                return;
            }
        }
        block(NO, @"");
        
    }];
}

+ (void) addUser:(FNBUser *)user andArtistWithSpotifyID:(NSString *)spotifyID toDatabaseWithCompletionBlock: (void (^) (BOOL artistAddedToUserSuccessfully))block {
    // check if artist database exists
    [self checkExistanceOfDatabaseEntryForArtistSpotifyID:spotifyID withCompletionBlock:^(BOOL artistDatabaseExists, NSString *artistName) {
        
        // if artist database doesnt exist
        if (!artistDatabaseExists) {
            // get spotify dictionary from Spotify
            [FNBSpotifySearch getArtistDictionaryFromSpotifyID:spotifyID withCompletionBlock:^(BOOL gotMatchingArtist, NSDictionary *artistDictionary) {
                if (gotMatchingArtist) {
                    NSLog(@"this is the artist dictioanry: %@", artistDictionary);
                    // create database entry
                    [self makeDatabaseEntryForArtistFromSpotifyDictionary:artistDictionary withCompletionBlock:^(BOOL artistDatabaseCreated) {
                        // then add user to the artist database and add artist to user database
                        [self addUser:user ToExistingArtistDatabase:artistDictionary[@"name"]];
                        [self addArtist:artistDictionary[@"name"] ToDatabaseOfUser:user];
                        block(YES);
                    }];
                    
                }
            }];
        }
        else {
            NSLog(@"The artists database already exists for spotifyID: %@", spotifyID);
            [self addUser:user ToExistingArtistDatabase:artistName];
            [self addArtist:artistName ToDatabaseOfUser:user];
            block(YES);
        }
    }];

}


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

+ (void) getArtistNameForArtistDatabaseName:(NSString *) artistName withCompletionBlock: (void (^) (BOOL artistDatabaseExists, NSString *artistActualName))block {
    [self checkExistanceOfDatabaseEntryForArtistName:artistName withCompletionBlock:^(BOOL artistDatabaseExists) {
        if (artistDatabaseExists) {
            Firebase *artistsRef = [self getArtistFirebaseRef];
            Firebase *newArtistRef = [artistsRef childByAppendingPath:artistName];
            [newArtistRef observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
                NSString *actualArtistName = snapshot.value[@"name"];
                block(YES, actualArtistName);
            }];
        }
        else {
            NSLog(@"tried to get artist's actual name: %@, but couldnt find them in the database", artistName);
            block(NO, @"");
        }
    }];
}


+ (void) setPropertiesOfArtist:(FNBArtist *)artist FromDatabaseWithCompletionBlock: (void (^) (BOOL setPropertiesCompleted)) setArtistPropertiesCompletionBlock {
    Firebase *artistsRef = [self getArtistFirebaseRef];
    Firebase *specificArtistRef = [artistsRef childByAppendingPath:[self formatedArtistName:artist.name]];
//    NSLog(@"QUEING UP A SINGLE EVENT OBSERVATION FOR: %@", artist.name);
    // This block gets called for a single in this artists data
    [specificArtistRef observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
//        NSLog(@"OBSERVED SINGLE EVENT FOR: %@", artist.name);
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
    NSLog(@"making artist database in makeDatabaseEntryForArtistFromSpotifyDictionary (FNBFirebaseClient)");
    
    [self checkExistanceOfDatabaseEntryForArtistSpotifyID:artistSpotifyDictionary[@"id"] withCompletionBlock:^(BOOL artistDatabaseExists, NSString *artistName) {
        if (!artistDatabaseExists) {
            //get rid of .#$[]/ characters in artist's name
            NSString *formatedArtistName = [self formatedArtistName:artistSpotifyDictionary[@"name"] ];
            
            Firebase *artistsRef = [self getArtistFirebaseRef];
            Firebase *currentArtistRef = [artistsRef childByAppendingPath:formatedArtistName];
            
            
            
            
            NSMutableDictionary *initialArtistValues = [@{@"name" : artistSpotifyDictionary[@"name"],
                                                  @"spotifyID": artistSpotifyDictionary[@"id"] ,
                                                  @"twitterHandle": @"",
                                                  @"subscribedUsers" : [NSMutableDictionary new],
                                                  @"images" : artistSpotifyDictionary[@"images"]
                                                  } mutableCopy];
            // protection if artist has no genres
            if (artistSpotifyDictionary[@"genres"]) {
                [initialArtistValues setObject:artistSpotifyDictionary[@"genres"] forKey:@"genres"];
            }
            [currentArtistRef setValue:initialArtistValues];
            NSLog(@"Added Spotify artist to database");
            makeDatabaseCompletionBlock(YES);

        }
        else {
            NSLog(@"Artist database already exists. From makeDatabaseEntryForArtistFromSpotifyDictionary (FNBFirebaseClient)");
            makeDatabaseCompletionBlock(YES);

        }
    }];
    
}


#pragma mark - User and Artist Methods

// helper method for addCurrentUser:(FNBUser *)currentUser andArtistToEachOthersDatabases
+ (void) addArtist:(NSString *)artistName ToDatabaseOfUser:(FNBUser *)user {
    NSString *formattedArtistName = [self formatedArtistName:artistName];
    
    Firebase *usersRef = [self getUserFirebaseRef];
    Firebase *currentUserRef = [usersRef childByAppendingPath:user.userID];
    Firebase *usersArtistRef = [currentUserRef childByAppendingPath:@"artistsDictionary"];
    
    NSDictionary *newArtistDictionary = @{formattedArtistName : @0};
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
    NSString *formattedArtistName = [self formatedArtistName:artistName];
    
    Firebase *artistsRef = [self getArtistFirebaseRef];
    Firebase *currentArtistRef = [artistsRef childByAppendingPath:[self formatedArtistName:formattedArtistName]];
    Firebase *artistsSubscribedUsersRef = [currentArtistRef childByAppendingPath:@"subscribedUsers"];
    NSDictionary *newUserDictionary = @{user.userID : @0};
    [artistsSubscribedUsersRef updateChildValues:newUserDictionary];
}

// helper method for deleteCurrentUser:(FNBUser *)currentUser andArtistFromEachOthersDatabases:(FNBArtist *)newArtist
+ (void) deleteUser:(FNBUser *)user FromArtist:(NSString *)artistName withCompletionBlock: (void (^) (BOOL deletedUserFromArtistCompleted)) deletedUserFromArtistCompletionBlock  {
    Firebase *artistsRef = [self getArtistFirebaseRef];
    Firebase *currentArtistRef = [artistsRef childByAppendingPath:artistName];
    Firebase *artistsSubscribedUsersRef = [currentArtistRef childByAppendingPath:@"subscribedUsers"];
    Firebase *specificUserRef = [artistsSubscribedUsersRef childByAppendingPath:user.userID];
    [specificUserRef removeValueWithCompletionBlock:^(NSError *error, Firebase *ref) {
        if (!error) {
            deletedUserFromArtistCompletionBlock(YES);
        }
        else {
            NSLog(@"There was an error deleting user from artist's databse");
        }
    }];
}

// helper method for deleteCurrentUser:(FNBUser *)currentUser andArtistFromEachOthersDatabases:(FNBArtist *)newArtist
+ (void) deleteArtist:(NSString *)artistName FromUser:(FNBUser *)user withCompletionBlock: (void (^) (BOOL deletedArtistFromUserCompleted)) deletedArtistFromUserCompletionBlock  {
    Firebase *usersRef = [self getUserFirebaseRef];
    Firebase *currentUserRef = [usersRef childByAppendingPath:user.userID];
    Firebase *usersArtistRef = [currentUserRef childByAppendingPath:@"artistsDictionary"];
    Firebase *specificArtistRef = [usersArtistRef childByAppendingPath:artistName];
    
    [specificArtistRef removeValueWithCompletionBlock:^(NSError *error, Firebase *ref) {
        if (!error) {
            deletedArtistFromUserCompletionBlock(YES);
        }
        else {
            NSLog(@"There was an error deleting artist from user's databse");
        }
    }];
}



+ (void) addCurrentUser:(FNBUser *)currentUser andArtistToEachOthersDatabases:(NSDictionary *)newArtistDictionary {
    NSString *artistName = [self formatedArtistName:newArtistDictionary[@"name"]];
    
    [self addUser:currentUser ToArtistDatabase:newArtistDictionary];
    [self addArtist:artistName ToDatabaseOfUser:currentUser];
}

+ (void) deleteCurrentUser:(FNBUser *)currentUser andArtistFromEachOthersDatabases:(NSString *)newArtistName withCompletionBlock: (void (^) (BOOL deletedArtistAndUserCompleted)) deletedArtistFromUserCompletionBlock  {
    NSString *artistName = [self formatedArtistName:newArtistName];
    
    [self deleteUser:currentUser FromArtist:artistName withCompletionBlock:^(BOOL deletedUserFromArtistCompleted) {
        if (deletedUserFromArtistCompleted) {
            [self deleteArtist:artistName FromUser:currentUser withCompletionBlock:^(BOOL deletedArtistFromUserCompleted) {
                if (deletedArtistFromUserCompleted) {
                    deletedArtistFromUserCompletionBlock(YES);
                }
            }];

        }
    }];
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

+ (void) getDictionaryOfAllArtistsInDatabaseWithCompletionBlock: (void (^) (BOOL completed, NSDictionary *artistsDictionary))block{
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
    NSCharacterSet *doNotWant = [NSCharacterSet characterSetWithCharactersInString:@".#$[]/"];
    NSLog(@"%@", [[artistName componentsSeparatedByCharactersInSet:doNotWant] componentsJoinedByString:@""]);
    return [[artistName componentsSeparatedByCharactersInSet:doNotWant] componentsJoinedByString:@""];
}

# pragma - mark Network Availability Methods

+(BOOL)isNetworkAvailable {
    SCNetworkReachabilityFlags flags;
    SCNetworkReachabilityRef loc;
    
    loc = SCNetworkReachabilityCreateWithName(nil, "www.apple.com");
    BOOL success = SCNetworkReachabilityGetFlags(loc, &flags);
    
    BOOL canReach = success && !(flags & kSCNetworkFlagsConnectionRequired) && (flags & kSCNetworkFlagsReachable);
    
    return canReach;
}

@end
