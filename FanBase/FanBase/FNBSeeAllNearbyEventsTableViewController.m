//
//  SeeAllNearbyEventsTableViewController.m
//  FanBase
//
//  Created by Andy Novak on 4/18/16.
//  Copyright © 2016 Angelica Bato. All rights reserved.
//

#import "FNBSeeAllNearbyEventsTableViewController.h"
#import "FNBSeeAllNearbyEventsTableViewCell.h"
#import "FNBArtistEvent.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "FNBEventInfoVC.h"

@interface FNBSeeAllNearbyEventsTableViewController ()


@end

@implementation FNBSeeAllNearbyEventsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
        FNBArtistEvent *selectedEvent = self.receivedConcertsArray[indexPath.row];
        
        
        // Create an instance of FNBEventInfoVC (view controller)
        // Use UIStoryboard class/type to create the instance
        FNBEventInfoVC *eventInfoVC = [[UIStoryboard storyboardWithName:@"FNBArtistNews" bundle:nil] instantiateViewControllerWithIdentifier:@"eventInfo"];
        
        // Assign event value to property on eventInfoVC
        eventInfoVC.event = selectedEvent;
        
        // Push eventInfoVC in my window
        [self.navigationController pushViewController:eventInfoVC animated:YES];

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.receivedConcertsArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FNBSeeAllNearbyEventsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"eventCell" forIndexPath:indexPath];
    cell.eventDateLabel.text = ((FNBArtistEvent *)self.receivedConcertsArray[indexPath.row]).dateOfConcert;
    cell.eventTitleLabel.text = ((FNBArtistEvent *)self.receivedConcertsArray[indexPath.row]).eventTitle;
    [cell.eventImage setImageWithURL:[NSURL URLWithString: ((FNBArtistEvent *)self.receivedConcertsArray[indexPath.row]).artistImageURL]];
    
    
    return cell;
}



@end
