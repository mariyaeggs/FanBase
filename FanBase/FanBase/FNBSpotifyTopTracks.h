//
//  TopTracks.h
//  spotifytop10
//
//  Created by Rodrigo on 3/31/16.
//  Copyright © 2016 Rodrigo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface FNBSpotifyTopTracks : NSObject

@property (nonatomic,strong) NSString *albumName;
@property (nonatomic,strong) NSString *trackName;
@property (nonatomic,strong) NSString *imageURL;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *trackSampleURL;

-(id)initWithName:(NSString *)albumName trackName:(NSString *)trackName imageURL:(NSString *)imageURL trackSampleURL:(NSString *) trackSampleURL;

@end
