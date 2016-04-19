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

@interface FNBSeeMoreTweetsTableViewController ()

@end

@implementation FNBSeeMoreTweetsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    
    
//    - (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//    {
//        return [indexPath row] * 20;
//    
//    
//
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.receivedArtist.tweetsArray.count;

}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    FNBTwitterPostTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tweetCell" forIndexPath:indexPath];
    
    NSURL *picURL = [NSURL URLWithString:self.receivedArtist.tweetsArray[indexPath.row][@"user"][@"profile_image_url"]];
    [cell.userPicture setImageWithURL:picURL];
    
    
    cell.userName.text = [NSString stringWithFormat:@"%@",self.receivedArtist.tweetsArray[indexPath.row][@"user"][@"name"]];
    cell.userTweet.text = self.receivedArtist.tweetsArray[indexPath.row][@"text"];
    
    
    
    return cell;

}

@end
