//
//  FanFeedTableViewController.m
//  FanBase
//
//  Created by Angelica Bato on 3/29/16.
//  Copyright © 2016 Angelica Bato. All rights reserved.
//

#import "FNBFanFeedTableViewController.h"

@interface FNBFanFeedTableViewController ()

@property (strong, nonatomic) NSArray *tweetsOfArtistNews;

@end

@implementation FNBFanFeedTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"Outside client req");
    
//    [FNBTwitterAPIClient generateTweetsForKeyword:@"Adele" completion:^(NSArray *returnedArray) {
//        NSLog(@"Inside client req");
//        NSLog(@"%@",returnedArray);
//        self.tweetsOfArtistNews = returnedArray;
//        
//        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//            [self.tableView reloadData];
//        }];
//    }];
    
    [FNBTwitterAPIClient generateTweetsOfUsername:@"Adele" completion:^(NSArray *returnedArray) {
        NSLog(@"Inside the client for Username req");
        NSLog(@"%@",returnedArray);
        self.tweetsOfArtistNews = returnedArray;
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self.tableView reloadData];
        }];
        
    }];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tweetsOfArtistNews.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FNBTwitterPostTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tweetCell" forIndexPath:indexPath];
    
    NSURL *picURL = [NSURL URLWithString:self.tweetsOfArtistNews[indexPath.row][@"user"][@"profile_image_url"]];
    [cell.userPicture setImageWithURL:picURL];
    
    cell.userName.text = [NSString stringWithFormat:@"@%@",self.tweetsOfArtistNews[indexPath.row][@"user"][@"screen_name"]];
    cell.userTweet.text = self.tweetsOfArtistNews[indexPath.row][@"text"];
    
    return cell;
}

@end
