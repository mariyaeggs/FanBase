//
//  FNBNavigationWithHambugerButtonViewController.m
//  FanBase
//
//  Created by Andy Novak on 4/20/16.
//  Copyright © 2016 Angelica Bato. All rights reserved.
//

#import "FNBNavigationWithHambugerButtonViewController.h"

@interface FNBNavigationWithHambugerButtonViewController () <UINavigationControllerDelegate>

@end

@implementation FNBNavigationWithHambugerButtonViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.delegate = self;

}

-(void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    //Initializes hamburger bar menu button
    UIBarButtonItem *hamburgerButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu"] style:UIBarButtonItemStyleDone target:self action:@selector(hamburgerButtonTapped:)];
    viewController.navigationItem.rightBarButtonItem = hamburgerButton;
}

-(void)hamburgerButtonTapped:(id)sender {
    NSLog(@"Hamburger pressed and posting notification");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HamburgerButtonNotification" object:nil];
}

@end
