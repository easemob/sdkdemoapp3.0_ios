//
//  AppDelegate+EaseMobDebug.h
//  ChatDemo-UI2.0
//
//  Created by dujiepeng on 15/7/1.
//  Copyright (c) 2015年 dujiepeng. All rights reserved.
//  测试用，开发者不需要使用此类

#import "AppDelegate.h"

@interface AppDelegate (EaseMobDebug)

/*!
 *  @brief 判断是否开启了测试模式，本类以及本方法开发者不需要集成使用，直接调用registerSDKWithAppKey:apnsCertName:otherConfig即可
 *  @return 返回结果
 *  @remark 本类以及本方法开发者不需要集成使用
 */
-(BOOL)isSpecifyServer;

@end
