//
//  FNBAppDelegate.m
//  FanBase
//
//  Created by Mariya Eggensperger on 4/6/16.
//  Copyright © 2016 Angelica Bato. All rights reserved.
//

#import "FNBAppDelegate.h"
#import "FNBViewController.h"

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
    
    
    
    // ----- Attempt to change app-wide color----
//    self.window.tintColor = [UIColor colorWithRed:230.0 green:255.0 blue:247.0 alpha:1.0];
//    UIColor *gradientMaskLayer = [UIColor colorWithRed:184.0 green:204.0 blue:198.0 alpha:1.0];
//    CAGradientLayer *gradientMask = [CAGradientLayer layer];
//    gradientMask.frame = self.window.bounds;
//    gradientMask.colors = @[(id)gradientMaskLayer.CGColor,(id)[UIColor clearColor].CGColor];
//    
//    [self.window.layer insertSublayer:gradientMask atIndex:1];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
