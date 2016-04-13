//
//  FNBEventInfoVC.m
//  FanBase
//
//  Created by Angelica Bato on 4/7/16.
//  Copyright © 2016 Angelica Bato. All rights reserved.
//

#import "FNBEventInfoVC.h"
#import "FNBArtistMainPageTableViewController.h"

@interface FNBEventInfoVC ()

@property (strong, nonatomic) IBOutlet MKMapView *eventMapView;
@property (strong, nonatomic) IBOutlet UILabel *eventTitle;
@property (strong, nonatomic) IBOutlet UILabel *eventVenue;
@property (strong, nonatomic) IBOutlet UILabel *eventDate;
@property (strong, nonatomic) IBOutlet UILabel *ticketsAvailable;
@property (strong, nonatomic) IBOutlet UIImageView *artistImage;


@end

@implementation FNBEventInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CLLocationDegrees latitude = [self.event.venue[@"latitude"] doubleValue];
    CLLocationDegrees longitude = [self.event.venue[@"longitude"] doubleValue];
    CLLocationCoordinate2D location2 = CLLocationCoordinate2DMake(latitude, longitude);
    
    CLLocationDistance regionRadius = 1000;
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(location2, (regionRadius*2.0), (regionRadius*2.0));
    
    MKPointAnnotation *annot = [[MKPointAnnotation alloc] init];
    [annot setCoordinate:location2];
    
    [self.eventMapView setCenterCoordinate:location2 animated:YES];
    [self.eventMapView setRegion:region animated:YES];
    [self.eventMapView addAnnotation:annot];
    
    
    self.eventTitle.text = self.event.eventTitle;
    self.eventVenue.text = self.event.venue[@"name"];
    self.eventDate.text = self.event.dateOfConcert;
    if (self.event.isTicketsAvailable == YES) {
        self.ticketsAvailable.text = @"Ticket Available: YES";
    }
    else {
        self.ticketsAvailable.text = @"Ticket Available: NO";
    }
    
    
    NSURL *picURL = [NSURL URLWithString:self.event.artistImageURL];
    [self.artistImage setImageWithURL:picURL];
    
    

}

-(void)viewWillAppear:(BOOL)animated {
    NSLog(@"view will appear");
    
    // Check to see if presenting view controller is kind of class FNBArtistMainPageTableViewController
    if ([self.presentingViewController isKindOfClass:[FNBArtistMainPageTableViewController class]]) {
        NSLog(@"presenting class is of type FNBArtistMainPageTableViewController");
        
        // Create and add a button to the view in order to dismiss view controller
        UIButton *dismissButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        
        // Add target method to handle when button is pressed in order to dismiss
        [dismissButton addTarget:self action:@selector(dismissVC:) forControlEvents:UIControlEventTouchUpInside];
        
        // Add button to subview of main view
        [self.view addSubview:dismissButton];
        
        // Set up design of button
        dismissButton.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.9];
        [dismissButton setTitle:@"X" forState:UIControlStateNormal];
        [dismissButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        // Add constraints to button to place it in top right corner
        dismissButton.translatesAutoresizingMaskIntoConstraints = NO;
        [dismissButton.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:20].active = YES;
        [dismissButton.rightAnchor constraintEqualToAnchor:self.view.rightAnchor constant:-20].active = YES;
    }
}

// Target method for dismissing view controller when presenting class is FNBArtistMainPageTableViewController
-(void)dismissVC:(UIButton *)sender {
    NSLog(@"button pressed");
    
    // Dismiss view controller and return to FNBArtistMainPageTableViewController
    [self dismissViewControllerAnimated:YES completion:nil];
    
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



@end
