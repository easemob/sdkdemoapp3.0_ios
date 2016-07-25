//
//  RedpacketUserAccount.h
//  ChatDemo-UI3.0
//
//  Created by Mr.Yang on 16/3/1.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YZHRedpacketBridgeProtocol.h"



@interface YZHRedpacketBridge : NSObject

@property (nonatomic, weak) id <YZHRedpacketBridgeDelegate> delegate;

@property (nonatomic, weak) id <YZHRedpacketBridgeDataSource>dataSource;

/**
 *  商户名称
 */
@property (nonatomic, copy)  NSString *redpacketOrgName __attribute__((deprecated("方法已经停用，请通过云账户后端进行配置")));

/**
 *  支付宝回调当前APP时的URL Scheme, 应该传入当前App的Bundle Identifier
 */
@property (nonatomic, copy)  NSString *redacketURLScheme;

+ (YZHRedpacketBridge *)sharedBridge;

/**
 *  是否需要更新签名
 *  用户切换或者红包Token更新都需要更新Sign
 */
- (BOOL)isNeedUpdateSignWithUserId:(NSString *)userId;

/* 以下2种方法，根据IM选择其一 */

/**
 *  Method1:通过签名的方式获取Token (以下参数均需要由AppServer提供签名接口支持，签名方法见集成文档)
 *  此方法目前适应于：腾讯IM， 未适配的可联系我们
 *
 *  @param sign       签名接口返回参数
 *  @param partner    签名接口返回参数
 *  @param appUserid  签名接口返回参数 - 用户在App的用户ID
 *  @param timeStamp  签名接口返回参数 - 时间戳
 */
- (void)configWithSign:(NSString *)sign
               partner:(NSString *)partner
             appUserId:(NSString *)appUserid
             timeStamp:(long)timeStamp;

/**
 *  Method2: 通过环信imToken的方式获取Token
 *
 *  @param appKey    商户在环信申请的AppKey
 *  @param appUserId 用户在App的用户ID， 默认与imUserId相同
 *  @param imToken   环信IM的Token
 */
- (void)configWithAppKey:(NSString *)appKey
               appUserId:(NSString *)appUserId
                 imToken:(NSString *)imToken;

/**
 *  用户退出需要清空Token
 */
- (void)redpacketUserLoginOut __attribute__((deprecated("方法已经不需要调用, SDK根据用户变更和Token过期自动切换")));

/**
 *  请求Token
 *
 *  @param tokenRequestCompletionBlock 请求Token成功后的回调
 */
- (void)reRequestRedpacketUserToken:(void(^)(NSInteger code, NSString *msg))tokenRequestCompletionBlock;


@end
