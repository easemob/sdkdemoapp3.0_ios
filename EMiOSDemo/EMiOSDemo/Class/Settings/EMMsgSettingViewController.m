//
//  EMGeneralViewController.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2018/12/28.
//  Copyright © 2018 XieYajie. All rights reserved.
//

#import <MessageUI/MFMailComposeViewController.h>
#import <MessageUI/MessageUI.h>
#import "EMMsgSettingViewController.h"
#import "EMMsgNotificViewController.h"
#import "SPDateTimePickerView.h"

#import "EMDemoOptions.h"
#import "EMServiceCheckViewController.h"

@interface EMMsgSettingViewController ()<MFMailComposeViewControllerDelegate,SPDateTimePickerViewDelegate>

@property (nonatomic, strong) NSString *logPath;

@property (nonatomic, strong) UISwitch *disturbSwitch;

@end

@implementation EMMsgSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    self.title = @"消息设置";
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.tableView.rowHeight = 66;
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.backgroundColor = kColor_LightGray;
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    
    self.disturbSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width - 65, 20, 50, 40)];
    [self.disturbSwitch addTarget:self action:@selector(disturbValueChanged) forControlEvents:UIControlEventValueChanged];
    [self.disturbSwitch setOn:([EMClient sharedClient].pushOptions.noDisturbStatus == EMPushNoDisturbStatusClose ? NO : YES) animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
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
        case 3:
            count = 3;
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
    if (section == 2 || (section == 0 && row == 1)) {
        cellIdentifier = @"UITableViewCellValue1";
    }
    
    UISwitch *switchControl = nil;
    BOOL isSwitchCell = NO;
    if (section == 1 || section == 3) {
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
    }
    
    EMDemoOptions *options = [EMDemoOptions sharedOptions];
    
    cell.detailTextLabel.text = nil;
    cell.accessoryType = UITableViewCellAccessoryNone;
    /*
    if (row == 0) {
        cell.separatorInset = UIEdgeInsetsMake(0, [UIScreen mainScreen].bounds.size.width, 0, 0);
    }*/
    if (section == 0) {
        if (row == 0) {
            cell.textLabel.text = @"消息免打扰";
            cell.accessoryView = self.disturbSwitch;
            
            //[switchControl setOn:([EMClient sharedClient].pushOptions.noDisturbStatus == EMPushNoDisturbStatusClose ? NO : YES) animated:NO];
        } else if (row == 1) {
            cell.textLabel.text = @"免打扰时间";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            EMPushOptions *options = [EMClient sharedClient].pushOptions;
            if (options.noDisturbingStartH >= 0 && options.noDisturbingEndH >= 0) {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@:00 - %@:00", @(options.noDisturbingStartH), @(options.noDisturbingEndH)];
            } else {
                cell.detailTextLabel.text = @"空";
            }
        }
    } else if (section == 1) {
        if (row == 0) {
            cell.textLabel.text = @"发送我的输入状态";
            [switchControl setOn:options.isChatTyping animated:NO];
        }
    } else if (section == 2) {
        if (row == 0) {
            cell.textLabel.text = @"消息通知";
            cell.detailTextLabel.text = [EMClient sharedClient].pushOptions.displayStyle == EMPushDisplayStyleSimpleBanner ? @"仅未读提示" : @"详情信息";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else if (row == 1) {
            cell.textLabel.text = @"消息排序";
            cell.detailTextLabel.text = options.isSortMessageByServerTime ? @"按服务器时间" : @"按接收顺序";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    } else if (section == 3) {
        if (row == 0) {
            cell.textLabel.text = @"自动下载图片缩略图";
            [switchControl setOn:options.isAutoDownloadThumbnail animated:NO];
        } else if (row == 1) {
            cell.textLabel.text = @"消息附件上传到环信服务器";
            [switchControl setOn:options.isAutoTransferMessageAttachments animated:NO];
        } else if (row == 2) {
            cell.textLabel.text = @"优先从服务器获取消息";
            [switchControl setOn:options.isPriorityGetMsgFromServer animated:NO];
        }
    }
    cell.separatorInset = UIEdgeInsetsMake(0, 16, 0, 16);
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0.0001;
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
    } else if (section == 2) {
        if (row == 0) {
            [self msgNotiDetil];
        } else if (row == 1) {
            [self updateMessageSort];
        }
    }
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(nullable NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            [EMAlertController showInfoAlert:@"邮件保存成功"];
            break;
        case MFMailComposeResultSaved:
            [EMAlertController showSuccessAlert:@"邮件保存成功"];
            break;
        case MFMailComposeResultSent:
            [EMAlertController showSuccessAlert:@"邮件发送成功"];
            break;
        case MFMailComposeResultFailed:
            [EMAlertController showErrorAlert:@"邮件发送失败"];
            break;
        default:
            break;
    }
    
    [[NSFileManager defaultManager] removeItemAtPath:self.logPath error:nil];
    self.logPath = nil;
    
    [self dismissViewControllerAnimated:YES completion:nil];
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
        if (row == 0) {
            options.isChatTyping = aSwitch.isOn;
            [[EMDemoOptions sharedOptions] archive];
        }
    } else if (section == 3) {
        if (row == 0) {
            [EMClient sharedClient].options.isAutoDownloadThumbnail = aSwitch.isOn;
            options.isAutoDownloadThumbnail = aSwitch.isOn;
            [options archive];
        } else if (row == 1) {
            [EMClient sharedClient].options.isAutoTransferMessageAttachments = aSwitch.isOn;
            options.isAutoTransferMessageAttachments = aSwitch.isOn;
            [options archive];
        } else if (row == 2) {
            options.isPriorityGetMsgFromServer = aSwitch.isOn;
            [options archive];
        }
    }
}

- (void)disturbValueChanged
{
    [self.tableView reloadData];
    
    if (!self.disturbSwitch.isOn) {
        [self showHint:@"更新免打扰设置..."];
        EMPushOptions *options = [[EMClient sharedClient] pushOptions];
        options.noDisturbingStartH = 0;
        options.noDisturbingEndH = 0;
        options.noDisturbStatus = EMPushNoDisturbStatusClose;
        [[EMClient sharedClient] updatePushOptionsToServer];
        [self hideHud];
    }
}

- (void)changeDisturbDateAction
{
    
    SPDateTimePickerView *pickerView = [[SPDateTimePickerView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width,  self.view.frame.size.height)];
    pickerView.pickerViewMode = 6;
    pickerView.delegate = self;
    pickerView.title = @"设置时间段";
    [self.view addSubview:pickerView];
    [pickerView showDateTimePickerView];
}

#pragma mark - SPDateTimePickerViewDelegate
- (void)didClickFinishDateTimePickerView:(NSString *)date {
    NSLog(@"%@",date);
    NSRange range = [date rangeOfString:@"-"];
    NSString *start = [date substringToIndex:range.location];
    NSString *end = [date substringFromIndex:range.location + 1];
    EMPushOptions *options = [[EMClient sharedClient] pushOptions];
    options.noDisturbingStartH = [start intValue];
    options.noDisturbingEndH = [end intValue];
    options.noDisturbStatus = EMPushNoDisturbStatusDay;
    [[EMClient sharedClient] updatePushOptionsToServer];
    [self.tableView reloadData];
}

- (void)_updatePushStyle:(EMPushDisplayStyle)aStyle
{
    [self showHint:@"更新通知消息显示类型..."];
    EMPushOptions *options = [[EMClient sharedClient] pushOptions];
    options.displayStyle = aStyle;
    [[EMClient sharedClient] updatePushOptionsToServer];
    [self.tableView reloadData];
    [self hideHud];
}

- (void)msgNotiDetil
{
    EMMsgNotificViewController *controller = [[EMMsgNotificViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)updatePushStyle
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"通知消息显示" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"仅通知" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self _updatePushStyle:EMPushDisplayStyleSimpleBanner];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"显示消息详情" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self _updatePushStyle:EMPushDisplayStyleMessageSummary];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

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

- (void)sendLogEmailAction
{
    if ([MFMailComposeViewController canSendMail] == false) {
        [EMAlertController showErrorAlert:@"系统邮箱未设置"];
        //return;
    }
    
    EMError *error = nil;
    [self showHudInView:self.view hint:@"获取压缩路径..."];
    __weak typeof(self) weakSelf = self;
    [[EMClient sharedClient] getLogFilesPathWithCompletion:^(NSString *aPath, EMError *aError) {
        [weakSelf hideHud];
        if (error) {
            return ;
        }
        
        weakSelf.logPath = aPath;
        MFMailComposeViewController *mailCompose = [[MFMailComposeViewController alloc] init];
        if(mailCompose) {
            //设置代理
            [mailCompose setMailComposeDelegate:self];
            //设置邮件主题
            [mailCompose setSubject:@"这是Log文件"];
            //设置邮件内容
            NSString *emailBody = @"测试发送log压缩文件";
            [mailCompose setMessageBody:emailBody isHTML:NO];
            
            //设置邮件附件{mimeType:文件格式|fileName:文件名}
            NSData *pData = [[NSData alloc] initWithContentsOfFile:aPath];
            NSString *type = [aPath pathExtension];
            NSString *name = [aPath lastPathComponent];
            [mailCompose addAttachmentData:pData mimeType:type fileName:name];
            
            //设置邮件视图在当前视图上显示方式
            [self presentViewController:mailCompose animated:YES completion:nil];
        }
    }];
}

- (void)saveLogToDocument {
    __weak typeof(self) weakSelf = self;
    [[EMClient sharedClient] getLogFilesPathWithCompletion:^(NSString *aPath, EMError *aError) {
        if (!aPath) {
            [EMAlertController showErrorAlert:@"日志获取失败"];
            return ;
        }
        
        NSFileManager *fm = [NSFileManager defaultManager];
        NSString *toPath = [NSString stringWithFormat:@"%@/Documents/", NSHomeDirectory()];
        [fm copyItemAtPath:aPath toPath:toPath error:nil];
        
        [EMAlertController showSuccessAlert:@"已将文件移动到沙箱"];
    }];
}

@end
