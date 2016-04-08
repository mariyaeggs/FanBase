//
//  FBSTableViewController.h
//  spotifytop10
//
//  Created by Rodrigo on 3/31/16.
//  Copyright © 2016 Rodrigo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FNBSpotifyAPIclient.h"
#import "FNBSpotifyTopTracks.h"

@interface FNBArtistTop10TableViewController : UITableViewController
@property (strong, nonatomic) NSString *recievedArtistSpotifyID; 
@end
