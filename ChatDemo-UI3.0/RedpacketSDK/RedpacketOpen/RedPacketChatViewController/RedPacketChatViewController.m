//
//  ChatWithRedPacketViewController.m
//  ChatDemo-UI3.0
//
//  Created by Mr.Yang on 16/2/23.
//


#import "RedPacketChatViewController.h"
#import "EaseRedBagCell.h"
#import "UIImageView+EMWebCache.h"
#import "RedpacketMessageCell.h"
#import "RedpacketViewControl.h"
#import "RedpacketMessageModel.h"
#import "RedPacketUserConfig.h"
#import "RedpacketOpenConst.h"
#import "YZHRedpacketBridge.h"
#import "UserProfileManager.h"

/**
 *  红包单击事件索引
 */
static NSInteger const _redpacket_send_index   = 6;

/**
 *  零钱单击事件索引
 */
static NSInteger const _redpacket_change_index = 7;


/**
 *  红包聊天窗口
 */
@interface RedPacketChatViewController () < EaseMessageCellDelegate,
EaseMessageViewControllerDataSource,RedpacketViewControlDelegate>
/**
 *  发红包的控制器
 */
@property (nonatomic, strong)   RedpacketViewControl *viewControl;

@end

@implementation RedPacketChatViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /**
     红包功能的控制器， 产生用户单击红包后的各种动作
     */
    _viewControl = [[RedpacketViewControl alloc] init];
    //  需要当前的聊天窗口
    _viewControl.conversationController = self;
    // 群红包需要的返回成员列表
    _viewControl.delegate = self;
    //  需要当前聊天窗口的会话ID
    RedpacketUserInfo *userInfo = [RedpacketUserInfo new];
    userInfo.userId = self.conversation.chatter;
    _viewControl.converstationInfo = userInfo;
    
    __weak typeof(self) weakSelf = self;
    
    //  用户抢红包和用户发送红包的回调
    [_viewControl setRedpacketGrabBlock:^(RedpacketMessageModel *messageModel) {
        //  发送通知到发送红包者处
        [weakSelf sendRedpacketHasBeenTaked:messageModel];
        
    } andRedpacketBlock:^(RedpacketMessageModel *model) {
        //  发送红包
        [weakSelf sendRedPacketMessage:model];
        
    }];
    
    //  设置用户头像
    [[EaseRedBagCell appearance] setAvatarSize:40.f];
    //  设置头像圆角
    [[EaseRedBagCell appearance] setAvatarCornerRadius:20.f];
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor],NSFontAttributeName : [UIFont systemFontOfSize:18]};
    
    if ([self.chatToolbar isKindOfClass:[EaseChatToolbar class]]) {
        //  MARK: __redbag  红包
        [self.chatBarMoreView insertItemWithImage:[UIImage imageNamed:@"RedpacketCellResource.bundle/redpacket_redpacket"] highlightedImage:[UIImage imageNamed:@"RedpacketCellResource.bundle/redpacket_redpacket_high"] title:@"红包"];
        
        //  MARK: __redbag 零钱
        /*
         [self.chatBarMoreView insertItemWithImage:[UIImage imageNamed:@"RedpacketCellResource.bundle/redpacket_changeMoney_high"] highlightedImage:[UIImage imageNamed:@"RedpacketCellResource.bundle/redpacket_changeMoney"] title:@"零钱"];
         */
    }
    
    //  显示红包的Cell视图
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([RedpacketMessageCell class]) bundle:nil]forCellReuseIdentifier:NSStringFromClass([RedpacketMessageCell class])];
    
}

//  长时间按在某条Cell上的动作
- (BOOL)messageViewController:(EaseMessageViewController *)viewController canLongPressRowAtIndexPath:(NSIndexPath *)indexPath
{
    id object = [self.dataArray objectAtIndex:indexPath.row];
    
    if ([object conformsToProtocol:NSProtocolFromString(@"IMessageModel")]) {
        id <IMessageModel> messageModel = object;
        NSDictionary *ext = messageModel.message.ext;
        
        //  如果是红包，则只显示删除按钮
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

#pragma mark - EaseMessageCellDelegate 单击了Cell 事件

- (void)messageCellSelected:(id<IMessageModel>)model
{
    NSDictionary *dict = model.message.ext;
    
    if ([RedpacketMessageModel isRedpacket:dict]) {
        [self.viewControl redpacketCellTouchedWithMessageModel:[self toRedpacketMessageModel:model]];
        
    }else {
        [super messageCellSelected:model];
    }
}

#pragma mrak - 自定义红包的Cell
- (UITableViewCell *)messageViewController:(UITableView *)tableView
                       cellForMessageModel:(id<IMessageModel>)messageModel
{
    NSDictionary *ext = messageModel.message.ext;
    if (![RedpacketMessageModel isRedpacketRelatedMessage:ext]) {
        return [super messageViewController:tableView cellForMessageModel:messageModel];
    }
    
    if ([RedpacketMessageModel isRedpacket:ext]) {
        EaseRedBagCell *cell = [tableView dequeueReusableCellWithIdentifier:[EaseRedBagCell cellIdentifierWithModel:messageModel]];
        
        if (!cell) {
            cell = [[EaseRedBagCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[EaseRedBagCell cellIdentifierWithModel:messageModel] model:messageModel];
            cell.delegate = self;
        }
        
        cell.model = messageModel;
        
        return cell;
    }
    
    RedpacketMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([RedpacketMessageCell class])];
    cell.model = messageModel;
    
    return cell;
}

- (CGFloat)messageViewController:(EaseMessageViewController *)viewController
           heightForMessageModel:(id<IMessageModel>)messageModel
                   withCellWidth:(CGFloat)cellWidth
{
    NSDictionary *ext = messageModel.message.ext;
    
    if ([RedpacketMessageModel isRedpacket:ext])    {
        return [EaseRedBagCell cellHeightWithModel:messageModel];
    }else if ([RedpacketMessageModel isRedpacketTakenMessage:ext]) {
        return 36;
    }
    
    return [super messageViewController:viewController heightForMessageModel:messageModel withCellWidth:cellWidth];
}

#pragma mark - DataSource
//  未读消息回执
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
    if (index == _redpacket_send_index || index == 3) {
        if (self.conversation.conversationType == eConversationTypeChat) {
            //单聊发送界面
            [self.viewControl presentRedPacketViewController];
        }else{
            //群内指向红包
            NSArray *groupArray = [EMGroup groupWithId:self.conversation.chatter].occupants;
            //群聊红包发送界面
            [self.viewControl presentRedPacketMoreViewControllerWithGroupMemberArray:groupArray];
        }
        
    } else if (index == _redpacket_change_index) {
        //  零钱界面
        [self.viewControl presentChangeMoneyViewController];
    }else {
        [self.chatToolbar endEditing:YES];
    }
}

#pragma Delegate RedpacketViewControlDelegate
//定向红包
- (NSArray *)groupMemberList
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
    
    return mArray;
}

- (void)sendRedPacketMessage:(RedpacketMessageModel *)model
{
    NSDictionary *dic = [model redpacketMessageModelToDic];
    NSString *message = [NSString stringWithFormat:@"[%@]%@", model.redpacket.redpacketOrgName, model.redpacket.redpacketGreeting];
    
    [self sendTextMessage:message withExt:dic];
}

//  MARK: 发送红包被抢的消息
- (void)sendRedpacketHasBeenTaked:(RedpacketMessageModel *)messageModel
{
    NSString *text = nil;
    NSMutableDictionary *dict = [messageModel.redpacketMessageModelToDic mutableCopy];
    
    /**
     *  当前用户的用户ID
     */
    NSString *currentUserId = [[[[EaseMob sharedInstance] chatManager] loginInfo] objectForKey:kSDKUsername];
    
    if (self.conversation.conversationType == eConversationTypeChat) {
        /**
         *  忽略推送
         */
        [dict setValue:@(YES) forKey:@"em_ignore_notification"];
        NSString *receiver = messageModel.redpacketReceiver.userNickname;
        if (receiver.length > 18) {
            receiver = [[receiver substringToIndex:18] stringByAppendingString:@"..."];
        }
        text = [NSString stringWithFormat:@"%@领取了你的红包", receiver];
        
        [self sendTextMessage:text withExt:dict];
        
    }else{
        if ([messageModel.redpacketSender.userId isEqualToString:currentUserId]) {
            text = @"你领取了自己的红包";
            
        }else {
            NSString *sender = messageModel.redpacketSender.userNickname;
            if (sender.length > 18) {
               sender = [[sender substringToIndex:18] stringByAppendingString:@"..."];
            }
            text = [NSString stringWithFormat:@"你领取了%@的红包", sender];
            
            [[EaseMob sharedInstance].chatManager asyncSendMessage:[self createCmdMessageWithModel:messageModel] progress:nil];
        }

        EMMessage *redpacketGroupMessage = [self createTextMessageWithText:text receiver:self.conversation.chatter andExt:dict];
        [self addMessageToDataSource:redpacketGroupMessage progress:nil];
        [[EaseMob sharedInstance].chatManager insertMessageToDB:redpacketGroupMessage append2Chat:YES];
    }
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

- (RedpacketMessageModel *)toRedpacketMessageModel:(id <IMessageModel>)model
{
    RedpacketMessageModel *messageModel = [RedpacketMessageModel redpacketMessageModelWithDic:model.message.ext];
    BOOL isGroup = self.conversation.conversationType == eConversationTypeGroupChat;
    messageModel.redpacketReceiver.isGroup = isGroup;
    if (isGroup) {
        messageModel.redpacketSender = [self profileEntityWith:model.message.groupSenderName];
        messageModel.toRedpacketReceiver = [self profileEntityWith:messageModel.toRedpacketReceiver.userId];
    }else
    {
        messageModel.redpacketSender = [self profileEntityWith:model.message.from];
    }
    return messageModel;
}

// 要在此处根据userID获得用户昵称,和头像地址
- (RedpacketUserInfo *)profileEntityWith:(NSString *)userId
{
    RedpacketUserInfo *userInfo = [RedpacketUserInfo new];
    UserProfileEntity *profileEntity = [[UserProfileManager sharedInstance] getUserProfileByUsername:userId];
    if (profileEntity) {
        if (profileEntity.nickname && profileEntity.nickname.length > 0) {
            
            userInfo.userNickname = profileEntity.nickname;
            
        } else {
            userInfo.userNickname = userId;
        }
    } else {
        userInfo.userNickname = userId;
    }
    userInfo.userAvatar = profileEntity.imageUrl;
    userInfo.userId = userId;
    return userInfo;
}

#pragma mark - EMChatManagerChatDelegate

- (void)didReceiveCmdMessage:(EMMessage *)message
{
    NSString *currentUserId = [[[[EaseMob sharedInstance] chatManager] loginInfo] objectForKey:kSDKUsername];
    NSString *senderId = message.ext[RedpacketKeyRedpacketSenderId];
    /**
     *  为了兼容老版本传过来的Cmd消息，必须做一下判断
     */
    BOOL isRedpacketSender = [currentUserId isEqualToString:senderId];
    
    EMCommandMessageBody * body = (EMCommandMessageBody *)message.messageBodies[0];
    if ([body.action isEqualToString:RedpacketKeyRedapcketCmd] && isRedpacketSender) {
        NSString *receiver = message.ext[RedpacketKeyRedpacketCmdToGroup];
        /**
         *  红包消息属于当前聊天窗口
         */
        if(receiver.length == 0) {
            receiver = message.from;
        }
        
        if ([receiver isEqualToString:self.conversation.chatter]) {
            [self addMessageToDataSource:[self cmdMessageBodyToTextMessageBody:message toReceiver:receiver] progress:nil];
        }
    }
}

- (EMMessage *)cmdMessageBodyToTextMessageBody:(EMMessage *)message toReceiver:(NSString *)receiver
{
    NSDictionary *dict = message.ext;
    NSString *receiverNick = [dict valueForKey:RedpacketKeyRedpacketReceiverNickname];
    if (receiverNick.length > 18) {
        receiverNick = [[receiverNick substringToIndex:18] stringByAppendingString:@"..."];
    }
    
    NSString *text = [NSString stringWithFormat:@"%@领取了你的红包",receiverNick];
    
    return [self createTextMessageWithText:text receiver:receiver andExt:message.ext];
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
