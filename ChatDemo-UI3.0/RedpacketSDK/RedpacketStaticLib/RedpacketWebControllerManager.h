//
//  RedpacketWebControllerManager.h
//  RedpacketRequestDataLib
//
//  Created by Mr.Yang on 16/4/20.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void(^RedpacketSendLuckMoneySuccess)(NSDictionary * dict);

@interface RedpacketWebControllerManager : NSObject


/**
 *  零钱的Web页面
 *
 *  @return WebController
 */
+ (UIViewController *)changeMoneyWebController;

/**
 *  零钱明细的Web页面
 *
 *  @return WebController
 */
+ (UIViewController *)changeMoneyListWebController;

/**
 *  找回密码
 */
+ (UIViewController *)forgetPassWebController;

/**
 *  京东支付
 *
 *  @param money        需要付的款项
 *  @param successBlock 成功后的回调
 *
 *  @return 京东支付控制器
 */
+ (UIViewController *)jdPayWebControllerWithMoney:(NSString *)money
                                  andSuccessBlock:(RedpacketSendLuckMoneySuccess)successBlock;


+ (UIViewController *)bindCardWebController;


+ (UIViewController *)settingPayPassWebController;

+ (UIViewController *)helpWebController;



@end
