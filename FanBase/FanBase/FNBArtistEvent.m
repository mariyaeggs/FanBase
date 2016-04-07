//
//  FNBArtistEvent.m
//  FanBase
//
//  Created by Angelica Bato on 4/7/16.
//  Copyright © 2016 Angelica Bato. All rights reserved.
//

#import "FNBArtistEvent.h"

@implementation FNBArtistEvent

-(instancetype)initWithEventTitle:(NSString *)eventTitle
                             date:(NSString *)dateOfConcert
                     availability:(BOOL)isTicketsAvailable
                            venue:(NSDictionary *)venue
                             star:(BOOL)isStarred {
    
    self = [super init];
    if (self) {
        _eventTitle = eventTitle;
        _dateOfConcert = dateOfConcert;
        _isTicketsAvailable = isTicketsAvailable;
        _venue = venue;
        _isStarred = isStarred;
    }
    
    return self;
    
}

@end
