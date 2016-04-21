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
#import "FNBViewController.h"
#import "FNBSeeAllNearbyEventsTableViewController.h"

@interface FNBLoginContainerViewController () <SideBarDelegate>

//Outlet for main containerView in storyboard
@property (weak, nonatomic) IBOutlet UIView *containerView;

@property (nonatomic, strong) SideBar *sideBar;
@property (nonatomic) BOOL sideBarAllocatted;

@end

@implementation FNBLoginContainerViewController 

- (void)viewDidLoad {
    [super viewDidLoad];

    
    BOOL isNetworkAvailable = [FNBFirebaseClient isNetworkAvailable];
    //BOOL isNetworkAvailable = [FNBFirebaseClient isNetworkAvailable];


    //Initializes hamburger bar menu button
    UIBarButtonItem *hamburgerButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu"] style:UIBarButtonItemStyleDone target:self action:@selector(hamburgerButtonTapped:)];
    self.navigationItem.rightBarButtonItem = hamburgerButton;
    
    self.sideBarAllocatted = NO;

    // problem: this method doesn't get called again after user logs in once
    [FNBFirebaseClient checkUntilUserisAuthenticatedWithCompletionBlock:^(BOOL isAuthenticatedUser) {
        if (isAuthenticatedUser) {
            // Initialize side bar
            self.sideBar = [[SideBar alloc] initWithSourceView:self.view sideBarItems:@[@"Profile", @"Discover", @"Logout"]];
            self.sideBar.delegate = self;
            self.sideBarAllocatted = YES;
            self.sideBar.displayGestureRecognizer.enabled = YES;
        }
        else {
            if (self.sideBarAllocatted) {
                self.sideBar.displayGestureRecognizer.enabled = NO;
            }
        }
             
    }];


    
    
    if (isNetworkAvailable) {
        [FNBFirebaseClient checkOnceIfUserIsAuthenticatedWithCompletionBlock:^(BOOL isAuthenticUser) {
            // put a loading icon here
            if (isAuthenticUser) {
                [self showUserMainPageVC];
            }
            else {
                [self showLoginVC];
            }
        }];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleUserLoggedInNotification:) name:@"UserDidLogInNotification" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleUserLoggedOutNotification:) name:@"UserDidLogOutNotification" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleHamburgerButtonNotification:) name:@"HamburgerButtonNotification" object:nil];
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
    [self showUserMainPageVC];
}

-(void)handleUserLoggedOutNotification:(NSNotification *)notification
{
    [FNBFirebaseClient logoutUser]; 
    [self showLoginVC];
}

- (void) showLoginVC {
    NSLog(@"starting to show the login VC");
    FNBLoginViewController *loginVC = [[UIStoryboard storyboardWithName:@"Firebase" bundle:nil] instantiateViewControllerWithIdentifier:@"loginViewControllerID"] ;
    //    FNBLoginViewController *loginVC = [self.storyboard instantiateViewControllerWithIdentifier:@"loginViewControllerID"];
    [self setEmbeddedViewController:loginVC];
    [self.navigationController popToRootViewControllerAnimated:YES];
    if (self.sideBarAllocatted) {
        self.sideBar.displayGestureRecognizer.enabled = NO;
    }
}


- (void)showUserMainPageVC {
    UIStoryboard *nextStoryboard = [UIStoryboard storyboardWithName:@"UserPage" bundle:nil];
    FNBUserProfilePageTableViewController *userVC = [nextStoryboard instantiateViewControllerWithIdentifier:@"UserPageID"];
    
    [self setEmbeddedViewController:userVC];
    [self.navigationController popToRootViewControllerAnimated:YES];

}


- (void)showDiscoverPageVC {
    FNBViewController *discoverPageVC = [[UIStoryboard storyboardWithName:@"Discover2" bundle:nil]instantiateViewControllerWithIdentifier:@"DiscoverPageID"];
    [self setEmbeddedViewController:discoverPageVC];
    [self.navigationController popToRootViewControllerAnimated:YES];
    
}

- (void)showEventsNearMeVC {
    FNBSeeAllNearbyEventsTableViewController *upcomingEventsVC = [[UIStoryboard storyboardWithName:@"UserPage" bundle:nil]instantiateViewControllerWithIdentifier:@"myEvents"];
    // TODO: get the user's events
    upcomingEventsVC.receivedConcertsArray = @[];
    [self setEmbeddedViewController:upcomingEventsVC];
    [self.navigationController popToRootViewControllerAnimated:YES];
    
}

- (void) showInternetBadVC {
    FNBNoInternetVCViewController *nextVC = [[UIStoryboard storyboardWithName:@"Firebase" bundle:nil] instantiateViewControllerWithIdentifier:@"NoInternet"];
    [self setEmbeddedViewController:nextVC];
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
