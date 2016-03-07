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
#import "UserProfileViewController.h"
#import "UserProfileManager.h"
#import "ContactListSelectViewController.h"
#import "ChatDemoHelper.h"

#import "ReadFireCell.h"
#import "OccupantListViewController.h"
/** @brief 用于消息撤销后，插入的提示消息ext的字段，对应值为BOOL类型*/
#define KEM_REVOKE_EXTKEY_REVOKEPROMPT       @"em_revoke_extKey_revokePrompt"

@interface ChatViewController ()<UIAlertViewDelegate, EaseMessageViewControllerDelegate, EaseMessageViewControllerDataSource,EMClientDelegate>
{
    UIMenuItem *_copyMenuItem;
    UIMenuItem *_deleteMenuItem;
    UIMenuItem *_transpondMenuItem;
    
    UIMenuItem *_revokeMenuItem;
    
    NSRunLoop *_runLoop;
    NSTimer *_timer;
    UIAlertView *_textReadAlert;
    BOOL _isHasRevokePrompt;
    NSString *_conversationTitle;
}

@property (nonatomic) BOOL isPlayingAudio;

@property (nonatomic) NSMutableDictionary *emotionDic;

@property (nonatomic, strong) id<IMessageModel> currentModel;

@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.showRefreshHeader = YES;
    self.delegate = self;
    self.dataSource = self;
    _isHasRevokePrompt = YES;
    
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
    
    [self configEaseMessageHelp];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    if (self.conversation.type == EMConversationTypeChatRoom)
    {
        //退出聊天室，删除会话
        NSString *chatter = [self.conversation.conversationId copy];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            EMError *error = nil;
            [[EMClient sharedClient].roomManager leaveChatroom:chatter error:&error];
            if (error !=nil) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Leave chatroom '%@' failed [%@]", chatter, error.errorDescription] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    [alertView show];
                });
            }
        });
    }
    
    [[EMClient sharedClient] removeDelegate:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.conversation.type == EMConversationTypeGroupChat) {
        if ([[self.conversation.ext objectForKey:@"subject"] length])
        {
            self.title = [self.conversation.ext objectForKey:@"subject"];
        }
    }
    _conversationTitle = self.title;
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
    if (self.conversation.type == EMConversationTypeChat) {
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
        [self.conversation deleteAllMessages];
        [self.dataArray removeAllObjects];
        [self.messsagesSource removeAllObjects];
        
        [self.tableView reloadData];
    }
}

#pragma mark - EaseMessageViewControllerDelegate

- (BOOL)messageViewController:(EaseMessageViewController *)viewController
   canLongPressRowAtIndexPath:(NSIndexPath *)indexPath
{
    id object = [self.dataArray objectAtIndex:indexPath.row];
    if ([object conformsToProtocol:@protocol(IMessageModel)])
    {
        id<IMessageModel> model = (id<IMessageModel>)object;
        //如果是文本类型的消息撤销的提示信息，使用EaseMessageTimeCell，不允许长按事件
        if ([model.message.ext[KEM_REVOKE_EXTKEY_REVOKEPROMPT] boolValue] && model.bodyType == EMMessageBodyTypeText)
        {
            return NO;
        }
    }
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

- (BOOL)messageViewController:(EaseMessageViewController *)viewController didSelectMessageModel:(id<IMessageModel>)messageModel
{
    if (!messageModel.isSender && [EaseMessageHelper isRemoveAfterReadMessage:messageModel.message])
    {
        [self markReadingMessage:messageModel];
        switch (messageModel.bodyType) {
            case EMMessageBodyTypeText:
            {
                [self textReadFire];
                _textReadAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"message.burn.tips", @"Reading 6 seconds, the message automatically burned") message:messageModel.text delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
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
    UserProfileViewController *userprofile = [[UserProfileViewController alloc] initWithUsername:messageModel.message.from];
    [self.navigationController pushViewController:userprofile animated:YES];
}

- (void)messageViewController:(EaseMessageViewController *)viewController
        handleEaseMessageHelp:(EMHelperType)easeMessageHelpType index:(NSInteger)index
{
    switch (easeMessageHelpType)
    {
        case emHelperTypeGroupAt:
        {
            OccupantListViewController *occupantListVC = [[OccupantListViewController alloc] initWithGroupId:self.conversation.conversationId];
            __weak EaseTextView *weakTextView = viewController.chatToolbar.inputTextView;
            __weak typeof(self) weakSelf = self;
            occupantListVC.SelectedOccupant = ^(NSString *occupantName){
                NSMutableString *content = [[NSMutableString alloc] initWithString:weakTextView.text];
                if (!occupantName || occupantName.length == 0 || content.length < index)
                {//此时选取@对象取消 或 选取错误, 重置emHelpType为默认状态
                    [weakSelf resetEaseMessageHelpType];
                    [EaseMessageHelper markSelectOccupantId:nil];
                }
                else {
                    NSString *insertString = [occupantName stringByAppendingString:@" "];
                    [content insertString:insertString atIndex:index];
                    weakTextView.text = content;
                    [weakSelf changeEaseMessageHelpType:emHelperTypeGroupAt];
                    [EaseMessageHelper markSelectOccupantId:occupantName];
                }
            };
            
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:occupantListVC];
            [self presentViewController:nav animated:YES completion:nil];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - EaseMessageViewControllerDataSource

- (CGFloat)messageViewController:(EaseMessageViewController *)viewController heightForMessageModel:(id<IMessageModel>)messageModel withCellWidth:(CGFloat)cellWidth
{
    if ([messageModel.message.ext[KEM_REVOKE_EXTKEY_REVOKEPROMPT] boolValue])
    {
        //消息撤销提示
        return self.timeCellHeight;
    }
    return 0.f;
}

- (UITableViewCell *)messageViewController:(UITableView *)tableView cellForMessageModel:(id<IMessageModel>)messageModel
{
    if ([EaseMessageHelper isRemoveAfterReadMessage:messageModel.message])
    {
        NSString *CellIdentifier = [ReadFireCell cellIdentifierWithModel:messageModel];
        ReadFireCell *cell = (ReadFireCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[ReadFireCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier model:messageModel];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.model = messageModel;
        BOOL isReading = _currentModel && [_currentModel.messageId isEqualToString:messageModel.messageId];
        [cell isReadMessage:isReading];
        
        return cell;
    }
    else if ([messageModel.message.ext[KEM_REVOKE_EXTKEY_REVOKEPROMPT] boolValue] && messageModel.bodyType == EMMessageBodyTypeText)
    {//消息撤销提示
        NSString *TimeCellIdentifier = [EaseMessageTimeCell cellIdentifier];
        EaseMessageTimeCell *timeCell = (EaseMessageTimeCell *)[tableView dequeueReusableCellWithIdentifier:TimeCellIdentifier];
        
        if (timeCell == nil) {
            timeCell = [[EaseMessageTimeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TimeCellIdentifier];
            timeCell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        EMTextMessageBody *body = (EMTextMessageBody *)messageModel.message.body;
        timeCell.title = body.text;
        return timeCell;
    }
    return nil;
}

- (id<IMessageModel>)messageViewController:(EaseMessageViewController *)viewController
                           modelForMessage:(EMMessage *)message
{
    id<IMessageModel> model = nil;
    model = [[EaseMessageModel alloc] initWithMessage:message];
    model.avatarImage = [UIImage imageNamed:@"EaseUIResource.bundle/user"];
    UserProfileEntity *profileEntity = [[UserProfileManager sharedInstance] getUserProfileByUsername:model.nickname];
    if (profileEntity) {
        model.avatarURLPath = profileEntity.imageUrl;
        model.nickname = profileEntity.nickname;
    }
    model.failImageName = @"imageDownloadFail";
    return model;
}

- (NSArray*)emotionFormessageViewController:(EaseMessageViewController *)viewController
{
    NSMutableArray *emotions = [NSMutableArray array];
    for (NSString *name in [EaseEmoji allEmoji]) {
        EaseEmotion *emotion = [[EaseEmotion alloc] initWithName:@"" emotionId:name emotionThumbnail:name emotionOriginal:name emotionOriginalURL:@"" emotionType:EMEmotionDefault];
        [emotions addObject:emotion];
    }
    EaseEmotion *temp = [emotions objectAtIndex:0];
    EaseEmotionManager *managerDefault = [[EaseEmotionManager alloc] initWithType:EMEmotionDefault emotionRow:3 emotionCol:7 emotions:emotions tagImage:[UIImage imageNamed:temp.emotionId]];
    
    NSMutableArray *emotionGifs = [NSMutableArray array];
    _emotionDic = [NSMutableDictionary dictionary];
    NSArray *names = @[@"icon_002",@"icon_007",@"icon_010",@"icon_012",@"icon_013",@"icon_018",@"icon_019",@"icon_020",@"icon_021",@"icon_022",@"icon_024",@"icon_027",@"icon_029",@"icon_030",@"icon_035",@"icon_040"];
    int index = 0;
    for (NSString *name in names) {
        index++;
        EaseEmotion *emotion = [[EaseEmotion alloc] initWithName:[NSString stringWithFormat:@"[示例%d]",index] emotionId:[NSString stringWithFormat:@"em%d",(1000 + index)] emotionThumbnail:[NSString stringWithFormat:@"%@_cover",name] emotionOriginal:[NSString stringWithFormat:@"%@",name] emotionOriginalURL:@"" emotionType:EMEmotionGif];
        [emotionGifs addObject:emotion];
        [_emotionDic setObject:emotion forKey:[NSString stringWithFormat:@"em%d",(1000 + index)]];
    }
    EaseEmotionManager *managerGif= [[EaseEmotionManager alloc] initWithType:EMEmotionGif emotionRow:2 emotionCol:4 emotions:emotionGifs tagImage:[UIImage imageNamed:@"icon_002_cover"]];
    
    return @[managerDefault,managerGif];
}

- (BOOL)isEmotionMessageFormessageViewController:(EaseMessageViewController *)viewController
                                    messageModel:(id<IMessageModel>)messageModel
{
    BOOL flag = NO;
    if ([messageModel.message.ext objectForKey:MESSAGE_ATTR_IS_BIG_EXPRESSION]) {
        return YES;
    }
    return flag;
}

- (EaseEmotion*)emotionURLFormessageViewController:(EaseMessageViewController *)viewController
                                      messageModel:(id<IMessageModel>)messageModel
{
    NSString *emotionId = [messageModel.message.ext objectForKey:MESSAGE_ATTR_EXPRESSION_ID];
    EaseEmotion *emotion = [_emotionDic objectForKey:emotionId];
    if (emotion == nil) {
        emotion = [[EaseEmotion alloc] initWithName:@"" emotionId:emotionId emotionThumbnail:@"" emotionOriginal:@"" emotionOriginalURL:@"" emotionType:EMEmotionGif];
    }
    return emotion;
}

- (NSDictionary*)emotionExtFormessageViewController:(EaseMessageViewController *)viewController
                                        easeEmotion:(EaseEmotion*)easeEmotion
{
    return @{MESSAGE_ATTR_EXPRESSION_ID:easeEmotion.emotionId,MESSAGE_ATTR_IS_BIG_EXPRESSION:@(YES)};
}

#pragma mark - EaseMob

#pragma mark - EMClientDelegate

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
    [[EMClient sharedClient].chatManager removeDelegate:self];
    [[EMClient sharedClient].roomManager removeDelegate:self];
    [[ChatDemoHelper shareHelper] setChatVC:nil];
    
    if (self.deleteConversationIfNull) {
        //判断当前会话是否为空，若符合则删除该会话
        EMMessage *message = [self.conversation latestMessage];
        if (message == nil) {
            [[EMClient sharedClient].chatManager deleteConversation:self.conversation.conversationId deleteMessages:NO];
        }
    }
    
    [self.navigationController popViewControllerAnimated:YES];
    
    [self cancellationEaseMessageHelp];
}

- (void)showGroupDetailAction
{
    [self.view endEditing:YES];
    if (self.conversation.type == EMConversationTypeGroupChat) {
        ChatGroupDetailViewController *detailController = [[ChatGroupDetailViewController alloc] initWithGroupId:self.conversation.conversationId];
        [self.navigationController pushViewController:detailController animated:YES];
    }
    else if (self.conversation.type == EMConversationTypeChatRoom)
    {
        ChatroomDetailViewController *detailController = [[ChatroomDetailViewController alloc] initWithChatroomId:self.conversation.conversationId];
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
        BOOL isDelete = [groupId isEqualToString:self.conversation.conversationId];
        if (self.conversation.type != EMConversationTypeChat && isDelete) {
            self.messageTimeIntervalTag = -1;
            [self.conversation deleteAllMessages];
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
        
        [self.conversation deleteMessageWithId:model.message.messageId];
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
        
        if ([self.dataArray count] == 0) {
            self.messageTimeIntervalTag = -1;
        }
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
        [[EMClient sharedClient].chatManager importMessages:@[message]];
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
                    messageType:(EMMessageBodyType)messageType
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
    
    if (messageType == EMMessageBodyTypeText) {
        [menuArray addObjectsFromArray:@[_copyMenuItem,_transpondMenuItem]];
    } else if (messageType == EMMessageBodyTypeImage){
        [menuArray addObjectsFromArray:@[_transpondMenuItem]];
    }
    [self.menuController setMenuItems:menuArray];
    [self.menuController setTargetRect:showInView.frame inView:showInView.superview];
    [self.menuController setMenuVisible:YES animated:YES];
}


#pragma mark - EaseChatBarMoreViewDelegate
- (void)moreView:(EaseChatBarMoreView *)moreView removeAfterRead:(BOOL)isRemove
{
    if (isRemove)
    {
        [self changeEaseMessageHelpType:emHelperTypeRemoveAfterRead];
    }
    else {
        [self resetEaseMessageHelpType];
    }
    
    [self.chatToolbar endEditing:YES];
}

#pragma mark - EMReadManagerProtocol

//图片、音频、视频
- (void)readMessageFinished:(id<IMessageModel>)model
{
    [self handleRemoveAfterReadMessage:model];
}

#pragma mark - EMLocationViewDelegate
//地理位置
- (void)locationMessageReadAck:(id<IMessageModel>)messageModel
{
    [self handleRemoveAfterReadMessage:messageModel];
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
    [[EaseMessageHelper sharedInstance] updateCurrentMsg:messageModel.message];
    [self.tableView reloadData];
}

//处理阅读即焚消息
- (void)handleRemoveAfterReadMessage:(id<IMessageModel>)model
{
    id<IMessageModel> messageModel = model;
    if (!messageModel) {
        return;
    }
    //未连接，当前查看的消息存入NSUserDefaults，待连接后处理阅后即焚
    if (![[EMClient sharedClient] isConnected])
    {
        [self.tableView reloadData];
        [[EaseMessageHelper sharedInstance] updateCurrentMsg:model.message];
        [self showHint:NSLocalizedString(@"reconnection.fail", @"reconnection failure, later will continue to reconnection")];
        return;
    }
    
    [[EaseMessageHelper sharedInstance] handleRemoveAfterReadMessage:messageModel.message];
}

#pragma mark - timer

- (void)timerAction
{
    if (_textReadAlert.visible) {
        [_textReadAlert dismissWithClickedButtonIndex:0 animated:NO];
    }
    
    [self handleRemoveAfterReadMessage:_currentModel];
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
    return [EaseMessageHelper canRevokeMessage:model.message];
}

//发送方,处理点击撤销
- (void)revokeMessage
{
    if (![[EMClient sharedClient] isConnected])
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
    [self.conversation deleteMessageWithId:model.messageId];
    //发送cmd消息
    [EaseMessageHelper sendRevokeCMDMessage:model.message];
    //重置
    self.menuIndexPath = nil;
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
    if ([[EMClient sharedClient].chatManager importMessages:@[newMessage]])
    {
        newModel = [[EaseMessageModel alloc] initWithMessage:newMessage];
    }
    return newModel;
}

//撤销提示语
- (NSString *)prompt:(EMMessage *)message
{
    NSString *prompt = @"撤消了一条消息";
    NSString *account = [EMClient sharedClient].currentUsername;
    if ([message.from isEqualToString:account])
    {
        prompt = [@"您" stringByAppendingString:prompt];
    }
    else if (message.chatType == EMChatTypeChat)
    {
        prompt = [message.from stringByAppendingString:prompt];
    }
    else {
        prompt = [message.from stringByAppendingString:prompt];
    }
    return prompt;
}

- (EMMessage *)promptMessage:(NSString *)prompt
                  oldMessage:(EMMessage *)oldMessage
{
    EMTextMessageBody *body = [[EMTextMessageBody alloc] initWithText:prompt];
    NSString *currentUsername = [EMClient sharedClient].currentUsername;
    EMMessage *message = [[EMMessage alloc] initWithConversationID:oldMessage.conversationId from:currentUsername to:oldMessage.conversationId body:body ext:nil];
    message.timestamp = oldMessage.timestamp;
    message.chatType = oldMessage.chatType;
    message.isRead = YES;
    message.isReadAcked = YES;
    message.isDeliverAcked = YES;
    message.ext = [NSDictionary dictionaryWithObjectsAndKeys:@YES, KEM_REVOKE_EXTKEY_REVOKEPROMPT, nil];
    return message;
}

//删除指定消息
- (void)removeAppointMessage:(EMMessage *)message index:(NSInteger)index
{
    NSIndexSet *indexSet = [[self removeTimePrompt:index] mutableCopy];
    [self.dataArray removeObjectsAtIndexes:indexSet];
    [self.messsagesSource removeObject:message];
}

//获取消息在messageSource中的下标
- (NSInteger)fetchMessageIndex:(EMMessage *)message
{
    __block NSInteger index = -1;
    [self.messsagesSource enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[EMMessage class]]) {
            EMMessage *msg = (EMMessage *)obj;
            if ([msg.messageId isEqualToString:message.messageId])
            {
                index = idx;
                *stop = YES;
            }
        }
    }];
    return index;
}

//获取待删除消息对象indexPath
- (NSInteger)fetchRemoveMessageModelIndex:(EMMessage *)message
{
    if (![self.conversation.conversationId isEqualToString:message.conversationId])
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


#pragma mark - 配置EaseMessageHelp

- (void)configEaseMessageHelp
{
    if (self.conversation.type == EMConversationTypeChat)
    {
        [EaseMessageHelper openInputState];
    }
}

- (void)cancellationEaseMessageHelp
{
    [EaseMessageHelper closeInputState];
    if ([EaseMessageHelper isConversationHasUnreadGroupAtMessage:self.conversation])
    {
        [EaseMessageHelper updateConversationToDB:self.conversation message:nil isUnread:NO];
        [[ChatDemoHelper shareHelper].conversationListVC refreshDataSource];
    }
}


#pragma mark - EaseMessageHelperProtocal

- (void)emHelper:(EaseMessageHelper *)emHelper handleRevokeMessage:(NSArray *)needRevokeMessags
{
    for (EMMessage *message in needRevokeMessags)
    {
        NSInteger index = [self fetchRemoveMessageModelIndex:message];
        if (index >= 0)
        {
            if (_isHasRevokePrompt)
            {
                //此时为消息撤销模式，且显示消息撤销提示
                id<IMessageModel> newModel = [self insertRevokePromptMessageToDB:message];
                if (newModel)
                {
                    NSInteger msgIndex = [self fetchMessageIndex:message];
                    if (msgIndex >= 0) {
                        [self.messsagesSource replaceObjectAtIndex:msgIndex withObject:newModel.message];
                        [self.dataArray replaceObjectAtIndex:index withObject:newModel];
                    }
                }
            }
            else {
                //消息撤销不显示撤销提示
                [self removeAppointMessage:message index:index];
            }
        }
    }
    [self.tableView reloadData];
}

- (void)emHelper:(EaseMessageHelper *)emHelper handleRemoveAfterReadMessage:(NSArray *)removeMessages
{
    for (EMMessage *message in removeMessages) {
        NSInteger index = [self fetchRemoveMessageModelIndex:message];
        if (index >= 0)
        {
            //阅后即焚
            [self removeAppointMessage:message index:index];
        }
    }
    [self.tableView reloadData];
}

- (void)emHelper:(EaseMessageHelper *)emHelper handleInputStateMessage:(NSString *)conversationTitle
{
    if (conversationTitle)
    {
        self.title = conversationTitle;
    }
    else {
        self.title = _conversationTitle;
    }
}

@end
