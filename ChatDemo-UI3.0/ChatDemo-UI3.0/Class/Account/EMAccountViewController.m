//
//  EMAccountViewController.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2018/12/24.
//  Copyright © 2018 XieYajie. All rights reserved.
//

#import "EMAccountViewController.h"

#import "EMDemoOptions.h"
#import "EMAlertController.h"

@interface EMAccountViewController ()

@property (nonatomic, strong) UIImageView *headerView;
@property (nonatomic, strong) UISwitch *disturbSwitch;

@end

@implementation EMAccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    [self _setupSubviews];
}

#pragma mark - Subviews

- (void)_setupSubviews
{
//    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"back_gary"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(backAction)];
    
    self.title = @"个人信息";
    
    self.tableView.sectionHeaderHeight = 15;
//    self.tableView.sectionFooterHeight = 15;
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.backgroundColor = [UIColor colorWithRed:245 / 255.0 green:245 / 255.0 blue:245 / 255.0 alpha:1.0];
    
    self.headerView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"user_default"]];
    self.headerView.frame = CGRectMake(0, 0, 60, 60);
    self.headerView.userInteractionEnabled = YES;
    
    self.disturbSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 40, 60)];
    [self.disturbSwitch addTarget:self action:@selector(disturbValueChanged) forControlEvents:UIControlEventValueChanged];
    [self.disturbSwitch setOn:([EMClient sharedClient].pushOptions.noDisturbStatus == EMPushNoDisturbStatusClose ? NO : YES) animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = 0;
    switch (section) {
        case 0:
            count = 3;
            break;
        case 1:
        {
            if (self.disturbSwitch.isOn) {
                count = 2;
            } else {
                count = 1;
            }
        }
            break;
        case 2:
            count = 1;
            break;
            
        default:
            break;
    }
    
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"UITableViewCell"];
        cell.detailTextLabel.textColor = [UIColor grayColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    cell.textLabel.textColor = [UIColor blackColor];
    cell.detailTextLabel.text = @"";
    cell.accessoryView = nil;
    cell.accessoryType = UITableViewCellAccessoryNone;
    if (section == 0) {
        if (row == 0) {
            cell.textLabel.text = @"头像";
            cell.accessoryView = self.headerView;
        } else if (row == 1) {
            cell.textLabel.text = @"用户ID";
            cell.detailTextLabel.text = [EMClient sharedClient].currentUsername;
        } else if (row == 2) {
            cell.textLabel.text = @"昵称";
            cell.detailTextLabel.text = [EMClient sharedClient].pushOptions.displayName;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    } else if (section == 1) {
        if (row == 0) {
            cell.textLabel.text = @"免打扰";
            cell.accessoryView = self.disturbSwitch;
        } else if (row == 1) {
            cell.textLabel.text = @"免打扰时间";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            EMPushOptions *options = [EMClient sharedClient].pushOptions;
            if (options.noDisturbingStartH > 0 && options.noDisturbingEndH > 0) {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@", @(options.noDisturbingStartH), @(options.noDisturbingEndH)];
            }
        }
    } else if (section == 2) {
        if (row == 0) {
            cell.textLabel.textColor = [UIColor redColor];
            cell.textLabel.text = @"退出登录";
        }
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 55;
    if (indexPath.section == 0 && indexPath.row == 0) {
        height = 80;
    }
    
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 20;
    }
    
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 20;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:13];
        label.textColor = [UIColor lightGrayColor];
        label.text = @"    iOS APNS推送时使用的显示昵称";
        return label;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (section == 0) {
        if (row == 2) {
            
        }
    } else if (section == 1) {
        if (row == 1) {
            
        }
    } else if (section == 2) {
        if (row == 0) {
            [self logoutAction];
        }
    }
}

#pragma mark - Action

- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)disturbValueChanged
{
    [self.tableView reloadData];
}

- (void)_updateNikeName:(NSString *)aName
{
    __weak typeof(self) weakself = self;
    //设置推送设置
    [self showHint:@"正在更新昵称..."];
    [[EMClient sharedClient] setApnsNickname:aName];
    [self hideHud];
}

- (void)changeNikeNameAction
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"更改昵称" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"请输入昵称";
        textField.text = [EMClient sharedClient].pushOptions.displayName;;
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:cancelAction];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UITextField *textField = alertController.textFields.firstObject;
        [self showHint:NSLocalizedString(@"setting.saving", "saving...")];
        [[EMClient sharedClient] setApnsNickname:textField.text];
        
    }];
    [alertController addAction:okAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)logoutAction
{
    __weak typeof(self) weakself = self;
    [self showHudInView:self.view hint:NSLocalizedString(@"setting.logoutOngoing", @"loging out...")];
    [[EMClient sharedClient] logout:YES completion:^(EMError *aError) {
        [weakself hideHud];
        if (aError) {
            [EMAlertController showErrorAlert:aError.errorDescription];
        } else {
            EMDemoOptions *options = [EMDemoOptions sharedOptions];
            options.isAutoLogin = NO;
            options.loggedInUsername = @"";
            [options archive];
            
//            [[ApplyViewController shareController] clear];
            [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@NO];
        }
    }];
}

@end
