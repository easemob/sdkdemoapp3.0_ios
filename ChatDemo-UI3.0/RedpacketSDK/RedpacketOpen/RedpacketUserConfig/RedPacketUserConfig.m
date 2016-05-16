//
//  YZHUserConfig.m
//  ChatDemo-UI3.0
//
//  Created by Mr.Yang on 16/3/8.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "RedPacketUserConfig.h"
#import "UserProfileManager.h"
#import "EaseMob.h"
#import "YZHRedpacketBridge.h"
#import "RedpacketMessageModel.h"



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
    NSString *nickname = entity.nickname;;
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

/**
 *  环信Token过期后的回调
 */
- (void)redpacketUserTokenGetInfoByMethod:(RequestTokenMethod)method
{
    //  刷新环信Token
    EaseMob *easemob = [EaseMob sharedInstance];
    EMError *error = nil;
    
    SEL selector = NSSelectorFromString(@"fetchTokenFromServer");
    IMP imp = [easemob methodForSelector:selector];
    EMError *(*func)(id, SEL) = (void *)imp;
    error = func(easemob, selector);
    
    if (!error) {
        [self configRedpacketService];
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

@end
