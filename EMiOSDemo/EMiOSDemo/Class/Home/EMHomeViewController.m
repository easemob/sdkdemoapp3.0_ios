//
//  EMHomeViewController.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2018/12/24.
//  Copyright © 2018 XieYajie. All rights reserved.
//

#import "EMHomeViewController.h"

#import "EMConversationsViewController.h"
#import "EMContactsViewController.h"
#import "EMSettingsViewController.h"

#define kTabbarItemTag_Conversation 0
#define kTabbarItemTag_Contact 1
#define kTabbarItemTag_Settings 2

@interface EMHomeViewController ()<UITabBarDelegate, EMChatManagerDelegate, EMNotificationsDelegate>

@property (nonatomic) BOOL isViewAppear;

@property (nonatomic, strong) UITabBar *tabBar;
@property (strong, nonatomic) NSArray *viewControllers;

@property (nonatomic, strong) EMConversationsViewController *conversationsController;
@property (nonatomic, strong) EMContactsViewController *contactsController;
@property (nonatomic, strong) EMSettingsViewController *settingsController;

@end

@implementation EMHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self _setupSubviews];
    
    //监听消息接收，主要更新会话tabbaritem的badge
    [[EMClient sharedClient].chatManager addDelegate:self delegateQueue:nil];
    //监听通知申请，主要更新联系人tabbaritem的badge
    [[EMNotificationHelper shared] addDelegate:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
    self.isViewAppear = YES;
    [self _loadTabBarItemsBadge];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.isViewAppear = NO;
}

- (void)dealloc
{
    [[EMClient sharedClient].chatManager removeDelegate:self];
    [[EMNotificationHelper shared] removeDelegate:self];
}

#pragma mark - Subviews

- (void)_setupSubviews
{
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        [self setEdgesForExtendedLayout: UIRectEdgeNone];
    }
    
    [[UITableViewHeaderFooterView appearance] setTintColor:kColor_LightGray];
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navbar_white"] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar.layer setMasksToBounds:YES];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.tabBar = [[UITabBar alloc] init];
    self.tabBar.delegate = self;
    self.tabBar.translucent = NO;
    self.tabBar.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.tabBar];
    [self.tabBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_bottom);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.height.mas_equalTo(50);
    }];
    
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    [self.tabBar addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.tabBar.mas_top);
        make.left.equalTo(self.tabBar.mas_left);
        make.right.equalTo(self.tabBar.mas_right);
        make.height.equalTo(@1);
    }];
    
    [self _setupChildController];
}

- (UITabBarItem *)_setupTabBarItemWithTitle:(NSString *)aTitle
                                    imgName:(NSString *)aImgName
                            selectedImgName:(NSString *)aSelectedImgName
                                        tag:(NSInteger)aTag
{
    UITabBarItem *retItem = [[UITabBarItem alloc] initWithTitle:aTitle image:[UIImage imageNamed:aImgName] selectedImage:[UIImage imageNamed:aSelectedImgName]];
    retItem.tag = aTag;
    [retItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIFont systemFontOfSize:14], NSFontAttributeName, [UIColor lightGrayColor],NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
    [retItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:13], NSFontAttributeName, kColor_Blue, NSForegroundColorAttributeName, nil] forState:UIControlStateSelected];
    return retItem;
}

- (void)_setupChildController
{
    self.conversationsController = [[EMConversationsViewController alloc] init];
    UITabBarItem *consItem = [self _setupTabBarItemWithTitle:@"聊天" imgName:@"tabbar_chat_gray" selectedImgName:@"tabbar_chat_blue" tag:kTabbarItemTag_Conversation];
    self.conversationsController.tabBarItem = consItem;
    [self addChildViewController:self.conversationsController];
    
    self.contactsController = [[EMContactsViewController alloc] init];
    UITabBarItem *contItem = [self _setupTabBarItemWithTitle:@"联系人" imgName:@"tabbar_contacts_gray" selectedImgName:@"tabbar_contacts_blue" tag:kTabbarItemTag_Contact];
    self.contactsController.tabBarItem = contItem;
    [self addChildViewController:self.contactsController];
    
    self.settingsController = [[EMSettingsViewController alloc] init];
    UITabBarItem *settingsItem = [self _setupTabBarItemWithTitle:@"设置" imgName:@"tabbar_settings_gray" selectedImgName:@"tabbar_settings_blue" tag:kTabbarItemTag_Settings];
    self.settingsController.tabBarItem = settingsItem;
    [self addChildViewController:self.settingsController];
    
    self.viewControllers = @[self.conversationsController, self.contactsController, self.settingsController];
    
    [self.tabBar setItems:@[consItem, contItem, settingsItem]];
    
    self.tabBar.selectedItem = consItem;
    [self tabBar:self.tabBar didSelectItem:consItem];
}

#pragma mark - UITabBarDelegate

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    NSInteger tag = item.tag;
    UIView *addView = nil;
    if (tag == kTabbarItemTag_Conversation) {
        addView = self.conversationsController.view;
    } else if (tag == kTabbarItemTag_Contact) {
        addView = self.contactsController.view;
    } else if (tag == kTabbarItemTag_Settings) {
        addView = self.settingsController.view;
    }
    
    if (addView) {
        [self.view addSubview:addView];
        [addView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view);
            make.left.equalTo(self.view);
            make.right.equalTo(self.view);
            make.bottom.equalTo(self.tabBar.mas_top);
        }];
    }
}

#pragma mark - EMChatManagerDelegate

- (void)messagesDidReceive:(NSArray *)aMessages
{
    if (self.isViewAppear) {
        [self _loadConversationTabBarItemBadge];
    }
}

#pragma mark - EMNotificationsDelegate

- (void)didNotificationsUnreadCountUpdate:(NSInteger)aUnreadCount
{
    if (aUnreadCount > 0) {
        self.contactsController.tabBarItem.badgeValue = @(aUnreadCount).stringValue;
    } else {
        self.contactsController.tabBarItem.badgeValue = nil;
    }
}

#pragma mark - Private

- (void)_loadConversationTabBarItemBadge
{
    NSArray *conversations = [[EMClient sharedClient].chatManager getAllConversations];
    NSInteger unreadCount = 0;
    for (EMConversation *conversation in conversations) {
        unreadCount += conversation.unreadMessagesCount;
    }
    
    if (unreadCount > 0) {
        self.conversationsController.tabBarItem.badgeValue = @(unreadCount).stringValue;
    } else {
        self.conversationsController.tabBarItem.badgeValue = nil;
    }
}

- (void)_loadTabBarItemsBadge
{
    [self _loadConversationTabBarItemBadge];
    
    [self didNotificationsUnreadCountUpdate:[EMNotificationHelper shared].unreadCount];
}

@end
