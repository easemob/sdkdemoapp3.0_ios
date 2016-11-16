//
//  EMSettingsViewController.m
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 16/9/21.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "EMSettingsViewController.h"
#import "EMAboutViewController.h"
#import "EMPushNotificationViewController.h"
#import "EMAccountViewController.h"
#import "EMChatsSettingViewController.h"
#import "EMChatDemoHelper.h"
#import "UIViewController+HUD.h"

@interface EMSettingsViewController ()

@property (nonatomic, strong) UISwitch *callPushSwitch;

@property (nonatomic) EMPushNoDisturbStatus pushStatus;
@end

@implementation EMSettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)reloadNotificationStatus
{
    [self.tableView reloadData];
}

#pragma mark - getters

- (UISwitch *)callPushSwitch
{
    if (_callPushSwitch == nil) {
        
        _callPushSwitch = [[UISwitch alloc] init];
        [_callPushSwitch addTarget:self action:@selector(callPushChanged:) forControlEvents:UIControlEventValueChanged];
        [_callPushSwitch setOn:[[[NSUserDefaults standardUserDefaults] objectForKey:@"callPushChanged"] boolValue]];
    }
    
    return _callPushSwitch;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *ident = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ident];
    if (!cell) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ident];
    }
    
    if (indexPath.row == 0) {
        
        cell.textLabel.text = NSLocalizedString(@"setting.about", @"About");
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else if (indexPath.row == 1) {
        
        cell.textLabel.text = NSLocalizedString(@"setting.push", @"Push Notifications");
        BOOL isPushOn = [self isAllowedNotification];
        cell.detailTextLabel.text = isPushOn ? NSLocalizedString(@"setting.push.enable", @"Enable") : NSLocalizedString(@"setting.push.disable", @"Disable");
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else if (indexPath.row == 2) {
        
        cell.textLabel.text = NSLocalizedString(@"setting.account", @"Account");
        cell.detailTextLabel.text = [[EMClient sharedClient] currentUsername];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else if (indexPath.row == 3) {
        
        cell.textLabel.text = NSLocalizedString(@"setting.chats", @"Chats");
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    } else {
        
        cell.textLabel.text = NSLocalizedString(@"setting.callPush", @"If the offline send call push");
        self.callPushSwitch.frame = CGRectMake(self.tableView.frame.size.width - 65, 8, 50, 30);
        [cell.contentView addSubview:self.callPushSwitch];
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
    if (indexPath.row == 0) {
            
        EMAboutViewController *about = [[EMAboutViewController alloc] init];
        about.title = NSLocalizedString(@"title.setting.about", @"About");
        [self.navigationController pushViewController:about animated:YES];
    } else if (indexPath.row == 1) {

        EMPushNotificationViewController *pushController = [[EMPushNotificationViewController alloc] init];
        pushController.title = NSLocalizedString(@"title.setting.push", @"Push Notifications");
        [EMChatDemoHelper shareHelper].pushVC = pushController;
        [self.navigationController pushViewController:pushController animated:YES];
    } else if (indexPath.row == 2) {
            
        EMAccountViewController *accout = [[EMAccountViewController alloc] init];
            accout.title = NSLocalizedString(@"title.setting.account", @"Account");
        [self.navigationController pushViewController:accout animated:YES];
    } else if (indexPath.row == 3) {
            
        EMChatsSettingViewController *chatSetting = [[EMChatsSettingViewController alloc] init];
        chatSetting.title = NSLocalizedString(@"title.setting.chats", @"Chats");
        [self.navigationController pushViewController:chatSetting animated:YES];
    }
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        
        UIView *header = [[UIView alloc] init];
        header.backgroundColor = RGBACOLOR(228, 233, 236, 1.0);
        return header;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0;
    } else {
        
        return 20;
    }
}

- (BOOL)isAllowedNotification {
    
    if ([[UIDevice currentDevice].systemVersion floatValue] > 7.0) {
        
        UIUserNotificationSettings *setting = [[UIApplication sharedApplication] currentUserNotificationSettings];
        if (setting.types != UIUserNotificationTypeNone) {
            
            return YES;
        }
    } else {
        
        UIRemoteNotificationType type = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
        if (type != UIRemoteNotificationTypeNone) {
            
            return YES;
        }
    }
    
    return NO;
}
#pragma mark - Actions

- (void)callPushChanged:(UISwitch *)sender
{
    NSLog(@"callPushChanged --- %d",(int)sender.on);
    
    EMCallOptions *options = [[EMClient sharedClient].callManager getCallOptions];
    options.isSendPushIfOffline = sender.isOn;
    if (sender.isOn) {

        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        if (![ud objectForKey:@"callPushChanged"]) {
            [ud setBool:YES forKey:@"callPushChanged"];
            [ud synchronize];
        }
    } else {
        
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        if ([ud objectForKey:@"callPushChanged"]) {
            [ud removeObjectForKey:@"callPushChanged"];
            [ud synchronize];
        }
    }
}



@end
