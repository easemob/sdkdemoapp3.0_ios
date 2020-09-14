//
//  EMCallSettingsViewController.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2018/12/28.
//  Copyright © 2018 XieYajie. All rights reserved.
//

#import "EMCallSettingsViewController.h"

#import "EMDemoOptions.h"
#import "SingleCallController.h"

static bool g_Watermark = NO;
@interface EMCallSettingsViewController ()
@end

@implementation EMCallSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    [self _setupSubviews];
    
    [SingleCallController sharedManager];
}

#pragma mark - Subviews

- (void)_setupSubviews
{
    [self addPopBackLeftItem];
    self.title = @"实时音视频";
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.tableView.rowHeight = 55;
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.backgroundColor = kColor_LightGray;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = 0;
    switch (section) {
        case 0:
            count = 1;
            break;
        case 1:
            count = 5;
            break;
        case 2:
            count = 2;
            break;
        case 3:
            count = 2;
            break;
        case 4:
            count = 1;
            break;
        default:
            break;
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    NSString *cellIdentifier = [NSString stringWithFormat:@"%ld + %ld", (long)indexPath.section, (long)indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    UISwitch *switchControl = nil;
    
    // Configure the cell...
    if (cell == nil) {
        if(section == 4){
            if(row == 0){
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                switchControl = [[UISwitch alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width - 65, 10, 50, 40)];
                switchControl.tag = section*10 + row + 10000;
                [switchControl addTarget:self action:@selector(cellSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
                [cell.contentView addSubview:switchControl];
            }
        }else if(section == 3) {
            if(row == 0){
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                switchControl = [[UISwitch alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width - 65, 10, 50, 40)];
                switchControl.tag = section*10 + row + 10000;
                [switchControl addTarget:self action:@selector(cellSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
                [cell.contentView addSubview:switchControl];
            }else if(row == 1) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
            }
        }else if (section != 2) {
            if (row == 0 || row == 2 || row == 3 || row == 4) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                switchControl = [[UISwitch alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width - 65, 10, 50, 40)];
                switchControl.tag = section + row + 10000;
                [switchControl addTarget:self action:@selector(cellSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
                [cell.contentView addSubview:switchControl];
            }else {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
            }
        } else {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else if (section != 2) {
        if (row == 0 || row == 2 || row == 3) {
            switchControl = [cell.contentView viewWithTag:(section + row + 10000)];
        }
    }
    
    EMCallOptions *options = [[EMClient sharedClient].callManager getCallOptions];
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    if (section == 0) {
        if (row == 0) {
            cell.textLabel.text = @"离线推送呼叫";
            [switchControl setOn:[EMDemoOptions sharedOptions].isOfflineHangup animated:YES];
        }
    } else if (section == 1) {
        if (row == 0) {
            cell.textLabel.text = @"显示视频通话信息";
            [switchControl setOn:[EMDemoOptions sharedOptions].isShowCallInfo animated:NO];
        } else if (row == 1) {
            cell.textLabel.text = @"默认摄像头";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.detailTextLabel.text = [EMDemoOptions sharedOptions].isUseBackCamera ? @"后置摄像头" : @"前置摄像头";
        } else if (row == 2) {
            cell.textLabel.text = @"开启服务器录制";
            [switchControl setOn:[EMDemoOptions sharedOptions].willRecord animated:NO];
        } else if (row == 3) {
            cell.textLabel.text = @"开启录制混流";
            [switchControl setOn:[EMDemoOptions sharedOptions].willMergeStrem animated:NO];
        } else if (row == 4) {
            cell.textLabel.text = @"支持微信小程序";
            [switchControl setOn:[EMDemoOptions sharedOptions].isSupportWechatMiniProgram animated:NO];
        }
    } else if (section == 2) {
        if (row == 0) {
            cell.textLabel.text = @"视频最大码率";
            cell.detailTextLabel.text = @(options.maxVideoKbps).stringValue;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else if (row == 1) {
            cell.textLabel.text = @"视频最小码率";
            cell.detailTextLabel.text = @(options.minVideoKbps).stringValue;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }else if (section == 3) {
        if(row == 0) {
            cell.textLabel.text = @"开启外部音频输入";
            [switchControl setOn:options.enableCustomAudioData];
        }else if(row == 1) {
            cell.textLabel.text = @"外部音频输入采样率";
            cell.detailTextLabel.text = @(options.audioCustomSamples).stringValue;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }else if (section == 4) {
        if(row == 0){
            cell.textLabel.text = @"水印功能";
            [switchControl setOn:g_Watermark];
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
    if (section == 1 || section == 4) {
        return 10;
    }
    
    return 30;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 1 || section == 4) {
        return nil;
    }
    
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:13];
    label.textColor = [UIColor lightGrayColor];
    if (section == 0) {
        label.text = @"    用户离线时推送呼叫请求";
    } else if (section == 2) {
        label.numberOfLines = 2;
        label.text = @"    固定分辨率会受到网络不稳定等因素影响";
    }else if (section == 3) {
        label.text = @"    通话过程中不能修改";
    }
    
    return label;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (section == 1) {
        if (row == 1) {
            [self updateCameraDirection];
        }
    } else if (section == 2) {
        if (row == 0) {
            [self updateMaxVideoKbps];
        } else if (row == 1) {
            [self updateMinVideoKbps];
        }
    }else if (section == 3) {
        if(row == 1) {
            [self updateExternalAudioSamples];
        }
    }
}

#pragma mark - Action

- (void)cellSwitchValueChanged:(UISwitch *)aSwitch
{
    NSInteger tag = aSwitch.tag;
    if (tag == 0 + 10000) {
        [EMDemoOptions sharedOptions].isOfflineHangup = aSwitch.on;
        [[EMDemoOptions sharedOptions] archive];
    } else if (tag == 2 + 10000) {
        [EMDemoOptions sharedOptions].isShowCallInfo = aSwitch.isOn;
        [[EMDemoOptions sharedOptions] archive];
    }
    else if (tag == 3 + 10000) {
        [EMDemoOptions sharedOptions].willRecord = aSwitch.isOn;
        [[EMDemoOptions sharedOptions] archive];
    }
    else if (tag == 4 + 10000) {
        [EMDemoOptions sharedOptions].willMergeStrem = aSwitch.isOn;
        [[EMDemoOptions sharedOptions] archive];
    }
    else if (tag == 5 + 10000) {
        [EMDemoOptions sharedOptions].isSupportWechatMiniProgram = aSwitch.isOn;
        [[EMDemoOptions sharedOptions] archive];
    }
    else if(tag == 3*10+10000) {
        EMCallOptions *options = [[EMClient sharedClient].callManager getCallOptions];
        options.enableCustomAudioData = aSwitch.isOn;
    }else if(tag == 4*10 + 10000) {
        g_Watermark = aSwitch.isOn;
        if(g_Watermark)
        {
            NSString * imagePath = [[NSBundle mainBundle] pathForResource:@"watermark" ofType:@"png"];
            EMWaterMarkOption* option = [[EMWaterMarkOption alloc] init];
            option.marginX = 60;
            option.startPoint = LEFTTOP;
            option.marginY = 60;
            option.enable = YES;
            option.url = [NSURL fileURLWithPath:imagePath];
            [[EMClient sharedClient].conferenceManager addVideoWatermark:option];
        }else{
            [[EMClient sharedClient].conferenceManager clearVideoWatermark];
        }
    }
}

- (void)updateCameraDirection
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"默认摄像头方向" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    EMDemoOptions *options = [EMDemoOptions sharedOptions];
    [alertController addAction:[UIAlertAction actionWithTitle:@"前置摄像头" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        options.isUseBackCamera = NO;
        [options archive];
        [self.tableView reloadData];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"后置摄像头" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        options.isUseBackCamera = YES;
        [options archive];
        [self.tableView reloadData];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)updateMaxVideoKbps
{
    EMCallOptions *options = [[EMClient sharedClient].callManager getCallOptions];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"视频最大码率" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"请输入视频最大码率(150-1000)";
        textField.text = @(options.maxVideoKbps).stringValue;
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:cancelAction];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UITextField *textField = alertController.textFields.firstObject;
        int value = [textField.text intValue];
        if ((value >= 150 && value <= 1000) || value == 0) {
            options.maxVideoKbps = value;
            [[SingleCallController sharedManager] saveCallOptions];
            [self.tableView reloadData];
        } else {
            [EMAlertController showErrorAlert:@"最大视频码率范围150 - 1000"];
        }
    }];
    [alertController addAction:okAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)updateMinVideoKbps
{
    EMCallOptions *options = [[EMClient sharedClient].callManager getCallOptions];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"视频最小码率" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"请输入视频最小码率";
        textField.text = @(options.maxVideoKbps).stringValue;
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:cancelAction];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UITextField *textField = alertController.textFields.firstObject;
        int value = [textField.text intValue];
        if (value < 0) {
            value = 0;
        }
        options.minVideoKbps = value;
        [[SingleCallController sharedManager] saveCallOptions];
        [self.tableView reloadData];
    }];
    [alertController addAction:okAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)updateExternalAudioSamples
{
    EMCallOptions *options = [[EMClient sharedClient].callManager getCallOptions];
    if(!options.enableCustomAudioData)
        return;
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"外部音频输入采样率" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"外部音频输入采样率";
        textField.text = @(options.audioCustomSamples).stringValue;
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:cancelAction];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UITextField *textField = alertController.textFields.firstObject;
        int value = [textField.text intValue];
        if (value < 0) {
            value = 0;
        }
        options.audioCustomSamples = value;
        [[SingleCallController sharedManager] saveCallOptions];
        [self.tableView reloadData];
    }];
    [alertController addAction:okAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
