//
//  FNBInstagramLoginViewController.m
//  FanBase
//
//  Created by Angelica Bato on 3/31/16.
//  Copyright © 2016 Angelica Bato. All rights reserved.
//

#import "FNBInstagramLoginViewController.h"
#import <AFNetworking/AFNetworking.h>
#import <AFOAuth2Manager/AFOAuth2Manager.h>
#import <SafariServices/SafariServices.h>
#import "Secrets.h"


@interface FNBInstagramLoginViewController ()

@end

@implementation FNBInstagramLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"HEY!, viewDidLoad:");
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginComplete:) name:@"LoginCompleted" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginFailed:) name:@"LoginFailed" object:nil];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    
    //if statement that checks that we have a token stored.. IF and ONLY if it doesn't exist do we present the safarVC
    if (![self hasValidLogin]) {
        NSString *urlString = [NSString stringWithFormat:@"https://api.instagram.com/oauth/authorize/?client_id=%@&redirect_uri=%@&scope=public_content&response_type=token",InstagramClientID,InstagramRedirectURL];
        
        NSURL *url = [NSURL URLWithString:urlString];
        SFSafariViewController *safariVC = [[SFSafariViewController alloc] initWithURL:url];
        
        [self presentViewController:safariVC animated:YES completion:nil];
    }
    else {
        NSLog(@"%d",[self hasValidLogin]);
        AFOAuthCredential *credential = [AFOAuthCredential retrieveCredentialWithIdentifier:@"IGCredential"];
        NSLog(@"%@",credential.accessToken);
    }
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(BOOL)hasValidLogin {
    AFOAuthCredential *credential = [AFOAuthCredential retrieveCredentialWithIdentifier:@"IGCredential"];
    
    return credential;
}

-(void)loginComplete:(NSNotification *)notification {
    
    NSLog(@"Login completed!");
    NSLog(@"%@",notification.description);
    
//    [self fetchDetails];
    
    [self dismissViewControllerAnimated:YES completion:nil];
//    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)loginFailed:(NSNotification *)notification {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Oops!" message:@"Something went wrong and we couldn't authenticate your account." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
    
}

-(void)fetchDetails {
    AFOAuthCredential *credential = [AFOAuthCredential retrieveCredentialWithIdentifier:@"IGCredential"];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    
    
//    [manager.requestSerializer setAuthorizationHeaderFieldWithCredential:credential];
    NSLog(@"Fetching details");
    
    //https://api.instagram.com/v1/tags/nofilter/media/recent?access_token=ACCESS_TOKEN

//    [manager POST:@"https://api.github.com/user" parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        NSLog(@"Success!");
//        NSLog(@"%@",responseObject);
//        
//        //        NSDictionary *userDictionary = responseObject;
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        NSLog(@"Oh no! Something went wrong in the GET method");
//    }];
    
}


@end
