//
//  SettingViewController.m
//  ChatDemo-UI3.0
//
//  Created by dhc on 15/6/24.
//  Copyright (c) 2015年 easemob.com. All rights reserved.
//

#import "SettingViewController.h"

#import "EaseMob.h"
//#import <EaseUI/UIViewController+HUD.h>

#import "PushNotificationViewController.h"
#import "BlackListViewController.h"
#import "DebugViewController.h"
#import "EditNicknameViewController.h"

@interface SettingViewController ()

@property (strong, nonatomic) UIView *footerView;

@property (strong, nonatomic) UISwitch *autoLoginSwitch;
@property (strong, nonatomic) UISwitch *ipSwitch;
@property (strong, nonatomic) UISwitch *delConversationSwitch;

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    self.title = NSLocalizedString(@"title.setting", @"Setting");

    self.tableView.tableFooterView = self.footerView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - getter

- (UIView *)footerView
{
    if (_footerView == nil) {
        _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 80)];
        _footerView.backgroundColor = [UIColor clearColor];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(10, 0, _footerView.frame.size.width - 10, 0.5)];
        line.backgroundColor = [UIColor lightGrayColor];
        [_footerView addSubview:line];
        
        UIButton *logoutButton = [[UIButton alloc] initWithFrame:CGRectMake(40, 20, _footerView.frame.size.width - 80, 40)];
        [logoutButton setBackgroundColor:[UIColor colorWithRed:254 / 255.0 green:100 / 255.0 blue:80 / 255.0 alpha:1.0]];
        NSDictionary *loginInfo = [[EaseMob sharedInstance].chatManager loginInfo];
        NSString *username = [loginInfo objectForKey:kSDKUsername];
        NSString *logoutButtonTitle = [[NSString alloc] initWithFormat:NSLocalizedString(@"setting.loginUser", @"log out(%@)"), username];
        [logoutButton setTitle:logoutButtonTitle forState:UIControlStateNormal];
        [logoutButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [logoutButton addTarget:self action:@selector(logoutAction) forControlEvents:UIControlEventTouchUpInside];
        [_footerView addSubview:logoutButton];
    }
    
    return _footerView;
}

- (UISwitch *)autoLoginSwitch
{
    if (_autoLoginSwitch == nil) {
        _autoLoginSwitch = [[UISwitch alloc] init];
        [_autoLoginSwitch addTarget:self action:@selector(autoLoginChanged:) forControlEvents:UIControlEventValueChanged];
    }
    
    return _autoLoginSwitch;
}

- (UISwitch *)ipSwitch
{
    if (_ipSwitch == nil) {
        _ipSwitch = [[UISwitch alloc] init];
        [_ipSwitch addTarget:self action:@selector(useIpChanged:) forControlEvents:UIControlEventValueChanged];
    }
    
    return _ipSwitch;
}

- (UISwitch *)delConversationSwitch
{
    if (!_delConversationSwitch)
    {
        _delConversationSwitch = [[UISwitch alloc] init];
        _delConversationSwitch.on = [EaseMob sharedInstance].chatManager.isAutoDeleteConversationWhenLeaveGroup;
        [_delConversationSwitch addTarget:self action:@selector(delConversationChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _delConversationSwitch;
}

#pragma mark - Table view datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 7;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.textLabel.text = NSLocalizedString(@"setting.autoLogin", @"automatic login");
            cell.accessoryType = UITableViewCellAccessoryNone;
            self.autoLoginSwitch.frame = CGRectMake(self.tableView.frame.size.width - (self.autoLoginSwitch.frame.size.width + 10), (cell.contentView.frame.size.height - self.autoLoginSwitch.frame.size.height) / 2, self.autoLoginSwitch.frame.size.width, self.autoLoginSwitch.frame.size.height);
            [cell.contentView addSubview:self.autoLoginSwitch];
        }
        else if (indexPath.row == 1)
        {
            cell.textLabel.text = NSLocalizedString(@"title.apnsSetting", @"Apns Settings");
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        else if (indexPath.row == 2)
        {
            cell.textLabel.text = NSLocalizedString(@"title.buddyBlock", @"Black List");
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        else if (indexPath.row == 3)
        {
            cell.textLabel.text = NSLocalizedString(@"title.debug", @"Debug");
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        else if (indexPath.row == 4){
            cell.textLabel.text = NSLocalizedString(@"setting.useIp", @"Use IP");
            cell.accessoryType = UITableViewCellAccessoryNone;
            self.ipSwitch.frame = CGRectMake(self.tableView.frame.size.width - (self.ipSwitch.frame.size.width + 10), (cell.contentView.frame.size.height - self.ipSwitch.frame.size.height) / 2, self.ipSwitch.frame.size.width, self.ipSwitch.frame.size.height);
            [cell.contentView addSubview:self.ipSwitch];
        }
        else if (indexPath.row == 5){
            cell.textLabel.text = NSLocalizedString(@"setting.deleteConWhenLeave", @"Delete conversation when leave a group");
            cell.accessoryType = UITableViewCellAccessoryNone;
            self.delConversationSwitch.frame = CGRectMake(self.tableView.frame.size.width - (self.delConversationSwitch.frame.size.width + 10), (cell.contentView.frame.size.height - self.delConversationSwitch.frame.size.height) / 2, self.delConversationSwitch.frame.size.width, self.delConversationSwitch.frame.size.height);
            [cell.contentView addSubview:self.delConversationSwitch];
        } else if (indexPath.row == 6){
            cell.textLabel.text = NSLocalizedString(@"setting.iospushname", @"iOS push nickname");
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        //        else if (indexPath.row == 7){
        //            cell.textLabel.text = @"聊天记录备份和恢复";
        //            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        //        }
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 1) {
        PushNotificationViewController *pushController = [[PushNotificationViewController alloc] initWithStyle:UITableViewStylePlain];
        [self.navigationController pushViewController:pushController animated:YES];
    }
    else if (indexPath.row == 2)
    {
        BlackListViewController *blackController = [[BlackListViewController alloc] initWithNibName:nil bundle:nil];
        [self.navigationController pushViewController:blackController animated:YES];
    }
    else if (indexPath.row == 3)
    {
        DebugViewController *debugController = [[DebugViewController alloc] initWithStyle:UITableViewStylePlain];
        [self.navigationController pushViewController:debugController animated:YES];
    } else if (indexPath.row == 6) {
        EditNicknameViewController *editName = [[EditNicknameViewController alloc] initWithNibName:nil bundle:nil];
        [self.navigationController pushViewController:editName animated:YES];
    }
    //    else if(indexPath.row == 7){
    //        BackupViewController *backupController = [[BackupViewController alloc] initWithNibName:nil bundle:nil];
    //        [self.navigationController pushViewController:backupController animated:YES];
    //    }
}

#pragma mark - action

- (void)autoLoginChanged:(UISwitch *)autoSwitch
{
    [[EaseMob sharedInstance].chatManager setIsAutoLoginEnabled:autoSwitch.isOn];
}

- (void)useIpChanged:(UISwitch *)ipSwitch
{
    [[EaseMob sharedInstance].chatManager setIsUseIp:ipSwitch.isOn];
}

- (void)delConversationChanged:(UISwitch *)control
{
    [EaseMob sharedInstance].chatManager.isAutoDeleteConversationWhenLeaveGroup = control.isOn;
}

- (void)logoutAction
{
    __weak SettingViewController *weakSelf = self;
//    [self showHudInView:self.view hint:NSLocalizedString(@"setting.logoutOngoing", @"loging out...")];
    [[EaseMob sharedInstance].chatManager asyncLogoffWithUnbindDeviceToken:YES completion:^(NSDictionary *info, EMError *error) {
//        [weakSelf hideHud];
        if (error && error.errorCode != EMErrorServerNotLogin) {
//            [weakSelf showHint:error.description];
        }
        else{
            [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@NO];
        }
    } onQueue:nil];
}

#pragma mark - public

- (void)refreshSetting
{
    [self.autoLoginSwitch setOn:[[EaseMob sharedInstance].chatManager isAutoLoginEnabled] animated:YES];
    [self.ipSwitch setOn:[[EaseMob sharedInstance].chatManager isUseIp] animated:YES];
    
    [self.tableView reloadData];
}

@end
