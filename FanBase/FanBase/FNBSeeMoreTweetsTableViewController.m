//
//  FNBSeeMoreTweetsTableViewController.m
//  FanBase
//
//  Created by Andy Novak on 4/14/16.
//  Copyright © 2016 Angelica Bato. All rights reserved.
//

#import "FNBSeeMoreTweetsTableViewController.h"
#import "FNBTwitterPostTableViewCell.h"
#import "UIImageView+AFNetworking.h"
#import "FNBColorConstants.h"

@interface FNBSeeMoreTweetsTableViewController ()

@end

@implementation FNBSeeMoreTweetsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //Initializes hamburger bar menu button
    UIBarButtonItem *hamburgerButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu"] style:UIBarButtonItemStyleDone target:self action:@selector(hamburgerButtonTapped:)];
    self.navigationItem.rightBarButtonItem = hamburgerButton;
    
    //Gradient
    self.view.tintColor = FNBOffWhiteColor;
    UIColor *gradientMaskLayer = FNBLightGreenColor;
    CAGradientLayer *gradientMask = [CAGradientLayer layer];
    gradientMask.frame = self.view.bounds;
    gradientMask.colors = @[(id)gradientMaskLayer.CGColor,(id)[UIColor clearColor].CGColor];
    [self.view.layer insertSublayer:gradientMask atIndex:0];
    
    

}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.receivedArtist.tweetsArray.count;

}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    FNBTwitterPostTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tweetCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    NSURL *picURL = [NSURL URLWithString:self.receivedArtist.tweetsArray[indexPath.row][@"user"][@"profile_image_url"]];
    [cell.userPicture setImageWithURL:picURL];
    
    
    cell.userName.text = [NSString stringWithFormat:@"%@",self.receivedArtist.tweetsArray[indexPath.row][@"user"][@"name"]];
    cell.userTweet.text = self.receivedArtist.tweetsArray[indexPath.row][@"text"];
    
    
    
    return cell;

}

-(void)hamburgerButtonTapped:(id)sender {
    NSLog(@"Hamburger pressed and posting notification");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HamburgerButtonNotification" object:nil];
}

@end
