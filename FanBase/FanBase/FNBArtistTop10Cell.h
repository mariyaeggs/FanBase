//
//  TableViewCell.h
//  spotifytop10
//
//  Created by Rodrigo on 4/1/16.
//  Copyright © 2016 Rodrigo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FNBArtistTop10Cell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *AlbumImageView;

@property (weak, nonatomic) IBOutlet UILabel *TrackNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *AlbumNameLabel;

@property (weak, nonatomic) IBOutlet UIButton *play_pauseButton;

@property (strong, nonatomic) NSString *trackSampleURL;

@end
