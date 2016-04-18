//
//  FNBArtistEvent.h
//  FanBase
//
//  Created by Angelica Bato on 4/7/16.
//  Copyright © 2016 Angelica Bato. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FNBArtistEvent : NSObject

@property (strong, nonatomic) NSString *eventTitle;
@property (strong, nonatomic) NSString *dateOfConcert;
@property (assign, nonatomic) BOOL isTicketsAvailable;
@property (strong, nonatomic) NSDictionary *venue;
@property (assign, nonatomic) BOOL isStarred;
@property (strong, nonatomic) NSString *artistImageURL;
@property (strong, nonatomic) NSString *unformattedDateOfConcert;

-(instancetype)initWithEventTitle:(NSString *)eventTitle
                             date:(NSString *)dateOfConcert
                     availability:(BOOL)isTicketsAvailable
                            venue:(NSDictionary *)venue
                             star:(BOOL)isStarred
                            image:(NSString *)imageURL;

-(instancetype)initWithEventTitle:(NSString *)eventTitle
                             date:(NSString *)dateOfConcert
                     availability:(BOOL)isTicketsAvailable
                            venue:(NSDictionary *)venue
                             star:(BOOL)isStarred
                            image:(NSString *)imageURL
                  unformattedDate:(NSString *)unformattedDateOfConcert;

@end
