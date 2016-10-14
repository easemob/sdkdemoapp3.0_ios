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

@interface EMMainViewController ()
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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadViewControllers
{
    self.title = NSLocalizedString(@"title.contacts", @"Contacts");
    _contactsVC = [[EMContactsViewController alloc] init];
    _contactsVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"title.contacts", @"Contacts")
                                                           image:nil
                                                             tag:0];
    
    _chatsVC = [[EMChatsViewController alloc] init];
    _chatsVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"title.chats", @"Chats")
                                                        image:nil
                                                          tag:1];
    
    _settingsVC = [[EMSettingsViewController alloc] init];
    _settingsVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"title.settings", @"Settings")
                                                           image:nil
                                                             tag:2];

    
    self.viewControllers = @[_contactsVC,_chatsVC,_settingsVC];
    self.selectedIndex = 0;
}

#pragma mark - UITabBarDelegate

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    if (item.tag == 0) {
        self.title = NSLocalizedString(@"title.contacts", @"Contacts");
        self.navigationItem.rightBarButtonItem = nil;
    }else if (item.tag == 1){
        self.title = NSLocalizedString(@"title.chats", @"Chats");
        self.navigationItem.rightBarButtonItem = nil;
    }else if (item.tag == 2){
        self.title = NSLocalizedString(@"title.settings", @"Settings");
        self.navigationItem.rightBarButtonItem = nil;
    }
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
