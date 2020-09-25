//
//  EMChatViewController.m
//  EaseIM
//
//  Created by XieYajie on 2019/1/18.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import <AVKit/AVKit.h>
#import <Photos/Photos.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "EMChatViewController.h"

#import "EMImageBrowser.h"
#import "EMDateHelper.h"
#import "EMAudioPlayerHelper.h"
#import "EMConversationHelper.h"
#import "EMMessageModel.h"

#import "EMMessageCell.h"
#import "EMMessageTimeCell.h"
#import "EMMsgRecordCell.h"

#import "EMMsgTouchIncident.h"
#import "EMChatViewController+EMMsgLongPressIncident.h"
#import "EMChatViewController+ChatToolBarIncident.h"

@interface EMChatViewController ()<UIScrollViewDelegate, EMMultiDevicesDelegate, EMChatManagerDelegate, EMChatBarDelegate, EMMessageCellDelegate, EMChatBarEmoticonViewDelegate, EMChatBarRecordAudioViewDelegate,EMMoreFunctionViewDelegate>

@end

@implementation EMChatViewController

- (instancetype)initWithConversationId:(NSString *)aId
                                  type:(EMConversationType)aType
                      createIfNotExist:(BOOL)aIsCreate
{
    self = [super init];
    if (self) {
        EMConversation *conversation = [[EMClient sharedClient].chatManager getConversation:aId type:aType createIfNotExist:aIsCreate];
        [self setDefaultProperty:[[EMConversationModel alloc] initWithEMModel:conversation]];
    }
    
    return self;
}

- (instancetype)initWithCoversationModel:(EMConversationModel *)aConversationModel
{
    self = [super init];
    if (self) {
        [self setDefaultProperty:aConversationModel];
    }
    
    return self;
}

- (void)setDefaultProperty:(EMConversationModel *)aConversationModel
{
    self.conversationModel = aConversationModel;
    self.msgQueue = dispatch_queue_create("emmessage.com", NULL);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.msgTimelTag = -1;
    
    [self _setupChatSubviews];
    
    [[EMClient sharedClient] addMultiDevicesDelegate:self delegateQueue:nil];
    [[EMClient sharedClient].chatManager addDelegate:self delegateQueue:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleWillPushCallController:) name:CALL_PUSH_VIEWCONTROLLER object:nil];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapTableViewAction:)];
    [self.tableView addGestureRecognizer:tap];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self tableViewDidTriggerHeaderRefresh];
    [EMConversationHelper markAllAsRead:self.conversationModel];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.backgroundColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    self.navigationController.navigationBarHidden = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    NSMutableDictionary *ext = [[NSMutableDictionary alloc]initWithDictionary:self.conversationModel.emModel.ext];
    //草稿
    if ([self.conversationModel.emModel.ext objectForKey:kConversation_Draft] && ![[self.conversationModel.emModel.ext objectForKey:kConversation_Draft] isEqualToString:@""]) {
        self.chatBar.textView.text = [self.conversationModel.emModel.ext objectForKey:kConversation_Draft];
        [self.chatBar textChangedExt];
        [ext setObject:@"" forKey:kConversation_Draft];
        [self.conversationModel.emModel setExt:ext];
    }
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)dealloc
{
    [[EMClient sharedClient] removeMultiDevicesDelegate:self];
    [[EMClient sharedClient].chatManager removeDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Subviews

- (void)_setupChatSubviews
{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"backleft"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(backAction)];
    [self _setupNavigationBarTitle];
    self.view.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0];
    self.showRefreshHeader = YES;
    
    self.tableView.backgroundColor = kColor_LightGray;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 130;
    
    self.chatBar = [[EMChatBar alloc] init];
    self.chatBar.delegate = self;
    [self.view addSubview:self.chatBar];
    [self.chatBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    self.searchBar.hidden = YES;
    
    [self.chatBar.sendBtn addTarget:self action:@selector(_sendText) forControlEvents:UIControlEventTouchUpInside];
    //会话工具栏
    [self _setupChatBarMoreViews];
    
    [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.chatBar.mas_top);
    }];
}

- (void)_setupNavigationBarTitle
{
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width * 06, 40)];
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.font = [UIFont systemFontOfSize:18];
    self.titleLabel.textColor = [UIColor blackColor];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.text = self.conversationModel.name;
    [titleView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleView);
        make.left.equalTo(titleView).offset(5);
        make.right.equalTo(titleView).offset(-5);
    }];
    
    self.titleDetailLabel = [[UILabel alloc] init];
    self.titleDetailLabel.font = [UIFont systemFontOfSize:15];
    self.titleDetailLabel.textColor = [UIColor grayColor];
    self.titleDetailLabel.textAlignment = NSTextAlignmentCenter;
    [titleView addSubview:self.titleDetailLabel];
    [self.titleDetailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom);
        make.left.equalTo(self.titleLabel);
        make.right.equalTo(self.titleLabel);
        make.bottom.equalTo(titleView);
    }];
    
    self.navigationItem.titleView = titleView;
}

- (void)_setupChatBarMoreViews
{
    //语音
    NSString *path = [self getAudioOrVideoPath];
    EMChatBarRecordAudioView *recordView = [[EMChatBarRecordAudioView alloc] initWithRecordPath:path];
    recordView.delegate = self;
    self.chatBar.recordAudioView = recordView;
    //表情
    EMChatBarEmoticonView *moreEmoticonView = [[EMChatBarEmoticonView alloc] init];
    moreEmoticonView.delegate = self;
    self.chatBar.moreEmoticonView = moreEmoticonView;
    
    //更多
    EMMoreFunctionView *moreFunction = [[EMMoreFunctionView alloc]initWithConversation:self.conversationModel.emModel];
    moreFunction.delegate = self;
    self.chatBar.moreFunctionView = moreFunction;
}

- (NSString *)getAudioOrVideoPath
{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    path = [path stringByAppendingPathComponent:@"EMDemoRecord"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return path;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = [self.dataArray count];
    if (tableView == self.searchResultTableView)
        count = [self.searchResults count];
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id obj;
    if (tableView == self.tableView)
        obj = [self.dataArray objectAtIndex:indexPath.row];
    if (tableView == self.searchResultTableView)
        obj = [self.searchResults objectAtIndex:indexPath.row];
    NSString *cellString = nil;
    if ([obj isKindOfClass:[NSString class]])
        cellString = (NSString *)obj;
    if ([obj isKindOfClass:[EMMessageModel class]]) {
        EMMessageModel *model = (EMMessageModel *)obj;
        if (model.type == EMMessageTypeExtRecall)
            cellString = @"您撤回一条消息";
        if (model.type == EMMessageTypeExtNewFriend || model.type == EMMessageTypeExtAddGroup)
            cellString = ((EMTextMessageBody *)(model.emModel.body)).text;
    }
    
    if ([cellString length] > 0) {
        EMMessageTimeCell *cell = (EMMessageTimeCell *)[tableView dequeueReusableCellWithIdentifier:@"EMMessageTimeCell"];
        // Configure the cell...
        if (cell == nil)
            cell = [[EMMessageTimeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"EMMessageTimeCell"];
        cell.timeLabel.text = cellString;
        return cell;
    }
    
    UITableViewCell *cell;
    EMMessageModel *model = (EMMessageModel *)obj;
    NSString *identifier;
    identifier = [EMMessageCell cellIdentifierWithDirection:model.direction type:model.type];
    EMMessageCell *msgCell = (EMMessageCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    // Configure the cell...
    if (msgCell == nil) {
        msgCell = [[EMMessageCell alloc] initWithDirection:model.direction type:model.type];
        msgCell.delegate = self;
    }
    msgCell.model = model;
    cell = msgCell;
    return cell;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
    [self.chatBar clearMoreViewAndSelectedButton];
}

#pragma mark - EMChatBarDelegate

- (void)chatBarDidShowMoreViewAction
{
    [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.chatBar.mas_top);
    }];
    
    [self performSelector:@selector(scrollToBottomRow) withObject:nil afterDelay:0.1];
}

#pragma mark - EMMoreFunctionViewDelegate

- (void)chatBarMoreFunctionAction:(NSInteger)componentType
{
    [self chatToolBarComponentAction:componentType];
}

#pragma mark - EMChatBarRecordAudioViewDelegate

- (void)chatBarRecordAudioViewStopRecord:(NSString *)aPath
                              timeLength:(NSInteger)aTimeLength
{
    EMVoiceMessageBody *body = [[EMVoiceMessageBody alloc] initWithLocalPath:aPath displayName:@"audio"];
    body.duration = (int)aTimeLength;
    if(body.duration < 1){
        [self showHint:@"说话时间太短"];
        return;
    }
    [self sendMessageWithBody:body ext:nil isUpload:YES];
}

#pragma mark - EMChatBarEmoticonViewDelegate

- (void)didSelectedTextDetele
{
    [self.chatBar deleteTailText];
}

- (void)didSelectedEmoticonModel:(EMEmoticonModel *)aModel
{
    if (aModel.type == EMEmotionTypeEmoji)
        [self.chatBar inputViewAppendText:aModel.name];
    
    if (aModel.type == EMEmotionTypeGif) {
        NSDictionary *ext = @{MSG_EXT_GIF:@(YES), MSG_EXT_GIF_ID:aModel.eId};
        [self sendTextAction:aModel.name ext:ext];
    }
}

#pragma mark - EMMessageCellDelegate

- (void)messageCellDidSelected:(EMMessageCell *)aCell
{
    //消息事件策略分类
    EMMessageEventStrategy *eventStrategy = [EMMessageEventStrategyFactory getStratrgyImplWithMsgCell:aCell];
    eventStrategy.chatController = self;
    [eventStrategy messageCellEventOperation:aCell];
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)messageCellDidLongPress:(EMMessageCell *)aCell
{
    self.menuIndexPath = [self.tableView indexPathForCell:aCell];
    [UIMenuController sharedMenuController].menuItems = [self showMenuViewController:aCell model:aCell.model];
    [UIMenuController sharedMenuController].menuVisible = YES;
    [[UIMenuController sharedMenuController] setTargetRect:aCell.bubbleView.frame inView:aCell];
}

- (void)messageCellDidResend:(EMMessageModel *)aModel
{
    if (aModel.emModel.status != EMMessageStatusFailed && aModel.emModel.status != EMMessageStatusPending) {
        return;
    }
    
    __weak typeof(self) weakself = self;
    [[[EMClient sharedClient] chatManager] resendMessage:aModel.emModel progress:nil completion:^(EMMessage *message, EMError *error) {
        [weakself.tableView reloadData];
    }];
    
    [self.tableView reloadData];
}

#pragma mark -- UIDocumentInteractionControllerDelegate
- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller
{
    return self;
}
- (UIView*)documentInteractionControllerViewForPreview:(UIDocumentInteractionController*)controller
{
    return self.view;
}
- (CGRect)documentInteractionControllerRectForPreview:(UIDocumentInteractionController*)controller
{
    return self.view.frame;
}

#pragma mark - EMMultiDevicesDelegate

- (void)multiDevicesGroupEventDidReceive:(EMMultiDevicesEvent)aEvent
                                 groupId:(NSString *)aGroupId
                                     ext:(id)aExt
{
    if (aEvent == EMMultiDevicesEventGroupDestroy || aEvent == EMMultiDevicesEventGroupLeave) {
        if ([self.conversationModel.emModel.conversationId isEqualToString:aGroupId]) {
            //[self.navigationController popToViewController:self animated:YES];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

#pragma mark - EMChatManagerDelegate

- (void)messagesDidReceive:(NSArray *)aMessages
{
    __weak typeof(self) weakself = self;
    dispatch_async(self.msgQueue, ^{
        NSString *conId = weakself.conversationModel.emModel.conversationId;
        NSMutableArray *msgArray = [[NSMutableArray alloc] init];
        for (int i = 0; i < [aMessages count]; i++) {
            EMMessage *msg = aMessages[i];
            if (![msg.conversationId isEqualToString:conId])
                continue;
            if (msg.body.type == EMMessageBodyTypeText && [((EMTextMessageBody *)msg.body).text isEqualToString:EMCOMMUNICATE_CALLINVITE]) {
                //通话邀请
                [weakself.conversationModel.emModel deleteMessageWithId:msg.messageId error:nil];
                continue;
            }
            [weakself returnReadReceipt:msg];
            [weakself.conversationModel.emModel markMessageAsReadWithId:msg.messageId error:nil];
            [msgArray addObject:msg];
        }
        
        NSArray *formated = [weakself formatMessages:msgArray];
        [weakself.dataArray addObjectsFromArray:formated];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself refreshTableView];
        });
    });
}

- (void)messagesDidRecall:(NSArray *)aMessages {
    __block NSMutableArray *sameObject = [NSMutableArray array];
    [aMessages enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        EMMessage *msg = (EMMessage *)obj;
        [self.dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[EMMessageModel class]]) {
                EMMessageModel *model = (EMMessageModel *)obj;
                if ([model.emModel.messageId isEqualToString:msg.messageId]) {
                    // 如果上一行是时间，且下一行也是时间
                    if (idx - 1 >= 0) {
                        id nextMessage = nil;
                        id prevMessage = [self.dataArray objectAtIndex:(idx - 1)];
                        if (idx + 1 < [self.dataArray count]) {
                            nextMessage = [self.dataArray objectAtIndex:(idx + 1)];
                        }
                        if ((!nextMessage
                             || [nextMessage isKindOfClass:[NSString class]])
                            && [prevMessage isKindOfClass:[NSString class]]) {
                            [sameObject addObject:prevMessage];
                        }
                    }
                    [sameObject addObject:model];
                    *stop = YES;
                }
            }
        }];
    }];
    
    if (sameObject.count > 0) {
        for (id obj in sameObject) {
            [self.dataArray removeObject:obj];
        }
        
        [self.tableView reloadData];
    }
}

//为了从home会话列表切进来触发 群组阅读回执 或 消息已读回执
- (void)sendDidReadReceipt
{
    __weak typeof(self) weakself = self;
    NSString *conId = weakself.conversationModel.emModel.conversationId;
    void (^block)(NSArray *aMessages, EMError *aError) = ^(NSArray *aMessages, EMError *aError) {
        if (!aError && [aMessages count]) {
            for (int i = 0; i < [aMessages count]; i++) {
                EMMessage *msg = aMessages[i];
                if (![msg.conversationId isEqualToString:conId]) {
                    continue;
                }
                [weakself returnReadReceipt:msg];
                [weakself.conversationModel.emModel markMessageAsReadWithId:msg.messageId error:nil];
            }
        }
    };
    [self.conversationModel.emModel loadMessagesStartFromId:self.moreMsgId count:self.conversationModel.emModel.unreadMessagesCount searchDirection:EMMessageSearchDirectionUp completion:block];
}

- (void)messageStatusDidChange:(EMMessage *)aMessage
                         error:(EMError *)aError
{
    __weak typeof(self) weakself = self;
    dispatch_async(self.msgQueue, ^{
        NSString *conId = weakself.conversationModel.emModel.conversationId;
        if (![conId isEqualToString:aMessage.conversationId]){
            return ;
        }
        
        __block NSUInteger index = NSNotFound;
        __block EMMessageModel *reloadModel = nil;
        [self.dataArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isKindOfClass:[EMMessageModel class]]) {
                EMMessageModel *model = (EMMessageModel *)obj;
                if ([model.emModel.messageId isEqualToString:aMessage.messageId]) {
                    reloadModel = model;
                    index = idx;
                    *stop = YES;
                }
            }
        }];
        
        if (index != NSNotFound) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakself.dataArray replaceObjectAtIndex:index withObject:reloadModel];
                [weakself.tableView beginUpdates];
                [weakself.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                [weakself.tableView endUpdates];
            });
        }
        
    });
}

#pragma mark - KeyBoard

- (void)keyBoardWillShow:(NSNotification *)note
{
    // 获取用户信息
    NSDictionary *userInfo = [NSDictionary dictionaryWithDictionary:note.userInfo];
    // 获取键盘高度
    CGRect keyBoardBounds  = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyBoardHeight = keyBoardBounds.size.height;
    // 获取键盘动画时间
    CGFloat animationTime  = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    // 定义好动作
    void (^animation)(void) = ^void(void) {
        [self.chatBar mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.view).offset(-keyBoardHeight);
        }];
    };
    
    if (animationTime > 0) {
        [UIView animateWithDuration:animationTime animations:animation completion:^(BOOL finished) {
            [self scrollToBottomRow];
        }];
    } else {
        animation();
    }
}

- (void)keyBoardWillHide:(NSNotification *)note
{
    // 获取用户信息
    NSDictionary *userInfo = [NSDictionary dictionaryWithDictionary:note.userInfo];
    // 获取键盘动画时间
    CGFloat animationTime  = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    // 定义好动作
    void (^animation)(void) = ^void(void) {
        [self.chatBar mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.view);
        }];
    };
    
    if (animationTime > 0) {
        [UIView animateWithDuration:animationTime animations:animation];
    } else {
        animation();
    }
}

#pragma mark - NSNotification

- (void)handleWillPushCallController:(NSNotification *)aNotif
{
    /*
    if (aNotif) {
        __weak typeof(self) weakself = self;
        NSString *communicatePushType = [NSString stringWithFormat:@"%@ 邀请你通话",[EMClient sharedClient].currentUsername];
        if ([[aNotif.object objectForKey:EMCOMMUNICATE_TYPE] isEqualToString:EMCOMMUNICATE_TYPE_VOICE])
            communicatePushType = [NSString stringWithFormat:@"%@ 邀请你视频通话",[EMClient sharedClient].currentUsername];
        if ([[aNotif.object objectForKey:EMCOMMUNICATE_TYPE] isEqualToString:EMCOMMUNICATE_TYPE_VIDEO])
            communicatePushType = [NSString stringWithFormat:@"%@ 邀请你语音通话",[EMClient sharedClient].currentUsername];
        NSString *from = [[EMClient sharedClient] currentUsername];
        NSString *to = self.conversationModel.emModel.conversationId;
        EMMessage *message = [[EMMessage alloc] initWithConversationID:to from:from to:to body:[[EMTextMessageBody alloc]initWithText:EMCOMMUNICATE_CALLINVITE] ext:@{@"em_apns_ext":@{@"target-content-id":@"communicate",@"em_push_content":communicatePushType}, @"em_force_notification":@YES, @"em_push_mutable_content":@YES}];
        message.chatType = (EMChatType)self.conversationModel.emModel.type;
        [[EMClient sharedClient].chatManager sendMessage:message progress:nil completion:^(EMMessage *message, EMError *error) {
            [weakself.conversationModel.emModel deleteMessageWithId:message.messageId error:nil];
        }];
    }*/
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
    [[EMImageBrowser sharedBrowser] dismissViewController];
    [[EMAudioPlayerHelper sharedHelper] stopPlayer];
}

#pragma mark - Gesture Recognizer

- (void)handleTapTableViewAction:(UITapGestureRecognizer *)aTap
{
    if (aTap.state == UIGestureRecognizerStateEnded) {
        [self.view endEditing:YES];
        [self.chatBar clearMoreViewAndSelectedButton];
    }
}

- (void)scrollToBottomRow
{
    NSInteger toRow = -1;
    if (self.isSearching) {
        if ([self.searchResults count] > 0) {
            toRow = self.searchResults.count - 1;
            NSIndexPath *toIndexPath = [NSIndexPath indexPathForRow:toRow inSection:0];
            [self.searchResultTableView scrollToRowAtIndexPath:toIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        }
        return;
    }
    if ([self.dataArray count] > 0) {
        toRow = self.dataArray.count - 1;
        NSIndexPath *toIndexPath = [NSIndexPath indexPathForRow:toRow inSection:0];
        [self.tableView scrollToRowAtIndexPath:toIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
}

- (void)_showCustomTransferFileAlertView
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"(づ｡◕‿‿◕｡)づ" message:@"需要自定义实现上传附件方法" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - Send Message

- (void)_sendText
{
    if(self.chatBar.sendBtn.tag == 1){
        [self sendTextAction:self.chatBar.textView.text ext:nil];
    }
}

- (void)sendTextAction:(NSString *)aText
                    ext:(NSDictionary *)aExt
{
    if(![aExt objectForKey:MSG_EXT_GIF]){
        [self.chatBar clearInputViewText];
    }
    if ([aText length] == 0) {
        return;
    }
    
    //TODO: 处理@
    //messageExt
    
    //TODO: 处理表情
    //    NSString *sendText = [EaseConvertToCommonEmoticonsHelper convertToCommonEmoticons:aText];
    
    EMTextMessageBody *body = [[EMTextMessageBody alloc] initWithText:aText];
    [self sendMessageWithBody:body ext:aExt isUpload:NO];
}

#pragma mark - Data

- (NSArray *)formatMessages:(NSArray<EMMessage *> *)aMessages
{
    NSMutableArray *formated = [[NSMutableArray alloc] init];

    for (int i = 0; i < [aMessages count]; i++) {
        EMMessage *msg = aMessages[i];
        if (msg.chatType == EMChatTypeChat && msg.isReadAcked && (msg.body.type == EMMessageBodyTypeText || msg.body.type == EMMessageBodyTypeLocation)) {
            //
            [[EMClient sharedClient].chatManager sendMessageReadAck:msg.messageId toUser:msg.conversationId completion:nil];
        } else if (msg.chatType == EMChatTypeGroupChat && !msg.isReadAcked && (msg.body.type == EMMessageBodyTypeText || msg.body.type == EMMessageBodyTypeLocation)) {
        }
        
        CGFloat interval = (self.msgTimelTag - msg.timestamp) / 1000;
        if (self.msgTimelTag < 0 || interval > 60 || interval < -60) {
            NSString *timeStr = [EMDateHelper formattedTimeFromTimeInterval:msg.timestamp];
            [formated addObject:timeStr];
            self.msgTimelTag = msg.timestamp;
        }
        
        EMMessageModel *model = [[EMMessageModel alloc] initWithEMMessage:msg];

        [formated addObject:model];
    }
    
    return formated;
}

- (void)tableViewDidTriggerHeaderRefresh
{
    __weak typeof(self) weakself = self;
    void (^block)(NSArray *aMessages, EMError *aError) = ^(NSArray *aMessages, EMError *aError) {
        if (!aError && [aMessages count]) {
            EMMessage *msg = aMessages[0];
            weakself.moreMsgId = msg.messageId;
            
            dispatch_async(self.msgQueue, ^{
                NSArray *formated = [weakself formatMessages:aMessages];
                [weakself.dataArray insertObjects:formated atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [formated count])]];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakself refreshTableView];
                });
            });
        }
        
        [weakself tableViewDidFinishTriggerHeader:YES reload:NO];
    };

    if(self.conversationModel.emModel.unreadMessagesCount > 0){
        [self sendDidReadReceipt];
    }
    
    if ([EMDemoOptions sharedOptions].isPriorityGetMsgFromServer) {
        EMConversation *conversation = self.conversationModel.emModel;
        [EMClient.sharedClient.chatManager asyncFetchHistoryMessagesFromServer:conversation.conversationId conversationType:conversation.type startMessageId:self.moreMsgId pageSize:50 completion:^(EMCursorResult *aResult, EMError *aError) {
            block(aResult.list, aError);
         }];
    } else {
        [self.conversationModel.emModel loadMessagesStartFromId:self.moreMsgId count:50 searchDirection:EMMessageSearchDirectionUp completion:block];
    }
}

#pragma mark - Action

- (void)backAction
{
    [[EMAudioPlayerHelper sharedHelper] stopPlayer];
    [EMConversationHelper resortConversationsLatestMessage];
    
    EMConversation *conversation = self.conversationModel.emModel;
    if (conversation.type == EMChatTypeChatRoom) {
        [[EMClient sharedClient].roomManager leaveChatroom:conversation.conversationId completion:nil];
    } else {
        //草稿
        if (self.chatBar.textView.text.length > 0) {
            NSMutableDictionary *ext = [[NSMutableDictionary alloc]initWithDictionary:self.conversationModel.emModel.ext];
            [ext setObject:self.chatBar.textView.text forKey:kConversation_Draft];
            [self.conversationModel.emModel setExt:ext];
        }
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

//发送消息体
- (void)sendMessageWithBody:(EMMessageBody *)aBody
                         ext:(NSDictionary * __nullable)aExt
                    isUpload:(BOOL)aIsUpload
{
    if (!([EMClient sharedClient].options.isAutoTransferMessageAttachments) && aIsUpload) {
        [self _showCustomTransferFileAlertView];
        return;
    }
    
    NSString *from = [[EMClient sharedClient] currentUsername];
    NSString *to = self.conversationModel.emModel.conversationId;
    EMMessage *message = [[EMMessage alloc] initWithConversationID:to from:from to:to body:aBody ext:aExt];
    
    //是否需要发送阅读回执
    if([aExt objectForKey:MSG_EXT_READ_RECEIPT])
        message.isNeedGroupAck = YES;
    
    message.chatType = (EMChatType)self.conversationModel.emModel.type;
    
    __weak typeof(self) weakself = self;
    NSArray *formated = [weakself formatMessages:@[message]];
    [self.dataArray addObjectsFromArray:formated];
    if (!self.moreMsgId)
        //新会话的第一条消息
        self.moreMsgId = message.messageId;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakself refreshTableView];
    });
    [[EMClient sharedClient].chatManager sendMessage:message progress:nil completion:^(EMMessage *message, EMError *error) {
        if (error)
            [EMAlertController showErrorAlert:error.errorDescription];
        [weakself messageStatusDidChange:message error:error];
    }];
}

#pragma mark - Public

- (void)returnReadReceipt:(EMMessage *)msg{}

- (void)refreshTableView
{
    [self.tableView reloadData];
    [self.tableView setNeedsLayout];
    [self.tableView layoutIfNeeded];
    [self scrollToBottomRow];
}

@end
