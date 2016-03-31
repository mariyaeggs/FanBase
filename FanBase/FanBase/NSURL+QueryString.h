//
//  NSURL+QueryString.h
//  FanBase
//
//  Created by Angelica Bato on 3/31/16.
//  Copyright © 2016 Angelica Bato. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (QueryString)

- (NSString *)valueForFragment;

//- (NSString *)valueForFirstQueryItemNamed:(NSString *)name;

@end
