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
@property (strong, nonatomic) Firebase *rootRef;
@property (strong, nonatomic) Firebase *messagesRef;

@end

@implementation FNBFanFeedViewController
//-(void)viewWillAppear:(BOOL)animated {
//
//    
//    
//    NSLog(@"In viewWillAppear");
//    [self addMessageWithID:@"someoneElse" text:@"Hey Person!"];
//    [self addMessageWithID:self.senderId text:@"Yo"];
//    [self addMessageWithID:self.senderId text:@"I like turtles"];
//    NSLog(@"%@",self.messages);
//    [self finishReceivingMessage];
//}

- (void)viewDidLoad {
    NSLog(@"In viewDidLoad");
    [super viewDidLoad];
    
    self.messages = [NSMutableArray new];
    self.rootRef = [[Firebase alloc] initWithUrl:@"https://flickering-fire-7717.firebaseio.com/"];
    self.messagesRef = [[Firebase alloc] init];
    
    self.title = @"FanFeed";
    self.senderId = @"andyNovak";
    self.senderDisplayName = @"Andy";
    [self setupBubbles];
    
    self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
    self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
    
    self.messagesRef = [self.rootRef childByAppendingPath:@"messages"];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    [self observeMessages];
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
    NSLog(@"self.messages @indexPath.item: %@", message.senderId);
    NSLog(@"current User = %@",self.senderId);
    if ([message.senderId isEqualToString:self.senderId]) {
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

-(void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text senderId:(NSString *)senderId senderDisplayName:(NSString *)senderDisplayName date:(NSDate *)date {
    Firebase *itemRef = self.messagesRef.childByAutoId;
    NSDictionary *messageItem = @{
                                  @"text": text,
                                  @"senderId": senderId
                                  };
    [itemRef setValue:messageItem];
    
    [self finishSendingMessage];
}

-(void)observeMessages {
   FQuery *messagesQuery = [self.messagesRef queryLimitedToLast:25];
    [messagesQuery observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
        NSString *senderId = snapshot.value[@"senderId"];
        NSLog(@"senderID: %@",senderId);
        NSString *text = snapshot.value[@"text"];
        [self addMessageWithID:senderId text:text];
        [self finishReceivingMessage];
    }];
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
