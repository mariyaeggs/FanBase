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
#import "FNBNoInternetVCViewController.h"
#import "FanBase-Bridging-Header.h"
#import "FanBase-Swift.h"
#import "FNBDiscoverPageViewController.h"
#import "FNBSeeAllNearbyEventsTableViewController.h"
#import "EULAViewController.h"

@interface FNBLoginContainerViewController () <SideBarDelegate>

//Outlet for main containerView in storyboard
@property (weak, nonatomic) IBOutlet UIView *containerView;

@property (nonatomic, strong) SideBar *sideBar;
@property (nonatomic) BOOL sideBarAllocatted;

//@property (strong, nonatomic) UIViewController *setRootViewController;

@end

@implementation FNBLoginContainerViewController 

- (void)viewDidLoad {
    [super viewDidLoad];
        
    BOOL isNetworkAvailable = [FNBFirebaseClient isNetworkAvailable];

    //Initializes hamburger bar menu button
    UIBarButtonItem *hamburgerButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu"] style:UIBarButtonItemStyleDone target:self action:@selector(hamburgerButtonTapped:)];
    self.navigationItem.rightBarButtonItem = hamburgerButton;
    
//    self.sideBarAllocatted = NO;

    // Initialize side bar
    self.sideBar = [[SideBar alloc] initWithSourceView:self.view sideBarItems:@[@"Profile", @"Discover", @"Logout"]];
    self.sideBar.delegate = self;

//    [FNBFirebaseClient checkUntilUserisAuthenticatedWithCompletionBlock:^(BOOL isAuthenticatedUser) {
//        if (isAuthenticatedUser) {
//            // Initialize side bar
//            self.sideBar = [[SideBar alloc] initWithSourceView:self.view sideBarItems:@[@"Profile", @"Discover", @"Logout"]];
//            self.sideBar.delegate = self;
//            self.sideBarAllocatted = YES;
//            self.sideBar.displayGestureRecognizer.enabled = YES;
//        }
//        else {
//            if (self.sideBarAllocatted) {
//                self.sideBar.displayGestureRecognizer.enabled = NO;
//            }
//            
//            
//
//        }
//             
//    }];


    
    
    if (isNetworkAvailable) {
        [FNBFirebaseClient checkOnceIfUserIsAuthenticatedWithCompletionBlock:^(BOOL isAuthenticUser) {
            // put a loading icon here
            if (isAuthenticUser) {
                [self showUserMainPageVC];
            }
            else {
                [self showFacebookLoginPageVC];
            }
        }];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleUserLoggedInNotification:) name:@"UserDidLogInNotification" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleUserLoggedOutNotification:) name:@"UserDidLogOutNotification" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleHamburgerButtonNotification:) name:@"HamburgerButtonNotification" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAgreedToEULA:) name:@"UserAgreedToEULA" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNewUserLoggedIn:) name:@"NewUserNotification" object:nil];

    }
    else {
        [self showInternetBadVC];
    }
}
- (IBAction)hamburgerTapped:(id)sender {
    
    if (self.sideBar.isSideBarOpen) {
        [self.sideBar showSideBarMenu:NO];
    } else {
        [self.sideBar showSideBarMenu:YES];
    }
}

// If bar menu is tapped
-(void)hamburgerButtonTapped:(id)sender {
    
    if (self.sideBar.isSideBarOpen) {
        [self.sideBar showSideBarMenu:NO];
    } else {
        [self.sideBar showSideBarMenu:YES];
    }
    
}
// Side bar delegate method implementation
-(void)didSelectButtonAtIndex:(NSInteger)index {
    
    NSLog(@"%ld", (long)index);
    
    if ((long)index == 0) {
        [self showUserMainPageVC];
    } else if ((long)index == 1) {
        [self showDiscoverPageVC];
//    } else if ((long)index == 2) {
//        [self showEventsNearMeVC];
    } else if ((long)index == 2) {
        [self handleUserLoggedOutNotification:nil];
    }
    [self.sideBar showSideBarMenu:NO];
}

-(void)handleHamburgerButtonNotification:(NSNotification *)notification {
    
    [self hamburgerButtonTapped:nil];
}

-(void)handleUserLoggedInNotification:(NSNotification *)notification
{
    [self setMenuEnableBasedOnUserLogin];
    [self showUserMainPageVC];
}

-(void)handleUserLoggedOutNotification:(NSNotification *)notification
{
    // if menu open, close it
    if (self.sideBar.isSideBarOpen) {
        [self.sideBar showSideBarMenu:NO];
    }
    [FNBFirebaseClient logoutUser];
    [[FBSDKLoginManager new] logOut];

    [self showFacebookLoginPageVC];
}

- (void)handleNewUserLoggedIn:(NSNotification *)notification {
    // disable the hamburger button and the side menu
    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.sideBar.displayGestureRecognizer.enabled = NO;

    [self showEULAVCWithAuthData:notification.object];
}
- (void)handleAgreedToEULA:(NSNotification *)notification {
    // enable the hamburger button and the side menu
    self.navigationItem.rightBarButtonItem.enabled = YES;
    self.sideBar.displayGestureRecognizer.enabled = YES;

    FAuthData *authdata = notification.object;
    // add user to database
    [FNBFirebaseClient addNewUserToDatabaseWithFacebookAuthData:authdata withCompletion:^(BOOL completed) {
        [self showUserMainPageVC];
    }];
    
}
//- (void) showLoginVC {
//    // for FB login
//    [FNBFirebaseClient showFacebookLoginScreenOnVC:self withCompletion:^(BOOL finishedFBLogin, BOOL isANewUser) {
//        if (finishedFBLogin) {
//            if (isANewUser) {
//                // show EULA VC
//                UIViewController *EULAVC = [[UIStoryboard storyboardWithName:@"Firebase" bundle:nil] instantiateViewControllerWithIdentifier:@"EULAVC"] ;
//                [self presentViewController:EULAVC animated:YES completion:nil];
//            }
//            else {
//                [self showUserMainPageVC];
//            }
//            
//        }
//    }];

//    FNBLoginViewController *loginVC = [[UIStoryboard storyboardWithName:@"Firebase" bundle:nil] instantiateViewControllerWithIdentifier:@"loginViewControllerID"] ;
//    //    FNBLoginViewController *loginVC = [self.storyboard instantiateViewControllerWithIdentifier:@"loginViewControllerID"];
//    [self setEmbeddedViewController:loginVC];
//    [self.navigationController popToRootViewControllerAnimated:YES];
//    if (self.sideBarAllocatted) {
//        self.sideBar.displayGestureRecognizer.enabled = NO;
//    }
//}


- (void)showUserMainPageVC {
    UIStoryboard *nextStoryboard = [UIStoryboard storyboardWithName:@"UserPage" bundle:nil];
    FNBUserProfilePageTableViewController *userVC = [nextStoryboard instantiateViewControllerWithIdentifier:@"UserPageID"];
    
    [self setEmbeddedViewController:userVC];
    [self.navigationController.view setNeedsLayout];
    [self.navigationController popToRootViewControllerAnimated:NO];
}

- (void)showFacebookLoginPageVC {
    [self setMenuEnableBasedOnUserLogin];

    UIStoryboard *nextStoryboard = [UIStoryboard storyboardWithName:@"Firebase" bundle:nil];
    FNBUserProfilePageTableViewController *FBLoginVC = [nextStoryboard instantiateViewControllerWithIdentifier:@"FBLoginViewControllerID"];
    [self setEmbeddedViewController:FBLoginVC];
    [self.navigationController.view setNeedsLayout];
    [self.navigationController popToRootViewControllerAnimated:NO];
}

- (void) showEULAVCWithAuthData:(FBSDKLoginManagerLoginResult *) authdata {
    UIStoryboard *nextStoryboard = [UIStoryboard storyboardWithName:@"Firebase" bundle:nil];
     EULAViewController *EULAVC = [nextStoryboard instantiateViewControllerWithIdentifier:@"EULAVC"];
    EULAVC.authdata = authdata;
    [self setEmbeddedViewController:EULAVC];
    [self.navigationController.view setNeedsLayout];
    [self.navigationController popToRootViewControllerAnimated:NO];
}

- (void)showDiscoverPageVC {
    FNBDiscoverPageViewController *discoverPageVC = [[UIStoryboard storyboardWithName:@"Discover2" bundle:nil]instantiateViewControllerWithIdentifier:@"DiscoverPageID"];
    [self setEmbeddedViewController:discoverPageVC];
    [self.navigationController.view setNeedsLayout];
    [self.navigationController popToRootViewControllerAnimated:YES];
    
}

- (void)showEventsNearMeVC {
    FNBSeeAllNearbyEventsTableViewController *upcomingEventsVC = [[UIStoryboard storyboardWithName:@"UserPage" bundle:nil]instantiateViewControllerWithIdentifier:@"myEvents"];
    // TODO: get the user's events
    upcomingEventsVC.receivedConcertsArray = @[];
    [self setEmbeddedViewController:upcomingEventsVC];
    [self.navigationController.view setNeedsLayout];
    [self.navigationController popToRootViewControllerAnimated:YES];
    
}

- (void) showInternetBadVC {
    FNBNoInternetVCViewController *nextVC = [[UIStoryboard storyboardWithName:@"Firebase" bundle:nil] instantiateViewControllerWithIdentifier:@"NoInternet"];
    [self setEmbeddedViewController:nextVC];
}

- (void) setMenuEnableBasedOnUserLogin {
    [FNBFirebaseClient checkUntilUserisAuthenticatedWithCompletionBlock:^(BOOL isAuthenticatedUser) {
        if (isAuthenticatedUser) {
            self.sideBar.displayGestureRecognizer.enabled = YES;
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }
        else {
            self.sideBar.displayGestureRecognizer.enabled = NO;
            self.navigationItem.rightBarButtonItem.enabled = NO;
        }
    }];
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
}

@end
