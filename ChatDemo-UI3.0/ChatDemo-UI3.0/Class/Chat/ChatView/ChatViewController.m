//
//  ChatViewController.m
//  ChatDemo-UI3.0
//
//  Created by dhc on 15/6/26.
//  Copyright (c) 2015年 easemob.com. All rights reserved.
//

#import "ChatViewController.h"

#import "ChatGroupDetailViewController.h"
#import "ChatroomDetailViewController.h"
#import "CustomMessageCell.h"
#import "UserProfileViewController.h"
#import "UserProfileManager.h"
#import "ContactListSelectViewController.h"
#import "ReadFireCell.h"

#define KEMEFFECT_REVOKEM_EXT_PROMPT       @"messageRevokePrompt"

@interface ChatViewController ()<UIAlertViewDelegate, EaseMessageViewControllerDelegate, EaseMessageViewControllerDataSource>
{
    UIMenuItem *_copyMenuItem;
    UIMenuItem *_deleteMenuItem;
    UIMenuItem *_transpondMenuItem;
    
    UIMenuItem *_revokeMenuItem;
    
    NSRunLoop *_runLoop;
    NSTimer *_timer;
    UIAlertView *_textReadAlert;
    BOOL _isHasRevokePrompt; //判断是否需要增加撤销提示,默认YES增加撤销提示
}

@property (nonatomic) BOOL isPlayingAudio;

@property (nonatomic, strong) id<IMessageModel> currentModel;

@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _isHasRevokePrompt = YES;
    self.showRefreshHeader = YES;
    self.delegate = self;
    self.dataSource = self;
    
    [[EaseBaseMessageCell appearance] setSendBubbleBackgroundImage:[[UIImage imageNamed:@"chat_sender_bg"] stretchableImageWithLeftCapWidth:5 topCapHeight:35]];
    [[EaseBaseMessageCell appearance] setRecvBubbleBackgroundImage:[[UIImage imageNamed:@"chat_receiver_bg"] stretchableImageWithLeftCapWidth:35 topCapHeight:35]];
    
    [[EaseBaseMessageCell appearance] setSendMessageVoiceAnimationImages:@[[UIImage imageNamed:@"chat_sender_audio_playing_full"], [UIImage imageNamed:@"chat_sender_audio_playing_000"], [UIImage imageNamed:@"chat_sender_audio_playing_001"], [UIImage imageNamed:@"chat_sender_audio_playing_002"], [UIImage imageNamed:@"chat_sender_audio_playing_003"]]];
    [[EaseBaseMessageCell appearance] setRecvMessageVoiceAnimationImages:@[[UIImage imageNamed:@"chat_receiver_audio_playing_full"],[UIImage imageNamed:@"chat_receiver_audio_playing000"], [UIImage imageNamed:@"chat_receiver_audio_playing001"], [UIImage imageNamed:@"chat_receiver_audio_playing002"], [UIImage imageNamed:@"chat_receiver_audio_playing003"]]];
    
    [[EaseBaseMessageCell appearance] setAvatarSize:40.f];
    [[EaseBaseMessageCell appearance] setAvatarCornerRadius:20.f];
    
    [[EaseChatBarMoreView appearance] setMoreViewBackgroundColor:[UIColor colorWithRed:240 / 255.0 green:242 / 255.0 blue:247 / 255.0 alpha:1.0]];
    
    [self _setupBarButtonItem];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteAllMessages:) name:KNOTIFICATIONNAME_DELETEALLMESSAGE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(exitGroup) name:@"ExitGroup" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(insertCallMessage:) name:@"insertCallMessage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCallNotification:) name:@"callOutWithChatter" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCallNotification:) name:@"callControllerClose" object:nil];
    
    //通过会话管理者获取已收发消息
    [self tableViewDidTriggerHeaderRefresh];
    
    EaseEmotionManager *manager= [[EaseEmotionManager alloc] initWithType:EMEmotionDefault emotionRow:3 emotionCol:7 emotions:[EaseEmoji allEmoji]];
    [self.faceView setEmotionManagers:@[manager]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.conversation.conversationType == eConversationTypeGroupChat) {
        if ([[self.conversation.ext objectForKey:@"groupSubject"] length])
        {
            self.title = [self.conversation.ext objectForKey:@"groupSubject"];
        }
    }
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
    if (alertView == _textReadAlert) {
        
        [self timerAction];
        return;
    }
    if (alertView.cancelButtonIndex != buttonIndex) {
        self.messageTimeIntervalTag = -1;
        [self.conversation removeAllMessages];
        [self.dataArray removeAllObjects];
        [self.messsagesSource removeAllObjects];
        
        [self.tableView reloadData];
    }
}

#pragma mark - EaseMessageViewControllerDelegate

- (BOOL)messageViewController:(EaseMessageViewController *)viewController
   canLongPressRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (BOOL)messageViewController:(EaseMessageViewController *)viewController
   didLongPressRowAtIndexPath:(NSIndexPath *)indexPath
{
    id object = [self.dataArray objectAtIndex:indexPath.row];
    if (![object isKindOfClass:[NSString class]]) {
        EaseMessageCell *cell = (EaseMessageCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        [cell becomeFirstResponder];
        self.menuIndexPath = indexPath;
        [self _showMenuViewController:cell.bubbleView andIndexPath:indexPath messageType:cell.model.bodyType];
    }
    return YES;
}

- (UITableViewCell *)messageViewController:(UITableView *)tableView cellForMessageModel:(id<IMessageModel>)model
{
    if ([RemoveAfterReadManager isReadAfterRemoveMessage:model.message])
    {
        NSString *CellIdentifier = [ReadFireCell cellIdentifierWithModel:model];
        ReadFireCell *cell = (ReadFireCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[ReadFireCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier model:model];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.model = model;
        BOOL isReading = _currentModel && [_currentModel.messageId isEqualToString:model.messageId];
        [cell isReadMessage:isReading];
        
        return cell;
    }
    else if ([model.message.ext[KEMEFFECT_REVOKEM_EXT_PROMPT] boolValue])
    {//消息撤销提示
        NSString *TimeCellIdentifier = [EaseMessageTimeCell cellIdentifier];
        EaseMessageTimeCell *timeCell = (EaseMessageTimeCell *)[tableView dequeueReusableCellWithIdentifier:TimeCellIdentifier];
        
        if (timeCell == nil) {
            timeCell = [[EaseMessageTimeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TimeCellIdentifier];
            timeCell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        EMTextMessageBody *body = model.message.messageBodies.firstObject;
        timeCell.title = body.text;
        return timeCell;
    }
    else if (model.bodyType == eMessageBodyType_Text) {
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

- (CGFloat)messageViewController:(EaseMessageViewController *)viewController
           heightForMessageModel:(id<IMessageModel>)messageModel
                   withCellWidth:(CGFloat)cellWidth
{
    if ([messageModel.message.ext[KEMEFFECT_REVOKEM_EXT_PROMPT] boolValue])
    {
        //消息撤销提示
        return self.timeCellHeight;
    }
    if (messageModel.bodyType == eMessageBodyType_Text) {
        return [CustomMessageCell cellHeightWithModel:messageModel];
    }
    return 0.f;
}

- (BOOL)messageViewController:(EaseMessageViewController *)viewController didSelectMessageModel:(id<IMessageModel>)messageModel
{
    if (!messageModel.isSender && [RemoveAfterReadManager isReadAfterRemoveMessage:messageModel.message])
    {
        [self markReadingMessage:messageModel];
        switch (messageModel.bodyType) {
            case eMessageBodyType_Text:
            {
                [self textReadFire];
                _textReadAlert = [[UIAlertView alloc] initWithTitle:@"此消息阅读6秒后自动焚毁" message:messageModel.text delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
                [_textReadAlert show];
            }
                break;
            default:
                break;
        }
    }
    BOOL flag = NO;
    return flag;
}

- (void)messageViewController:(EaseMessageViewController *)viewController
   didSelectAvatarMessageModel:(id<IMessageModel>)messageModel
{
    UserProfileViewController *userprofile = [[UserProfileViewController alloc] initWithUsername:messageModel.nickname];
    [self.navigationController pushViewController:userprofile animated:YES];
}


- (void)messageViewController:(EaseMessageViewController *)viewController
            didSelectMoreView:(EaseChatBarMoreView *)moreView
                      AtIndex:(NSInteger)index
{
    // 隐藏键盘
    [self.chatToolbar endEditing:YES];
}

- (void)messageViewController:(EaseMessageViewController *)viewController
          didSelectRecordView:(UIView *)recordView
                 withEvenType:(EaseRecordViewType)type
{
    switch (type) {
        case EaseRecordViewTypeTouchDown:
        {
            if ([self.recordView isKindOfClass:[EaseRecordView class]]) {
                [(EaseRecordView *)self.recordView  recordButtonTouchDown];
            }
        }
            break;
        case EaseRecordViewTypeTouchUpInside:
        {
            if ([self.recordView isKindOfClass:[EaseRecordView class]]) {
                [(EaseRecordView *)self.recordView recordButtonTouchUpInside];
            }
            [self.recordView removeFromSuperview];
        }
            break;
        case EaseRecordViewTypeTouchUpOutside:
        {
            if ([self.recordView isKindOfClass:[EaseRecordView class]]) {
                [(EaseRecordView *)self.recordView recordButtonTouchUpOutside];
            }
            [self.recordView removeFromSuperview];
        }
            break;
        case EaseRecordViewTypeDragInside:
        {
            if ([self.recordView isKindOfClass:[EaseRecordView class]]) {
                [(EaseRecordView *)self.recordView recordButtonDragInside];
            }
        }
            break;
        case EaseRecordViewTypeDragOutside:
        {
            if ([self.recordView isKindOfClass:[EaseRecordView class]]) {
                [(EaseRecordView *)self.recordView recordButtonDragOutside];
            }
        }
            break;
        default:
            break;
    }
}

#pragma mark - EaseMessageViewControllerDataSource

- (id<IMessageModel>)messageViewController:(EaseMessageViewController *)viewController
                           modelForMessage:(EMMessage *)message
{
    id<IMessageModel> model = nil;
    model = [[EaseMessageModel alloc] initWithMessage:message];
    model.avatarImage = [UIImage imageNamed:@"EaseUIResource.bundle/user"];
    UserProfileEntity *profileEntity = [[UserProfileManager sharedInstance] getUserProfileByUsername:model.nickname];
    if (profileEntity) {
        model.avatarURLPath = profileEntity.imageUrl;
    }
    model.failImageName = @"imageDownloadFail";
    return model;
}

#pragma mark - EaseChatBarMoreViewDelegate
#warning 阅后即焚修改
- (void)moreView:(EaseChatBarMoreView *)moreView removeAfterRead:(BOOL)isRemove
{
    if (isRemove)
    {
        [self enableRemoveAfterRead];
    }
    else {
        [self disableRemoveAfterRead];
    }
    
    [self.chatToolbar endEditing:YES];
}

#pragma mark - EMReadManagerProtocol

//图片、音频、视频
- (void)readMessageFinished:(id<IMessageModel>)model
{
    [self readFireMessageDeal:model];
}

#pragma mark - EMLocationViewDelegate
//地理位置
- (void)locationMessageReadAck:(id<IMessageModel>)messageModel
{
    [self readFireMessageDeal:messageModel];
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

#pragma mark - action

- (void)backAction
{
    if (self.deleteConversationIfNull) {
        //判断当前会话是否为空，若符合则删除该会话
        [self removeConversation];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showGroupDetailAction
{
    [self.view endEditing:YES];
    if (self.conversation.conversationType == eConversationTypeGroupChat) {
        ChatGroupDetailViewController *detailController = [[ChatGroupDetailViewController alloc] initWithGroupId:self.conversation.chatter];
        [self.navigationController pushViewController:detailController animated:YES];
    }
    else if (self.conversation.conversationType == eConversationTypeChatRoom)
    {
        ChatroomDetailViewController *detailController = [[ChatroomDetailViewController alloc] initWithChatroomId:self.conversation.chatter];
        [self.navigationController pushViewController:detailController animated:YES];
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

- (void)transpondMenuAction:(id)sender
{
    if (self.menuIndexPath && self.menuIndexPath.row > 0) {
        id<IMessageModel> model = [self.dataArray objectAtIndex:self.menuIndexPath.row];
        ContactListSelectViewController *listViewController = [[ContactListSelectViewController alloc] initWithNibName:nil bundle:nil];
        listViewController.messageModel = model;
        [listViewController tableViewDidTriggerHeaderRefresh];
        [self.navigationController pushViewController:listViewController animated:YES];
    }
    self.menuIndexPath = nil;
}

- (void)revokeMessageAction:(id)sender
{
    [self revokeMessage];
}


- (void)copyMenuAction:(id)sender
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    if (self.menuIndexPath && self.menuIndexPath.row > 0) {
        id<IMessageModel> model = [self.dataArray objectAtIndex:self.menuIndexPath.row];
        pasteboard.string = model.text;
    }
    
    self.menuIndexPath = nil;
}

- (void)deleteMenuAction:(id)sender
{
    if (self.menuIndexPath && self.menuIndexPath.row > 0) {
        id<IMessageModel> model = [self.dataArray objectAtIndex:self.menuIndexPath.row];
        NSMutableIndexSet *indexs = [NSMutableIndexSet indexSetWithIndex:self.menuIndexPath.row];
        NSMutableArray *indexPaths = [NSMutableArray arrayWithObjects:self.menuIndexPath, nil];
        
        [self.conversation removeMessage:model.message];
        [self.messsagesSource removeObject:model.message];
        
        if (self.menuIndexPath.row - 1 >= 0) {
            id nextMessage = nil;
            id prevMessage = [self.dataArray objectAtIndex:(self.menuIndexPath.row - 1)];
            if (self.menuIndexPath.row + 1 < [self.dataArray count]) {
                nextMessage = [self.dataArray objectAtIndex:(self.menuIndexPath.row + 1)];
            }
            if ((!nextMessage || [nextMessage isKindOfClass:[NSString class]]) && [prevMessage isKindOfClass:[NSString class]]) {
                [indexs addIndex:self.menuIndexPath.row - 1];
                [indexPaths addObject:[NSIndexPath indexPathForRow:(self.menuIndexPath.row - 1) inSection:0]];
            }
        }
        
        [self.dataArray removeObjectsAtIndexes:indexs];
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    }
    
    self.menuIndexPath = nil;
}

#pragma mark - notification
- (void)exitGroup
{
    [self.navigationController popToViewController:self animated:NO];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)insertCallMessage:(NSNotification *)notification
{
    id object = notification.object;
    if (object) {
        EMMessage *message = (EMMessage *)object;
        [self addMessageToDataSource:message progress:nil];
        [[EaseMob sharedInstance].chatManager insertMessageToDB:message append2Chat:YES];
    }
}

- (void)handleCallNotification:(NSNotification *)notification
{
    id object = notification.object;
    if ([object isKindOfClass:[NSDictionary class]]) {
        //开始call
        self.isViewDidAppear = NO;
    } else {
        //结束call
        self.isViewDidAppear = YES;
    }
}

#pragma mark - private

- (void)_showMenuViewController:(UIView *)showInView
                   andIndexPath:(NSIndexPath *)indexPath
                    messageType:(MessageBodyType)messageType
{
    if (self.menuController == nil) {
        self.menuController = [UIMenuController sharedMenuController];
    }
    
    if (_deleteMenuItem == nil) {
        _deleteMenuItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"delete", @"Delete") action:@selector(deleteMenuAction:)];
    }
    
    if (_copyMenuItem == nil) {
        _copyMenuItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"copy", @"Copy") action:@selector(copyMenuAction:)];
    }
    
    if (_transpondMenuItem == nil) {
        _transpondMenuItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"transpond", @"Transpond") action:@selector(transpondMenuAction:)];
    }
    
    NSMutableArray *menuArray = [NSMutableArray arrayWithObjects:_deleteMenuItem, nil];
    if ([self canRevokeMessage]) {
        if (_revokeMenuItem == nil) {
            _revokeMenuItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"revoke", @"Revoke") action:@selector(revokeMessageAction:)];
        }
        [menuArray addObject:_revokeMenuItem];
    }
    
    
    if (messageType == eMessageBodyType_Text) {
        [menuArray addObjectsFromArray:@[_copyMenuItem,_transpondMenuItem]];
    } else if (messageType == eMessageBodyType_Image){
        [menuArray addObjectsFromArray:@[_transpondMenuItem]];
    }
    
    [self.menuController setMenuItems:menuArray];
    [self.menuController setTargetRect:showInView.frame inView:showInView.superview];
    [self.menuController setMenuVisible:YES animated:YES];
}

#pragma mark - ==============================================================================
#pragma mark - 为了阅后即焚
- (void)textReadFire {
    _timer = [NSTimer scheduledTimerWithTimeInterval:6 target:self selector:@selector(timerAction) userInfo:nil repeats:NO];
    if (!_runLoop) {
        _runLoop = [[NSRunLoop alloc] init];
    }
    [_runLoop addTimer:_timer forMode:NSRunLoopCommonModes];
    [_runLoop run];
}

//标记正在阅读的消息
- (void)markReadingMessage:(id<IMessageModel>)messageModel
{
    _currentModel = messageModel;
    [[RemoveAfterReadManager sharedInstance] updateCurrentMsg:messageModel.message];
    [self.tableView reloadData];
}

//处理阅读即焚消息
- (void)readFireMessageDeal:(id<IMessageModel>)model
{
    id<IMessageModel> messageModel = model;
    if (!messageModel) {
        return;
    }
    //未连接，当前查看的消息存入NSUserDefaults，待连接后处理阅后即焚
    if (![[EaseMob sharedInstance].chatManager isConnected])
    {
        [self.tableView reloadData];
        return;
    }
    
    [[RemoveAfterReadManager sharedInstance] readFireMessageDeal:messageModel.message];
}

#pragma mark - timer

- (void)timerAction
{
    if (_textReadAlert.visible) {
        [_textReadAlert dismissWithClickedButtonIndex:0 animated:NO];
    }
    
    [self readFireMessageDeal:_currentModel];
    _currentModel = nil;
    if (_timer.isValid) {
        [_timer invalidate];
        _timer = nil;
        _runLoop = nil;
    }
}

#pragma mark - ==============================================================================
#pragma mark - 为了消息撤销
//验证是否符合2分钟内消息撤销
- (BOOL)canRevokeMessage {
    if (!self.menuIndexPath || self.menuIndexPath.row <= 0)
    {
        return NO;
    }
    id<IMessageModel> model = [self.dataArray objectAtIndex:self.menuIndexPath.row];
    return [MessageRevokeManager canRevokeMessage:model.message];
}

//发送方,处理点击撤销
- (void)revokeMessage
{
    if (![[EaseMob sharedInstance].chatManager isConnected])
    {
        //连接断开
        [self showHint:NSLocalizedString(@"reconnection.fail", @"reconnection failure, later will continue to reconnection")];
        return;
    }
    //执行删除，并穿透传消息
    id<IMessageModel> model = [self.dataArray objectAtIndex:self.menuIndexPath.row];
    [self.messsagesSource removeObject:model.message];
    NSInteger index = self.menuIndexPath.row;
    if (_isHasRevokePrompt)
    {
        //开启撤销提示
        id<IMessageModel> newModel = [self insertRevokePromptMessageToDB:model.message];
        if (newModel)
        {
            [self.dataArray replaceObjectAtIndex:index withObject:newModel];
        }
        else {
            [self.dataArray removeObject:model];
        }
    }
    else {
        NSIndexSet *indexSet = [[self removeTimePrompt:index] mutableCopy];
        [self.dataArray removeObjectsAtIndexes:indexSet];
        [self.messsagesSource removeObject:model.message];
    }
    [self.tableView reloadData];
    [self.conversation removeMessageWithId:model.messageId];
    //发送cmd消息
    [MessageRevokeManager sendRevokeMessageToChatter:model.message.conversationChatter
                                           messageId:model.message.messageId
                                    conversationType:self.conversation.conversationType];
    //重置
    self.menuIndexPath = nil;
}

/**
 * 判断会话是否可以删掉。原因：除了撤销提示消息，不含有其他类型消息
 *
 * @param conversation 待验证会话
 */
- (void)removeConversation
{
    if (!self.conversation.latestMessage)
    {
        [[EaseMob sharedInstance].chatManager removeConversationByChatter:self.conversation.chatter
                                                           deleteMessages:NO
                                                              append2Chat:YES];
        return;
    }
    //便利该会话所有消息，若都是消息撤销提示类的消息，则把此会话删除
    NSArray * messages = [self.conversation loadAllMessages];
    __block BOOL isNeedRemove = YES;
    [messages enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        EMMessage *m = (EMMessage *)obj;
        if (![m.ext objectForKey:KEMEFFECT_REVOKEM_EXT_PROMPT])
        {
            isNeedRemove = NO;
            *stop = YES;
        }
    }];
    //若返回值为YES，则按照需求，可以在会话列表删除此会话
    if (isNeedRemove)
    {
        [[EaseMob sharedInstance].chatManager removeConversationByChatter:self.conversation.chatter
                                                           deleteMessages:NO
                                                              append2Chat:YES];
    }
}

#pragma mark - 插入撤销提示处理
/**
 * 向DB插入 撤销提示的消息
 *
 * @param messageModel 被替换的消息
 * @return 带有撤销提示的文本消息
 */
- (id<IMessageModel>)insertRevokePromptMessageToDB:(EMMessage *)message
{
    NSString *prompt = [self prompt:message];
    id<IMessageModel> newModel = nil;
    EMMessage *newMessage = [self promptMessage:prompt oldMessage:message];
    if ([[EaseMob sharedInstance].chatManager insertMessageToDB:newMessage])
    {
        newModel = [[EaseMessageModel alloc] initWithMessage:newMessage];
    }
    return newModel;
}

//撤销提示语
- (NSString *)prompt:(EMMessage *)message
{
    NSString *prompt = @"撤消了一条消息";
    NSString *account = [[[EaseMob sharedInstance].chatManager loginInfo] objectForKey:kSDKUsername];
    if ([message.from isEqualToString:account])
    {
        prompt = [@"您" stringByAppendingString:prompt];
    }
    else if (message.messageType == eMessageTypeChat)
    {
        prompt = [message.from stringByAppendingString:prompt];
    }
    else {
        prompt = [message.groupSenderName stringByAppendingString:prompt];
    }
    return prompt;
}

- (EMMessage *)promptMessage:(NSString *)prompt
                  oldMessage:(EMMessage *)oldMessage
{
    EMChatText *textChat = [[EMChatText alloc] init];
    textChat.text = prompt;
    EMTextMessageBody *body = [[EMTextMessageBody alloc] initWithChatObject:textChat];
    EMMessage *message = [[EMMessage alloc] initWithReceiver:oldMessage.conversationChatter bodies:@[body]];
    message.timestamp = oldMessage.timestamp;
    message.messageType = oldMessage.messageType;
    message.requireEncryption = NO;
    message.isRead = YES;
    message.isReadAcked = YES;
    message.isDeliveredAcked = YES;
    message.deliveryState = eMessageDeliveryState_Delivered;
    message.ext = [NSDictionary dictionaryWithObjectsAndKeys:@YES, KEMEFFECT_REVOKEM_EXT_PROMPT, nil];
    return message;
}

#pragma mark - Notification
/**
 *  阅后即焚或消息回撤处理结果，刷新UI的通知
 */
- (void)updateMainUINotification:(NSNotification *)notification
{
    NSObject *obj = notification.object;
    if ([obj isKindOfClass:[NSArray class]])
    {
        NSArray *messages = [(NSArray *)obj mutableCopy];
        for (EMMessage *message in messages)
        {
            NSInteger index = [self removeMessageModel:message];
            if (index < 0) {
                //不存在此消息
                continue;
            }
            BOOL isHasRemove = NO;
            if (![RemoveAfterReadManager isReadAfterRemoveMessage:message] && _isHasRevokePrompt)
            {
                //此时为消息撤销模式，且显示消息撤销提示
                id<IMessageModel> newModel = [self insertRevokePromptMessageToDB:message];
                if (newModel)
                {
                    NSInteger msgIndex = [self.messsagesSource indexOfObject:message];
                    [self.messsagesSource replaceObjectAtIndex:msgIndex withObject:newModel.message];
                    [self.dataArray replaceObjectAtIndex:index withObject:newModel];
                    isHasRemove = YES;
                }
            }
            if (!isHasRemove)
            {
                //阅后即焚 或 消息撤销不显示撤销提示
                NSIndexSet *indexSet = [[self removeTimePrompt:index] mutableCopy];
                [self.dataArray removeObjectsAtIndexes:indexSet];
                [self.messsagesSource removeObject:message];
            }
        }
        [self.tableView reloadData];
    }
}

//获取数据源消息对象indexPath
- (NSInteger)removeMessageModel:(EMMessage *)message
{
    if (![self.conversation.chatter isEqualToString:message.conversationChatter])
    {
        return -1;
    }
    __block NSInteger index = -1;
    [self.dataArray enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj conformsToProtocol:@protocol(IMessageModel)])
        {
            id<IMessageModel> model = (id<IMessageModel>)obj;
            if ([model.messageId isEqualToString:message.messageId])
            {
                index = idx;
                *stop = YES;
            }
        }
    }];
    return index;
}

//数据源移除时间提示
- (NSIndexSet *)removeTimePrompt:(NSInteger)msgIndex
{
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSetWithIndex:msgIndex];
    if (msgIndex - 1 >= 0 && [[self.dataArray objectAtIndex:msgIndex - 1] isKindOfClass:[NSString class]])
    {
        BOOL isRemoveTimeString = YES;
        if (msgIndex + 1 < self.dataArray.count && ![[self.dataArray objectAtIndex:msgIndex + 1] isKindOfClass:[NSString class]])
        {
            isRemoveTimeString = NO;
        }
        if (isRemoveTimeString)
        {
            [indexSet addIndex:msgIndex - 1];
        }
    }
    return indexSet;
}

@end
