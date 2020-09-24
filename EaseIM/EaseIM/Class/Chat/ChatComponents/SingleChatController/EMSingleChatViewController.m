//
//  EMSingleChatViewController.m
//  EaseIM
//
//  Created by 娜塔莎 on 2020/7/9.
//  Copyright © 2020 娜塔莎. All rights reserved.
//

#import "EMSingleChatViewController.h"
#import "EMChatInfoViewController.h"
#import "EMMessageModel.h"

@interface EMSingleChatViewController () <EMChatBarDelegate>

//Typing
@property (nonatomic) BOOL isTyping;
@property (nonatomic) BOOL enableTyping;
@property (nonatomic) BOOL isViewDidAppear;

@end

@implementation EMSingleChatViewController

- (instancetype)initWithConversationId:(NSString *)aId type:(EMConversationType)aType
                                    createIfNotExist:(BOOL)aIsCreate
                                        isChatRecord:(BOOL)aIsChatRecord
{
    return [super initWithConversationId:aId type:aType createIfNotExist:aIsCreate];
}

- (instancetype)initWithCoversationModel:(EMConversationModel *)aConversationModel
{
    return [super initWithCoversationModel:aConversationModel];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //本地通话记录
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(insertLocationCallRecord:) name:EMCOMMMUNICATE_RECORD object:nil];
    //单聊主叫方才能发送通话记录信息(远端通话记录)
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendCallEndMsg:) name:EMCOMMMUNICATE object:nil];
    self.isTyping = NO;
    self.enableTyping = NO;
    if ([EMDemoOptions sharedOptions].isChatTyping && self.conversationModel.emModel.type == EMConversationTypeChat) {
        self.enableTyping = YES;
    }
    
    [self _setupNavigationBarRightItem];
}

- (void)_setupNavigationBarRightItem
{
    UIImage *image = [[UIImage imageNamed:@"userData"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(chatInfoAction)];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.isViewDidAppear = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.isViewDidAppear = NO;
    if (self.enableTyping && self.isTyping)
        [self _sendEndTyping];
}

- (void)dealloc
{
    self.isViewDidAppear = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - EMChatManagerDelegate

//　收到已读回执
- (void)messagesDidRead:(NSArray *)aMessages
{
    __weak typeof(self) weakself = self;
    dispatch_async(self.msgQueue, ^{
        NSString *conId = weakself.conversationModel.emModel.conversationId;
        __block BOOL isReladView = NO;
        for (EMMessage *message in aMessages) {
            if (![conId isEqualToString:message.conversationId]){
                continue;
            }
            
            [weakself.dataArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if ([obj isKindOfClass:[EMMessageModel class]]) {
                    EMMessageModel *model = (EMMessageModel *)obj;
                    if ([model.emModel.messageId isEqualToString:message.messageId]) {
                        model.emModel.isReadAcked = YES;
                        isReladView = YES;
                        *stop = YES;
                    }
                }
            }];
        }
        
        if (isReladView) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakself.tableView reloadData];
            });
        }
    });
}

- (void)cmdMessagesDidReceive:(NSArray *)aCmdMessages
{
    __weak typeof(self) weakself = self;
    dispatch_async(self.msgQueue, ^{
        NSString *conId = weakself.conversationModel.emModel.conversationId;
        for (EMMessage *message in aCmdMessages) {
            
            if (![conId isEqualToString:message.conversationId]) {
                continue;
            }
            
            EMCmdMessageBody *body = (EMCmdMessageBody *)message.body;
            NSString *str = @"";
            if ([body.action isEqualToString:MSG_TYPING_BEGIN]) {
                str = @"对方正在输入...";
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                self.titleDetailLabel.text = str;
            });
        }
    });
}

#pragma mark - EMChatBarDelegate

- (void)inputViewDidChange:(EMTextView *)aInputView
{
    if (self.enableTyping) {
        if (!self.isTyping) {
            self.isTyping = YES;
            [self _sendBeginTyping];
        }
    }
}

//正在输入状态
- (void)_sendBeginTyping
{
    NSString *from = [[EMClient sharedClient] currentUsername];
    NSString *to = self.conversationModel.emModel.conversationId;
    EMCmdMessageBody *body = [[EMCmdMessageBody alloc] initWithAction:MSG_TYPING_BEGIN];
    body.isDeliverOnlineOnly = YES;
    EMMessage *message = [[EMMessage alloc] initWithConversationID:to from:from to:to body:body ext:nil];
    message.chatType = (EMChatType)self.conversationModel.emModel.type;
    [[EMClient sharedClient].chatManager sendMessage:message progress:nil completion:nil];
}

- (void)_sendEndTyping
{
    self.isTyping = NO;
    
    NSString *from = [[EMClient sharedClient] currentUsername];
    NSString *to = self.conversationModel.emModel.conversationId;
    EMCmdMessageBody *body = [[EMCmdMessageBody alloc] initWithAction:MSG_TYPING_END];
    body.isDeliverOnlineOnly = YES;
    EMMessage *message = [[EMMessage alloc] initWithConversationID:to from:from to:to body:body ext:nil];
    message.chatType = (EMChatType)self.conversationModel.emModel.type;
    [[EMClient sharedClient].chatManager sendMessage:message progress:nil completion:nil];
}

- (void)keyBoardWillHide:(NSNotification *)note
{
    [super keyBoardWillHide:note];
    if (self.enableTyping)
        [self _sendEndTyping];
}

#pragma mark - Action

- (void)returnReadReceipt:(EMMessage *)msg
{
    if ([self _isNeedSendReadAckForMessage:msg isMarkRead:NO]) {
        [[EMClient sharedClient].chatManager sendMessageReadAck:msg.messageId toUser:msg.conversationId completion:nil];
    }
}

- (BOOL)_isNeedSendReadAckForMessage:(EMMessage *)aMessage
                          isMarkRead:(BOOL)aIsMarkRead
{
    if (!self.isViewDidAppear || aMessage.direction == EMMessageDirectionSend || aMessage.isReadAcked || aMessage.chatType != EMChatTypeChat)
        return NO;
    
    EMMessageBody *body = aMessage.body;
    if (!aIsMarkRead && (body.type == EMMessageBodyTypeVideo || body.type == EMMessageBodyTypeVoice || body.type == EMMessageBodyTypeImage))
        return NO;

    if (body.type == EMMessageTypeText && [((EMTextMessageBody *)body).text isEqualToString:EMCOMMUNICATE_CALLED_MISSEDCALL] && aMessage.direction == EMMessageDirectionReceive)
        return NO;
        
    return YES;
}

//本地通话记录
- (void)insertLocationCallRecord:(NSNotification*)noti
{
    EMMessage *message = (EMMessage *)[noti.object objectForKey:@"msg"];
    NSArray *formated = [self formatMessages:@[message]];
    [self.dataArray addObjectsFromArray:formated];
    self.moreMsgId = message.messageId;
    [self refreshTableView];
}

//通话记录消息
- (void)sendCallEndMsg:(NSNotification*)noti
{
    EMTextMessageBody *body;
    if (![[noti.object objectForKey:EMCOMMUNICATE_DURATION_TIME] isEqualToString:@""])
        body = [[EMTextMessageBody alloc] initWithText:[NSString stringWithFormat:@"通话时长 %@",[noti.object objectForKey:EMCOMMUNICATE_DURATION_TIME]]];
    else
        //body = [[EMTextMessageBody alloc] initWithText:[noti.object objectForKey:EMCOMMUNICATE_MISSED_CALL]];
        body = [[EMTextMessageBody alloc] initWithText:@"有一个未接通话"];
    NSDictionary *iOSExt = @{@"em_apns_ext":@{@"need-delete-content-id":@"communicate",@"em_push_content":@"有一条通话记录待查看", @"em_push_sound":@"ring.caf", @"em_push_mutable_content":@YES}, @"em_force_notification":@YES, EMCOMMUNICATE_TYPE:[noti.object objectForKey:EMCOMMUNICATE_TYPE]};
    NSDictionary *androidExt = @{@"em_push_ext":@{@"type":@"call"}, @"em_android_push_ext":@{@"em_push_sound":@"/raw/ring", @"em_push_channel_id":@"hyphenate_offline_push_notification"}};
    NSMutableDictionary *pushExt = [[NSMutableDictionary alloc]initWithDictionary:iOSExt];
    [pushExt addEntriesFromDictionary:androidExt];
    //[self sendMessageWithBody:body ext:[NSDictionary dictionaryWithDictionary:pushExt] isUpload:NO];
    NSString *from = [[EMClient sharedClient] currentUsername];
    NSString *to = self.conversationModel.emModel.conversationId;
    EMMessage *message = [[EMMessage alloc] initWithConversationID:to from:from to:to body:body ext:nil];
    message.chatType = (EMChatType)self.conversationModel.emModel.type;
    [[EMClient sharedClient].chatManager sendMessage:message progress:nil completion:^(EMMessage *message, EMError *error) {
        [self.conversationModel.emModel deleteMessageWithId:message.messageId error:nil];
    }];
}

//单聊详情页
- (void)chatInfoAction
{
    __weak typeof(self) weakself = self;
    EMChatInfoViewController *chatInfoController = [[EMChatInfoViewController alloc]initWithCoversationModel:self.conversationModel];
    [chatInfoController setClearRecordCompletion:^(BOOL isClearRecord) {
        if (isClearRecord) {
            [weakself.dataArray removeAllObjects];
            [weakself.tableView reloadData];
        }
    }];
    [self.navigationController pushViewController:chatInfoController animated:NO];
}

- (void)_sendTextAction:(NSString *)aText ext:(NSDictionary *)aExt
{
    [super sendTextAction:aText ext:aExt];
    if (self.enableTyping) {
        [self _sendEndTyping];
    }
}

@end
