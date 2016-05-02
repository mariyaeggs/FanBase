//
//  FNBAppDelegate.m
//  FanBase
//
//  Created by Mariya Eggensperger on 4/6/16.
//

#import "FNBAppDelegate.h"
#import "FNBDiscoverPageViewController.h"
#import "UILabel+SubstituteFont.h"
#import "FNBColorConstants.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@implementation FNBAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    
//    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    // Override point for customization after application launch.
    
//    FNBViewController *viewController = [[FNBViewController alloc] initWithStyle:UITableViewStylePlain];
//    
//    self.viewController = [[UINavigationController alloc] initWithRootViewController:viewController];
//    self.window.rootViewController = self.viewController;
//    [self.window makeKeyAndVisible];
    
    [UILabel appearance].fis_substituteFontName = @"Avenir";
    [UIButton appearance].tintColor = FNBDarkGreenColor;
    [[UIButton appearance] setTitleColor:FNBDarkGreenColor forState:UIControlStateNormal];
    [UITextField appearance].tintColor = FNBDarkGreyColor;
    self.window.tintColor = [UIColor blackColor];
    
    
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                    didFinishLaunchingWithOptions:launchOptions];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [FBSDKAppEvents activateApp];
}
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}

@end
