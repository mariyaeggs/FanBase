//
//  FNBFirebaseClient.m
//  FirebaseGettingUserInfo
//
//  Created by Andy Novak on 3/29/16.
//  Copyright © 2016 Andy Novak. All rights reserved.
//

#import "FNBFirebaseClient.h"

@implementation FNBFirebaseClient

+ (void) loginWithEmail:(NSString *)email Password:(NSString *)password {
    Firebase *ref = [[Firebase alloc] initWithUrl:ourFirebaseURL];
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
    Firebase *ref = [[Firebase alloc] initWithUrl:ourFirebaseURL];
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

// this method creates new user, and passes email, password, UID, and a completion bool to the block
+ (void) createNewUserWithEmail:(NSString *)email Password:(NSString *)password WithBlockIfSuccessful:(void (^) (BOOL successfulCreationOfNewUser, NSString *receivedEmail, NSString *receivedPassword, NSString *createdUID)) successBlock {
    Firebase *ref = [[Firebase alloc] initWithUrl:ourFirebaseURL];
    
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

+ (void) addNewUserToDatabaseWithEmail:(NSString *)email Password:(NSString *)password UID:(NSString *)uid {
    Firebase *ref = [[Firebase alloc] initWithUrl:ourFirebaseURL];
    Firebase *usersRef = [ref childByAppendingPath:@"users"];
    Firebase *newUserRef = [usersRef childByAppendingPath:uid];
    
    // this is what the initial user gets as values
    NSDictionary *initialUserValues = @{@"UID" : uid, @"email": email , @"password": password, @"artistsDictionary" : @{@"Adele" : @0}};
    [newUserRef setValue:initialUserValues];
    NSLog(@"Added user to database");
}



//// helper method for getPropertiesOfLoggedInUser
//+ (void) getPropertiesOfUserWithUID:(NSString *)uid {
//    NSLog(@"this is the uid: %@", uid);
//    Firebase *ref = [[Firebase alloc] initWithUrl:ourFirebaseURL];
//    Firebase *usersRef = [ref childByAppendingPath:@"users"];
//    Firebase *newUserRef = [usersRef childByAppendingPath:uid];
//    
//    // This block gets called for any change in this users data
//    [newUserRef observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
//        NSLog(@"Snapshot of Users values: %@", snapshot.value);
//    } withCancelBlock:^(NSError *error) {
//        NSLog(@"%@", error.description);
//    }];
//}

//+ (void) getPropertiesOfLoggedInUser {
//    Firebase *ref = [[Firebase alloc] initWithUrl:ourFirebaseURL];
//    [ref observeAuthEventWithBlock:^(FAuthData *authData) {
//        NSLog(@"this is the authData of getpropofLoggedInUser: %@", authData);
//        if (authData != nil) {
//            [self getPropertiesOfUserWithUID:authData.uid];
//        }
//        else {
//            NSLog(@"authData is nil");
//        }
//    }];
//}

// This method sets the properties of the FNBUser whenever an update happens. Helper method for setPropertiesOfLoggedInUserToUser.
+ (void) setPropertiesOfUser: (FNBUser *)user WithUID:(NSString *)uid withCompletionBlock: (void (^) (BOOL updateHappened))updateBlock {
    NSLog(@"this is the uid: %@", uid);
    Firebase *ref = [[Firebase alloc] initWithUrl:ourFirebaseURL];
    Firebase *usersRef = [ref childByAppendingPath:@"users"];
    Firebase *newUserRef = [usersRef childByAppendingPath:uid];
    
    // This block gets called for any change in this users data
    [newUserRef observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        NSLog(@"Snapshot of Users values: %@", snapshot.value);
        user.email = snapshot.value[@"email"];
        user.userID = snapshot.value[@"UID"];
        user.artistsDictionary = snapshot.value[@"artistsDictionary"];
        updateBlock(YES);
        
    } withCancelBlock:^(NSError *error) {
        NSLog(@"%@", error.description);
    }];
}

// This method sets the properties of the FNBUser based on the logged in user.
+ (void) setPropertiesOfLoggedInUserToUser: (FNBUser *)user withCompletionBlock: (void (^) (BOOL updateHappened))updateBlockOfLoggedInUser{
    Firebase *ref = [[Firebase alloc] initWithUrl:ourFirebaseURL];
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

+ (void) logoutUser {
    Firebase *ref = [[Firebase alloc] initWithUrl:ourFirebaseURL];
    [ref unauth];
}

+ (void) addArtist:(NSString *)artistName ToDatabaseOfUser:(FNBUser *)user {
    Firebase *ref = [[Firebase alloc] initWithUrl:ourFirebaseURL];
    Firebase *usersRef = [ref childByAppendingPath:@"users"];
    Firebase *currentUserRef = [usersRef childByAppendingPath:user.userID];
    Firebase *usersArtistRef = [currentUserRef childByAppendingPath:@"artistsDictionary"];
    
    NSDictionary *newArtistDictionary = @{artistName : @0};
    [usersArtistRef updateChildValues:newArtistDictionary];
}
@end
