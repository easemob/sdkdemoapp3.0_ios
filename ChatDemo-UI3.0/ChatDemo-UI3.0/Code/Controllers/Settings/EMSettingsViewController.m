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

@interface EMSettingsViewController ()

@property (nonatomic, strong) UISwitch *videoBitrateSwitch;

@property (nonatomic) EMPushNoDisturbStatus pushStatus;
@end

@implementation EMSettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadPushOptions];
    
}

- (void)loadPushOptions
{
    __weak typeof(self) weakSelf = self;
    [[EMClient sharedClient] getPushNotificationOptionsFromServerWithCompletion:^(EMPushOptions *aOptions, EMError *aError) {
        
        if (!aError) {
            [weakSelf refreshPushOptions];
        }
    }];
}

- (void)refreshPushOptions
{
    EMPushOptions *options = [[EMClient sharedClient] pushOptions];
    if (_pushStatus != options.noDisturbStatus) {
        
        _pushStatus = options.noDisturbStatus;
        [self.tableView reloadData];
    }
}



#pragma mark - getters

- (UISwitch *)videoBitrateSwitch
{
    if (_videoBitrateSwitch == nil) {
        
        _videoBitrateSwitch = [[UISwitch alloc] init];
        [_videoBitrateSwitch addTarget:self action:@selector(switchVideoBitrate:) forControlEvents:UIControlEventValueChanged];
    }
    
    return _videoBitrateSwitch;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *ident = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ident];
    if (!cell) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ident];
    }

    if (indexPath.section == 0) {
        
        if (indexPath.row == 0) {
            
            cell.textLabel.text = @"About";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else if (indexPath.row == 1) {
            
            cell.textLabel.text = @"API Key";
            cell.detailTextLabel.text = @"HyphenateDemo";
        } else if (indexPath.row == 2) {
            
            BOOL isPushOn = _pushStatus == EMPushNoDisturbStatusClose ? YES : NO;
            cell.textLabel.text = @"Push Notifications";
            cell.detailTextLabel.text = isPushOn ? @"On" : @"Off";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    } else {
        
        if (indexPath.row == 0) {
            
            cell.textLabel.text = @"Account";
            cell.detailTextLabel.text = [[EMClient sharedClient] currentUsername];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else if (indexPath.row == 1) {
            
            cell.textLabel.text = @"Chats";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else {
            
            cell.textLabel.text = @"Adaptive Video Bitrate";
            self.videoBitrateSwitch.frame = CGRectMake(self.tableView.frame.size.width - self.videoBitrateSwitch.frame.size.width - 15, 8, 50, 30);
            [cell.contentView addSubview:self.videoBitrateSwitch];
        }
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        
        if (indexPath.row == 0) {
            
            EMAboutViewController *about = [[EMAboutViewController alloc] init];
            about.title = @"About";
            [self.navigationController pushViewController:about animated:YES];
        } else if (indexPath.row == 2) {
            
            EMPushNotificationViewController *pushController = [[EMPushNotificationViewController alloc] init];
            pushController.title = @"Push Notifications";
            [pushController getPushStatus:^(EMPushNoDisturbStatus disturbStatus) {
                _pushStatus = disturbStatus;
                [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            }];
            [self.navigationController pushViewController:pushController animated:YES];
        }
    } else {
        
        if (indexPath.row == 0) {
            
            EMAccountViewController *accout = [[EMAccountViewController alloc] init];
            accout.title = @"Account";
            [self.navigationController pushViewController:accout animated:YES];
        } else if (indexPath.row == 1) {
            
            EMChatsSettingViewController *chatSetting = [[EMChatsSettingViewController alloc] init];
            chatSetting.title = @"Chats";
            [self.navigationController pushViewController:chatSetting animated:YES];
        }
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

#pragma mark - Actions

- (void)switchVideoBitrate:(UISwitch *)sender
{
    NSLog(@"switchVideoBitrate --- %d",(int)sender.on);
}



@end
