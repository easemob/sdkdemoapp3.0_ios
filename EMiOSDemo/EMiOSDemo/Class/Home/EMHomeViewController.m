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
#import "EMMineViewController.h"
#import "EMRemindManager.h"

#define kTabbarItemTag_Conversation 0
#define kTabbarItemTag_Contact 1
#define kTabbarItemTag_Settings 2

@interface EMHomeViewController ()<UITabBarDelegate, EMChatManagerDelegate, EMNotificationsDelegate>

@property (nonatomic) BOOL isViewAppear;

@property (nonatomic, strong) UITabBar *tabBar;
@property (strong, nonatomic) NSArray *viewControllers;

@property (nonatomic, strong) EMConversationsViewController *conversationsController;
@property (nonatomic, strong) EMContactsViewController *contactsController;
@property (nonatomic, strong) EMMineViewController *mineController;
@property (nonatomic, strong) UIView *addView;

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

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}
- (BOOL)prefersStatusBarHidden
{
    return NO;
}

- (void)dealloc
{
    [[EMClient sharedClient].chatManager removeDelegate:self];
    [[EMNotificationHelper shared] removeDelegate:self];
    [EMNotificationHelper destoryShared];
}

#pragma mark - Subviews

- (void)_setupSubviews
{
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        [self setEdgesForExtendedLayout: UIRectEdgeNone];
    }
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.tabBar = [[UITabBar alloc] init];
    self.tabBar.delegate = self;
    self.tabBar.translucent = NO;
    self.tabBar.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.tabBar];
    [self.tabBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_bottom).offset(-EMVIEWBOTTOMMARGIN);
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
    UITabBarItem *consItem = [self _setupTabBarItemWithTitle:@"会话" imgName:@"icon-tab会话unselected" selectedImgName:@"icon-tab会话" tag:kTabbarItemTag_Conversation];
    self.conversationsController.tabBarItem = consItem;
    [self addChildViewController:self.conversationsController];
    
    self.contactsController = [[EMContactsViewController alloc] init];
    UITabBarItem *contItem = [self _setupTabBarItemWithTitle:@"通讯录" imgName:@"icon-tab通讯录unselected" selectedImgName:@"icon-tab通讯录" tag:kTabbarItemTag_Contact];
    self.contactsController.tabBarItem = contItem;
    [self addChildViewController:self.contactsController];
    
    //UITabBarItem *discoverItem = [self _setupTabBarItemWithTitle:@"发现" imgName:@"icon-tab发现unselected" selectedImgName:@"icon-tab发现" tag:kTabbarItemTag_Settings];
    
    self.mineController = [[EMMineViewController alloc] init];
    UITabBarItem *mineItem = [self _setupTabBarItemWithTitle:@"我" imgName:@"icon-tab我unselected" selectedImgName:@"icon-tab我" tag:kTabbarItemTag_Settings];
    self.mineController.tabBarItem = mineItem;
    [self addChildViewController:self.mineController];
    
    self.viewControllers = @[self.conversationsController, self.contactsController, self.mineController];
    
    [self.tabBar setItems:@[consItem, contItem, mineItem]];
    
    self.tabBar.selectedItem = consItem;
    [self tabBar:self.tabBar didSelectItem:consItem];
}

#pragma mark - UITabBarDelegate

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    NSInteger tag = item.tag;
    UIView *tmpView = nil;
    if (tag == kTabbarItemTag_Conversation)
        tmpView = self.conversationsController.view;
    if (tag == kTabbarItemTag_Contact)
        tmpView = self.contactsController.view;
    if (tag == kTabbarItemTag_Settings)
        tmpView = self.mineController.view;
    
    if (self.addView == tmpView) {
        return;
    } else {
        [self.addView removeFromSuperview];
        self.addView = nil;
    }
    
    self.addView = tmpView;
    if (self.addView) {
        [self.view addSubview:self.addView];
        [self.addView mas_makeConstraints:^(MASConstraintMaker *make) {
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
    for (EMMessage *msg in aMessages) {
        if (msg.body.type == EMMessageBodyTypeText && [((EMTextMessageBody *)msg.body).text isEqualToString:EMCOMMUNICATE_CALLINVITE]) {
            //通话邀请
            EMConversation *conversation = [[EMClient sharedClient].chatManager getConversation:msg.conversationId type:EMConversationTypeGroupChat createIfNotExist:YES];
            if ([((EMTextMessageBody *)msg.body).text isEqualToString:EMCOMMUNICATE_CALLINVITE]) {
                [conversation deleteMessageWithId:msg.messageId error:nil];
                continue;
            }
        }
            
        if ([(NSString *)[msg.ext objectForKey:MSG_EXT_CALLID] length] != 0 || [(NSString *)[msg.ext objectForKey:@"conferenceId"] length] != 0) {
            //会议邀请消息
            [[NSNotificationCenter defaultCenter] postNotificationName:CALL_INVITECONFERENCEVIEW object:msg];
            break;
        }
    }
    if (self.isViewAppear) {
        [self _loadConversationTabBarItemBadge];
    }
}

- (void)conversationListDidUpdate:(NSArray *)aConversationList
{
    [self _loadConversationTabBarItemBadge];
}

#pragma mark - EMNotificationsDelegate

- (void)didNotificationsUnreadCountUpdate:(NSInteger)aUnreadCount
{
    EMNotificationHelper.shared.unreadCount = aUnreadCount;
    [self _loadConversationTabBarItemBadge];
}

#pragma mark - Private

- (void)_loadConversationTabBarItemBadge
{
    NSArray *conversations = [[EMClient sharedClient].chatManager getAllConversations];
    NSInteger unreadCount = 0;
    for (EMConversation *conversation in conversations) {
        unreadCount += conversation.unreadMessagesCount;
    }
    NSString *unreadCountStr = (unreadCount + [EMNotificationHelper shared].unreadCount) > 0 ? @(unreadCount + [EMNotificationHelper shared].unreadCount).stringValue : nil;
    self.conversationsController.tabBarItem.badgeValue = unreadCountStr;
    [EMRemindManager updateApplicationIconBadgeNumber:unreadCount + [EMNotificationHelper shared].unreadCount];
}

- (void)_loadTabBarItemsBadge
{
    [self _loadConversationTabBarItemBadge];
    
    [self didNotificationsUnreadCountUpdate:[EMNotificationHelper shared].unreadCount];
}

@end
