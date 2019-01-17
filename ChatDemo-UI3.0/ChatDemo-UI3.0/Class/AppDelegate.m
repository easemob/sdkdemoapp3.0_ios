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

#import <UserNotifications/UserNotifications.h>
#import "AppDelegate.h"

#import <Bugly/Bugly.h>

#import "ChatDemoHelper.h"
#if DEMO_CALL == 1
#import "DemoCallManager.h"
#endif

#import "EMGlobalVariables.h"
#import "EMDemoOptions.h"

#import "EMHomeViewController.h"
#import "EMLoginViewController.h"

@interface AppDelegate () <UNUserNotificationCenterDelegate>

@end


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    _connectionState = EMConnectionConnected;
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    [self _initDemo];
    [self _initHyphenate];

    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[EMClient sharedClient] applicationDidEnterBackground:application];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [[EMClient sharedClient] applicationWillEnterForeground:application];
}

// 将得到的deviceToken传给SDK
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[EMClient sharedClient] bindDeviceToken:deviceToken];
    });
}

// 注册deviceToken失败，此处失败，与环信SDK无关，一般是您的环境配置或者证书配置有误
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"注册device token失败" message:error.description delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alert show];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
//    if (gMainController) {
//        [gMainController jumpToChatList];
//    }
    
    [[EMClient sharedClient] application:application didReceiveRemoteNotification:userInfo];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
//    if (gMainController) {
//        [gMainController didReceiveLocalNotification:notification];
//    }
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler
{
    NSDictionary *userInfo = notification.request.content.userInfo;
    [[EMClient sharedClient] application:[UIApplication sharedApplication] didReceiveRemoteNotification:userInfo];
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler
{
//    if (gMainController) {
//        [gMainController didReceiveUserNotification:response.notification];
//    }
    completionHandler();
}

#pragma mark - EMPushManagerDelegateDevice

// 打印收到的apns信息
-(void)didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:userInfo options:NSJSONWritingPrettyPrinted error:&parseError];
    NSString *str = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"推送内容" message:str delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alert show];
    
}

#pragma mark - Hyphenate

- (void)_initHyphenate
{
    EMDemoOptions *demoOptions = [EMDemoOptions sharedOptions];
    if (demoOptions.isAutoLogin){
        gIsInitializedSDK = YES;
        [[EMClient sharedClient] initializeSDKWithOptions:[demoOptions toOptions]];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@(YES)];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@(NO)];
    }
}

#pragma mark - Demo

//注册远程通知
- (void)_registerRemoteNotification
{
    UIApplication *application = [UIApplication sharedApplication];
    application.applicationIconBadgeNumber = 0;
    
    if (NSClassFromString(@"UNUserNotificationCenter")) {
        [UNUserNotificationCenter currentNotificationCenter].delegate = self;
        
        [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert completionHandler:^(BOOL granted, NSError *error) {
            if (granted) {
#if !TARGET_IPHONE_SIMULATOR
                dispatch_async(dispatch_get_main_queue(), ^{
                    [application registerForRemoteNotifications];
                });
#endif
            }
        }];
        return;
    }
    
    if([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationType notificationTypes = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:notificationTypes categories:nil];
        [application registerUserNotificationSettings:settings];
    }
    
#if !TARGET_IPHONE_SIMULATOR
    if ([application respondsToSelector:@selector(registerForRemoteNotifications)]) {
        [application registerForRemoteNotifications];
    } else {
        UIRemoteNotificationType notificationTypes = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert;
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:notificationTypes];
    }
#endif
}

- (void)_initDemo
{
#ifdef DEBUG
#else
    //环信Demo中使用Bugly收集crash信息，没有使用cocoapods,库存放在ChatDemo-UI3.0/ChatDemo-UI3.0/3rdparty/Bugly.framework，可自行删除
    //如果你自己的项目也要使用bugly，请按照bugly官方教程自行配置
    [Bugly startWithAppId:nil];
#endif
    
    //注册登录状态监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginStateChange:) name:KNOTIFICATION_LOGINCHANGE object:nil];
    
    //注册推送
    [self _registerRemoteNotification];
    
#if DEMO_CALL == 1
    [DemoCallManager sharedManager];
#endif
}

- (void)loginStateChange:(NSNotification *)aNotif
{
    UINavigationController *navigationController = nil;
    
    BOOL loginSuccess = [aNotif.object boolValue];
    if (loginSuccess) {//登录成功加载主窗口控制器
        navigationController = (UINavigationController *)self.window.rootViewController;
        if (!navigationController || (navigationController && ![navigationController.viewControllers[0] isKindOfClass:[EMHomeViewController class]])) {
            EMHomeViewController *homeController = [[EMHomeViewController alloc] init];
            gHomeController = homeController;
            navigationController = [[UINavigationController alloc] initWithRootViewController:homeController];
        }
        ChatDemoHelper *demoHelper = [ChatDemoHelper shareHelper];
        [demoHelper asyncGroupFromServer];
        [demoHelper asyncConversationFromDB];
        [demoHelper asyncPushOptions];
    } else {//登录失败加载登录页面控制器
        gHomeController = nil;
        
        EMLoginViewController *controller = [[EMLoginViewController alloc] init];
        navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
        
        [[UINavigationBar appearance] setTitleTextAttributes:
         [NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor], NSForegroundColorAttributeName, [UIFont systemFontOfSize:18], NSFontAttributeName, nil]];
    }
    
    self.window.rootViewController = navigationController;
}

@end
