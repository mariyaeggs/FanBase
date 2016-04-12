//
//  FNBFanFeedViewController.m
//  FanBase
//
//  Created by Angelica Bato on 4/11/16.
//  Copyright © 2016 Angelica Bato. All rights reserved.
//

#import "FNBFanFeedViewController.h"

@interface FNBFanFeedViewController ()

@property (strong, nonatomic) NSMutableArray<JSQMessage *> *messages;
@property (strong, nonatomic) JSQMessagesBubbleImage *outgoingBubbleImage;
@property (strong, nonatomic) JSQMessagesBubbleImage *incomingBubbleImage;

@end

@implementation FNBFanFeedViewController
-(void)viewWillAppear:(BOOL)animated {
    self.messages = [NSMutableArray new];
    NSLog(@"In viewWillAppear");
    [self addMessageWithID:@"someoneElse" text:@"Hey Person!"];
    [self addMessageWithID:self.senderId text:@"Yo"];
    [self addMessageWithID:self.senderId text:@"I like turtles"];
    NSLog(@"%@",self.messages);
    [self finishReceivingMessage];
}

- (void)viewDidLoad {
    NSLog(@"In viewDidLoad");
    [super viewDidLoad];
    self.title = @"FanFeed";
    self.senderId = @"angelirose";
    self.senderDisplayName = @"Angelica";
    [self setupBubbles];
    
    self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
    self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setupBubbles {
    NSLog(@"In setupBubbles");
    JSQMessagesBubbleImageFactory *factory = [[JSQMessagesBubbleImageFactory alloc] init];
    self.outgoingBubbleImage = [factory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleBlueColor]];
    self.incomingBubbleImage = [factory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
}

-(id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.messages[indexPath.item];
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.messages.count;
}

-(id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    JSQMessage *message = self.messages[indexPath.item];
    if (message.senderId == self.senderId) {
        NSLog(@"Returning outgoing Bubble Image");
        return self.outgoingBubbleImage;
        
    }
    NSLog(@"returning incoming Bubble Image");
    return self.incomingBubbleImage;
}

-(id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

-(void)addMessageWithID:(NSString *)id text:(NSString *)text {
    JSQMessage *message = [[JSQMessage alloc] initWithSenderId:id senderDisplayName:@"" date:[NSDate date] text:text];
    [self.messages addObject:message];
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
