//
//  EMGroupSettingsViewController.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/25.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EMGroupSettingsViewController.h"

@interface EMGroupSettingsViewController ()

@property (nonatomic, strong) EMGroup *group;

@property (nonatomic, strong) UISwitch *shieldSwitch;
@property (nonatomic, strong) UISwitch *pushSwitch;

@end

@implementation EMGroupSettingsViewController

- (instancetype)initWithGroup:(EMGroup *)aGroup
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.group = aGroup;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    [self _setupSubviews];
}

#pragma mark - Subviews

- (void)_setupSubviews
{
    [self addPopBackLeftItem];
    self.title = @"群组设置";
    
    self.tableView.rowHeight = 55;
    self.tableView.backgroundColor = kColor_LightGray;
    
    self.shieldSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width - 65, 10, 50, 40)];
    [self.shieldSwitch addTarget:self action:@selector(shieldSwitchValueChanged) forControlEvents:UIControlEventValueChanged];
    [self.shieldSwitch setOn:self.group.isBlocked];
    
    self.pushSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width - 65, 10, 50, 40)];
    [self.pushSwitch addTarget:self action:@selector(pushSwitchValueChanged) forControlEvents:UIControlEventValueChanged];
    [self.pushSwitch setOn:self.group.isPushNotificationEnabled];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = 1;
    if (section == 1 && self.shieldSwitch.isOn) {
        count = 0;
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (section == 0) {
        if (row == 0) {
            cell.textLabel.textColor = [UIColor blackColor];
            cell.textLabel.text = @"屏蔽群组消息";
            [cell.contentView addSubview:self.shieldSwitch];
        }
    } else if (section == 1) {
        if (row == 0) {
            cell.textLabel.textColor = [UIColor blackColor];
            cell.textLabel.text = self.pushSwitch.isOn ? @"接收并提示群消息" : @"只接收但不提示消息";
            [cell.contentView addSubview:self.pushSwitch];
        }
    } else if (section == 2) {
        if (row == 0) {
            cell.textLabel.textColor = kColor_Blue;
            cell.textLabel.text = @"清空消息";
        }
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 20;
    }
    
    if (section == 1 && self.shieldSwitch.isOn) {
        return 0;
    }
    
    return 10;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 1 && self.shieldSwitch.isOn) {
        return 0;
    }
    
    return 30;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 2 || (section == 1 && self.shieldSwitch.isOn)) {
        return nil;
    }
    
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:13];
    label.textColor = [UIColor lightGrayColor];
    label.numberOfLines = 2;
    if (section == 0) {
        label.text = @"    屏蔽群组的全部消息";
    } else if (section == 1) {
        label.text = self.pushSwitch.isOn ? @"    接收消息并且提示消息通知" : @"    接收消息但是不提示消息通知";
    }
    
    return label;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 2 && indexPath.row == 0) {
        [self showHudInView:self.view hint:@"正在删除..."];
        [[NSNotificationCenter defaultCenter] postNotificationName:CHAT_CLEANMESSAGES object:self.group.groupId];
        [self hideHud];
    }
}

#pragma mark - Action

- (void)shieldSwitchValueChanged
{
    if (self.shieldSwitch.isOn == self.group.isBlocked) {
        return;
    }
    
    [self showHudInView:self.view hint:@"更新群组设置..."];
    __weak typeof(self) weakself = self;
    void (^block)(EMGroup *aGroup, EMError *aError) = ^void(EMGroup *aGroup, EMError *aError) {
        [weakself hideHud];
        if (aError) {
            [weakself.shieldSwitch setOn:!weakself.shieldSwitch.isOn];
            [EMAlertController showErrorAlert:@"更新群组设置失败"];
        } else {
            [EMAlertController showSuccessAlert:@"更新群组设置成功"];
            weakself.group = aGroup;
            [weakself.tableView reloadData];
        }
    };
    
    if (self.shieldSwitch.isOn) {
        [[EMClient sharedClient].groupManager blockGroup:self.group.groupId completion:block];
    } else {
        [[EMClient sharedClient].groupManager unblockGroup:self.group.groupId completion:block];
    }
}

- (void)pushSwitchValueChanged
{
    if (self.pushSwitch.isOn == self.group.isPushNotificationEnabled) {
        return;
    }
    
    [self showHudInView:self.view hint:@"更新群组设置..."];
    __weak typeof(self) weakself = self;
    [[EMClient sharedClient].groupManager updatePushServiceForGroup:self.group.groupId isPushEnabled:self.pushSwitch.isOn completion:^(EMGroup *aGroup, EMError *aError) {
        [weakself hideHud];
        if (aError) {
            [weakself.pushSwitch setOn:!weakself.pushSwitch.isOn];
            [EMAlertController showErrorAlert:@"更新群组设置失败"];
        } else {
            [EMAlertController showSuccessAlert:@"更新群组设置成功"];
            weakself.group = aGroup;
            [weakself.tableView reloadData];
        }
    }];
}

@end
