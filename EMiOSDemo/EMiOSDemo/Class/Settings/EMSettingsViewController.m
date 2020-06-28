//
//  EMSettingsViewController.m
//  EMiOSDemo
//
//  Created by 娜塔莎 on 2020/6/10.
//  Copyright © 2020 娜塔莎. All rights reserved.
//

#import "EMSettingsViewController.h"
#import "EMSecurityViewController.h"
#import "EMGeneralViewController.h"
#import "EMMsgRemindViewController.h"
#import "EMSecurityPrivacyViewController.h"

@interface EMSettingsViewController ()

@end

@implementation EMSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _setupSubviews];
    self.showRefreshHeader = NO;
}

#pragma mark - Subviews

- (void)_setupSubviews
{
    [self addPopBackLeftItem];
    self.title = @"设置";
    self.view.backgroundColor = [UIColor colorWithRed:249/255.0 green:249/255.0 blue:249/255.0 alpha:1.0];
    
    self.tableView.rowHeight = 66;
    self.tableView.backgroundColor = kColor_LightGray;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 20)];
    self.tableView.scrollEnabled = NO;
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCellStyleValue1"];
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"UITableViewCellStyleValue1"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    if (section == 0) {
        if (row == 0) {
            cell.textLabel.text = @"账号与安全";
        } else if (row == 1) {
            cell.textLabel.text = @"新消息提醒";
        }
    } else if (section == 1) {
        if (row == 0) {
            cell.textLabel.text = @"通用";
        } else if (row == 1) {
            cell.textLabel.text = @"隐私";
        }
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    [cell setSeparatorInset:UIEdgeInsetsMake(0, 16, 0, 16)];
    cell.textLabel.font = [UIFont systemFontOfSize:14.f];
    cell.textLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (section == 0) {
        if (row == 0) {
            EMSecurityViewController *securityController = [[EMSecurityViewController alloc]init];
            [self.navigationController pushViewController:securityController animated:YES];
        } else if (row == 1) {
            EMMsgRemindViewController *msgRemindController = [[EMMsgRemindViewController alloc]init];
            [self.navigationController pushViewController:msgRemindController animated:YES];
        }
    } else if (section == 1) {
        if (row == 0) {
            EMGeneralViewController *generalController = [[EMGeneralViewController alloc]init];
            [self.navigationController pushViewController:generalController animated:YES];
        } else if (row == 1) {
            EMSecurityPrivacyViewController *securityPrivacyController = [[EMSecurityPrivacyViewController alloc]init];
            [self.navigationController pushViewController:securityPrivacyController animated:YES];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0.001;
    }
    return 16;
}

@end
