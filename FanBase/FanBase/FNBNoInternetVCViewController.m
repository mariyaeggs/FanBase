//
//  FNBNoInternetVCViewController.m
//  FanBase
//
//  Created by Angelica Bato on 4/18/16.
//  Copyright © 2016 Angelica Bato. All rights reserved.
//

#import "FNBNoInternetVCViewController.h"

@interface FNBNoInternetVCViewController ()
@property (strong, nonatomic) IBOutlet UIImageView *noInternetImage;
@property (strong, nonatomic) IBOutlet UILabel *descNoInternet;

@end

@implementation FNBNoInternetVCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.noInternetImage.image = [UIImage imageNamed:@"No_Network"];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
