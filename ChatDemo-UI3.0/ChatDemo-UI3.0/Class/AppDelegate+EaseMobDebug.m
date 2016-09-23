/************************************************************
 *  * Hyphenate CONFIDENTIAL
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Hyphenate Inc.
 */

#import "AppDelegate+EaseMobDebug.h"

#import "EMOptions+PrivateDeploy.h"

#warning 环信内部测试用，开发者不需要使用此类

@implementation AppDelegate (EaseMobDebug)

-(BOOL)isSpecifyServer{
////    EMOptions *options = [EMOptions optionsWithAppkey:@"easemob-demo#chatdemoui"];
////    options.chatPort = 6720;
////    options.chatServer = @"121.41.75.10";
////    options.restServer = @"121.41.87.159:8010";
////    options.apnsCertName = @"chatdemoui_dev";
//    
//    //1v1新版普通 沙箱
////    EMOptions *options = [EMOptions optionsWithAppkey:@"easemob-demo#chatdemoui"];
////    options.chatPort = 6717;
////    options.chatServer = @"120.26.12.158";
////    options.restServer = @"a1.sdb.easemob.com";
////    options.apnsCertName = @"sdbmormal_dev1";
//    
//    //1v1新版普通转会议/1v1新旧版互通 沙箱
//    EMOptions *options = [EMOptions optionsWithAppkey:@"easemob-demo#1212"];
//    options.chatPort = 6717;
//    options.chatServer = @"120.26.12.158";
//    options.restServer = @"a1.sdb.easemob.com";
//    
//    //yss test
////    EMOptions *options = [EMOptions optionsWithAppkey:@"easemob-demo#chatdemoui"];
////    options.chatPort = 6720;
////    options.chatServer = @"121.41.75.10";
////    options.restServer = @"121.41.87.159:8010";
//    
//    options.enableConsoleLog = YES;
//    options.enableDnsConfig = NO;
//    
//    [[EMClient sharedClient] initializeSDKWithOptions:options];
//    
//    return YES;
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    NSNumber *specifyServer = [ud objectForKey:@"identifier_enable"];
    if ([specifyServer boolValue]) {
        NSString *apnsCertName = nil;
#if DEBUG
        apnsCertName = @"chatdemoui_dev";
#else
        apnsCertName = @"chatdemoui";
#endif
        NSString *appkey = [ud stringForKey:@"identifier_appkey"];
        if (!appkey)
        {
            appkey = @"easemob-demo#no1";
            [ud setObject:appkey forKey:@"identifier_appkey"];
        }
        NSString *imServer = [ud stringForKey:@"identifier_imserver"];
        if (!imServer)
        {
            imServer = @"120.26.12.158";
            [ud setObject:imServer forKey:@"identifier_imserver"];
        }
        NSString *imPort = [ud stringForKey:@"identifier_import"];
        if (!imPort)
        {
            imPort = @"6717";
            [ud setObject:imPort forKey:@"identifier_import"];
        }
        NSString *restServer = [ud stringForKey:@"identifier_restserver"];
        if (!restServer)
        {
            restServer = @"42.121.255.137";
            [ud setObject:restServer forKey:@"identifier_restserver"];
        }
        [ud synchronize];
        
        EMOptions *options = [EMOptions optionsWithAppkey:appkey];
        if (![ud boolForKey:@"enable_dns"])
        {
            options.enableDnsConfig = NO;
            options.chatPort = [[ud stringForKey:@"identifier_import"] intValue];
            options.chatServer = [ud stringForKey:@"identifier_imserver"];
            options.restServer = [ud stringForKey:@"identifier_restserver"];
        }
        //    EMOptions *options = [EMOptions optionsWithAppkey:@"easemob-demo#chatdemoui"];
        options.apnsCertName = @"chatdemoui_dev";
        options.enableConsoleLog = YES;
        
        [[EMClient sharedClient] initializeSDKWithOptions:options];
        return YES;
    }
    
    return NO;
}
@end
