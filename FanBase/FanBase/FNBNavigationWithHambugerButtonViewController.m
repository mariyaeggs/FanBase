//
//  FNBNavigationWithHambugerButtonViewController.m
//  FanBase
//
//  Created by Andy Novak on 4/20/16.
//  Copyright © 2016 Angelica Bato. All rights reserved.
//

#import "FNBNavigationWithHambugerButtonViewController.h"

@interface FNBNavigationWithHambugerButtonViewController ()

@end

@implementation FNBNavigationWithHambugerButtonViewController

- (void)viewDidLoad {
    [super viewDidLoad];

        //Initializes hamburger bar menu button
        UIBarButtonItem *hamburgerButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu"] style:UIBarButtonSystemItemDone target:self action:@selector(hamburgerButtonTapped:)];
    

        
        self.navigationItem.rightBarButtonItem = hamburgerButton;

}

-(void)hamburgerButtonTapped:(id)sender {
    NSLog(@"Hamburger pressed in the custom navigation controller");

}

@end
