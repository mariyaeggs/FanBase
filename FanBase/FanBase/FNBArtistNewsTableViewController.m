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
    
    if ([self isForceTouchAvailable]) {
        self.previewingContext = [self registerForPreviewingWithDelegate:self sourceView:self.view];
    }
    else {
        [self unregisterForPreviewingWithContext:self.previewingContext];
        self.previewingContext = nil;
    }
    
    self.allNews = [@[@[],@[]] mutableCopy];
    
    //PULL EVENTS
    [FNBBandsInTownAPIClient generateEventsForArtist:@"Adele" completion:^(NSArray *returnedArray) {

        self.allNews[1] = returnedArray;
        NSLog(@"%@",self.allNews);
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self.tableView reloadData];
        }];
        
    }];
    
    //PULL TWEETS
    [FNBTwitterAPIClient generateTweetsOfUsername:@"Adele" completion:^(NSArray *returnedArray) {

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
        FNBArtistEvent *event = self.allNews[1][indexPath.row];
        NSURL *picURL = [NSURL URLWithString:event.artistImageURL];
        [cell.artistImage setImageWithURL:picURL];
        
        cell.eventTitle.text = [NSString stringWithFormat:@"%@",event.eventTitle];
        
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

-(NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    NSString *twitter = @"Tweets";
    NSString *events = @"Events";
    return @[twitter,events];
}

-(NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return index;
}

# pragma mark - Helper Methods

-(BOOL)isForceTouchAvailable {
    BOOL isForceTouchAvailable = NO;
    if([self.traitCollection respondsToSelector:@selector(forceTouchCapability)]) {
        isForceTouchAvailable = self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable;
    }
    return isForceTouchAvailable;
}


# pragma mark - Previewing Delegate methods

-(UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location {
    if ([self.presentedViewController isKindOfClass:[UIViewController class]]) {
        return nil;
    }
    CGPoint cellPos = [self.tableView convertPoint:location fromView:self.view];
    NSIndexPath *path = [self.tableView indexPathForRowAtPoint:cellPos];
    
    if (path && path.section == 1) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"FNBArtistNews" bundle:nil];
        FNBEventInfoVC *previewVC = [storyboard instantiateViewControllerWithIdentifier:@"eventInfo"];
        previewVC.event = [self.allNews[1] objectAtIndex:path.row];
        
        return previewVC;
    }
    
    return nil;
}

-(void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit {
    [self.navigationController showViewController:viewControllerToCommit sender:nil];
}


//-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    
//    
//    if ([self.tableView indexPathForSelectedRow].section == 1) {
//        FNBEventInfoVC *destVC = segue.destinationViewController;
//        destVC.event = self.allNews[1][[self.tableView indexPathForSelectedRow].row];
//    }
//    
//}

@end
