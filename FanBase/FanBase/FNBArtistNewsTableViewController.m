//
//  FanFeedTableViewController.m
//  FanBase
//
//  Created by Angelica Bato on 3/29/16.
//  Copyright © 2016 Angelica Bato. All rights reserved.
//

#import "FNBArtistNewsTableViewController.h"

@interface FNBArtistNewsTableViewController ()


@end

@implementation FNBArtistNewsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"Outside client req");
    
    if ([self isForceTouchAvailable]) {
        self.previewingContext = [self registerForPreviewingWithDelegate:self sourceView:self.view];
        self.longPress.enabled = NO;
    }
    else {
        [self unregisterForPreviewingWithContext:self.previewingContext];
        self.previewingContext = nil;
        
        self.longPress.enabled = YES;
    }
    
  }




- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.eventsArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
        EventPostTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"eventCell" forIndexPath:indexPath];
        FNBArtistEvent *event = self.eventsArray[indexPath.row];
        NSURL *picURL = [NSURL URLWithString:event.artistImageURL];
        [cell.artistImage setImageWithURL:picURL];
        
        cell.eventTitle.text = [NSString stringWithFormat:@"%@",event.eventTitle];
        
        return cell;

}




# pragma mark - Helper Methods

-(BOOL)isForceTouchAvailable {
    BOOL isForceTouchAvailable = NO;
    if([self.traitCollection respondsToSelector:@selector(forceTouchCapability)]) {
        isForceTouchAvailable = self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable;
    }
    return isForceTouchAvailable;
}

-(UILongPressGestureRecognizer *)longPress {
    if (!_longPress) {
        _longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(showPeek)];
        [self.tableView addGestureRecognizer:_longPress];
    }
    return _longPress;
}
-(void)showPeek {
    CGPoint tapPoint = [self.longPress locationInView:self.tableView];
    NSIndexPath *path = [self.tableView indexPathForRowAtPoint:tapPoint];
    
    if (path && path.section == 1) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"FNBArtistNews" bundle:nil];
        FNBEventInfoVC *previewVC = [storyboard instantiateViewControllerWithIdentifier:@"eventInfo"];
        previewVC.event = [self.eventsArray objectAtIndex:path.row];
        [self.navigationController showViewController:previewVC sender:nil];
    }
    
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
        previewVC.event = [self.eventsArray objectAtIndex:path.row];
        
        return previewVC;
    }
    
    return nil;
}

-(void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit {
    [self.navigationController showViewController:viewControllerToCommit sender:nil];
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    
            FNBEventInfoVC *destVC = segue.destinationViewController;
        destVC.event = self.eventsArray[[self.tableView indexPathForSelectedRow].row];
    
    
}

@end
