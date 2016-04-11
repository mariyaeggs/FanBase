//
//  FNBFanFeedViewController.h
//  FanBase
//
//  Created by Angelica Bato on 4/11/16.
//  Copyright © 2016 Angelica Bato. All rights reserved.
//

#import <JSQMessagesViewController/JSQMessagesViewController.h>
#import <JSQMessagesBubbleImage.h>
#import <JSQMessagesBubbleImageFactory.h>
#import <UIColor+JSQMessages.h>
#import <JSQMessage.h>


@interface FNBFanFeedViewController : JSQMessagesViewController

@property (strong, nonatomic) NSString *senderID;
@property (copy, nonatomic) NSString *senderDisplayName;



@end
