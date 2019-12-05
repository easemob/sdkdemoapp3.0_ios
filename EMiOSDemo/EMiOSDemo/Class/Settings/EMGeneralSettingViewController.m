//
//  EMGeneralSettingViewController.m
//  EMiOSDemo
//
//  Created by 娜塔莎 on 2019/11/28.
//  Copyright © 2019 娜塔莎. All rights reserved.
//

#import "EMGeneralSettingViewController.h"

@interface EMGeneralSettingViewController ()

@end

@implementation EMGeneralSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.showRefreshHeader = YES;
    // Uncomment the following line to preserve selection between presentations.
    [self _setupSubviews];
}

#pragma mark - Subviews

- (void)_setupSubviews
{
    [self addPopBackLeftItem];
    self.title = @"通用设置";
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.tableView.rowHeight = 66;
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.backgroundColor = kColor_LightGray;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 20)];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
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
    NSString *cellIdentifier = @"UITableViewCellSwitch";

    UISwitch *switchControl = nil;

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    switchControl = [[UISwitch alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width - 65, 20, 50, 40)];
    switchControl.tag = [self _tagWithIndexPath:indexPath];
    [switchControl addTarget:self action:@selector(cellSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
    [cell.contentView addSubview:switchControl];

    EMDemoOptions *options = [EMDemoOptions sharedOptions];
    if (row == 0) {
        cell.textLabel.text = @"自动接受群组邀请";
        [switchControl setOn:options.isAutoAcceptGroupInvitation animated:NO];
    } else if (row == 1) {
        cell.textLabel.text = @"退出群组时删除会话";
        [switchControl setOn:options.isDeleteMessagesWhenExitGroup animated:NO];
    }
    
    [cell setSeparatorInset:UIEdgeInsetsMake(0, 16, 0, 16)];
    return cell;
}

#pragma mark - Action

- (void)cellSwitchValueChanged:(UISwitch *)aSwitch
{
    EMDemoOptions *options = [EMDemoOptions sharedOptions];
    NSIndexPath *indexPath = [self _indexPathWithTag:aSwitch.tag];
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (section == 0) {
        if (row == 0) {
            [EMClient sharedClient].options.isAutoAcceptGroupInvitation = aSwitch.isOn;
            options.isAutoAcceptGroupInvitation = aSwitch.isOn;
            [options archive];
        } else if (row == 1) {
            [EMClient sharedClient].options.isDeleteMessagesWhenExitGroup = aSwitch.isOn;
            options.isDeleteMessagesWhenExitGroup = aSwitch.isOn;
            [options archive];
        }
    }
}

#pragma mark - Private
- (NSInteger)_tagWithIndexPath:(NSIndexPath *)aIndexPath
{
    NSInteger tag = aIndexPath.section * 10 + aIndexPath.row;
    return tag;
}

- (NSIndexPath *)_indexPathWithTag:(NSInteger)aTag
{
    NSInteger section = aTag / 10;
    NSInteger row = aTag % 10;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
    return indexPath;
}

@end