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



@interface FNBLoginContainerViewController () <SideBarDelegate>

//Outlet for main containerView in storyboard
@property (weak, nonatomic) IBOutlet UIView *containerView;

@property (nonatomic, strong) SideBar *sideBar;


@end

@implementation FNBLoginContainerViewController 

- (void)viewDidLoad {
    [super viewDidLoad];

    
    BOOL isNetworkAvailable = [FNBFirebaseClient isNetworkAvailable];
    //BOOL isNetworkAvailable = [FNBFirebaseClient isNetworkAvailable];


    //Initializes hamburger bar menu button
//    UIBarButtonItem *hamburgerButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu"] style:UIBarButtonSystemItemDone target:self action:@selector(hamburgerButtonTapped:)];
//    hamburgerButton.tintColor = [UIColor blackColor];
//    self.navigationItem.rightBarButtonItem = hamburgerButton;
//
//    
//    // Call the sidebar menu function
//    

//    // Initialize side bar
//    self.sideBar = [[SideBar alloc] initWithSourceView:self.view sideBarItems:@[@"Profile", @"Discover", @"Events"]];
//    self.sideBar.delegate = self;
//
    
    
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


//// Side bar delegate method implementation
//-(void)didSelectButtonAtIndex:(NSInteger)index {
//    
//    
//}
//
//// If bar menu is tapped
//-(void)hamburgerButtonTapped:(id)sender {
//    
//    if (self.sideBar.isSideBarOpen) {
//        [self.sideBar showSideBarMenu:NO];
//    } else {
//        [self.sideBar showSideBarMenu:YES];
//    }
//    
//}

-(void)handleHamburgerButtonNotification:(NSNotification *)notification {
    
    NSLog(@"We got hamburgers?");
    [self.sideBar showSideBarMenu:YES];
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
}

- (void)showUserMainPageVC {

    UIStoryboard *nextStoryboard = [UIStoryboard storyboardWithName:@"UserPage" bundle:nil];
//    UINavigationController *nextNavController = [nextStoryboard instantiateViewControllerWithIdentifier:@"userPageNavControllerID"];
//    FNBUserProfilePageTableViewController *userVC = nextNavController.viewControllers[0];
    FNBUserProfilePageTableViewController *userVC = [nextStoryboard instantiateViewControllerWithIdentifier:@"UserPageID"];
    
    [self setEmbeddedViewController:userVC];
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
