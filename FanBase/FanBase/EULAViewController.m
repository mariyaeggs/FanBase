//
//  EULAViewController.m
//  FanBase
//
//  Created by Mariya Eggensperger on 4/28/16.
//  Copyright © 2016 Angelica Bato. All rights reserved.
//

#import "EULAViewController.h"

@interface EULAViewController()
@property (weak, nonatomic) IBOutlet UITextView *connectedTextView;


@end

@implementation EULAViewController


-(void) viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    [self.connectedTextView flashScrollIndicators];

}

- (void)viewDidLoad {
    
    [super viewDidLoad];
}
- (IBAction)agreeTapped:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UserAgreedToEULA" object:self.authdata];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
