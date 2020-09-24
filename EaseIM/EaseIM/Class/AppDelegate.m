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

#import "EaseIMHelper.h"
#import "SingleCallController.h"
#import "ConferenceController.h"

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

- (void)applicationWillTerminate:(UIApplication *)application
{
    //单人通话中（非群组会议）
    if (gIsCalling && !gIsConferenceCalling) {
        EMCallEndReason reason = EMCallEndReasonFailed;
        if (![SingleCallController.sharedManager.callDirection isEqualToString:EMCOMMUNICATE_DIRECTION_CALLINGPARTY])
            reason = EMCallEndReasonHangup;
        [[EMClient sharedClient].callManager endCall:SingleCallController.sharedManager.chatter reason:reason];
        /*
        //主叫方发送通话信息
        if ([SingleCallController.sharedManager.callDirection isEqualToString:EMCOMMUNICATE_DIRECTION_CALLINGPARTY]) {
            EMTextMessageBody *body;
            if (SingleCallController.sharedManager.callDurationTime) {
                body = [[EMTextMessageBody alloc] initWithText:[NSString stringWithFormat:@"通话时长 %@",SingleCallController.sharedManager.callDurationTime]];
            } else {
                body = [[EMTextMessageBody alloc] initWithText:EMCOMMUNICATE_CALLER_MISSEDCALL];
            }
            NSString *callType;
            if (SingleCallController.sharedManager.type == EMCallTypeVoice)
                callType = EMCOMMUNICATE_TYPE_VOICE;
            if (SingleCallController.sharedManager.type == EMCallTypeVideo)
                callType = EMCOMMUNICATE_TYPE_VIDEO;
            NSDictionary *iOSExt = @{@"em_apns_ext":@{@"need-delete-content-id":@"communicate",@"em_push_content":@"有一条通话记录待查看", @"em_push_sound":@"ring.caf", @"em_push_mutable_content":@YES}, @"em_force_notification":@YES, EMCOMMUNICATE_TYPE:callType};
            NSDictionary *androidExt = @{@"em_push_ext":@{@"type":@"call"}, @"em_android_push_ext":@{@"em_push_sound":@"/raw/ring", @"em_push_channel_id":@"hyphenate_offline_push_notification"}};
            NSMutableDictionary *pushExt = [[NSMutableDictionary alloc]initWithDictionary:iOSExt];
            [pushExt addEntriesFromDictionary:androidExt];
            NSString *to = SingleCallController.sharedManager.chatter;
            EMMessage *message = [[EMMessage alloc] initWithConversationID:to from:[[EMClient sharedClient] currentUsername] to:to body:body ext:pushExt];
            message.chatType = EMChatTypeChat;
            [[EMClient sharedClient].chatManager sendMessage:message progress:nil completion:nil];
        }*/
        
        EMTextMessageBody *body;
        if (SingleCallController.sharedManager.callDurationTime) {
            body = [[EMTextMessageBody alloc] initWithText:[NSString stringWithFormat:@"通话时长 %@",SingleCallController.sharedManager.callDurationTime]];
        } else {
            body = [[EMTextMessageBody alloc] initWithText:EMCOMMUNICATE_CALLER_MISSEDCALL];
        }
        NSString *callType;
        if (SingleCallController.sharedManager.type == EMCallTypeVoice)
            callType = EMCOMMUNICATE_TYPE_VOICE;
        if (SingleCallController.sharedManager.type == EMCallTypeVideo)
            callType = EMCOMMUNICATE_TYPE_VIDEO;
        NSDictionary *ext = @{EMCOMMUNICATE_TYPE:callType};
        NSString *from, *to;
        if ([SingleCallController.sharedManager.callDirection isEqualToString:EMCOMMUNICATE_DIRECTION_CALLINGPARTY]) {
            from = [[EMClient sharedClient] currentUsername];
            to = SingleCallController.sharedManager.chatter;
        } else {
            from = SingleCallController.sharedManager.chatter;
            to = [[EMClient sharedClient] currentUsername];
        }
        EMMessage *message = [[EMMessage alloc] initWithConversationID:SingleCallController.sharedManager.chatter from:from to:to body:body ext:ext];
        message.direction = [from isEqualToString:[[EMClient sharedClient] currentUsername]] ? EMMessageDirectionSend : EMMessageDirectionReceive;
        message.chatType = EMChatTypeChat;
        EMConversation *conversation = [[EMClient sharedClient].chatManager getConversation:SingleCallController.sharedManager.chatter type:EMConversationTypeChat createIfNotExist:YES];
        [conversation appendMessage:message error:nil];
    }
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
        [[NSNotificationCenter defaultCenter] postNotificationName:ACCOUNT_LOGIN_CHANGED object:@(YES)];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:ACCOUNT_LOGIN_CHANGED object:@(NO)];
    }
}

#pragma mark - Demo

- (void)_initDemo
{
    //注册登录状态监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginStateChange:) name:ACCOUNT_LOGIN_CHANGED object:nil];
    
    //注册推送
    [self _registerRemoteNotification];
}

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

- (void)loginStateChange:(NSNotification *)aNotif
{
    UINavigationController *navigationController = nil;
    
    BOOL loginSuccess = [aNotif.object boolValue];
    if (loginSuccess) {//登录成功加载主窗口控制器
        navigationController = (UINavigationController *)self.window.rootViewController;
        if (!navigationController || (navigationController && ![navigationController.viewControllers[0] isKindOfClass:[EMHomeViewController class]])) {
            EMHomeViewController *homeController = [[EMHomeViewController alloc] init];
            navigationController = [[UINavigationController alloc] initWithRootViewController:homeController];
        }
        
        [[EMClient sharedClient] getPushNotificationOptionsFromServerWithCompletion:^(EMPushOptions *aOptions, EMError *aError) {}];
        [EaseIMHelper shareHelper];
        [EMNotificationHelper shared];
        [SingleCallController sharedManager];
        [ConferenceController sharedManager];
    } else {//登录失败加载登录页面控制器
        EMLoginViewController *controller = [[EMLoginViewController alloc] init];
        navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    }
    
//    navigationController.navigationBar.barStyle = UIBarStyleDefault;
    [navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navbar_white"] forBarMetrics:UIBarMetricsDefault];
    [navigationController.navigationBar.layer setMasksToBounds:YES];
    navigationController.view.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = navigationController;
    
    [[UINavigationBar appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor], NSForegroundColorAttributeName, [UIFont systemFontOfSize:18], NSFontAttributeName, nil]];
    [[UITableViewHeaderFooterView appearance] setTintColor:kColor_LightGray];
    
//    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
//    if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
//        statusBar.backgroundColor = [UIColor whiteColor];
//    }
}

@end
