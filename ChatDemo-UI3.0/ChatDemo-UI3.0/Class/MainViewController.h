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

#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>

#import "ConversationListController.h"
#import "ContactListViewController.h"
#import "SettingsViewController.h"

@interface MainViewController : UITabBarController

@property (nonatomic, strong) ConversationListController *chatListVC;
@property (nonatomic, strong) ContactListViewController *contactsVC;
@property (nonatomic, strong) SettingsViewController *settingsVC;

- (void)jumpToChatList;

- (void)setupUntreatedApplyCount;

- (void)setupUnreadMessageCount;

- (void)networkChanged:(EMConnectionState)connectionState;

- (void)didReceiveLocalNotification:(UILocalNotification *)notification;

- (void)didReceiveUserNotification:(UNNotification *)notification;

- (void)playSoundAndVibration;

- (void)showNotificationWithMessage:(EMMessage *)message;

@end
