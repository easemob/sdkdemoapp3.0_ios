//
//  YZHUserConfig.m
//  ChatDemo-UI3.0
//
//  Created by Mr.Yang on 16/3/8.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "RedPacketUserConfig.h"
#import "UserProfileManager.h"
#import "YZHRedpacketBridge.h"
#import "RedpacketMessageModel.h"



static RedPacketUserConfig *__sharedConfig__ = nil;

@interface RedPacketUserConfig () <EMClientDelegate,
                                    YZHRedpacketBridgeDataSource,
                                    YZHRedpacketBridgeDelegate>
{
    NSString *_dealerAppKey;
    
    NSString *_imUserId;
    NSString *_imUserPass;
    /**
     *  环信登陆用户名
     */
    NSString *_imUserName;
}

@end

@implementation RedPacketUserConfig

- (void)beginObserve
{
    //  登录代理
    [[EMClient sharedClient] addDelegate:self delegateQueue:nil];
    //  如果接入的用户有通知，则接收通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLoginChanged:) name:KNOTIFICATION_LOGINCHANGE object:nil];
}

- (void)removeObserver
{
    [[EMClient sharedClient] removeDelegate:self];
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
    }
    
    return self;
}

- (void)configWithAppKey:(NSString *)appKey
{
    _dealerAppKey = appKey;
}


- (void)configWithImUserId:(NSString *)imUserId andImUserPass:(NSString *)imUserPass
{
    [self beginObserve];
    
    NSAssert(imUserId.length > 0, @"IM平台：用户登录id为空");
    NSAssert(imUserPass.length > 0, @"IM平台：用户密码为空");
    
    _imUserId = imUserId;
    _imUserPass = imUserPass;
    
    NSString *userId = self.redpacketUserInfo.userId;
    
    [[YZHRedpacketBridge sharedBridge] configWithAppKey:_dealerAppKey
                                              appUserId:userId
                                               imUserId:userId
                                          andImUserpass:_imUserPass];
}

#pragma mark - YZHRedpacketBridgeDataSource

/**
 *  获取当前用户登陆信息，YZHRedpacketBridgeDataSource
 */
- (RedpacketUserInfo *)redpacketUserInfo
{
    RedpacketUserInfo *userInfo = [RedpacketUserInfo new];
    userInfo.userId = [EMClient sharedClient].currentUsername;
    
    UserProfileEntity *entity = [[UserProfileManager sharedInstance] getCurUserProfile];
    NSString *nickname = entity.nickname;
    userInfo.userNickname = nickname.length > 0 ? nickname : userInfo.userId;
    userInfo.userAvatar = entity.imageUrl;;
    
    return userInfo;
}

//  配置红包相关的服务
- (void)configRedpacketService
{
    
}

#pragma mark - YZHRedpacketBridgeDelegate

/**
 *  环信Token过期后的回调
 */
- (void)redpacketUserTokenGetInfoByMethod:(RequestTokenMethod)method
{
    //  刷新环信Token

}

#pragma mark - IChatManagerDelegate

//  监测用户登录状态
- (void)userLoginChanged:(NSNotification *)notifaction
{
    BOOL isLoginSuccess = [[notifaction object] boolValue];
    if (isLoginSuccess) {
        
        NSString *userId = self.redpacketUserInfo.userId;
        [[YZHRedpacketBridge sharedBridge] configWithAppKey:_dealerAppKey
                                                  appUserId:userId
                                                   imUserId:userId
                                              andImUserpass:_imUserPass];
    }else  {
        //  用户退出，清除数据
        [self clearUserInfo];
    }
}

- (void)didLoginFromOtherDevice
{
    [self clearUserInfo];
}

- (void)clearUserInfo
{
    [[YZHRedpacketBridge sharedBridge] redpacketUserLoginOut];
    _imUserId = nil;
}


@end
