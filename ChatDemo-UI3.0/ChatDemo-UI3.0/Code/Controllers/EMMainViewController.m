//
//  EMMainViewController.m
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 16/9/19.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "EMMainViewController.h"

#import "EMContactsViewController.h"
#import "EMChatsViewController.h"
#import "EMSettingsViewController.h"
#import "EMChatDemoHelper.h"
#import "EaseCallManager.h"

@interface EMMainViewController () <EMChatManagerDelegate,EMGroupManagerDelegate,EMClientDelegate>
{
    EMContactsViewController *_contactsVC;
    EMChatsViewController *_chatsVC;
    EMSettingsViewController *_settingsVC;
}

@end

@implementation EMMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self loadViewControllers];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupUnreadMessageCount) name:KNOTIFICATION_UPDATEUNREADCOUNT object:nil];
    [self setupUnreadMessageCount];
    
    [self registerNotifications];
    
    [EaseCallManager sharedManager].mainVC = self;
}

- (void)dealloc
{
    [self unregisterNotifications];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)registerNotifications{
    [self unregisterNotifications];
    [[EMClient sharedClient] addDelegate:self delegateQueue:nil];
    [[EMClient sharedClient].chatManager addDelegate:self delegateQueue:nil];
    [[EMClient sharedClient].groupManager addDelegate:self delegateQueue:nil];
}

-(void)unregisterNotifications{
    [[EMClient sharedClient] removeDelegate:self];
    [[EMClient sharedClient].chatManager removeDelegate:self];
    [[EMClient sharedClient].groupManager removeDelegate:self];
}


- (void)loadViewControllers
{
    self.title = NSLocalizedString(@"title.contacts", @"Contacts");
    _contactsVC = [[EMContactsViewController alloc] init];
    _contactsVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"title.contacts", @"Contacts")
                                                           image:[UIImage imageNamed:@"Contacts"]
                                                             tag:0];
    [_contactsVC.tabBarItem setSelectedImage:[UIImage imageNamed:@"Contacts_active"]];
    [self unSelectedTapTabBarItems:_contactsVC.tabBarItem];
    [self selectedTapTabBarItems:_contactsVC.tabBarItem];
    [_contactsVC setupNavigationItem:self.navigationItem];
    
    _chatsVC = [[EMChatsViewController alloc] init];
    _chatsVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"title.chats", @"Chats")
                                                        image:[UIImage imageNamed:@"Chats"]
                                                          tag:1];
    [_chatsVC.tabBarItem setSelectedImage:[UIImage imageNamed:@"Chats_active"]];
    [self unSelectedTapTabBarItems:_chatsVC.tabBarItem];
    [self selectedTapTabBarItems:_chatsVC.tabBarItem];
    
    _settingsVC = [[EMSettingsViewController alloc] init];
    _settingsVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"title.settings", @"Settings")
                                                           image:[UIImage imageNamed:@"Settings"]
                                                             tag:2];
    [_settingsVC.tabBarItem setSelectedImage:[UIImage imageNamed:@"Settings_active"]];
    [self unSelectedTapTabBarItems:_settingsVC.tabBarItem];
    [self selectedTapTabBarItems:_settingsVC.tabBarItem];
    
    self.viewControllers = @[_contactsVC,_chatsVC,_settingsVC];
    self.selectedIndex = 0;
    
    [EMChatDemoHelper shareHelper].contactsVC = _contactsVC;
    [EMChatDemoHelper shareHelper].chatsVC = _chatsVC;
}

-(void)unSelectedTapTabBarItems:(UITabBarItem *)tabBarItem
{
    [tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                        [UIFont systemFontOfSize:11.f], NSFontAttributeName,RGBACOLOR(135, 152, 164, 1),NSForegroundColorAttributeName,
                                        nil] forState:UIControlStateNormal];
}

-(void)selectedTapTabBarItems:(UITabBarItem *)tabBarItem
{
    [tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                        [UIFont systemFontOfSize:11.f],
                                        NSFontAttributeName,RGBACOLOR(0, 186, 110, 1),NSForegroundColorAttributeName,
                                        nil] forState:UIControlStateSelected];
}

-(void)setupUnreadMessageCount
{
    NSArray *conversations = [[EMClient sharedClient].chatManager getAllConversations];
    NSInteger unreadCount = 0;
    for (EMConversation *conversation in conversations) {
        unreadCount += conversation.unreadMessagesCount;
    }
    if (_chatsVC) {
        if (unreadCount > 0) {
            _chatsVC.tabBarItem.badgeValue = [NSString stringWithFormat:@"%i",(int)unreadCount];
        }else{
            _chatsVC.tabBarItem.badgeValue = nil;
        }
    }
    UIApplication *application = [UIApplication sharedApplication];
    [application setApplicationIconBadgeNumber:unreadCount];
}

#pragma mark - UITabBarDelegate

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    if (item.tag == 0) {
        self.title = NSLocalizedString(@"title.contacts", @"Contacts");
        [_contactsVC setupNavigationItem:self.navigationItem];
    }else if (item.tag == 1){
        self.title = NSLocalizedString(@"title.chats", @"Chats");
        self.navigationItem.rightBarButtonItem = nil;
        [_chatsVC setupNavigationItem:self.navigationItem];
    }else if (item.tag == 2){
        self.title = NSLocalizedString(@"title.settings", @"Settings");
        [self clearNavigationItem];
    }
}

#pragma mark - EMChatManagerDelegate

- (void)messagesDidReceive:(NSArray *)aMessages
{
    [self setupUnreadMessageCount];
}

- (void)conversationListDidUpdate:(NSArray *)aConversationList
{
    [self setupUnreadMessageCount];
}

#pragma mark - EMClientDelegate

- (void)connectionStateDidChange:(EMConnectionState)aConnectionState
{
    [_chatsVC networkChanged:aConnectionState];
}

- (void)userAccountDidLoginFromOtherDevice
{
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@NO];
}

- (void)userAccountDidRemoveFromServer
{
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@NO];
}

- (void)clearNavigationItem {
    self.navigationItem.titleView = nil;
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem = nil;
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
