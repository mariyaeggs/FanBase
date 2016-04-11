//
//  FNBLoginContainerViewController.m
//  FanBase
//
//  Created by Andy Novak on 4/11/16.
//  Copyright © 2016 Angelica Bato. All rights reserved.
//

#import "FNBLoginContainerViewController.h"
#import "FNBLoginViewController.h"
#import "FNBUserProfilePageTableViewController.h"
#import "FNBFirebaseClient.h"

@interface FNBLoginContainerViewController ()
@property (weak, nonatomic) IBOutlet UIView *containerView;

@end

@implementation FNBLoginContainerViewController

- (void)viewDidLoad {
    [super viewDidLoad];

//    BOOL userIsLoggedIn = NO;
    
    [FNBFirebaseClient checkOnceIfUserIsAuthenticatedWithCompletionBlock:^(BOOL isAuthenticUser) {
        // put a loading icon here
        if (isAuthenticUser) {
            [self showUserMainPageVC];
        }
        else {
            [self showLoginVC];
        }
    }];
    
   
//    
//    if (userIsLoggedIn) {
//        // show the users main page
//        [self showUserMainPageVC];
//    }
//    
//    else {
//        // show the login screen
//        [self showLoginVC];
//    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleUserLoggedInNotification:) name:@"UserDidLogInNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleUserLoggedOutNotification:) name:@"UserDidLogOutNotification" object:nil];
}


-(void)handleUserLoggedInNotification:(NSNotification *)notification
{
    [self showUserMainPageVC];
}

-(void)handleUserLoggedOutNotification:(NSNotification *)notification
{
    [self showLoginVC];
}

- (void) showLoginVC {
    FNBLoginViewController *loginVC = [self.storyboard instantiateViewControllerWithIdentifier:@"loginViewControllerID"];
    [self setEmbeddedViewController:loginVC];
}

- (void) showUserMainPageVC {
    // not sure if this is right? what is the identifier? whats the difference between the following two lines?
//    [[UIStoryboard storyboardWithName:@"UserPage" bundle:nil] instantiateViewControllerWithIdentifier:@"UserPageID"];
//    FNBUserProfilePageTableViewController *userVC = [self.storyboard instantiateViewControllerWithIdentifier:@"UserPageID"];
    
    
    UIStoryboard *nextStoryboard = [UIStoryboard storyboardWithName:@"UserPage" bundle:nil];
    FNBUserProfilePageTableViewController *userVC = [nextStoryboard instantiateViewControllerWithIdentifier:@"UserPageID"];

    
    [self setEmbeddedViewController:userVC];
}

#pragma mark Child VC from Tim

-(void)setEmbeddedViewController:(UIViewController *)controller
{
    if([self.childViewControllers containsObject:controller]) {
        return;
    }
    
    for(UIViewController *vc in self.childViewControllers) {
        [vc willMoveToParentViewController:nil];
        
        if(vc.isViewLoaded) {
            [vc.view removeFromSuperview];
        }
        
        [vc removeFromParentViewController];
    }
    
    if(!controller) {
        return;
    }
    
    [self addChildViewController:controller];
    [self.containerView addSubview:controller.view];
    
    controller.view.translatesAutoresizingMaskIntoConstraints = NO;
    [controller.view.leftAnchor constraintEqualToAnchor:self.containerView.leftAnchor].active = YES;
    [controller.view.rightAnchor constraintEqualToAnchor:self.containerView.rightAnchor].active = YES;
    [controller.view.topAnchor constraintEqualToAnchor:self.containerView.topAnchor].active = YES;
    [controller.view.bottomAnchor constraintEqualToAnchor:self.containerView.bottomAnchor].active = YES;

    [controller didMoveToParentViewController:self];
}@end
