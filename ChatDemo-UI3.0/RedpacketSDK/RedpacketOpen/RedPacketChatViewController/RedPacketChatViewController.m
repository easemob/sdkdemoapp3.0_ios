//
//  ChatWithRedPacketViewController.m
//  ChatDemo-UI3.0
//
//  Created by Mr.Yang on 16/2/23.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "RedPacketChatViewController.h"
#import "EaseRedBagCell.h"
#import "RedpacketTakenMessageTipCell.h"
#import "RedpacketViewControl.h"
#import "RedpacketMessageModel.h"
#import "RedPacketUserConfig.h"
#import "RedpacketOpenConst.h"
#import "YZHRedpacketBridge.h"
#import "UserProfileManager.h"
#import "UIImageView+EMWebCache.h"

/** 红包聊天窗口 */
@interface RedPacketChatViewController () < EaseMessageCellDelegate,
                                            EaseMessageViewControllerDataSource,
                                            RedpacketViewControlDelegate>
/** 发红包的控制器 */
@property (nonatomic, strong)   RedpacketViewControl *viewControl;

@end

@implementation RedPacketChatViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /** RedPacketUserConfig 持有当前聊天窗口 */
    [RedPacketUserConfig sharedConfig].chatVC = self;
    /** 红包功能的控制器， 产生用户单击红包后的各种动作 */
    _viewControl = [[RedpacketViewControl alloc] init];
    /** 获取群组用户代理 */
    _viewControl.delegate = self;
    /** 需要当前的聊天窗口 */
    _viewControl.conversationController = self;
    /** 需要当前聊天窗口的会话ID */
    RedpacketUserInfo *userInfo = [RedpacketUserInfo new];
    userInfo.userId = self.conversation.chatter;
    _viewControl.converstationInfo = userInfo;
    __weak typeof(self) weakSelf = self;
    /** 用户抢红包和用户发送红包的回调 */
    [_viewControl setRedpacketGrabBlock:^(RedpacketMessageModel *messageModel) {
        /** 发送通知到发送红包者处 */
        if (messageModel.redpacketType != RedpacketTypeAmount) {
            [weakSelf sendRedpacketHasBeenTaked:messageModel];
        }
    } andRedpacketBlock:^(RedpacketMessageModel *model) {
        /** 发送红包 */
        [weakSelf sendRedPacketMessage:model];
    }];
    
    /** 设置用户头像大小 */
    [[EaseRedBagCell appearance] setAvatarSize:40.f];
    /** 设置头像圆角 */
    [[EaseRedBagCell appearance] setAvatarCornerRadius:20.f];
    
    if ([self.chatToolbar isKindOfClass:[EaseChatToolbar class]]) {
        /** 红包按钮 */
        [self.chatBarMoreView insertItemWithImage:[UIImage imageNamed:@"RedpacketCellResource.bundle/redpacket_redpacket"] highlightedImage:[UIImage imageNamed:@"RedpacketCellResource.bundle/redpacket_redpacket_high"] title:@"红包"];
        /** 转账按钮 */
        [self.chatBarMoreView insertItemWithImage:[UIImage imageNamed:@"RedPacketResource.bundle/redpacket_transfer_high"] highlightedImage:[UIImage imageNamed:@"RedPacketResource.bundle/redpacket_transfer_high"] title:@"转账"];
    }
}

#pragma mark - Delegate RedpacketViewControlDelegate
- (void)getGroupMemberListCompletionHandle:(void (^)(NSArray<RedpacketUserInfo *> *))completionHandle
{
    NSArray *groupArray = [[[EaseMob sharedInstance] chatManager] fetchOccupantList:self.conversation.chatter error:nil];
    NSMutableArray *mArray = [[NSMutableArray alloc]init];
    for (NSString *username in groupArray) {
        //创建一个用户模型 并赋值
        RedpacketUserInfo *userInfo = [self profileEntityWith:username];
        if ([[[[[EaseMob sharedInstance] chatManager ] loginInfo] objectForKey:kSDKUsername] isEqualToString:userInfo.userId]) {
            //定向红包 不能包含自己
        }else
        {
            [mArray addObject:userInfo];
        }
    }
    completionHandle(mArray);
}

/** 要在此处根据userID获得用户昵称,和头像地址 */
- (RedpacketUserInfo *)profileEntityWith:(NSString *)userId
{
    RedpacketUserInfo *userInfo = [RedpacketUserInfo new];

    UserProfileEntity *profile = [[UserProfileManager sharedInstance] getUserProfileByUsername:userId];
    if (profile) {
        if (profile.nickname && profile.nickname.length > 0) {
            userInfo.userNickname = profile.nickname;
        } else {
            userInfo.userNickname = userId;
        }
    } else {
        userInfo.userNickname = userId;
    }
    userInfo.userAvatar = profile.imageUrl;
    userInfo.userId = userId;
    return userInfo;
}

/** 长时间按在某条Cell上的动作 */
- (BOOL)messageViewController:(EaseMessageViewController *)viewController canLongPressRowAtIndexPath:(NSIndexPath *)indexPath
{
    id object = [self.dataArray objectAtIndex:indexPath.row];
    if ([object conformsToProtocol:NSProtocolFromString(@"IMessageModel")]) {
        id <IMessageModel> messageModel = object;
        NSDictionary *ext = messageModel.message.ext;
        /** 如果是红包，则只显示删除按钮 */
        if ([RedpacketMessageModel isRedpacket:ext]) {
            EaseMessageCell *cell = (EaseMessageCell *)[self.tableView cellForRowAtIndexPath:indexPath];
            [cell becomeFirstResponder];
            self.menuIndexPath = indexPath;
             [self showMenuViewController:cell.bubbleView andIndexPath:indexPath messageType:eMessageBodyType_Command];
            return NO;
        }else if ([RedpacketMessageModel isRedpacketTakenMessage:ext]) {
            return NO;
        }
    }
    return [super messageViewController:viewController canLongPressRowAtIndexPath:indexPath];
}

#pragma mrak - 自定义红包的Cell
- (UITableViewCell *)messageViewController:(UITableView *)tableView
                       cellForMessageModel:(id<IMessageModel>)messageModel
{
    NSDictionary *ext = messageModel.message.ext;
    if ([RedpacketMessageModel isRedpacketRelatedMessage:ext]) {
        if ([RedpacketMessageModel isRedpacket:ext] || [RedpacketMessageModel isRedpacketTransferMessage:ext]) {
            EaseRedBagCell *cell = [tableView dequeueReusableCellWithIdentifier:[EaseRedBagCell cellIdentifierWithModel:messageModel]];
            if (!cell) {
                cell = [[EaseRedBagCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[EaseRedBagCell cellIdentifierWithModel:messageModel] model:messageModel];
                cell.delegate = self;
            }
            cell.model = messageModel;
            return cell;
        }
        RedpacketTakenMessageTipCell *cell =  [[RedpacketTakenMessageTipCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        [cell configWithRedpacketMessageModel:[RedpacketMessageModel redpacketMessageModelWithDic:ext]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    return nil;
}

- (CGFloat)messageViewController:(EaseMessageViewController *)viewController
           heightForMessageModel:(id<IMessageModel>)messageModel
                   withCellWidth:(CGFloat)cellWidth
{
    NSDictionary *ext = messageModel.message.ext;
    if ([RedpacketMessageModel isRedpacket:ext] || [RedpacketMessageModel isRedpacketTransferMessage:ext])    {
        return [EaseRedBagCell cellHeightWithModel:messageModel];
    }else if ([RedpacketMessageModel isRedpacketTakenMessage:ext]) {
        return [RedpacketTakenMessageTipCell heightForRedpacketMessageTipCell];
    }
    return 0;
}

#pragma mark - DataSource
/** 未读消息回执 */
- (BOOL)messageViewController:(EaseMessageViewController *)viewController
shouldSendHasReadAckForMessage:(EMMessage *)message
                         read:(BOOL)read
{
    NSDictionary *ext = message.ext;
    if ([RedpacketMessageModel isRedpacketRelatedMessage:ext]) {
        return YES;
    }
    return [super shouldSendHasReadAckForMessage:message read:read];
}

#pragma mark - 点击按钮
- (void)messageViewController:(EaseMessageViewController *)viewController didSelectMoreView:(EaseChatBarMoreView *)moreView AtIndex:(NSInteger)index
{
    if (index == 6 || index == 3) {
        if (self.conversation.conversationType == eConversationTypeChat) {
            /** 单聊发送界面 */
            [self.viewControl presentRedPacketViewControllerWithType:RPSendRedPacketViewControllerRand memberCount:0];
        }else {
            /** 群聊红包发送界面 */
            NSArray *groupArray = [EMGroup groupWithId:self.conversation.chatter].occupants;
            [self.viewControl presentRedPacketViewControllerWithType:RPSendRedPacketViewControllerMember memberCount:groupArray.count];
        }
    } else if (index == 7) {
        /** 转账页面 */
        RedpacketUserInfo *userInfo = [RedpacketUserInfo new];
        userInfo = [self profileEntityWith:self.conversation.chatter];
        [self.viewControl presentTransferViewControllerWithReceiver:userInfo];
        
    }else {
        [self.chatToolbar endEditing:YES];
    }
}

#pragma mark - 发送红包消息
- (void)sendRedPacketMessage:(RedpacketMessageModel *)model
{
    NSDictionary *dic = [model redpacketMessageModelToDic];
    NSString *message;
    if ([RedpacketMessageModel isRedpacketTransferMessage:dic]) {
        message = [NSString stringWithFormat:@"[转账]转账%@元",model.redpacket.redpacketMoney];
    }else {
        message = [NSString stringWithFormat:@"[%@]%@", model.redpacket.redpacketOrgName, model.redpacket.redpacketGreeting];
    }
    [self sendTextMessage:message withExt:dic];
}

#pragma mark -  发送红包被抢的消息
- (void)sendRedpacketHasBeenTaked:(RedpacketMessageModel *)messageModel
{
    NSString *currentUserId = [[[[EaseMob sharedInstance] chatManager] loginInfo] objectForKey:kSDKUsername];
    NSString *senderId = messageModel.redpacketSender.userId;
    NSMutableDictionary *dic = [messageModel.redpacketMessageModelToDic mutableCopy];
    /** 忽略推送 */
    [dic setValue:@(YES) forKey:@"em_ignore_notification"];
    NSString *text = [NSString stringWithFormat:@"你领取了%@发的红包", messageModel.redpacketSender.userNickname];
    if (self.conversation.conversationType == eConversationTypeChat) {
        [self sendTextMessage:text withExt:dic];
    }else{
        if ([senderId isEqualToString:currentUserId]) {
            text = @"你领取了自己的红包";
        }else {
            /** 如果不是自己发的红包，则发送抢红包消息给对方 */
            [[EaseMob sharedInstance].chatManager sendMessage:[self createCmdMessageWithModel:messageModel] progress:nil error:nil];
        }
        EMMessage *redpacketGroupMessage = [self createTextMessageWithText:text receiver:self.conversation.chatter andExt:dic];
        [self addMessageToDataSource:redpacketGroupMessage progress:nil];
        [[EaseMob sharedInstance].chatManager insertMessageToDB:redpacketGroupMessage append2Chat:YES];    }
}

- (EMMessage *)createCmdMessageWithModel:(RedpacketMessageModel *)model
{
    NSMutableDictionary *dict = [model.redpacketMessageModelToDic mutableCopy];
    
    EMChatCommand *cmdChat = [[EMChatCommand alloc] init];
    cmdChat.cmd = RedpacketKeyRedapcketCmd;
    EMCommandMessageBody *body = [[EMCommandMessageBody alloc] initWithChatObject:cmdChat];
    EMMessage *message = [[EMMessage alloc] initWithReceiver:model.redpacketSender.userId bodies:@[body]];
    message.ext = dict;
    message.messageType = eMessageTypeChat;
    return message;
}

#pragma mark - EaseMessageCellDelegate 单击了Cell 事件
- (void)messageCellSelected:(id<IMessageModel>)model
{
    NSDictionary *dict = model.message.ext;
    if ([RedpacketMessageModel isRedpacket:dict]) {
        [self.viewControl redpacketCellTouchedWithMessageModel:[self toRedpacketMessageModel:model]];
    }else if([RedpacketMessageModel isRedpacketTransferMessage:dict]) {
        [self.viewControl presentTransferDetailViewController:[RedpacketMessageModel redpacketMessageModelWithDic:dict]];
    }else {
        [super messageCellSelected:model];
    }
}

- (RedpacketMessageModel *)toRedpacketMessageModel:(id <IMessageModel>)model
{
    RedpacketMessageModel *messageModel = [RedpacketMessageModel redpacketMessageModelWithDic:model.message.ext];
    if (self.conversation.conversationType == eConversationTypeGroupChat) {
        messageModel.redpacketSender = [self profileEntityWith:model.message.groupSenderName];
        messageModel.toRedpacketReceiver = [self profileEntityWith:messageModel.toRedpacketReceiver.userId];
    }else{
        messageModel.redpacketSender = [self profileEntityWith:model.message.from];
    }
    return messageModel;
}

- (EMMessage *)createTextMessageWithText:(NSString *)text
                                receiver:(NSString *)receiverId
                                  andExt:(NSDictionary *)ext
{
    NSString *willSendText = [EaseConvertToCommonEmoticonsHelper convertToCommonEmoticons:text];
    EMChatText *textChat = [[EMChatText alloc] initWithText:willSendText];
    EMTextMessageBody *body1 = [[EMTextMessageBody alloc] initWithChatObject:textChat];
    EMMessage *redpacketGroupMessage = [[EMMessage alloc] initWithReceiver:receiverId bodies:[NSArray arrayWithObject:body1]];
    redpacketGroupMessage.requireEncryption = NO;
    redpacketGroupMessage.messageType = eMessageTypeGroupChat;
    redpacketGroupMessage.ext = ext;
    redpacketGroupMessage.deliveryState = eMessageDeliveryState_Delivered;
    redpacketGroupMessage.isRead = YES;
    
    return redpacketGroupMessage;
}
@end
