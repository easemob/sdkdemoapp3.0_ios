//
//  YZHUserConfig.h
//  ChatDemo-UI3.0
//
//  Created by Mr.Yang on 16/3/8.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  @description: 红包用户配置服务
 *  1.获取当前用户的信息
 *  2.注册红包服务
 *  3.检测用户登陆状态
 */

@interface RedPacketUserConfig : NSObject

+ (RedPacketUserConfig *)sharedConfig;

/**
 *  配置环信IM分配的AppKey
 *
 *  @param appKey 环信IM分配的AppKey
 */
- (void)configWithAppKey:(NSString *)appKey;

- (void)configWithImUserId:(NSString *)imUserId andImUserPass:(NSString *)imUserPass;

@end
