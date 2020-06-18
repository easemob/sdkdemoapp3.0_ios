//
//  EMPrivacyViewController.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2018/12/27.
//  Copyright © 2018 XieYajie. All rights reserved.
//

#import "EMPrivacyViewController.h"

#import "EMDemoOptions.h"

@interface EMPrivacyViewController ()

@property (nonatomic, strong) UISwitch *typingSwitch;

@property (nonatomic, strong) UISwitch *autoRecvAckSwitch;

@end

@implementation EMPrivacyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    [self _setupSubviews];
}

#pragma mark - Subviews

- (void)_setupSubviews
{
    [self addPopBackLeftItem];
    self.title = @"隐私";
    self.view.backgroundColor = [UIColor colorWithRed:249/255.0 green:249/255.0 blue:249/255.0 alpha:1.0];
    
    self.tableView.rowHeight = 55;
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.backgroundColor = kColor_LightGray;

    self.typingSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 50, 40)];
    [self.typingSwitch addTarget:self action:@selector(typingSwitchValueChanged) forControlEvents:UIControlEventValueChanged];
    [self.typingSwitch setOn:[EMDemoOptions sharedOptions].isChatTyping animated:YES];

    self.autoRecvAckSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 50, 40)];
    [self.autoRecvAckSwitch addTarget:self action:@selector(autoReadAckSwitchValueChanged) forControlEvents:UIControlEventValueChanged];
    [self.autoRecvAckSwitch setOn:[EMDemoOptions sharedOptions].isAutoDeliveryAck animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
    }
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        cell.textLabel.text = @"显示正在输入";
        self.typingSwitch.frame = CGRectMake(self.tableView.frame.size.width - 65, 10, 40, 40);
        [cell.contentView addSubview:self.typingSwitch];
    } else if (indexPath.section == 1 && indexPath.row == 0) {
        cell.textLabel.text = @"自动发送消息已送达回执";
        self.autoRecvAckSwitch.frame = CGRectMake(self.tableView.frame.size.width - 65, 10, 40, 40);
        [cell.contentView addSubview:self.autoRecvAckSwitch];
    }
    
    return cell;
}


#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 20;
    }
    
    return 10;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 30;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:13];
        label.textColor = [UIColor lightGrayColor];
        label.text = @"    单聊时,若正在输入中,对方可看到输入状态";
        return label;
    } else if (section == 1) {
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:13];
        label.textColor = [UIColor lightGrayColor];
        label.text = @"    打开消息后,自动将用户发来的消息置为已读";
        return label;
    }
    
    return nil;
}

#pragma mark - Action

- (void)typingSwitchValueChanged
{
    [EMDemoOptions sharedOptions].isChatTyping = self.typingSwitch.isOn;
    [[EMDemoOptions sharedOptions] archive];
}

- (void)autoReadAckSwitchValueChanged
{
    [EMDemoOptions sharedOptions].isAutoDeliveryAck = self.autoRecvAckSwitch.isOn;
    [[EMDemoOptions sharedOptions] archive];
    
    [[EMClient sharedClient].options setEnableDeliveryAck:self.autoRecvAckSwitch.on];
}

@end
