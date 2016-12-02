//
//  YZHUserConfig.m
//  ChatDemo-UI3.0
//
//  Created by Mr.Yang on 16/3/8.
//

#import "RedPacketUserConfig.h"
#import "UserProfileManager.h"
#import "EaseMob.h"
#import "YZHRedpacketBridge.h"
#import "RedpacketMessageModel.h"
#import "AppDelegate.h"
#import "ConversationListController.h"


static RedPacketUserConfig *__sharedConfig__ = nil;

@interface RedPacketUserConfig () <IChatManagerDelegate,
                                    YZHRedpacketBridgeDataSource,
                                    YZHRedpacketBridgeDelegate>
{
    NSString *_dealerAppKey;
}

@end

@implementation RedPacketUserConfig

- (void)beginObserve
{
    /** 监听用户聊天 */
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
}

- (void)removeObserver
{
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
}

- (void)dealloc
{
    [self removeObserver];
}

+ (RedPacketUserConfig *)sharedConfig
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedConfig__ = [[RedPacketUserConfig alloc] init];
        [YZHRedpacketBridge sharedBridge].dataSource = __sharedConfig__;
        [YZHRedpacketBridge sharedBridge].delegate = __sharedConfig__;
        [YZHRedpacketBridge sharedBridge].isDebug = YES;
    });
    return __sharedConfig__;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self beginObserve];
    }
    return self;
}

- (void)configWithAppKey:(NSString *)appKey
{
    _dealerAppKey = appKey;
}

#pragma mark - YZHRedpacketBridgeDataSource
/** 获取当前用户登陆信息，YZHRedpacketBridgeDataSource */
- (RedpacketUserInfo *)redpacketUserInfo
{
    RedpacketUserInfo *userInfo = [RedpacketUserInfo new];
    NSDictionary *userInfoDic = [[[EaseMob sharedInstance] chatManager] loginInfo];
    NSString *userId = [userInfoDic objectForKey:kSDKUsername];
    userInfo.userId = userId;
    UserProfileEntity *entity = [[UserProfileManager sharedInstance] getCurUserProfile];
    NSString *nickname = [entity.nickname stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    userInfo.userNickname = nickname.length > 0 ? nickname : userId;
    userInfo.userAvatar = entity.imageUrl;;
    return userInfo;
}

#pragma mark - YZHRedpacketBridgeDelegate
- (void)redpacketFetchRegisitParam:(FetchRegisitParamBlock)fetchBlock withError:(NSError *)error;
{
    NSDictionary *userInfo = [[[EaseMob sharedInstance] chatManager] loginInfo];
    NSString *userId = [userInfo objectForKey:kSDKUsername];
    NSString *userToken = [userInfo objectForKey:kSDKToken];
    if (_dealerAppKey.length == 0) {
        NSLog(@"请先配置商户ID");
        return;
    }else if (userToken.length == 0) {
        NSLog(@"用户还未登录");
        return;
    }
    if (userToken) {
        RedpacketRegisitModel *model = [RedpacketRegisitModel easeModelWithAppKey:_dealerAppKey appToken:userToken andAppUserId:userId];
        fetchBlock(model);
    }else {
        fetchBlock(nil);
    }
    
}

#pragma mark - HandleCmdMessage
- (void)didReceiveOfflineCmdMessages:(NSArray *)offlineCmdMessages
{
    /** 收到红包被抢的 */
    for (EMMessage *message in offlineCmdMessages) {
        EMCommandMessageBody * body = (EMCommandMessageBody *)message.messageBodies[0];
        if ([body.action isEqualToString:RedpacketKeyRedapcketCmd]) {
            [self handleCmdMessage:message];
        }
    }
}

-(void)didReceiveCmdMessage:(EMMessage *)message
{
    /** 收到红包被抢的消息 */
    EMCommandMessageBody * body = (EMCommandMessageBody *)message.messageBodies[0];
    if ([body.action isEqualToString:RedpacketKeyRedapcketCmd]) {
        [self handleCmdMessage:message];
    }
}

- (void)handleCmdMessage:(EMMessage *)message
{
    /** 当前用户的用户ID */
    NSString *currentUserId = [[[[EaseMob sharedInstance] chatManager] loginInfo] objectForKey:kSDKUsername];
    NSString *senderId = message.ext[RedpacketKeyRedpacketSenderId];
    /**为了兼容老版本传过来的Cmd消息，必须做一下判断*/
    BOOL isRedpacketSender = [currentUserId isEqualToString:senderId];
    if (!isRedpacketSender) {
        return;
    }
    NSDictionary *dict = message.ext;
    NSString *receiver = [dict valueForKey:RedpacketKeyRedpacketReceiverNickname];
    if (receiver.length > 18) {
        receiver = [[receiver substringToIndex:18] stringByAppendingString:@"..."];
    }
    NSString *conversationId = message.ext[RedpacketKeyRedpacketCmdToGroup];
    if (conversationId.length == 0) {
        conversationId = message.from;
    }
    NSString *text = [NSString stringWithFormat:@"%@领取了你的红包",receiver];
    NSString *willSendText = [EaseConvertToCommonEmoticonsHelper convertToCommonEmoticons:text];
    EMChatText *textChat = [[EMChatText alloc] initWithText:willSendText];
    EMTextMessageBody *body1 = [[EMTextMessageBody alloc] initWithChatObject:textChat];
    EMMessage *redpacketGroupMessage = [[EMMessage alloc] initWithReceiver:conversationId bodies:[NSArray arrayWithObject:body1]];
    redpacketGroupMessage.requireEncryption = NO;
    redpacketGroupMessage.messageType = eMessageTypeGroupChat;
    redpacketGroupMessage.ext = message.ext;
    redpacketGroupMessage.deliveryState = eMessageDeliveryState_Delivered;
    redpacketGroupMessage.isRead = YES;
    /**插入数据库，并更新当前聊天界面*/
    [[EaseMob sharedInstance].chatManager insertMessagesToDB:@[redpacketGroupMessage] forChatter:conversationId append2Chat:YES];
}

/** 为了兼容红包2.0版本 */
- (void)didReceiveMessage:(EMMessage *)message
{
    NSDictionary *dict = message.ext;
    NSString *text;
    if ([RedpacketMessageModel isRedpacketTakenMessage:dict]) {
        NSString *receiver = [dict valueForKey:RedpacketKeyRedpacketReceiverNickname];
        if (receiver.length == 0) {
            receiver = [dict valueForKey:RedpacketKeyRedpacketReceiverId];
        }
        text = [NSString stringWithFormat:@"%@领取了你的红包", receiver];
    }else if ([RedpacketMessageModel isRedpacketTransferMessage:message.ext]){
        NSString *currentUserId = [[[[EaseMob sharedInstance] chatManager] loginInfo] objectForKey:kSDKUsername];
        NSString *senderId = message.ext[RedpacketKeyRedpacketSenderId];
        BOOL isRedpacketSender = [currentUserId isEqualToString:senderId];
        
        if (isRedpacketSender) {
            text = [NSString stringWithFormat:@"[转账]转账%@元", [dict valueForKey:RedpacketKeyRedpacketTransferAmout]];
        }else{
            text = [NSString stringWithFormat:@"[转账]向你转账%@元", [dict valueForKey:RedpacketKeyRedpacketTransferAmout]];;
        }
    }
    if (text.length) {
        for (id body in message.messageBodies) {
            if ([body isKindOfClass:[EMTextMessageBody class]]) {
                EMTextMessageBody *textBody = (EMTextMessageBody *)body;
                textBody.text = text;
                [message updateMessageBodiesToDB];
                ConversationListController *listVC = [((AppDelegate *)[UIApplication sharedApplication].delegate).mainController.viewControllers objectAtIndex:0];
                [listVC refreshDataSource];
                break;
            }
        }
    }
}

- (NSString *)textWithMessage:(EMMessage *)message
{
    NSString *text = nil;
    NSDictionary *dict = message.ext;
    NSString *currentUserId = [[[[EaseMob sharedInstance] chatManager] loginInfo] objectForKey:kSDKUsername];
    NSString *receiverId = [dict valueForKey:RedpacketKeyRedpacketReceiverId];
    BOOL isReceiver = [receiverId isEqualToString:currentUserId];
    if (isReceiver) {
        NSString *sender = [dict valueForKey:RedpacketKeyRedpacketSenderNickname];
        if (sender.length == 0) {
            sender = [dict valueForKey:RedpacketKeyRedpacketSenderId];
        }
        if ([message.from isEqualToString:receiverId]) {
            text = [NSString stringWithFormat:@"你领取了自己的红包"];
        }else {
            text = [NSString stringWithFormat:@"你领取了%@的红包", sender];
        }
    }else {
        NSString *receiver = [dict valueForKey:RedpacketKeyRedpacketReceiverNickname];
        if (receiver.length == 0) {
            receiver = [dict valueForKey:RedpacketKeyRedpacketReceiverId];
        }
        text = [NSString stringWithFormat:@"%@领取了你的红包", receiver];
    }
    return text;
}
/** 兼容结束 */

@end
