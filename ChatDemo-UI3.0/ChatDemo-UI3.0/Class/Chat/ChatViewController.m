//
//  ChatViewController.m
//  ChatDemo-UI3.0
//
//  Created by dhc on 15/6/26.
//  Copyright (c) 2015年 easemob.com. All rights reserved.
//

#import "ChatViewController.h"

#import "CustomMessageCell.h"
#import <EaseUI/UIViewController+HUD.h>
#import <EaseUI/NSDate+Category.h>
#import <EaseUI/Emoji.h>

@interface ChatViewController ()<UIAlertViewDelegate, EMMessageViewControllerDelegate, EMMessageViewControllerDataSource>

@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.showRefreshHeader = YES;
    self.delegate = self;
    self.dataSource = self;
    
    [[EMSendMessageCell appearance] setSendBubbleBackgroundImage:[[UIImage imageNamed:@"chat_sender_bg"] stretchableImageWithLeftCapWidth:5 topCapHeight:35]];
    [[EMSendMessageCell appearance] setRecvBubbleBackgroundImage:[[UIImage imageNamed:@"chat_receiver_bg"] stretchableImageWithLeftCapWidth:35 topCapHeight:35]];
    
    [[EMSendMessageCell appearance] setSendMessageVoiceAnimationImages:@[[UIImage imageNamed:@"chat_sender_audio_playing_000"], [UIImage imageNamed:@"chat_sender_audio_playing_001"], [UIImage imageNamed:@"chat_sender_audio_playing_002"], [UIImage imageNamed:@"chat_sender_audio_playing_003"]]];
    [[EMSendMessageCell appearance] setRecvMessageVoiceAnimationImages:@[[UIImage imageNamed:@"chat_receiver_audio_playing000"], [UIImage imageNamed:@"chat_receiver_audio_playing001"], [UIImage imageNamed:@"chat_receiver_audio_playing002"], [UIImage imageNamed:@"chat_receiver_audio_playing003"]]];
    
    [[EMRecvMessageCell appearance] setAvatarSize:40.f];
    [[EMRecvMessageCell appearance] setAvatarCornerRadius:20.f];
    [[EMSendMessageCell appearance] setAvatarSize:40.f];
    [[EMSendMessageCell appearance] setAvatarCornerRadius:20.f];
    
    [[EMChatBarMoreView appearance] setMoreViewBackgroundColor:[UIColor colorWithRed:240 / 255.0 green:242 / 255.0 blue:247 / 255.0 alpha:1.0]];
    
    [self _setupBarButtonItem];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteAllMessages:) name:KNOTIFICATIONNAME_DELETEALLMESSAGE object:nil];
    
    //通过会话管理者获取已收发消息
    [self tableViewDidTriggerHeaderRefresh];
    
    [self.chatBarMoreView insertItemWithImage:[UIImage imageNamed:@"chatBar_colorMore_videoCall"] highlightedImage:[UIImage imageNamed:@"chatBar_colorMore_videoCallSelected"] title:nil];
    [self.chatBarMoreView insertItemWithImage:[UIImage imageNamed:@"chatBar_colorMore_videoCall"] highlightedImage:[UIImage imageNamed:@"chatBar_colorMore_videoCallSelected"] title:nil];
    [self.chatBarMoreView insertItemWithImage:[UIImage imageNamed:@"chatBar_colorMore_videoCall"] highlightedImage:[UIImage imageNamed:@"chatBar_colorMore_videoCallSelected"] title:nil];
    [self.chatBarMoreView insertItemWithImage:[UIImage imageNamed:@"chatBar_colorMore_videoCall"] highlightedImage:[UIImage imageNamed:@"chatBar_colorMore_videoCallSelected"] title:nil];
    EMEmotionManager *manager= [[EMEmotionManager alloc] initWithType:EMEmotionDefault emotionRow:3 emotionCol:7 emotions:[Emoji allEmoji]];
    
    NSMutableArray *emotions = [[NSMutableArray alloc] init];
    for (int i = 0; i < 30; i++) {
        NSString *str = [NSString stringWithFormat:@"b%d.gif",i];
        [emotions addObject:str];
    }
    EMEmotionManager *manager2= [[EMEmotionManager alloc] initWithType:EMEmotionGif emotionRow:2 emotionCol:4 emotions:emotions];
    [self.faceView setNumberOfEmotionManagers:2 emotionManagers:@[manager,manager2]];
    
//    [[DXRecordView appearance] setVoiceMessageAnimationImages:@[@"voice_volume0",@"voice_volume1",@"voice_volume2",@"voice_volume3",@"voice_volume4"]];
//    [[DXRecordView appearance] setUpCancelText:@"123"];
//    [[DXRecordView appearance] setLoosenCancelText:@"456"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - setup subviews

- (void)_setupBarButtonItem
{
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [backButton setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    [self.navigationItem setLeftBarButtonItem:backItem];
    
    //单聊
    if (self.conversation.conversationType == eConversationTypeChat) {
        UIButton *clearButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        [clearButton setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
        [clearButton addTarget:self action:@selector(deleteAllMessages:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:clearButton];
    }
    else{//群聊
        UIButton *detailButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 44)];
        [detailButton setImage:[UIImage imageNamed:@"group_detail"] forState:UIControlStateNormal];
        [detailButton addTarget:self action:@selector(showGroupDetailAction) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:detailButton];
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.cancelButtonIndex != buttonIndex) {
        self.messageTimeIntervalTag = -1;
        [self.conversation removeAllMessages];
        [self.dataArray removeAllObjects];
        [self.messsagesSource removeAllObjects];
        
        [self.tableView reloadData];
    }
}

#pragma mark - EMMessageViewControllerDelegate

- (BOOL)messageViewController:(EMMessageViewController *)viewController
   canLongPressRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (UITableViewCell *)messageViewController:(UITableView *)tableView cellForMessageModel:(id<IMessageModel>)model
{
    if (model.bodyType == eMessageBodyType_Text) {
        NSString *CellIdentifier = [CustomMessageCell cellIdentifierWithModel:model];
        //发送cell
        CustomMessageCell *sendCell = (CustomMessageCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        // Configure the cell...
        if (sendCell == nil) {
            sendCell = [[CustomMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier model:model];
            sendCell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        sendCell.model = model;
        return sendCell;
    }
    return nil;
}

- (CGFloat)messageViewController:(EMMessageViewController *)viewController
           heightForMessageModel:(id<IMessageModel>)messageModel
                   withCellWidth:(CGFloat)cellWidth
{
    if (messageModel.bodyType == eMessageBodyType_Text) {
        return [CustomMessageCell cellHeightWithModel:messageModel];
    }
    return 0.f;
}

- (void)messageViewController:(EMMessageViewController *)viewController didSelectMessageModel:(id<IMessageModel>)messageModel withEventName:(NSString *)eventName
{
    if ([eventName isEqualToString:kRouterEventImageBubbleTapEventName]) {
        
    } else if ([eventName isEqualToString:kRouterEventLocationBubbleTapEventName]) {
        
    } else if ([eventName isEqualToString:kRouterEventAudioBubbleTapEventName]) {
        
    } else if ([eventName isEqualToString:kRouterEventChatCellVideoTapEventName]) {
        
    } else if ([eventName isEqualToString:kRouterEventFileBubbleTapEventName]) {
        
    }
}

- (void)messageViewController:(EMMessageViewController *)viewController
   didSelectAvatarMessageModel:(id<IMessageModel>)messageModel
{
    
}


- (void)messageViewController:(EMMessageViewController *)viewController
            didSelectMoreView:(EMChatBarMoreView *)moreView
                      AtIndex:(NSInteger)index
{
    // 隐藏键盘
    [self.chatToolbar endEditing:YES];
    if (self.conversation.conversationType == EMChatToolbarTypeChat) {
        if  (index == 5) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.easemob.com"]];
        }
    } else {
        if  (index == 3) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.easemob.com"]];
        }
    }
}

#pragma mark - EaseMob

#pragma mark - EMChatManagerLoginDelegate

- (void)didLoginFromOtherDevice
{
    if ([self.imagePicker.mediaTypes count] > 0 && [[self.imagePicker.mediaTypes objectAtIndex:0] isEqualToString:(NSString *)kUTTypeMovie]) {
        [self.imagePicker stopVideoCapture];
    }
}

- (void)didRemovedFromServer
{
    if ([self.imagePicker.mediaTypes count] > 0 && [[self.imagePicker.mediaTypes objectAtIndex:0] isEqualToString:(NSString *)kUTTypeMovie]) {
        [self.imagePicker stopVideoCapture];
    }
}

#pragma mark - EMCallManagerCallDelegate

#pragma mark - action

- (void)backAction
{
//    if (self.deleteConversationIfNull) {
        //判断当前会话是否为空，若符合则删除该会话
        EMMessage *message = [self.conversation latestMessage];
        if (message == nil) {
            [[EaseMob sharedInstance].chatManager removeConversationByChatter:self.conversation.chatter deleteMessages:NO append2Chat:YES];
        }
//    }
    
    [self reloadConversationList];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showGroupDetailAction
{
    [self.view endEditing:YES];
    if (self.conversation.conversationType == eConversationTypeGroupChat) {
        //        ChatGroupDetailViewController *detailController = [[ChatGroupDetailViewController alloc] initWithGroupId:_chatter];
        //        [self.navigationController pushViewController:detailController animated:YES];
    }
    else if (self.conversation.conversationType == eConversationTypeChatRoom)
    {
        //        ChatroomDetailViewController *detailController = [[ChatroomDetailViewController alloc] initWithChatroomId:_chatter];
        //        [self.navigationController pushViewController:detailController animated:YES];
    }
}

- (void)deleteAllMessages:(id)sender
{
    if (self.dataArray.count == 0) {
        [self showHint:NSLocalizedString(@"message.noMessage", @"no messages")];
        return;
    }
    
    if ([sender isKindOfClass:[NSNotification class]]) {
        NSString *groupId = (NSString *)[(NSNotification *)sender object];
        BOOL isDelete = [groupId isEqualToString:self.conversation.chatter];
        if (self.conversation.conversationType != eConversationTypeChat && isDelete) {
            self.messageTimeIntervalTag = -1;
            [self.conversation removeAllMessages];
            [self.messsagesSource removeAllObjects];
            [self.dataArray removeAllObjects];
            
            [self.tableView reloadData];
            [self showHint:NSLocalizedString(@"message.noMessage", @"no messages")];
        }
    }
    else if ([sender isKindOfClass:[UIButton class]]){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", @"Prompt") message:NSLocalizedString(@"sureToDelete", @"please make sure to delete") delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", @"Cancel") otherButtonTitles:NSLocalizedString(@"ok", @"OK"), nil];
        [alertView show];
    }
}


@end
