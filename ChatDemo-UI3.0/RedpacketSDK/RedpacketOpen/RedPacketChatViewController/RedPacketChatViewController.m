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
#import "ChatDemoHelper.h"
#import "UserProfileManager.h"
#import "UIImageView+WebCache.h"

/** 红包聊天窗口 */
@interface RedPacketChatViewController () < EaseMessageCellDelegate,
                                            EaseMessageViewControllerDataSource
                                            >
/** 发红包的控制器 */
@property (nonatomic, strong)   RedpacketViewControl *viewControl;

@end

@implementation RedPacketChatViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    /** 设置用户头像大小 */
    [[EaseRedBagCell appearance] setAvatarSize:40.f];
    /** 设置头像圆角 */
    [[EaseRedBagCell appearance] setAvatarCornerRadius:20.f];
    
    if ([self.chatToolbar isKindOfClass:[EaseChatToolbar class]]) {
        /** 红包按钮 */
        [self.chatBarMoreView insertItemWithImage:[UIImage imageNamed:@"RedpacketCellResource.bundle/redpacket_redpacket"] highlightedImage:[UIImage imageNamed:@"RedpacketCellResource.bundle/redpacket_redpacket_high"] title:@"红包"];
    }
}

#pragma mark - Delegate RedpacketViewControlDelegate
- (void)getGroupMemberListCompletionHandle:(void (^)(NSArray<RedpacketUserInfo *> *))completionHandle
{
    EMGroup *group = [[[EMClient sharedClient] groupManager] fetchGroupInfo:self.conversation.conversationId includeMembersList:YES error:nil];
    NSMutableArray *mArray = [[NSMutableArray alloc]init];
    
    for (NSString *username in group.occupants) {
        /** 创建一个用户模型 并赋值 */
        RedpacketUserInfo *userInfo = [self profileEntityWith:username];
        [mArray addObject:userInfo];
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
            [self showMenuViewController:cell.bubbleView andIndexPath:indexPath messageType:EMMessageBodyTypeCmd];
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

#pragma mark - 发送红包消息
- (void)messageViewController:(EaseMessageViewController *)viewController didSelectMoreView:(EaseChatBarMoreView *)moreView AtIndex:(NSInteger)index
{
    __weak typeof(self) weakSelf = self;
    RPRedpacketControllerType  redpacketVCType;
    RedpacketUserInfo *userInfo = [RedpacketUserInfo new];
    userInfo = [self profileEntityWith:self.conversation.conversationId];
    NSArray *groupArray = [EMGroup groupWithId:self.conversation.conversationId].occupants;
    if (index == 5 || index == 3) {
        if (self.conversation.type == EMConversationTypeChat) {
            redpacketVCType = RPRedpacketControllerTypeRand;
        }else {
            redpacketVCType = RPRedpacketControllerTypeGroup;
        }
    }
    [RedpacketViewControl presentRedpacketViewController:redpacketVCType fromeController:self groupMemberCount:groupArray.count withRedpacketReceiver:userInfo andSuccessBlock:^(RedpacketMessageModel *model) {
        [weakSelf sendRedPacketMessage:model];
    } withFetchGroupMemberListBlock:^(RedpacketMemberListFetchBlock completionHandle) {
        EMGroup *group = [[[EMClient sharedClient] groupManager] fetchGroupInfo:self.conversation.conversationId includeMembersList:YES error:nil];
        NSMutableArray *mArray = [[NSMutableArray alloc]init];
        for (NSString *username in group.occupants) {
            /** 创建一个用户模型 并赋值 */
            RedpacketUserInfo *userInfo = [self profileEntityWith:username];
            [mArray addObject:userInfo];
        }
        completionHandle(mArray);
    } andGenerateRedpacketIDBlock:nil];
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
    NSString *currentUser = [EMClient sharedClient].currentUsername;
    NSString *senderId = messageModel.redpacketSender.userId;
    NSString *conversationId = self.conversation.conversationId;
    NSMutableDictionary *dic = [messageModel.redpacketMessageModelToDic mutableCopy];
    /** 忽略推送 */
    [dic setValue:@(YES) forKey:@"em_ignore_notification"];
    NSString *text = [NSString stringWithFormat:@"你领取了%@发的红包", messageModel.redpacketSender.userNickname];
    if (self.conversation.type == EMConversationTypeChat) {
        [self sendTextMessage:text withExt:dic];
    }else{
        if ([senderId isEqualToString:currentUser]) {
            text = @"你领取了自己的红包";
        }else {
            /** 如果不是自己发的红包，则发送抢红包消息给对方 */
            [[EMClient sharedClient].chatManager sendMessage:[self createCmdMessageWithModel:messageModel] progress:nil completion:nil];
        }
        EMTextMessageBody *textMessageBody = [[EMTextMessageBody alloc] initWithText:text];
        EMMessage *textMessage = [[EMMessage alloc] initWithConversationID:conversationId from:currentUser to:conversationId body:textMessageBody ext:dic];
        textMessage.chatType = (EMChatType)self.conversation.type;
        textMessage.isRead = YES;
        /** 刷新当前聊天界面 */
        [self addMessageToDataSource:textMessage progress:nil];
        /** 存入当前会话并存入数据库 */
        [self.conversation insertMessage:textMessage error:nil];
    }
}

- (EMMessage *)createCmdMessageWithModel:(RedpacketMessageModel *)model
{
    NSMutableDictionary *dict = [model.redpacketMessageModelToDic mutableCopy];
    
    NSString *currentUser = [EMClient sharedClient].currentUsername;
    NSString *toUser = model.redpacketSender.userId;
    EMCmdMessageBody *cmdChat = [[EMCmdMessageBody alloc] initWithAction:RedpacketKeyRedapcketCmd];
    EMMessage *message = [[EMMessage alloc] initWithConversationID:self.conversation.conversationId from:currentUser to:toUser body:cmdChat ext:dict];
    message.chatType = EMChatTypeChat;
    
    return message;
}

#pragma mark - EaseMessageCellDelegate 单击了Cell 事件
- (void)messageCellSelected:(id<IMessageModel>)model
{
    NSDictionary *dict = model.message.ext;
    __weak typeof(self) weakSelf = self;
    if ([RedpacketMessageModel isRedpacket:dict] || [RedpacketMessageModel isRedpacketTransferMessage:dict]) {
        [self.view endEditing:YES];
        [RedpacketViewControl redpacketTouchedWithMessageModel:[self toRedpacketMessageModel:model]
                                            fromViewController:self
                                            redpacketGrabBlock:^(RedpacketMessageModel *messageModel) {
                                                if (messageModel.redpacketType != RedpacketTypeAmount) {
                                                    [weakSelf sendRedpacketHasBeenTaked:messageModel];
                                                }
                                            } advertisementAction:^(NSDictionary *args) {
                                                NSInteger actionType = [args[@"actionType"] integerValue];
                                                switch (actionType) {
                                                    case 0:
                                                        // 点击了领取红包
                                                        break;
                                                    case 1: {
                                                        // 点击了去看看按钮，此处为演示
                                                        UIViewController     *VC = [[UIViewController alloc]init];
                                                        UIWebView *webView = [[UIWebView alloc]initWithFrame:self.view.bounds];
                                                        [VC.view addSubview:webView];
                                                        NSString *url = args[@"LandingPage"];
                                                        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
                                                        [webView loadRequest:request];
                                                        [(UINavigationController *)self.presentedViewController pushViewController:VC animated:YES];
                                                    }
                                                        break;
                                                    case 2: {
                                                        // 点击了分享按钮，开发者可以根据需求自定义，动作。
                                                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"点击「分享」按钮，红包SDK将该红包素材内配置的分享链接传递给商户APP，由商户APP自行定义分享渠道完成分享动作。" delegate:nil cancelButtonTitle:@"我知道了" otherButtonTitles:nil];
                                                        [alert show];
                                                    }
                                                        break;
                                                    default:
                                                        break;
                                                }
                                                
        }];
    } else {
        [super messageCellSelected:model];
    }

}

- (RedpacketMessageModel *)toRedpacketMessageModel:(id <IMessageModel>)model
{
    NSDictionary *dict = model.message.ext;
    RedpacketMessageModel *messageModel = [RedpacketMessageModel redpacketMessageModelWithDic:dict];
    BOOL isGroup = self.conversation.type == EMConversationTypeGroupChat;
    if (isGroup) {
        messageModel.redpacketSender = [self profileEntityWith:model.message.from];
        messageModel.redpacketReceiver = [self profileEntityWith:messageModel.redpacketReceiver.userId];
        
    }else{
        messageModel.redpacketSender = [self profileEntityWith:model.message.from];
    }
    return messageModel;
}

@end
