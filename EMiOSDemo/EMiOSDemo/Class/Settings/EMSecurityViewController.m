//
//  EMSecurityViewController.m
//  EMiOSDemo
//
//  Created by 娜塔莎 on 2019/12/5.
//  Copyright © 2019 娜塔莎. All rights reserved.
//

#import "EMSecurityViewController.h"
#import "EMBlacklistViewController.h"
#import "EMDevicesViewController.h"

@interface EMSecurityViewController ()

@end

@implementation EMSecurityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _setupSubviews];
    self.showRefreshHeader = NO;
    // Do any additional setup after loading the view.
}

- (void)_setupSubviews
{
    [self addPopBackLeftItem];
    self.title = @"安全与隐私";
    self.view.backgroundColor = [UIColor colorWithRed:249/255.0 green:249/255.0 blue:249/255.0 alpha:1.0];

    self.tableView.scrollEnabled = NO;
    self.tableView.rowHeight = 60;
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.backgroundColor = [UIColor whiteColor];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.equalTo(@130);
    }];

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"UITableViewCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    UIImageView *imgView = [[UIImageView alloc]init];
    [cell.contentView addSubview:imgView];
    [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(cell.contentView);
        make.left.equalTo(cell.contentView).offset(20);
    }];
    [cell.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(imgView.mas_right).offset(18);
        make.centerY.equalTo(cell.contentView);
    }];
    
    if (section == 0) {
        if (row == 0) {
            imgView.image = [UIImage imageNamed:@"黑名单"];
            cell.textLabel.text = @"黑名单";
        } else if (row == 1) {
            imgView.image = [UIImage imageNamed:@"多端多设备管理"];
            cell.textLabel.text = @"多端多设备管理";
        }
    }
    
    cell.textLabel.font = [UIFont systemFontOfSize:14.0];
    cell.separatorInset = UIEdgeInsetsMake(0, 16, 0, 16);
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.001;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (section == 0) {
        if (row == 0) {
            EMBlacklistViewController *controller = [[EMBlacklistViewController alloc] init];
            [self.navigationController pushViewController:controller animated:YES];
        } else if (row == 1) {
            EMDevicesViewController *controller = [[EMDevicesViewController alloc] initWithStyle:UITableViewStylePlain];
            [self.navigationController pushViewController:controller animated:YES];
        }
    }
}

@end
