/************************************************************
 *  * EaseMob CONFIDENTIAL
 * __________________
 * Copyright (C) 2013-2014 EaseMob Technologies. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of EaseMob Technologies.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from EaseMob Technologies.
 */

#import "AppDelegate.h"
#import "MainViewController.h"
#import "LoginViewController.h"

#import "AppDelegate+EaseMob.h"
#import "AppDelegate+UMeng.h"
#import "AppDelegate+Parse.h"


@interface AppDelegate ()

@end


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    _connectionState = EMConnectionConnected;
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    if ([UIDevice currentDevice].systemVersion.floatValue >= 7.0) {
        [[UINavigationBar appearance] setBarTintColor:RGBACOLOR(30, 167, 252, 1)];
        [[UINavigationBar appearance] setTitleTextAttributes:
         [NSDictionary dictionaryWithObjectsAndKeys:RGBACOLOR(245, 245, 245, 1), NSForegroundColorAttributeName, [UIFont fontWithName:@ "HelveticaNeue-CondensedBlack" size:21.0], NSFontAttributeName, nil]];
    }
    
    // 环信UIdemo中有用到友盟统计crash，您的项目中不需要添加，可忽略此处。
    [self setupUMeng];
    
    // 环信UIdemo中有用到Parse，您的项目中不需要添加，可忽略此处。
    [self parseApplication:application didFinishLaunchingWithOptions:launchOptions];
    
#warning 初始化环信SDK，详细内容在AppDelegate+EaseMob.m 文件中
#warning SDK注册 APNS文件的名字, 需要与后台上传证书时的名字一一对应
    NSString *apnsCertName = nil;
#if DEBUG
    apnsCertName = @"chatdemoui_dev";
#else
    apnsCertName = @"chatdemoui";
#endif
    [self easemobApplication:application
didFinishLaunchingWithOptions:launchOptions
                      appkey:@"easemob-demo#chatdemoui"
                apnsCertName:apnsCertName
                 otherConfig:@{kSDKConfigEnableConsoleLogger:[NSNumber numberWithBool:YES]}];

    [self.window makeKeyAndVisible];
    return YES;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    if (_mainController) {
        [_mainController jumpToChatList];
    }
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    if (_mainController) {
        [_mainController didReceiveLocalNotification:notification];
    }
}
@end
