//
//  YZHRedpacketBridgeProtocol.h
//  RedpacketLib
//
//  Created by Mr.Yang on 16/4/8.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#ifndef YZHRedpacketBridgeProtocol_h
#define YZHRedpacketBridgeProtocol_h

 /// 用通知减少耦合

@class RedpacketUserInfo;

@protocol YZHRedpacketBridgeDataSource <NSObject>

/**
 *  主动获取App用户的用户信息
 *
 *  @return 用户信息Info
 */
- (RedpacketUserInfo *)redpacketUserInfo;

@end


@protocol YZHRedpacketBridgeDelegate <NSObject>

/**
 *  Saas平台Token超时，需要重新注册Token
 *
 *  @param error 错误内容
 *  @param code  错误码
 */
- (void)redpacketError:(NSString *)error withErrorCode:(NSInteger)code;


@end


#endif /* YZHRedpacketBridgeProtocol_h */
