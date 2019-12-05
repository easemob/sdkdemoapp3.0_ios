//
//  EMMsgNotificViewController.m
//  EMiOSDemo
//
//  Created by 娜塔莎 on 2019/11/28.
//  Copyright © 2019 娜塔莎. All rights reserved.
//

#import "EMMsgNotificViewController.h"
#import "YYBasicTickView.h"


#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define YY_COLOR UIColorFromRGB(0x2ecb94)

@interface EMMsgNotificViewController ()<YYBasicTickViewDelegate>

@end

@implementation EMMsgNotificViewController

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
    self.title = @"消息通知";
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

    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return 2;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    NSString *cellIdentifier = @"UITableViewCellAccessoryDetailDisclosureButton";
    if (section == 1) {
        cellIdentifier = @"UITableViewCellSwitch";
    }
    
    YYBasicTickView *basicTick = nil;
    UISwitch *switchControl = nil;
    
    BOOL isSwitchCell = NO;
    if (section == 1) {
        isSwitchCell = YES;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if (isSwitchCell) {
        switchControl = [[UISwitch alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width - 65, 20, 50, 40)];
        switchControl.tag = [self _tagWithIndexPath:indexPath];
        [switchControl addTarget:self action:@selector(cellSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
        [cell.contentView addSubview:switchControl];
    } else {
        basicTick = [[YYBasicTickView alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width - 45, 20, 25, 25) backGroundColor:YY_COLOR tickColor:[UIColor whiteColor]];
        [cell.contentView addSubview:basicTick];
        basicTick.index = [self _tagWithIndexPath:indexPath];
        basicTick.basicTickDelegate = self;
    }
    
    EMPushOptions *options = [[EMClient sharedClient] pushOptions];

    if (section == 0) {
        if (row == 0) {
            cell.textLabel.text = @"仅未读提示";
            if (options.displayStyle == EMPushDisplayStyleSimpleBanner) {
                [basicTick setTick:YES];
            } else {
                [basicTick setTick:NO];
            }
        } else if (row == 1) {
            cell.textLabel.text = @"详细信息";
            if (options.displayStyle == EMPushDisplayStyleMessageSummary) {
                [basicTick setTick:YES];
            } else {
                [basicTick setTick:NO];
            }
        }
        [basicTick setNeedsDisplay];
    } else if (section == 1) {
        if (row == 0) {
            cell.textLabel.text = @"语音通话邀请提示";
            [switchControl setOn:YES animated:NO];
        } else if (row == 1) {
            cell.textLabel.text = @"视频通话邀请提示";
            [switchControl setOn:YES animated:NO];
        }
    }
    [cell setSeparatorInset:UIEdgeInsetsMake(0, 16, 0, 16)];
    return cell;
}

#pragma mark - YYBasicTickViewDelegate
- (void)basicTickViewValueChanged:(YYBasicTickView *)tickView
{
    NSLog(@"Basic:%d",tickView.isTick);
    NSIndexPath *indexPath = [self _indexPathWithTag:tickView.index];
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (section == 0) {
        if (row == 0) {
            [self _updatePushStyle:EMPushDisplayStyleSimpleBanner];
        } else if (row == 1) {
            [self _updatePushStyle:EMPushDisplayStyleMessageSummary];
        }
        [self.tableView reloadData];
    }
    
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0.001;
    }
    
    return 10;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10;
}

#pragma mark - Private

- (void)_updatePushStyle:(EMPushDisplayStyle)aStyle
{
    [self showHint:@"更新通知消息显示类型..."];
    EMPushOptions *options = [[EMClient sharedClient] pushOptions];
    options.displayStyle = aStyle;
    [[EMClient sharedClient] updatePushOptionsToServer];
    [self hideHud];
}

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

#pragma mark - Action

- (void)cellSwitchValueChanged:(UISwitch *)aSwitch
{
    EMDemoOptions *options = [EMDemoOptions sharedOptions];
    NSIndexPath *indexPath = [self _indexPathWithTag:aSwitch.tag];
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (section == 0) {
        if (row == 0) {
            //[self disturbValueChanged:aSwitch.isOn];
        } else if (row == 1) {
            
        }
    }
}

@end