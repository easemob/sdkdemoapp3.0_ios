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

/**
 *  环信IMToken过期
 */
#define RedpacketEaseMobTokenOutDate  20304


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
    /**
     *  监听用户的登陆操作
     */
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
    
    /**
     *  检测切换用户的操做
     */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLoginChanged:) name:KNOTIFICATION_LOGINCHANGE object:nil];
}

- (void)removeObserver
{
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
        
    });
    
    return __sharedConfig__;
}

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        [self beginObserve];
        [YZHRedpacketBridge sharedBridge].redpacketOrgName = @"环信";
    }
    
    return self;
}

- (void)configWithAppKey:(NSString *)appKey
{
    _dealerAppKey = appKey;
}

#pragma mark - YZHRedpacketBridgeDataSource

/**
 *  获取当前用户登陆信息，YZHRedpacketBridgeDataSource
 */
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

//  配置红包相关的服务
- (void)configRedpacketService
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
    
    [[YZHRedpacketBridge sharedBridge] configWithAppKey:_dealerAppKey appUserId:userId imToken:userToken];
}

#pragma mark - YZHRedpacketBridgeDelegate

- (void)redpacketError:(NSString *)errorStr withErrorCode:(NSInteger)code
{
    NSLog(@"获取RedpacketTokenFalied:%@", errorStr);
    if (code == RedpacketEaseMobTokenOutDate) {
        //  刷新环信Token
        EaseMob *easemob = [EaseMob sharedInstance];
        EMError *error = nil;
        
        SEL selector = NSSelectorFromString(@"fetchTokenFromServer");
        if ([easemob respondsToSelector:selector]) {
            IMP imp = [easemob methodForSelector:selector];
            EMError *(*func)(id, SEL) = (void *)imp;
            error = func(easemob, selector);
            
            if (!error) {
                [self configRedpacketService];
            }
        }
    }
}

#pragma mark - IChatManagerDelegate
    
/**
 *  检测用户登陆状态
 */
- (void)userLoginChanged:(NSNotification *)notification
{
    BOOL isLoginSuccess = [notification.object boolValue];
    
    if(isLoginSuccess) {
        [self configRedpacketService];
        
    }else {
        [[YZHRedpacketBridge sharedBridge] redpacketUserLoginOut];
    }
}

/**
 *  自动登录状态监听
 */
- (void)didAutoLoginWithInfo:(NSDictionary *)loginInfo error:(EMError *)error
{
    [self configRedpacketService];
}

#pragma mark - HandleCmdMessage
- (void)didReceiveOfflineCmdMessages:(NSArray *)offlineCmdMessages
{
    /**
     *  收到红包被抢的
     */
    for (EMMessage *message in offlineCmdMessages) {
        EMCommandMessageBody * body = (EMCommandMessageBody *)message.messageBodies[0];
        if ([body.action isEqualToString:RedpacketKeyRedapcketCmd]) {
            [self handleCmdMessage:message];
        }
    }
}

-(void)didReceiveCmdMessage:(EMMessage *)message
{
    /**
     *  收到红包被抢的
     */
    EMCommandMessageBody * body = (EMCommandMessageBody *)message.messageBodies[0];
    
    if ([body.action isEqualToString:RedpacketKeyRedapcketCmd]) {
        [self handleCmdMessage:message];
    }
}

- (void)handleCmdMessage:(EMMessage *)message
{
    /**
     *  当前用户的用户ID
     */
    NSString *currentUserId = [[[[EaseMob sharedInstance] chatManager] loginInfo] objectForKey:kSDKUsername];
    NSString *senderId = message.ext[RedpacketKeyRedpacketSenderId];
    /**
     *  为了兼容老版本传过来的Cmd消息，必须做一下判断
     */
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
    
    /**
     *  插入数据库，并更新当前聊天界面
     */
    [[EaseMob sharedInstance].chatManager insertMessagesToDB:@[redpacketGroupMessage] forChatter:conversationId append2Chat:YES];
}

/*-------为了兼容红包2.0版本--------*/

- (void)didReceiveMessage:(EMMessage *)message
{
    if ([RedpacketMessageModel isRedpacketTakenMessage:message.ext] &&
        message.messageType == eMessageTypeChat) {
        for (id body in message.messageBodies) {
            if ([body isKindOfClass:[EMTextMessageBody class]]) {
                EMTextMessageBody *textBody = (EMTextMessageBody *)body;
                NSDictionary *dict = message.ext;
                NSString *receiver = [dict valueForKey:RedpacketKeyRedpacketReceiverNickname];
                if (receiver.length == 0) {
                    receiver = [dict valueForKey:RedpacketKeyRedpacketReceiverId];
                }
                textBody.text = [NSString stringWithFormat:@"%@领取了你的红包", receiver];;
                [message updateMessageBodiesToDB];
                return;
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
        text = [NSString stringWithFormat:@"你领取了%@的红包", sender];
    }else {
        NSString *receiver = [dict valueForKey:RedpacketKeyRedpacketReceiverNickname];
        if (receiver.length == 0) {
            receiver = [dict valueForKey:RedpacketKeyRedpacketReceiverId];
        }
        text = [NSString stringWithFormat:@"%@领取了你的红包", receiver];
    }
    
    return text;
}

/*--------兼容结束-----------------*/

@end
