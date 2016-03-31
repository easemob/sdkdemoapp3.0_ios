/************************************************************
 *  * Hyphenate CONFIDENTIAL
 * __________________
 * Copyright (C) 2016 Hyphenate Technologies. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Technologies.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Hyphenate Technologies.
 */

#import "AppDelegate.h"

@interface AppDelegate (EaseMobDebug)

/*!
 *  @brief 判断是否开启了测试模式，本类以及本方法开发者不需要集成使用，直接调用registerSDKWithAppKey:apnsCertName:otherConfig即可
 *  @return 返回结果
 *  @remark 本类以及本方法开发者不需要集成使用
 */
-(BOOL)isSpecifyServer;

@end
