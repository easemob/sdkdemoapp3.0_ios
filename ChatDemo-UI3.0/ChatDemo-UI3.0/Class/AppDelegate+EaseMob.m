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

#import "AppDelegate+EaseMob.h"
#import "AppDelegate+EaseMobDebug.h"
#import "AppDelegate+Parse.h"

#import "LoginViewController.h"
#import "ChatDemoHelper.h"
#import "MBProgressHUD.h"

/**
 *  本类中做了EaseMob初始化和推送等操作
 */

@implementation AppDelegate (EaseMob)

- (void)easemobApplication:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
                    appkey:(NSString *)appkey
              apnsCertName:(NSString *)apnsCertName
               otherConfig:(NSDictionary *)otherConfig
{
    //注册登录状态监听
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loginStateChange:)
                                                 name:KNOTIFICATION_LOGINCHANGE
                                               object:nil];
    
    [[EaseSDKHelper shareHelper] easemobApplication:application
                    didFinishLaunchingWithOptions:launchOptions
                                           appkey:appkey
                                     apnsCertName:apnsCertName
                                      otherConfig:@{kSDKConfigEnableConsoleLogger:[NSNumber numberWithBool:YES],@"easeSandBox":[NSNumber numberWithBool:[self isSpecifyServer]]}];
    
    [ChatDemoHelper shareHelper];
    
    BOOL isAutoLogin = [EMClient sharedClient].isAutoLogin;
    if (isAutoLogin){
        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@YES];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@NO];
    }
}

#pragma mark - App Delegate

// 将得到的deviceToken传给SDK
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [[EMClient sharedClient] bindDeviceToken:deviceToken];
}

// 注册deviceToken失败，此处失败，与环信SDK无关，一般是您的环境配置或者证书配置有误
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"apns.failToRegisterApns", Fail to register apns)
                                                    message:error.description
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"ok", @"OK")
                                          otherButtonTitles:nil];
    [alert show];
}

#pragma mark - login changed

- (void)loginStateChange:(NSNotification *)notification
{
    BOOL loginSuccess = [notification.object boolValue];
    UINavigationController *navigationController = nil;
    if (loginSuccess) {//登陆成功加载主窗口控制器
        //加载申请通知的数据
        [[ApplyViewController shareController] loadDataSourceFromLocalDB];
        if (self.mainController == nil) {
            self.mainController = [[MainViewController alloc] init];
            navigationController = [[UINavigationController alloc] initWithRootViewController:self.mainController];
        }else{
            navigationController  = self.mainController.navigationController;
        }
        // 环信UIdemo中有用到Parse，您的项目中不需要添加，可忽略此处
        [self initParse];
        
        [ChatDemoHelper shareHelper].mainVC = self.mainController;
        
        [[ChatDemoHelper shareHelper] asyncGroupFromServer];
        [[ChatDemoHelper shareHelper] asyncConversationFromDB];
        [[ChatDemoHelper shareHelper] asyncPushOptions];
    }
    else{//登陆失败加载登陆页面控制器
        self.mainController = nil;
        [ChatDemoHelper shareHelper].mainVC = nil;
        
        LoginViewController *loginController = [[LoginViewController alloc] init];
        navigationController = [[UINavigationController alloc] initWithRootViewController:loginController];
        [self clearParse];
    }
    
    //设置7.0以下的导航栏
    if ([UIDevice currentDevice].systemVersion.floatValue < 7.0){
        navigationController.navigationBar.barStyle = UIBarStyleDefault;
        [navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"titleBar"]
                                                 forBarMetrics:UIBarMetricsDefault];
        [navigationController.navigationBar.layer setMasksToBounds:YES];
    }
    
    self.window.rootViewController = navigationController;
}

#pragma mark - EMPushManagerDelegateDevice

// 打印收到的apns信息
-(void)didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSError *parseError = nil;
    NSData  *jsonData = [NSJSONSerialization dataWithJSONObject:userInfo
                                                        options:NSJSONWritingPrettyPrinted error:&parseError];
    NSString *str =  [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"apns.content", @"Apns content")
                                                    message:str
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"ok", @"OK")
                                          otherButtonTitles:nil];
    [alert show];
    
}

@end
