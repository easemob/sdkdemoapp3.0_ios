//
//  EMGeneralViewController.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2018/12/28.
//  Copyright © 2018 XieYajie. All rights reserved.
//

#import <MessageUI/MFMailComposeViewController.h>
#import <MessageUI/MessageUI.h>
#import "EMGeneralViewController.h"

#import "EMDemoOptions.h"
#import "EMAlertController.h"
#import "EMServiceCheckViewController.h"

@interface EMGeneralViewController ()<MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) NSString *logPath;

@end

@implementation EMGeneralViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    [self _setupSubviews];
}

#pragma mark - Subviews

- (void)_setupSubviews
{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"back_gary"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(backAction)];
    
    self.title = @"通用";
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.tableView.rowHeight = 55;
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.backgroundColor = [UIColor colorWithRed:245 / 255.0 green:245 / 255.0 blue:245 / 255.0 alpha:1.0];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 6;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = 0;
    switch (section) {
        case 0:
            count = 1;
            break;
        case 1:
            count = 2;
            break;
        case 2:
            count = 1;
            break;
        case 3:
            count = 1;
            break;
        case 4:
            count = 3;
            break;
        case 5:
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
    NSString *cellIdentifier = @"UITableViewCellValue1";
    if (section != 3 && row == 0) {
        cellIdentifier = @"UITableViewCellSwitch";
    }
    
    UISwitch *switchControl = nil;
    BOOL isSwitchCell = NO;
    if (section == 1 || section == 2 || section == 3 || (section == 4 && row == 0)) {
        isSwitchCell = YES;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (isSwitchCell) {
            switchControl = [[UISwitch alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width - 65, 10, 50, 40)];
            switchControl.tag = section * 10 + row;
            [switchControl addTarget:self action:@selector(cellSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
            [cell.contentView addSubview:switchControl];
        }
    } else if (isSwitchCell) {
        switchControl = [cell.contentView viewWithTag:(section * 10 + row)];
    }
    
    EMDemoOptions *options = [EMDemoOptions sharedOptions];
    
    cell.detailTextLabel.text = nil;
    cell.accessoryType = UITableViewCellAccessoryNone;
    if (section == 0) {
        if (row == 0) {
            cell.textLabel.text = @"当前版本";
            cell.detailTextLabel.text = [EMClient sharedClient].version;
//            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    } else if (section == 1) {
        if (row == 0) {
            cell.textLabel.text = @"自动接收群组邀请";
            [switchControl setOn:options.isAutoAcceptGroupInvitation animated:YES];
        } else if (row == 1) {
            cell.textLabel.text = @"群聊退出时删除会话";
            [switchControl setOn:options.isDeleteMessagesWhenExitGroup animated:YES];
        }
    } else if (section == 2) {
        if (row == 0) {
            cell.textLabel.text = @"优先从服务器获取消息";
            [switchControl setOn:options.isPriorityGetMsgFromServer animated:YES];
        }
    } else if (section == 3) {
        if (row == 0) {
            cell.textLabel.text = @"消息附件上传到环信服务器";
            [switchControl setOn:options.isAutoTransferMessageAttachments animated:YES];
        }
    } else if (section == 4) {
        if (row == 0) {
            cell.textLabel.text = @"自动下载图片缩略图";
            [switchControl setOn:options.isAutoDownloadThumbnail animated:YES];
        } else if (row == 1) {
            cell.textLabel.text = @"消息排序";
            cell.detailTextLabel.text = options.isSortMessageByServerTime ? @"按服务器时间" : @"按接收顺序";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else if (row == 2) {
            cell.textLabel.text = @"通知消息显示";
            cell.detailTextLabel.text = [EMClient sharedClient].pushOptions.displayStyle == EMPushDisplayStyleSimpleBanner ? @"仅通知" : @"显示详情";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    } else if (section == 5) {
        if (row == 0) {
            cell.textLabel.text = @"诊断";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else if (row == 1) {
            cell.textLabel.text = @"邮件发送日志";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
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
    if (section == 0 || section == 4 || section == 5) {
        return 10;
    }
    
    return 30;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 0 || section == 4 || section == 5) {
        return nil;
    }
    
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:13];
    label.textColor = [UIColor lightGrayColor];
    label.numberOfLines = 2;
    if (section == 1) {
        label.text = @"    退出群组或聊天室时，删除对应的消息及会话";
    } else if (section == 2) {
        label.text = @"    优先从服务器获取最新消息";
    } else if (section == 3) {
        label.text = @"    上传附件到环信服务器，关闭需自定义文件上传";
    }
    
    return label;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (section == 4) {
        if (row == 1) {
            [self updateMessageSort];
        } else if (row == 2) {
            [self updatePushStyle];
        }
    } else if (section == 5) {
        if (row == 0) {
            EMServiceCheckViewController *controller = [[EMServiceCheckViewController alloc] init];
            [self.navigationController pushViewController:controller animated:YES];
        } else if (row == 1) {
            [self sendLogEmailAction];
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

#pragma mark - Action

- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)cellSwitchValueChanged:(UISwitch *)aSwitch
{
    EMDemoOptions *options = [EMDemoOptions sharedOptions];
    NSInteger tag = aSwitch.tag;
    switch (tag) {
        case 10:
        {
            [EMClient sharedClient].options.isAutoAcceptGroupInvitation = aSwitch.isOn;
            
            options.isAutoAcceptGroupInvitation = aSwitch.isOn;
            [options archive];
        }
            break;
        case 11:
        {
            [EMClient sharedClient].options.isDeleteMessagesWhenExitGroup = aSwitch.isOn;
            
            options.isDeleteMessagesWhenExitGroup = aSwitch.isOn;
            [options archive];
        }
            break;
        case 20:
        {
            options.isPriorityGetMsgFromServer = aSwitch.isOn;
            [options archive];
        }
            break;
        case 30:
        {
            [EMClient sharedClient].options.isAutoTransferMessageAttachments = aSwitch.isOn;
            
            options.isAutoTransferMessageAttachments = aSwitch.isOn;
            [options archive];
        }
            break;
        case 40:
        {
            [EMClient sharedClient].options.isAutoDownloadThumbnail = aSwitch.isOn;
            
            options.isAutoDownloadThumbnail = aSwitch.isOn;
            [options archive];
        }
            break;
            
        default:
            break;
    }
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
        return;
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


@end
