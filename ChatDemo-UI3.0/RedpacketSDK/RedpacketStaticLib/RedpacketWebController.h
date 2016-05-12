//
//  RedpacketWebControllerManager.h
//  RedpacketRequestDataLib
//
//  Created by Mr.Yang on 16/4/20.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface RedpacketWebController : NSObject

/**
 *  零钱明细的Web页面
 *
 *  @return WebController
 */
+ (UIViewController *)changeMoneyListWebController;

/**
 *  常见问题的Web页面
 *
 *  @return WebController
 */
+ (UIViewController *)myRechangeQaWebController;

/**
 *  用户服务务协议的Web页面
 *
 *  @return WebController
 */
+ (UIViewController *)bindCardProtocolController;

/**
 *  个人账户资金损失保险的Web页面
 *
 *  @return WebController
 */
+ (UIViewController *)guaranteeTaipingyangProtocol;
/**
 *  红包服务帮助文档
 *
 *  @return WebController
 */

+ (UIViewController *)helpWebController;



@end
