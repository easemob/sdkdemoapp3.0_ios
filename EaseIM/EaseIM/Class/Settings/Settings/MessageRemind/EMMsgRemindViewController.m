//
//  EMMsgRemindViewController.m
//  EaseIM
//
//  Created by 娜塔莎 on 2020/6/10.
//  Copyright © 2020 娜塔莎. All rights reserved.
//

#import "EMMsgRemindViewController.h"
#import "EMMsgNotificViewController.h"

@interface EMMsgRemindViewController ()
@property (nonatomic, strong) UISwitch *msgRemindSwitch;
@end

@implementation EMMsgRemindViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.showRefreshHeader = NO;
    // Uncomment the following line to preserve selection between presentations.
    [self _setupSubviews];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
}

#pragma mark - Subviews

- (void)_setupSubviews
{
    [self addPopBackLeftItem];
    self.title = @"新消息提醒";
    self.view.backgroundColor = [UIColor colorWithRed:249/255.0 green:249/255.0 blue:249/255.0 alpha:1.0];
    
    self.tableView.scrollEnabled = NO;
    self.tableView.rowHeight = 66;
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.backgroundColor = kColor_LightGray;
    self.tableView.scrollEnabled = NO;
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    
    self.msgRemindSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width - 65, 20, 50, 40)];
    [self.msgRemindSwitch addTarget:self action:@selector(msgRemindValueChanged) forControlEvents:UIControlEventValueChanged];
    EMDemoOptions *options = [EMDemoOptions sharedOptions];
    [self.msgRemindSwitch setOn:options.isReceiveNewMsgNotice animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.msgRemindSwitch.isOn) {
        return 2;
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    NSString *cellIdentifier = @"UITableViewCellSwitch";
    if (section == 0 && row == 1) {
        cellIdentifier = @"UITableViewCellValue1";
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.detailTextLabel.text = nil;
    cell.accessoryType = UITableViewCellAccessoryNone;

    if (section == 0) {
        if (row == 0) {
            cell.textLabel.text = @"接收新消息通知";
            cell.accessoryView = self.msgRemindSwitch;
        } else if (row == 1) {
            cell.textLabel.text = @"显示消息详情";
            cell.detailTextLabel.text = [EMClient sharedClient].pushOptions.displayStyle == EMPushDisplayStyleSimpleBanner ? @"仅未读提示" : @"详细信息";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    cell.textLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
    cell.textLabel.font = [UIFont systemFontOfSize:14.0];
    cell.detailTextLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:14.0];
    cell.separatorInset = UIEdgeInsetsMake(0, 16, 0, 16);
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 46;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:14];
        label.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
        label.text = @"     新消息通知";
        label.textAlignment = NSTextAlignmentLeft;
        return label;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    if (row == 1) {
        EMMsgNotificViewController *controller = [[EMMsgNotificViewController alloc] init];
        [self.navigationController pushViewController:controller animated:NO];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 66;
}

- (void)msgRemindValueChanged
{
    EMDemoOptions *options = [EMDemoOptions sharedOptions];
    options.isReceiveNewMsgNotice = self.msgRemindSwitch.isOn;
    [options archive];
    [self.tableView reloadData];
}

@end
