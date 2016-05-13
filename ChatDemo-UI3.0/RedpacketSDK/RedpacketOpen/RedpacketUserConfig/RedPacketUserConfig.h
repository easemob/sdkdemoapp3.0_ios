//
//  YZHUserConfig.h
//  ChatDemo-UI3.0
//
//  Created by Mr.Yang on 16/3/8.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  红包用户信息-配置类-依赖于环信当前登陆用户（EMClient），和环信UserProfileManager中的数据,
 *  如果第三方App不依赖环信的这些数据，请自行修改此类中的相关代码
 */

@interface RedPacketUserConfig : NSObject

+ (RedPacketUserConfig *)sharedConfig;

/**
 *  配置环信IM分配的AppKey
 *
 *  @param appKey 环信IM分配的AppKey
 */
- (void)configWithAppKey:(NSString *)appKey;

@end
