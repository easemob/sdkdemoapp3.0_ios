//
//  HomeViewController.m
//  ChatDemo-UI3.0
//
//  Created by dhc on 15/6/24.
//  Copyright (c) 2015年 easemob.com. All rights reserved.
//

#import "HomeViewController.h"

#import "ConversationListController.h"
#import "ContactListViewController.h"
#import "SettingViewController.h"
//#import <EaseUI/EMCallViewController.h>
#import "ChatViewController.h"

@interface HomeViewController ()<IChatManagerDelegate, EMCallManagerDelegate>

@property (strong, nonatomic) ConversationListController *conversationController;
@property (strong, nonatomic) ContactListViewController *contactController;
@property (strong, nonatomic) SettingViewController *settingController;

@property (nonatomic) NSInteger selectedControllerIndex;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if ([UIDevice currentDevice].systemVersion.floatValue >= 7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
#warning 把self注册为SDK的delegate
    [self _registerEasemobDelegate];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(callOutWithChatter:) name:KNOTIFICATION_CALL object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(callControllerClose:) name:KNOTIFICATION_CALL_CLOSE object:nil];
    
    self.selectedControllerIndex = 0;
    [self _setupChildController];
    [self setupUnreadMessageCount];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    _settingController = nil;
    
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self  _unregisterEasemobDelegate];
}

#pragma mark - private

- (void)_registerEasemobDelegate
{
    [self _unregisterEasemobDelegate];
    
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
    [[EaseMob sharedInstance].callManager addDelegate:self delegateQueue:nil];
}

-(void)_unregisterEasemobDelegate
{
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
    [[EaseMob sharedInstance].callManager removeDelegate:self];
}

// 统计未读消息数
-(void)setupUnreadMessageCount
{
    NSArray *conversations = [[[EaseMob sharedInstance] chatManager] conversations];
    NSInteger unreadCount = 0;
    for (EMConversation *conversation in conversations) {
        unreadCount += conversation.unreadMessagesCount;
    }
    if (_conversationController) {
        if (unreadCount > 0) {
            _conversationController.tabBarItem.badgeValue = [NSString stringWithFormat:@"%i",(int)unreadCount];
        }else{
            _conversationController.tabBarItem.badgeValue = nil;
        }
    }
    
    UIApplication *application = [UIApplication sharedApplication];
    [application setApplicationIconBadgeNumber:unreadCount];
}


#pragma mark - private layout subviews

-(void)_unSelectedTapTabBarItems:(UITabBarItem *)tabBarItem
{
    [tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                        [UIFont systemFontOfSize:14], UITextAttributeFont,[UIColor whiteColor],UITextAttributeTextColor,
                                        nil] forState:UIControlStateNormal];
}

-(void)_selectedTapTabBarItems:(UITabBarItem *)tabBarItem
{
    [tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                        [UIFont systemFontOfSize:14],
                                        UITextAttributeFont, [UIColor colorWithRed:0 green:172 / 255.0 blue:255 / 255.0 alpha:1.0], UITextAttributeTextColor,
                                        nil] forState:UIControlStateSelected];
}

- (void)_setupChildController
{
    self.tabBar.backgroundImage = [[UIImage imageNamed:@"tabbarBackground"] stretchableImageWithLeftCapWidth:25 topCapHeight:25];
    self.tabBar.selectionIndicatorImage = [[UIImage imageNamed:@"tabbarSelectBg"] stretchableImageWithLeftCapWidth:25 topCapHeight:25];
    
    //conversation controller
    self.conversationController = [[ConversationListController alloc] init];
    self.conversationController.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"title.conversation", @"Conversations")
                                                           image:nil
                                                             tag:0];
    [self.conversationController.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"tabbar_chatsHL"]
                         withFinishedUnselectedImage:[UIImage imageNamed:@"tabbar_chats"]];
    [self _unSelectedTapTabBarItems:self.conversationController.tabBarItem];
    [self _selectedTapTabBarItems:self.conversationController.tabBarItem];
    
    //contact controller
    self.contactController = [[ContactListViewController alloc] init];
    self.contactController.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"title.addressbook", @"AddressBook") image:nil tag:1];
    [self.contactController.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"tabbar_contactsHL"]
                         withFinishedUnselectedImage:[UIImage imageNamed:@"tabbar_contacts"]];
    [self _unSelectedTapTabBarItems:self.contactController.tabBarItem];
    [self _selectedTapTabBarItems:self.contactController.tabBarItem];
    
    //setting controller
    self.settingController = [[SettingViewController alloc] init];
    self.settingController.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"title.setting", @"Setting") image:nil tag:2];
    [self.settingController.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"tabbar_settingHL"]
                         withFinishedUnselectedImage:[UIImage imageNamed:@"tabbar_setting"]];
    self.settingController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self _unSelectedTapTabBarItems:self.settingController.tabBarItem];
    [self _selectedTapTabBarItems:self.settingController.tabBarItem];
    
    self.viewControllers = @[self.conversationController, self.contactController, self.settingController];
    
    [self tabBar:self.tabBar didSelectItem:self.conversationController.tabBarItem];
//    [self _selectedTapTabBarItems:self.conversationController.tabBarItem];
}

#pragma mark - UITabBarDelegate

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    if (item.tag == 0)
    {
        self.title = NSLocalizedString(@"title.conversation", @"Conversations");
        self.navigationItem.rightBarButtonItems = nil;
    }
    else if (item.tag == 1){
        self.title = NSLocalizedString(@"title.addressbook", @"AddressBook");
        self.navigationItem.rightBarButtonItems = self.contactController.rightItems;
    }
    else if (item.tag == 2){
        self.title = NSLocalizedString(@"title.setting", @"Setting");
        self.navigationItem.rightBarButtonItems = nil;
        
        [self.settingController refreshSetting];
    }
}

#pragma mark - public

- (void)networkChanged:(EMConnectionState)connectionState
{
    
}

- (void)didReceiveLocalNotification:(UILocalNotification *)notification
{
    
}

#pragma mark - call

- (BOOL)canRecord
{
    __block BOOL bCanRecord = YES;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending)
    {
        if ([audioSession respondsToSelector:@selector(requestRecordPermission:)]) {
            [audioSession performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
                bCanRecord = granted;
            }];
        }
    }
    
    if (!bCanRecord) {
        UIAlertView * alt = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"setting.microphoneNoAuthority", @"No microphone permissions") message:NSLocalizedString(@"setting.microphoneAuthority", @"Please open in \"Setting\"-\"Privacy\"-\"Microphone\".") delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"ok", @"OK"), nil];
        [alt show];
    }
    
    return bCanRecord;
}

- (void)callOutWithChatter:(NSNotification *)notification
{
    /*
    id object = notification.object;
    if ([object isKindOfClass:[NSDictionary class]]) {
        if (![self canRecord]) {
            return;
        }
        
        EMError *error = nil;
        NSString *chatter = [object objectForKey:@"chatter"];
        EMCallSessionType type = [[object objectForKey:@"type"] intValue];
        EMCallSession *callSession = nil;
        if (type == eCallSessionTypeAudio) {
            callSession = [[EaseMob sharedInstance].callManager asyncMakeVoiceCall:chatter timeout:50 error:&error];
        }
        else if (type == eCallSessionTypeVideo){
            if (![EMCallViewController canVideo]) {
                return;
            }
            callSession = [[EaseMob sharedInstance].callManager asyncMakeVideoCall:chatter timeout:50 error:&error];
        }
        
        if (callSession && !error) {
            [[EaseMob sharedInstance].callManager removeDelegate:self];
            
            EMCallViewController *callController = [[EMCallViewController alloc] initWithSession:callSession isIncoming:NO];
            callController.modalPresentationStyle = UIModalPresentationOverFullScreen;
            [self presentViewController:callController animated:NO completion:nil];
        }
        
        if (error) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", @"error") message:error.description delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
            [alertView show];
        }
    }*/
}

- (void)callControllerClose:(NSNotification *)notification
{
    [[EaseMob sharedInstance].callManager addDelegate:self delegateQueue:nil];
}

#pragma mark - ICallManagerDelegate

- (void)callSessionStatusChanged:(EMCallSession *)callSession changeReason:(EMCallStatusChangedReason)reason error:(EMError *)error
{
    /*
    if (callSession.status == eCallSessionStatusConnected)
    {
        EMError *error = nil;
        do {
            BOOL isShowPicker = [[[NSUserDefaults standardUserDefaults] objectForKey:@"isShowPicker"] boolValue];
            if (isShowPicker) {
                error = [EMError errorWithCode:EMErrorInitFailure andDescription:NSLocalizedString(@"call.initFailed", @"Establish call failure")];
                break;
            }
            
            if (![self canRecord]) {
                error = [EMError errorWithCode:EMErrorInitFailure andDescription:NSLocalizedString(@"call.initFailed", @"Establish call failure")];
                break;
            }
            
#warning 在后台不能进行视频通话
            if(callSession.type == eCallSessionTypeVideo && ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive || ![EMCallViewController canVideo])){
                error = [EMError errorWithCode:EMErrorInitFailure andDescription:NSLocalizedString(@"call.initFailed", @"Establish call failure")];
                break;
            }
            
            if (!isShowPicker){
                [[EaseMob sharedInstance].callManager removeDelegate:self];
                EMCallViewController *callController = [[EMCallViewController alloc] initWithSession:callSession isIncoming:YES];
                callController.modalPresentationStyle = UIModalPresentationOverFullScreen;
                [self presentViewController:callController animated:NO completion:nil];
                if ([self.navigationController.topViewController isKindOfClass:[ChatViewController class]])
                {
                    ChatViewController *chatVc = (ChatViewController *)self.navigationController.topViewController;
                    chatVc.isInvisible = YES;
                }
            }
        } while (0);
        
        if (error) {
            [[EaseMob sharedInstance].callManager asyncEndCall:callSession.sessionId reason:eCallReasonHangup];
            return;
        }
    }*/
}

#pragma mark - IChatManagerDelegate 消息变化

- (void)didUpdateConversationList:(NSArray *)conversationList
{
    [self setupUnreadMessageCount];
}

// 未读消息数量变化回调
-(void)didUnreadMessagesCountChanged
{
    [self setupUnreadMessageCount];
}

- (void)didFinishedReceiveOfflineMessages
{
    [self setupUnreadMessageCount];
}


@end
