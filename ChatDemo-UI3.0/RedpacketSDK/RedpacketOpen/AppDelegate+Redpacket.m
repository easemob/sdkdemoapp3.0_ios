//
//  AppDelegate+Redpacket.m
//  ChatDemo-UI3.0
//
//  Created by Mr.Yang on 2016/12/13.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "AppDelegate+Redpacket.h"
#import <objc/runtime.h>
#import "RedpacketOpenConst.h"
#import <AlipaySDK/AlipaySDK.h>

BOOL rp_classMethodSwizzle(Class aClass, SEL originalSelector, SEL swizzleSelector, SEL nopSelector) {
    
    Method originalMethod = class_getInstanceMethod(aClass, originalSelector);
    Method swizzleMethod = class_getInstanceMethod(aClass, swizzleSelector);
    
    BOOL didAddMethod = class_addMethod(aClass,
                                        originalSelector,
                                        method_getImplementation(swizzleMethod),
                                        method_getTypeEncoding(swizzleMethod));
    
    if (didAddMethod) {
        Method nopMehtod = class_getInstanceMethod(aClass, nopSelector);
        class_replaceMethod(aClass,
                            swizzleSelector,
                            method_getImplementation(nopMehtod),
                            method_getTypeEncoding(nopMehtod));
        
    } else {
        method_exchangeImplementations(originalMethod, swizzleMethod);
    }
    
    return YES;
}


@implementation AppDelegate (Redpacket)

+ (void)load
{
    rp_classMethodSwizzle([self class],
                          @selector(applicationDidBecomeActive:),
                          @selector(rp_applicationDidBecomeActive:),
                          @selector(rpNop_applicationDidBecomeActive:));
    
    rp_classMethodSwizzle([self class],
                          @selector(application:openURL:options:),
                          @selector(rp_application:openURL:options:),
                          @selector(rpNop_applicationDidBecomeActive:));
    
    rp_classMethodSwizzle([self class],
                          @selector(application:openURL:sourceApplication:annotation:),
                          @selector(rp_application:openURL:sourceApplication:annotation:),
                          @selector(rpNop_applicationDidBecomeActive:));
}

- (void)rpNop_applicationDidBecomeActive:(UIApplication *)application
{
    
}

- (void)rp_applicationDidBecomeActive:(UIApplication *)application
{
    [[NSNotificationCenter defaultCenter] postNotificationName:RedpacketCancelPayNotifaction object:nil];
    [self rp_applicationDidBecomeActive:application];
}

// iOS9.0之前的API接口
- (BOOL)rp_application:(UIApplication *)application
               openURL:(NSURL *)url
     sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    if ([url.host isEqualToString:@"safepay"]) {
        //  支付宝支付
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            [[NSNotificationCenter defaultCenter] postNotificationName:RedpacketAlipayNotifaction object:resultDic];
        }];
        
#ifdef AliAuthPay
        [[AlipaySDK defaultService] processAuthResult:url standbyCallback:^(NSDictionary *resultDic) {
            [[NSNotificationCenter defaultCenter] postNotificationName:RedpacketAliAuthNotifaction object:resultDic];
        }];
#endif

    }
    
#ifdef WeChatAvaliable
    else if ([url.host isEqualToString:@"pay"]) {
        //  微信支付
        [WXApi handleOpenURL:url delegate:self];
    }
#endif
    
    return [self rp_application:application
                               openURL:url
                     sourceApplication:sourceApplication
                            annotation:annotation];;
}

// iOS9.0之后的API接口
- (BOOL)rp_application:(UIApplication *)app
            openURL:(NSURL *)url
            options:(NSDictionary<NSString*, id> *)options
{
    
    if ([url.host isEqualToString:@"safepay"]) {
        //  支付宝支付
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            [[NSNotificationCenter defaultCenter] postNotificationName:RedpacketAlipayNotifaction object:resultDic];
        }];
        
#ifdef AliAuthPay
        [[AlipaySDK defaultService] processAuthResult:url standbyCallback:^(NSDictionary *resultDic) {
            [[NSNotificationCenter defaultCenter] postNotificationName:RedpacketAliAuthNotifaction object:resultDic];
        }];
#endif
        
    }

#ifdef WeChatAvaliable
    else if ([url.host isEqualToString:@"pay"]) {
        //  微信支付
        [WXApi handleOpenURL:url delegate:self];
    }
#endif
    
    return [self rp_application:app openURL:url options:options];
}

#ifdef WeChatAvaliable
//  微信支付回调
-(void)rp_onResp:(BaseResp*)resp{
    
    if ([resp isKindOfClass:[PayResp class]]){
        PayResp*response=(PayResp*)resp;
        switch(response.errCode){
            case WXSuccess:
                //  服务器端查询支付通知或查询API返回的结果再提示成功
                [[NSNotificationCenter defaultCenter] postNotificationName:RedpacketWechatPayNotifaction object:resp];
                break;
            default:
                //  微信支付失败
                [[NSNotificationCenter defaultCenter] postNotificationName:RedpacketCancelPayNotifaction object:nil];
                break;
        }
    }
}

#endif

@end
