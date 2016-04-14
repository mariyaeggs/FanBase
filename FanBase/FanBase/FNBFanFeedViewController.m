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
@property (strong, nonatomic) JSQMessagesAvatarImage *outgoingAvatarImage;
@property (strong, nonatomic) JSQMessagesAvatarImage *incomingAvatarImage;


@property (strong, nonatomic) Firebase *rootRef;
@property (strong, nonatomic) Firebase *messagesRef;
@property (strong, nonatomic) Firebase *artistsRef;
@property (strong, nonatomic) Firebase *artistSpecificRef;
@property (strong, nonatomic) Firebase *userIsTypingRef;

@property (assign, nonatomic) BOOL localTyping;
@property (assign, nonatomic) BOOL isTyping;
@property (strong, nonatomic) FQuery *usersTypingQuery;

@end

@implementation FNBFanFeedViewController


# pragma mark - Setter/Getter Methods

-(void)setIsTyping:(BOOL)isTyping {
    _isTyping = isTyping;
    self.localTyping = isTyping;
    [self.userIsTypingRef setValue:@(_isTyping)];
    
}

# pragma mark - Setup Methods

- (void)viewDidLoad {
    NSLog(@"In viewDidLoad");
    [super viewDidLoad];
    
    //Setup test data
    self.senderId = @"angelirose";
    self.senderDisplayName = @"Angelica";
    self.senderAvatar = [UIImage imageNamed:@"Adele"];
    self.artist = [[FNBArtist alloc] initWithName:@"Adele"];
    
    self.localTyping = NO;
    
    self.messages = [NSMutableArray new];
    self.rootRef = [[Firebase alloc] initWithUrl:ourFirebaseURL];
    
    self.artistsRef = [[Firebase alloc] init];
    self.artistsRef = [self.rootRef childByAppendingPath:@"artists"];
    
    NSString *formattedArtistName = [FNBFirebaseClient formatedArtistName:self.artist.name];
    
    self.artistSpecificRef = [[Firebase alloc] init];
    self.artistSpecificRef = [self.artistsRef childByAppendingPath:formattedArtistName];
    
    
    self.messagesRef = [[Firebase alloc] init];
    self.messagesRef = [self.artistSpecificRef childByAppendingPath:@"messages"];
    
    self.title = @"FanFeed";

    
    
    [self setupBubbles];
    
    
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    [self observeMessages];
    [self observeTyping];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setupBubbles {
    JSQMessagesBubbleImageFactory *factory = [[JSQMessagesBubbleImageFactory alloc] init];
    self.outgoingBubbleImage = [factory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleBlueColor]];
    self.incomingBubbleImage = [factory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
}

# pragma mark - Delegate methods for collectionview

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
        return self.outgoingBubbleImage;
        
    }
    return self.incomingBubbleImage;
}

-(id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    JSQMessage *message = self.messages[indexPath.item];
    if ([message.senderId isEqualToString:self.senderId]) {
        JSQMessagesAvatarImage *image = [JSQMessagesAvatarImage avatarWithImage:[UIImage imageNamed:@"adele"]];
        return image;
    }
    
    JSQMessagesAvatarImage *image = [JSQMessagesAvatarImage avatarWithImage:[UIImage imageNamed:@"anonymous_avatar"]];
    return image;
}

-(void)addMessageWithID:(NSString *)id text:(NSString *)text {
    JSQMessage *message = [[JSQMessage alloc] initWithSenderId:id senderDisplayName:id date:[NSDate date] text:text];
    [self.messages addObject:message];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    JSQMessage *message = self.messages[indexPath.item];
    if ([message.senderId isEqualToString:self.senderId]) {
        cell.textView.textColor = [UIColor whiteColor];
    }
    else {
        cell.textView.textColor = [UIColor blackColor];
    }
    
    return cell;
}

-(NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath {
    
    JSQMessage *messageNow = self.messages[indexPath.item];

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterLongStyle];
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    
    NSString *stringFromDate = [formatter stringFromDate:messageNow.date];
    return [[NSAttributedString alloc] initWithString:stringFromDate];
    
}

-(NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath {
    JSQMessage *message = self.messages[indexPath.item];
    
    return [[NSAttributedString alloc] initWithString:message.senderId];
}

-(CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.item == 0) {
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    
    if (indexPath.item != 0) {
        JSQMessage *messageNow = self.messages[indexPath.item];
        JSQMessage *messageBefore = self.messages[indexPath.item-1];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterLongStyle];
        [formatter setTimeZone:[NSTimeZone localTimeZone]];
        
        NSString *stringOfNow = [formatter stringFromDate:messageNow.date];
        NSString *stringOfBefore = [formatter stringFromDate:messageBefore.date];
        
        
        if (![stringOfNow isEqualToString:stringOfBefore]) {
            return kJSQMessagesCollectionViewCellLabelHeightDefault;
        }
    }
    
    return 0.0f;
}

-(CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath {
    JSQMessage *currentMessage = [self.messages objectAtIndex:indexPath.item];
    if ([[currentMessage senderId] isEqualToString:self.senderId]) {
        return 0.0f;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:[currentMessage senderId]]) {
            return 0.0f;
        }
    }
    
    return kJSQMessagesCollectionViewCellLabelHeightDefault;
}



# pragma mark - Event listeners

-(void)textViewDidChange:(UITextView *)textView {
    [super textViewDidChange:textView];
    self.isTyping = ![textView.text isEqualToString:@""];
}

-(void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text senderId:(NSString *)senderId senderDisplayName:(NSString *)senderDisplayName date:(NSDate *)date {
    Firebase *itemRef = self.messagesRef.childByAutoId;
    NSDictionary *messageItem = @{
                                  @"text": text,
                                  @"senderId": senderId,
                                  @"senderDisplayName":senderDisplayName
                                  };
    [itemRef setValue:messageItem];
    
    self.isTyping = NO;
    
    [self finishSendingMessage];
}

# pragma mark - Observation methods

-(void)observeMessages {
   FQuery *messagesQuery = [self.messagesRef queryLimitedToLast:25];
    [messagesQuery observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
        NSString *senderId = snapshot.value[@"senderId"];
        NSString *text = snapshot.value[@"text"];
        [self addMessageWithID:senderId text:text];
        [self finishReceivingMessage];
    }];
}

-(void)observeTyping {
    
    Firebase *typingIndicatorRef = [self.rootRef childByAppendingPath:@"typingIndicator"];
    self.userIsTypingRef  = [typingIndicatorRef childByAppendingPath:self.senderId];
    [self.userIsTypingRef onDisconnectRemoveValue];
    
    self.usersTypingQuery = [[typingIndicatorRef queryOrderedByValue] queryEqualToValue:@(YES)];
    [self.usersTypingQuery observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        if (snapshot.childrenCount == 1 && self.isTyping) {
            return;
        }
        
        self.showTypingIndicator = snapshot.childrenCount > 0;
        [self scrollToBottomAnimated:YES];
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
