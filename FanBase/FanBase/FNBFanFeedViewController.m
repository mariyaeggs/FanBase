//
//  FNBFanFeedViewController.m
//  FanBase
//
//  Created by Angelica Bato on 4/11/16.
//  Copyright © 2016 Angelica Bato. All rights reserved.
//

#import "FNBFanFeedViewController.h"
#import "FanBase-Bridging-Header.h"
#import "Fanbase-Swift.h"


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
@property (strong, nonatomic) Firebase *usersRef;
@property (strong, nonatomic) Firebase *reportUserRef;
@property (strong, nonatomic) Firebase *reportContentRef;

@property (assign, nonatomic) BOOL localTyping;
@property (assign, nonatomic) BOOL isTyping;
@property (strong, nonatomic) FQuery *usersTypingQuery;

@property (strong, nonatomic) FNBUser *otherUser;



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
    [super viewDidLoad];
    
    //Initializes hamburger bar menu button
    UIBarButtonItem *hamburgerButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu"] style:UIBarButtonItemStyleDone target:self action:@selector(hamburgerButtonTapped:)];
    self.navigationItem.rightBarButtonItem = hamburgerButton;

    
    self.collectionView.backgroundColor = [UIColor colorWithRed:230/255.0 green:255/255.0 blue:247.0/255 alpha:1.0];
    
    self.senderId = self.user.userID;
    self.senderDisplayName = self.user.userName;
    self.senderAvatar = self.user.userImage;
    
//    self.artist = [[FNBArtist alloc] initWithName:@"Adele"];
    
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
    
    self.usersRef = [[Firebase alloc] init];
    self.usersRef = [self.rootRef childByAppendingPath:@"users"];
    
    self.reportUserRef = [[Firebase alloc] init];
    self.reportUserRef = [self.rootRef childByAppendingPath:@"reported users"];
    
    self.reportContentRef = [[Firebase alloc] init];
    self.reportContentRef = [self.rootRef childByAppendingPath:@"reported content"];
    
    
    self.title = [NSString stringWithFormat:@"FanFeed // %@", self.artist.name];
    
    [self setupBubbles];
}
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    [self observeMessages];
    [self observeTyping];
}

-(void)hamburgerButtonTapped:(id)sender {
    NSLog(@"Hamburger pressed and posting notification");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HamburgerButtonNotification" object:nil];
}

-(void)setupBubbles {
    JSQMessagesBubbleImageFactory *factory = [[JSQMessagesBubbleImageFactory alloc] init];
    self.outgoingBubbleImage = [factory outgoingMessagesBubbleImageWithColor:[UIColor colorWithRed:45.0/255 green:127.0/255 blue:102.0/255 alpha:1.0]];
    self.incomingBubbleImage = [factory incomingMessagesBubbleImageWithColor:[UIColor colorWithRed:184.0/255 green:204.0/255 blue:198.0/255 alpha:1.0]];
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
    
    JSQMessagesAvatarImage *image = [JSQMessagesAvatarImageFactory avatarImageWithUserInitials:[[message.senderDisplayName substringToIndex:1] uppercaseString] backgroundColor:[UIColor lightGrayColor] textColor:[UIColor blackColor] font:[UIFont fontWithName:@"Helvetica" size:8.0] diameter:10];

    return image;
}

-(void)addMessageWithID:(NSString *)id displayName:(NSString *)displayName text:(NSString *)text {
    JSQMessage *message = [[JSQMessage alloc] initWithSenderId:id senderDisplayName:displayName date:[NSDate date] text:text];
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
    
    return [[NSAttributedString alloc] initWithString:message.senderDisplayName];
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
                                  @"senderDisplayName":senderDisplayName,
                                  @"senderAvatarURL":self.user.profileImageURL
                                  };
    
    [itemRef setValue:messageItem];
    
    self.isTyping = NO;
    
    [self finishSendingMessage];
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapAvatarImageView:(UIImageView *)avatarImageView atIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Tapped avatar!");
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"REPORT USER" message:@"Would you like to report user?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *report = [UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"Report action here");
        
        Firebase *reportRef = self.reportUserRef.childByAutoId;
        JSQMessage *currentMess = self.messages[indexPath.item];
        NSDictionary *reportUserItem = @{
                                         @"reporterID":self.user.userID,
                                         @"reporterName":self.user.userName,
                                         @"channel":self.artist.name,
                                         @"reportedID":currentMess.senderId,
                                         @"reportedUserName":currentMess.senderDisplayName
                                         };
        
        [reportRef setValue:reportUserItem];
        
        UIAlertController *followUpAlert = [UIAlertController alertControllerWithTitle:@"Thanks!" message:@"We have recorded your report, and will follow up with this in the next 24 hours." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
        [followUpAlert addAction:ok];
        [self dismissViewControllerAnimated:YES completion:nil];
        [self presentViewController:followUpAlert animated:nil completion:nil];
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Nope!" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"It's alright");
    }];
    
    [alertController addAction:report];
    [alertController addAction:cancel];
    [self presentViewController:alertController animated:YES completion:nil];
    
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Tapped message bubble!");
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Report content" message:@"Would you like to report this as inappropriate content?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *report = [UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"Report action here");
        
        Firebase *reportRef = self.reportContentRef.childByAutoId;
        JSQMessage *currentMess = self.messages[indexPath.item];
        NSDictionary *reportContentItem = @{
                                         @"reporterID":self.user.userID,
                                         @"reporterName":self.user.userName,
                                         @"channel":self.artist.name,
                                         @"reported content":currentMess.text,
                                         @"reportedID":currentMess.senderId,
                                         @"reportedUserName":currentMess.senderDisplayName
                                         };
        
        [reportRef setValue:reportContentItem];
        
        UIAlertController *followUpAlert = [UIAlertController alertControllerWithTitle:@"Thanks!" message:@"We'll follow up with this in the next 24 hours." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
        [followUpAlert addAction:ok];
        [self presentViewController:followUpAlert animated:nil completion:nil];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Nope!" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"It's alright");
    }];
    
    [alertController addAction:report];
    [alertController addAction:cancel];
    [self presentViewController:alertController animated:YES completion:nil];
    
}

# pragma mark - Observation methods

-(void)observeMessages {
   FQuery *messagesQuery = [self.messagesRef queryLimitedToLast:25];
    [messagesQuery observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
        NSString *senderId = snapshot.value[@"senderId"];
        NSString *displayName = snapshot.value[@"senderDisplayName"];
        NSString *text = snapshot.value[@"text"];
        [self addMessageWithID:senderId displayName:displayName text:text];
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

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    if( [self.inputToolbar.contentView.textView isFirstResponder] )
    {
        [self.inputToolbar.contentView.textView resignFirstResponder];
    }
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
