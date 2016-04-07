//
//  FanFeedTableViewController.m
//  FanBase
//
//  Created by Angelica Bato on 3/29/16.
//  Copyright © 2016 Angelica Bato. All rights reserved.
//

#import "FNBArtistNewsTableViewController.h"

@interface FNBArtistNewsTableViewController ()
@property (strong, nonatomic) NSMutableArray *allNews;
@property (strong, nonatomic) NSArray *tweetsOfArtistNews;
@property (strong, nonatomic) NSArray *eventsForArtist;

@end

@implementation FNBArtistNewsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"Outside client req");
    
    self.allNews = [@[@[],@[]] mutableCopy];
    
    [FNBBandsInTownAPIClient generateEventsForArtist:@"Adele" completion:^(NSArray *returnedArray) {
//        NSLog(@"Inside BandsInTown Client");
//        NSLog(@"%@",returnedArray);

        self.allNews[1] = returnedArray;
        NSLog(@"%@",self.allNews);
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self.tableView reloadData];
        }];
        
    }];
    
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
//        NSLog(@"Inside the client for Username req");
//        NSLog(@"%@",returnedArray);
        self.allNews[0] = returnedArray;
        NSLog(@"%@",self.allNews);
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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *array = self.allNews[section];
    NSLog(@"Array.Count = %li",array.count);
    return array.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        NSLog(@"Check inside section %li",indexPath.section);
        
        FNBTwitterPostTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tweetCell" forIndexPath:indexPath];
        
        NSURL *picURL = [NSURL URLWithString:self.allNews[0][indexPath.row][@"user"][@"profile_image_url"]];
            [cell.userPicture setImageWithURL:picURL];
        
        
        cell.userName.text = [NSString stringWithFormat:@"%@",self.allNews[0][indexPath.row][@"user"][@"name"]];
        cell.userTweet.text = self.allNews[0][indexPath.row][@"text"];
        
        return cell;

    }
    else if (indexPath.section == 1) {
        NSLog(@"Check inside section %li",indexPath.section);
        
        EventPostTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"eventCell" forIndexPath:indexPath];
        NSURL *picURL = [NSURL URLWithString:self.allNews[1][indexPath.row][@"artists"][0][@"image_url"]];
        [cell.artistImage setImageWithURL:picURL];
        
        cell.eventTitle.text = [NSString stringWithFormat:@"%@",self.allNews[1][indexPath.row][@"title"]];
        
        return cell;
    }
    
    return nil;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *title = [NSString new];
    if (section == 0) {
        title = @"Tweets";
    }
    else if (section == 1) {
        title = @"Events";
    }
    
    return title;
}

@end
