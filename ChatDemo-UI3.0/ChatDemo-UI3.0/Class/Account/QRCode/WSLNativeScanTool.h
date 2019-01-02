//
//  WSLNativeScanTool.h
//  ScanQRcode
//
//  Created by 王双龙 on 2018/1/30.
//  Copyright © 2018年 https://www.jianshu.com/u/e15d1f644bea All rights reserved.
//

@import UIKit;
@import AVFoundation;

#import <Foundation/Foundation.h>

/**
 扫描完成的回调
 @param scanString 扫描出的字符串
 */
typedef void(^WSLScanFinishedBlock)( NSString * _Nullable scanString);

/**
 监听环境光感的回调
 @param brightness 亮度值
 */
typedef void(^WSLMonitorLightBlock)( float brightness);

@interface WSLNativeScanTool : NSObject

/**
 扫描出结果后的回调 ，注意循环引用的问题
 */
@property (nonatomic, copy) WSLScanFinishedBlock _Nullable scanFinishedBlock;

/**
 监听环境光感的回调,如果 != nil 表示开启监测环境亮度功能
 */
@property (nonatomic, copy) WSLMonitorLightBlock _Nullable monitorLightBlock;

/**
 闪光灯的状态,不需要设置，仅供外边判断状态使用
 */
@property (nonatomic, assign) BOOL flashOpen;

/**
 初始化 扫描工具
 @param preview 展示输出流的视图
 @param scanFrame 扫描中心识别区域范围
 */
- (instancetype )initWithPreview:(UIView *)preview andScanFrame:(CGRect)scanFrame;

/**
 闪光灯开关
 */
- (void)openFlashSwitch:(BOOL)open;

- (void)sessionStartRunning;

- (void)sessionStopRunning;

/**
 识别图中二维码
 */
- (void)scanImageQRCode:(UIImage *_Nullable)imageCode;

/**
 生成自定义样式二维码
 注意：有些颜色结合生成的二维码识别不了
 @param codeString 字符串
 @param size 大小
 @param backColor 背景色
 @param frontColor 前景色
 @param centerImage 中心图片
 @return image二维码
 */
+ (UIImage *)createQRCodeImageWithString:(nonnull NSString *)codeString andSize:(CGSize)size andBackColor:(nullable UIColor *)backColor andFrontColor:(nullable UIColor *)frontColor andCenterImage:(nullable UIImage *)centerImage;

@end
