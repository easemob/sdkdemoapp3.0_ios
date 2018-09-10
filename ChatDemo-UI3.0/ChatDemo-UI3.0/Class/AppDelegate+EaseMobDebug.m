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

#import <Hyphenate/EMOptions+PrivateDeploy.h>

#warning Internal testing, developers do not need to use

@implementation AppDelegate (EaseMobDebug)

-(BOOL)isSpecifyServer
{
//    EMOptions *options0 = [EMOptions optionsWithAppkey:@"easemob-demo#chatdemoui"];
//
//    options0.enableDnsConfig = NO;
//    options0.chatPort = 6717;
//    options0.chatServer = @"39.96.116.29";
//    options0.restServer = @"39.96.116.29:8080";
//
//    options0.apnsCertName = @"chatdemoui_dev";
//    options0.enableConsoleLog = YES;
//
//    [[EMClient sharedClient] initializeSDKWithOptions:options0];
//
//
//    return YES;
    

    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    NSNumber *specifyServer = [ud objectForKey:@"identifier_specifyserver"];
    if (![specifyServer boolValue]) {
        return NO;
    }
    
    NSString *apnsCertName = [ud stringForKey:@"identifier_apnsname"];
    if ([apnsCertName length] == 0) {
#if DEBUG
        apnsCertName = @"chatdemoui_dev";
#else
        apnsCertName = @"chatdemoui";
#endif
        [ud setObject:apnsCertName forKey:@"identifier_apnsname"];
    }
    
    NSString *appkey = [ud stringForKey:@"identifier_appkey"];
    if ([appkey length] == 0)
    {
        appkey = @"easemob-demo#chatdemoui";
        [ud setObject:appkey forKey:@"identifier_appkey"];
    }
    
    NSString *imServer = [ud stringForKey:@"identifier_imserver"];
    if ([imServer length] == 0)
    {
        imServer = @"msync-im1.sandbox.easemob.com";
        [ud setObject:imServer forKey:@"identifier_imserver"];
    }
    
    NSString *imPort = [ud stringForKey:@"identifier_import"];
    if ([imPort length] == 0)
    {
        imPort = @"6717";
        [ud setObject:imPort forKey:@"identifier_import"];
    }
    
    NSString *restServer = [ud stringForKey:@"identifier_restserver"];
    if ([restServer length] == 0)
    {
        restServer = @"a1.sdb.easemob.com";
        [ud setObject:restServer forKey:@"identifier_restserver"];
    }
    
    BOOL isHttpsOnly = NO;
    NSNumber *httpsOnly = [ud objectForKey:@"identifier_httpsonly"];
    if (httpsOnly) {
        isHttpsOnly = [httpsOnly boolValue];
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
    options.apnsCertName = @"chatdemoui_dev";
    options.enableConsoleLog = YES;
    options.usingHttpsOnly = isHttpsOnly;
    
    [[EMClient sharedClient] initializeSDKWithOptions:options];
    
    return YES;
}

@end
