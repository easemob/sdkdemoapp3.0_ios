//
//  RedpacketStatistics.h
//  RedpacketRequestDataLib
//
//  Created by Mr.Yang on 16/4/20.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  数据统计 rs 表示 redpacketStatistics
 */

@interface RedpacketStatisticsManager : NSObject


/**
 *  我的红包记录详情页
 */
+ (void)rs_inComeMoneyDetailPage;

/**
 *  我收到的红包历史
 */
+ (void)rs_inComeMoneyHistory;

/**
 *  收红包 是否成功标记
 *
 *  @param code 成功标记
 */
+ (void)rs_receiveMoneySatatusWithCode:(NSInteger)code;

/**
 *  接收红包
 */
+ (void)rs_receiveMoneyattempted;

/**
 *  抢红包按钮
 */
+ (void)rs_redpacketGrabButtonClick;

/**
 *  抢红包页面
 */
+ (void)rs_redpacketGrabView;

/**
 *  发送红包页面
 */
+ (void)rs_redpacketSendRedpacketView;

/**
 *  塞钱进红包
 */
+ (void)rs_putMoneyIntoRedpacketButtonClick;

/**
 *  京东付款页面
 */
+ (void)rs_jdPayWebView;

/**
 *  发送红包成功
 */
+ (void)rs_sendRedpacketSuccess;

/**
 *  支付页面
 */
+ (void)rs_payView;

/**
 *  京东支付方式
 */
+ (void)rs_redpacketPayByJD;

/**
 *  零钱支付方式
 */
+ (void)rs_redpacketPayByLQ;

/**
 *  选择支付页面
 */
+ (void)rs_payTypeSelectView;

/**
 *  发送红包失败
 */
+ (void)rs_sendRedpacketFailInCode:(NSInteger)code;


@end
