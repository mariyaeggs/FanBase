//
//  FanFeedTableViewController.m
//  FanBase
//
//  Created by Angelica Bato on 3/29/16.
//  Copyright © 2016 Angelica Bato. All rights reserved.
//

#import "FanFeedTableViewController.h"

@interface FanFeedTableViewController ()

@property (strong, nonatomic) NSArray *tweetsOfArtistNews;

@end

@implementation FanFeedTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"Outside client req");
    [TwitterAPIClient generateTweetsForKeyword:@"Adele" completion:^(NSArray *returnedArray) {
        NSLog(@"Inside client req");
        NSLog(@"%@",returnedArray);
        self.tweetsOfArtistNews = returnedArray;
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self.tableView reloadData];
        }];
    }];
    
//    [TwitterAPIClient generateTweetsOfUsername:@"Adele" completion:^(NSArray *returnedArray) {
//        NSLog(@"Inside the client for Username req");
//        NSLog(@"%@",returnedArray);
//        self.tweetsOfArtistNews = returnedArray;
//        
//        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//            [self.tableView reloadData];
//        }];
//        
//    }];
    
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    TwitterPostTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tweetCell" forIndexPath:indexPath];
    
    
    
    NSURL *picURL = [NSURL URLWithString:self.tweetsOfArtistNews[indexPath.row][@"user"][@"profile_image_url"]];
    NSData *picDATA = [NSData dataWithContentsOfURL:picURL];
    UIImage *userPic = [[UIImage alloc] initWithData:picDATA];
    
    cell.userPicture.image = userPic;
    cell.userName.text = [NSString stringWithFormat:@"@%@",self.tweetsOfArtistNews[indexPath.row][@"user"][@"screen_name"]];
    cell.userTweet.text = self.tweetsOfArtistNews[indexPath.row][@"text"];
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
