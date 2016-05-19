//
//  ChatWithRedPacketViewController.m
//  ChatDemo-UI3.0
//
//  Created by Mr.Yang on 16/2/23.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
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
EaseMessageViewControllerDataSource>
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
    //  需要当前聊天窗口的会话ID
    RedpacketUserInfo *userInfo = [RedpacketUserInfo new];
    userInfo.userId = self.conversation.conversationId;
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
    
    //  同步Token
    [[YZHRedpacketBridge sharedBridge] reRequestRedpacketUserToken];
    
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
//    if (![RedpacketMessageModel isRedpacketRelatedMessage:ext]) {
//        return [super messageViewController:tableView cellForMessageModel:messageModel];
//    }
    
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
    /*
     __weak typeof(self) weakSelf = self;
     //  在***领取了某人的红包消息上 查看红包详情
     [cell setRedpacketMesageCellTaped:^(id<IMessageModel> model) {
     //暂不支持
     [weakSelf.viewControl redpacketCellTouchedWithMessageModel:[weakSelf toRedpacketMessageModel:model]];
     
     }];
     */
    
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
    
    return 36.0f;
//    return [super messageViewController:viewController heightForMessageModel:messageModel withCellWidth:cellWidth];
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
        if (self.conversation.type == EMConversationTypeChat) {
            //单聊发送界面
            [self.viewControl presentRedPacketViewController];
        }else{
            //群聊红包发送界面
            [self.viewControl presentRedPacketMoreViewControllerWithCount:(int)[EMGroup groupWithId:self.conversation.conversationId].occupants.count];
        }
        
    } else if (index == _redpacket_change_index) {
        //  零钱界面
        [self.viewControl presentChangeMoneyViewController];
    }else {
        [self.chatToolbar endEditing:YES];
    }
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
    NSString *text = [NSString stringWithFormat:@"你领取了%@的红包", messageModel.redpacketSender.userNickname];
    
    NSDictionary *Info = [messageModel.redpacketDetailDic valueForKey:@"Info"];
//    NSString *GroupId = [NSString stringWithFormat:@"%@",[Info valueForKey:@"GroupId"]];
    
    NSMutableDictionary *dic = [messageModel.redpacketMessageModelToDic mutableCopy];
    [dic setValue:Info[@"SenderDuid"] forKey:RedpacketKeyRedpacketSenderId];
    [dic setValue:Info[@"SenderNickname"] forKey:RedpacketKeyRedpacketSenderNickname];
    
    if (self.conversation.type == EMConversationTypeChat) {
        [self sendTextMessage:text withExt:dic];
        
    }else{
        //  FIXME：内部转换方法
        
        // 群聊消息透传
        EMCmdMessageBody *body = [[EMCmdMessageBody alloc] initWithAction:RedpacketKeyRedapcketCmd];
        // 生成message
        NSString *currentUser = [EMClient sharedClient].currentUsername;
        NSString *receiver = self.conversation.conversationId;
        EMMessage *message = [[EMMessage alloc] initWithConversationID:receiver from:currentUser to:receiver body:body ext:dic];
        message.chatType = EMConversationTypeGroupChat; // 设置为群聊消息

        [[EMClient sharedClient].chatManager asyncSendMessage:message progress:nil completion:nil];
        
        //抢到以后消息需要本地存储一条~
        if ([messageModel.redpacketSender.userId isEqualToString:currentUser]) {
            text = @"你领取了自己发的红包";
            
        }else {
            text = [NSString stringWithFormat:@"你领取了%@发的红包", messageModel.redpacketSender.userNickname];
        }

        NSString *willSendText = [EaseConvertToCommonEmoticonsHelper convertToCommonEmoticons:text];
        EMTextMessageBody *textMessageBody = [[EMTextMessageBody alloc] initWithText:willSendText];
        EMMessage *textMessage = [[EMMessage alloc] initWithConversationID:receiver from:currentUser to:receiver body:textMessageBody ext:dic];
        textMessage.chatType = EMConversationTypeChat;
        textMessage.ext = dic;
        textMessage.isRead = YES;
        
        [self addMessageToDataSource:textMessage progress:nil];
        [[EMClient sharedClient].chatManager importMessages:@[textMessage]];
    }
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

- (RedpacketMessageModel *)toRedpacketMessageModel:(id <IMessageModel>)model
{
    RedpacketMessageModel *messageModel = [RedpacketMessageModel redpacketMessageModelWithDic:model.message.ext];
    BOOL isGroup = self.conversation.type == EMConversationTypeChat;
    messageModel.redpacketReceiver.isGroup = isGroup;
    
    messageModel.redpacketSender.userAvatar = model.avatarURLPath;

    NSString *nickName = model.nickname;
    if (nickName.length == 0) {
        nickName = model.message.from;
    }
    messageModel.redpacketSender.userNickname = nickName;
    
    return messageModel;
}

#pragma mark - EMChatManagerChatDelegate

- (void)didReceiveCmdMessage:(EMMessage *)message
{
    //抢到红包以后发送消息的监听 判断
    EMCmdMessageBody * body = (EMCmdMessageBody *)message.body;
    if ([body.action isEqualToString:RedpacketKeyRedapcketCmd]) {
        NSString *senderID = [NSString stringWithFormat:@"%@",message.ext[RedpacketKeyRedpacketSenderId]];
        /**
         *  当前用户是发红包的人
         */
        NSString *currentUser = [EMClient sharedClient].currentUsername;
        if ([senderID isEqualToString:currentUser]){
            /**
             *  加入tableView的DataSource 并刷新界面
             */
            [self addMessageToDataSource:message progress:nil];
        }
        
    }else{
        // [super didReceiveCmdMessage:message];
        
    }
}

@end
