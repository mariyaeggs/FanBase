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
                             star:(BOOL)isStarred
                            image:(NSString *)imageURL
                  unformattedDate:(NSString *)unformattedDateOfConcert
{
    self = [self initWithEventTitle:eventTitle date:dateOfConcert availability:isTicketsAvailable venue:venue star:isStarred image:imageURL];
    if (self) {
        _unformattedDateOfConcert = unformattedDateOfConcert;
    }
    return self;
}


-(instancetype)initWithEventTitle:(NSString *)eventTitle
                             date:(NSString *)dateOfConcert
                     availability:(BOOL)isTicketsAvailable
                            venue:(NSDictionary *)venue
                             star:(BOOL)isStarred
                            image:(NSString *)imageURL
{
    
    self = [super init];
    if (self) {
        _eventTitle = eventTitle;
        _dateOfConcert = dateOfConcert;
        _isTicketsAvailable = isTicketsAvailable;
        _venue = venue;
        _isStarred = isStarred;
        _artistImageURL = imageURL;
    }
    
    return self;
    
}

-(NSString *)description {
    return [NSString stringWithFormat:@"TITLE: %@ \n VENUE:%@",self.eventTitle, self.venue];
}



@end
