//
//  EMDeveloperServiceViewController.m
//  EaseIM
//
//  Created by 娜塔莎 on 2020/6/9.
//  Copyright © 2020 娜塔莎. All rights reserved.
//

#import "EMDeveloperServiceViewController.h"
#import "EMCustomAppkeyViewController.h"

@interface EMDeveloperServiceViewController ()

@end

@implementation EMDeveloperServiceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _setupSubviews];
    self.showRefreshHeader = NO;
}

#pragma mark - Subviews

- (void)_setupSubviews
{
    [self addPopBackLeftItem];
    self.title = @"开发者服务";
    self.view.backgroundColor = [UIColor colorWithRed:249/255.0 green:249/255.0 blue:249/255.0 alpha:1.0];
    
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
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = 1;
    if (section == 1) {
        count = 3;
    } else if (section == 2) {
        count = 2;
    }
    return count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    NSString *identify = nil;
    BOOL isSwitch = NO;
    if (section == 0 || (section == 1 && row == 0) || (section == 2 && row == 1) || (section == 3)) {
        identify = @"UITableViewCellStyleValue1";
    } else {
        identify = @"UITableViewCellSwitch";
        isSwitch = YES;
    }
    UISwitch *switchControl = nil;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identify];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (isSwitch) {
            switchControl = [[UISwitch alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width - 65, 20, 50, 40)];
            switchControl.tag = [self _tagWithIndexPath:indexPath];
            [switchControl addTarget:self action:@selector(cellSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
            [cell.contentView addSubview:switchControl];
        }
    }

    EMDemoOptions *options = [EMDemoOptions sharedOptions];
    if (section == 0) {
        cell.textLabel.text = @"当前SDK版本";
        cell.detailTextLabel.text = [NSString stringWithFormat:@"V %@",[EMClient sharedClient].version];
        cell.accessoryType = UITableViewCellSelectionStyleNone;
    } else if (section == 1) {
        if (row == 0) {
            cell.textLabel.text = @"自定义APPKey";
            cell.detailTextLabel.text = [EMDemoOptions.sharedOptions.appkey isEqualToString:DEF_APPKEY] ? @"默认" : EMDemoOptions.sharedOptions.appkey;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else if (row == 1) {
            cell.textLabel.text = @"优先从服务器获取消息";
            [switchControl setOn:options.isPriorityGetMsgFromServer animated:NO];
        } else if (row == 2) {
            cell.textLabel.text = @"消息附件上传到环信服务器";
            [switchControl setOn:options.isAutoTransferMessageAttachments animated:NO];
        }
    } else if (section == 2) {
        if (row == 0) {
            cell.textLabel.text = @"自动下载图片缩略图";
            [switchControl setOn:options.isAutoDownloadThumbnail animated:NO];
        } else if (row == 1) {
            cell.textLabel.text = @"消息排序";
            cell.detailTextLabel.text = options.isSortMessageByServerTime ? @"按服务器时间" : @"按接收顺序";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    cell.textLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
    cell.textLabel.font = [UIFont systemFontOfSize:14.0];
    cell.detailTextLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:14.0];
    [cell setSeparatorInset:UIEdgeInsetsMake(0, 16, 0, 16)];
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (section == 1 && row == 0) {
        //自定义appkey
        EMCustomAppkeyViewController *customAppkeyController = [[EMCustomAppkeyViewController alloc]init];
        [self.navigationController pushViewController:customAppkeyController animated:NO];
    } else if (section == 2 && row == 1) {
        [self updateMessageSort];
    } else if (section == 3) {
        //诊断
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0.0001;
    }
    
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 1) {
        return 46;
    }
    
    return 16;
}

#pragma mark - Action

- (void)cellSwitchValueChanged:(UISwitch *)aSwitch
{
    EMDemoOptions *options = [EMDemoOptions sharedOptions];
    NSIndexPath *indexPath = [self _indexPathWithTag:aSwitch.tag];
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (section == 1) {
        if (row == 1) {
            options.isPriorityGetMsgFromServer = aSwitch.isOn;
            [options archive];
        } else if (row == 2) {
            [EMClient sharedClient].options.isAutoTransferMessageAttachments = aSwitch.isOn;
            options.isAutoTransferMessageAttachments = aSwitch.isOn;
            [options archive];
        }
    } else if (section == 2) {
        [EMClient sharedClient].options.isAutoDownloadThumbnail = aSwitch.isOn;
        options.isAutoDownloadThumbnail = aSwitch.isOn;
        [options archive];
    }
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 1) {
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:12.0];
        label.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
        label.text = @"    上传附件到环信服务器，关闭需自定义文件上传";
        return label;
    }
    
    return nil;
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

//修改消息排序
- (void)updateMessageSort
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"消息排序" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    EMDemoOptions *options = [EMDemoOptions sharedOptions];
    [alertController addAction:[UIAlertAction actionWithTitle:@"按服务器时间" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        options.isSortMessageByServerTime = YES;
        [options archive];
        [EMClient sharedClient].options.sortMessageByServerTime = YES;
        [self.tableView reloadData];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"按接收顺序" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        options.isSortMessageByServerTime = NO;
        [options archive];
        [EMClient sharedClient].options.sortMessageByServerTime = NO;
        [self.tableView reloadData];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
