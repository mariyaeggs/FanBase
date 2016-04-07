//
//  FNBArtistEvent.h
//  FanBase
//
//  Created by Angelica Bato on 4/7/16.
//  Copyright © 2016 Angelica Bato. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FNBArtistEvent : NSObject

@property (strong, nonatomic) NSString *eventTitle;
@property (strong, nonatomic) NSString *dateOfConcert;
@property (assign, nonatomic) BOOL isTicketsAvailable;
@property (strong, nonatomic) NSDictionary *venue;
@property (assign, nonatomic) BOOL isStarred;




@end
