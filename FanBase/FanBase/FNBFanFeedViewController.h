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
#import <Firebase/Firebase.h>


@interface FNBFanFeedViewController : JSQMessagesViewController

@property (strong, nonatomic) NSString *senderId;
@property (strong, nonatomic) NSString *senderDisplayName;



@end
