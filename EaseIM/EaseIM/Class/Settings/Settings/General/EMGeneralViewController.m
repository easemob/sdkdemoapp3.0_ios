//
//  EMGeneralViewController.m
//  EaseIM
//
//  Updated by zhangchong on 2020/6/10.
//  Copyright © 2018 XieYajie. All rights reserved.
//

#import "EMGeneralViewController.h"
#import "SPDateTimePickerView.h"

#import "EMDemoOptions.h"
#import "EMServiceCheckViewController.h"

@interface EMGeneralViewController ()<SPDateTimePickerViewDelegate>

@property (nonatomic, strong) NSString *logPath;

@property (nonatomic, strong) UISwitch *disturbSwitch;

@end

@implementation EMGeneralViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.showRefreshHeader = NO;
    // Uncomment the following line to preserve selection between presentations.
    [self _setupSubviews];
}

#pragma mark - Subviews

- (void)_setupSubviews
{
    [self addPopBackLeftItem];
    self.title = @"通用";
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
    
    self.disturbSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width - 65, 20, 50, 40)];
    [self.disturbSwitch addTarget:self action:@selector(disturbValueChanged) forControlEvents:UIControlEventValueChanged];
    //NSLog(@"pushoption   :%@        disturb   %u",[EMClient sharedClient].pushOptions,[EMClient sharedClient].pushOptions.noDisturbStatus);
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
        {
            if (!self.disturbSwitch.isOn) {
                count = 1;
            } else {
                count = 2;
            }
        }
            break;
        case 1:
            count = 1;
            break;
        case 2:
            count = 2;
            break;
        default:
            break;
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    NSString *cellIdentifier = @"UITableViewCellSwitch";
    if (section == 0 && row == 1) {
        cellIdentifier = @"UITableViewCellValue1";
    }
    
    UISwitch *switchControl = nil;
    BOOL isSwitchCell = NO;
    if (section != 0) {
        isSwitchCell = YES;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (isSwitchCell) {
            switchControl = [[UISwitch alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width - 65, 20, 50, 40)];
            switchControl.tag = [self _tagWithIndexPath:indexPath];
            [switchControl addTarget:self action:@selector(cellSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
            [cell.contentView addSubview:switchControl];
        }
    }
    
    EMDemoOptions *options = [EMDemoOptions sharedOptions];
    
    cell.detailTextLabel.text = nil;
    cell.accessoryType = UITableViewCellAccessoryNone;

    if (section == 0) {
        if (row == 0) {
            cell.textLabel.text = @"消息免打扰";
            cell.accessoryView = self.disturbSwitch;
        } else if (row == 1) {
            cell.textLabel.text = @"免打扰时间";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            if ([EMClient sharedClient].pushOptions.noDisturbingStartH > 0 && [EMClient sharedClient].pushOptions.noDisturbingEndH > 0) {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@:00 - %@:00", @([EMClient sharedClient].pushOptions.noDisturbingStartH), @([EMClient sharedClient].pushOptions.noDisturbingEndH)];
            } else {
                cell.detailTextLabel.text = @"全天";
            }
        }
    } else if (section == 1) {
        if (row == 0) {
            cell.textLabel.text = @"显示输入状态";
            [switchControl setOn:options.isChatTyping animated:NO];
        }
    } else if (section == 2) {
        if (row == 0) {
            cell.textLabel.text = @"自动接受群组邀请";
            [switchControl setOn:options.isAutoAcceptGroupInvitation animated:NO];
        } else if (row == 1) {
            cell.textLabel.text = @"退出群组时删除会话";
            [switchControl setOn:options.isDeleteMessagesWhenExitGroup animated:NO];
        }
    }
    cell.textLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
    cell.textLabel.font = [UIFont systemFontOfSize:14.0];
    cell.separatorInset = UIEdgeInsetsMake(0, 16, 0, 16);
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0.001;
    }
    if (section == 2) {
        return 46;
    }
    return 16;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 2) {
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:14.0];
        label.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
        label.text = @"     群组设置";
        label.textAlignment = NSTextAlignmentLeft;
        return label;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 66;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (section == 0) {
        if (row == 1) {
            [self changeDisturbDateAction];
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

#pragma mark - Action

- (void)cellSwitchValueChanged:(UISwitch *)aSwitch
{
    EMDemoOptions *options = [EMDemoOptions sharedOptions];
    NSIndexPath *indexPath = [self _indexPathWithTag:aSwitch.tag];
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (section == 1) {
        options.isChatTyping = aSwitch.isOn;
        [[EMDemoOptions sharedOptions] archive];
    } else if (section == 2) {
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

- (void)disturbValueChanged
{
    __weak typeof(self) weakself = self;
    EMPushOptions *options = [[EMClient sharedClient] pushOptions];
    options.noDisturbStatus = EMPushNoDisturbStatusDay;
    options.noDisturbingStartH = 0;
    options.noDisturbingEndH = 24;
    if (!self.disturbSwitch.isOn) {
        options.noDisturbingEndH = 0;
        options.noDisturbStatus = EMPushNoDisturbStatusClose;
    }
    [[EMClient sharedClient] updatePushNotificationOptionsToServerWithCompletion:^(EMError *aError) {
        if (aError) {
            [weakself.disturbSwitch setOn:!weakself.disturbSwitch.isOn animated:YES];
            [EMAlertController showErrorAlert:aError.errorDescription];
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself.tableView reloadData];
        });
    }];
}

- (void)changeDisturbDateAction
{
    SPDateTimePickerView *pickerView = [[SPDateTimePickerView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width,  self.view.frame.size.height)];
    pickerView.pickerViewMode = SPDatePickerModeTime;
    pickerView.delegate = self;
    pickerView.title = @"设置时间段";
    [self.view addSubview:pickerView];
    [pickerView showDateTimePickerView];
}

#pragma mark - SPDateTimePickerViewDelegate
- (void)didClickFinishDateTimePickerView:(NSString *)date {
    __weak typeof(self) weakself = self;
    NSLog(@"%@",date);
    NSRange range = [date rangeOfString:@"-"];
    NSString *start = [date substringToIndex:range.location];
    NSString *end = [date substringFromIndex:range.location + 1];
    if ([start isEqualToString:end]) {
        [self showHint:@"起止时间不能相同"];
        return;
    }
    EMPushOptions *options = [[EMClient sharedClient] pushOptions];
    options.noDisturbingStartH = [start intValue];
    options.noDisturbingEndH = [end intValue];
    options.noDisturbStatus = EMPushNoDisturbStatusCustom;
    [[EMClient sharedClient] updatePushNotificationOptionsToServerWithCompletion:^(EMError *aError) {
        if (!aError) {
            [weakself hideHud];
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakself.tableView reloadData];
            });
        } else {
            [EMAlertController showErrorAlert:aError.errorDescription];
        }
    }];
}

@end
