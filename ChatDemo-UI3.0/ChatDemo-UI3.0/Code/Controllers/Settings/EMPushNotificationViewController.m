//
//  EMPushNotificationViewController.m
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 16/9/22.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "EMPushNotificationViewController.h"
#import "EMPushDisplaynameViewController.h"
@interface EMPushNotificationViewController()

@property (nonatomic, strong) UISwitch *displaySwitch;

@property (nonatomic, strong) UISwitch *pushSwitch;

@property (nonatomic, strong) UILabel *displayNameTip;

@property (nonatomic, strong) UILabel *systemNotificationTip;

@property (nonatomic) EMPushDisplayStyle pushDisplayStyle;

@property (nonatomic) EMPushNoDisturbStatus noDisturbStatus;

@property (nonatomic, copy) NSString *pushNickname;

@end

@implementation EMPushNotificationViewController


- (UISwitch *)displaySwitch
{
    if (!_displaySwitch) {
        
        _displaySwitch = [[UISwitch alloc] init];
        [_displaySwitch addTarget:self action:@selector(displayPush:) forControlEvents:UIControlEventValueChanged];

    }
    return _displaySwitch;
}

- (UISwitch *)pushSwitch
{
    if (!_pushSwitch) {
        
        _pushSwitch = [[UISwitch alloc] init];
        [_pushSwitch addTarget:self action:@selector(activePush:) forControlEvents:UIControlEventValueChanged];

    }
    return _pushSwitch;
}

- (UILabel *)displayNameTip
{
    if (!_displayNameTip) {
        
        _displayNameTip = [[UILabel alloc] init];
        _displayNameTip.backgroundColor = [UIColor clearColor];
        _displayNameTip.textAlignment = NSTextAlignmentLeft;
        _displayNameTip.lineBreakMode = NSLineBreakByWordWrapping;
        _displayNameTip.numberOfLines = 0;
        _displayNameTip.textColor = RGBACOLOR(112, 126, 137, 1.0);
        _displayNameTip.font = [UIFont systemFontOfSize:11];
        _displayNameTip.text = NSLocalizedString(@"setting.push.tip", @"The display name will appear in notification center.");
     }
    return _displayNameTip;
}

- (UILabel *)systemNotificationTip
{
    if (!_systemNotificationTip) {
        
        _systemNotificationTip = [[UILabel alloc] init];
        _systemNotificationTip.backgroundColor = [UIColor clearColor];
        _systemNotificationTip.textAlignment = NSTextAlignmentLeft;
        _systemNotificationTip.lineBreakMode = NSLineBreakByWordWrapping;
        _systemNotificationTip.numberOfLines = 0;
        _systemNotificationTip.textColor = RGBACOLOR(112, 126, 137, 1.0);
        _systemNotificationTip.font = [UIFont systemFontOfSize:11];
        _systemNotificationTip.text = NSLocalizedString(@"setting.push.anotherTip", @"Enable or disable Hyphenate Notifications via “Settings”->”Notifications” on your iPhone.");
    }
    return _systemNotificationTip;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self configBackButton];
    
    [self refreshPushOptions];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshPushOptions) name:@"RefreshPushOptions" object:nil];
}

- (void)getPushStatus:(PushStatus)callBack
{
    self.callBack = callBack;
}

- (void)refreshPushOptions
{
    EMPushOptions *options = [[EMClient sharedClient] pushOptions];
    _pushDisplayStyle = options.displayStyle;
    _noDisturbStatus = options.noDisturbStatus;
    _pushNickname = options.displayName;
    
    BOOL display = _pushDisplayStyle == EMPushDisplayStyleSimpleBanner ? NO : YES;
    BOOL noDisturb = _noDisturbStatus == EMPushNoDisturbStatusClose ? NO: YES;
    [self.displaySwitch setOn:display animated:YES];
    [self.pushSwitch setOn:noDisturb animated:YES];
    [self.tableView reloadData];
}

- (void)reloadNotificationStatus
{
    [self.tableView reloadData];
}

- (BOOL)isAllowedNotification {
    
    if ([[UIDevice currentDevice].systemVersion floatValue] > 7.0) {
        
        UIUserNotificationSettings *setting = [[UIApplication sharedApplication] currentUserNotificationSettings];
        if (setting.types != UIUserNotificationTypeNone) {
            
            return YES;
        }
    } else {
        
        UIRemoteNotificationType type = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
        if (type != UIRemoteNotificationTypeNone) {
            
            return YES;
        }
    }
    
    return NO;
}


#pragma mark - UITableViewDatasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    } else {
        return 3;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"PushCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    
    if (indexPath.section == 0) {
        
        if (indexPath.row == 0) {
            
            cell.textLabel.text = NSLocalizedString(@"setting.push.systemPush", @"Notification");
            BOOL enableNotification = [self isAllowedNotification];
            cell.detailTextLabel.text = enableNotification ? NSLocalizedString(@"setting.push.enable", @"Enabled") : NSLocalizedString(@"setting.push.disable", @"Disabled");
            
        }
    } else {
        
        if (indexPath.row == 0) {
            
            cell.textLabel.text = NSLocalizedString(@"setting.push.display", @"Display preview text");
            self.displaySwitch.frame = CGRectMake(self.tableView.frame.size.width - 65, 8, 50, 30);
            [cell.contentView addSubview:self.displaySwitch];


        } else if (indexPath.row == 1) {
            
            cell.textLabel.text = NSLocalizedString(@"setting.push.nodisturb", @"Do not disturb");
            self.pushSwitch.frame = CGRectMake(self.tableView.frame.size.width - 65, 8, 50, 30);
            [cell.contentView addSubview:self.pushSwitch];
        } else {
            
            cell.textLabel.text = NSLocalizedString(@"setting.push.displayname", @"Push notification display name");
            cell.detailTextLabel.text = _pushNickname;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1 && indexPath.row == 2) {
        
        EMPushDisplaynameViewController *display = [[EMPushDisplaynameViewController alloc] init];
        display.title = NSLocalizedString(@"setting.push.display", @"Display preview text");
        display.currentDisplayName = _pushNickname;
        [display getUpdatedDisplayName:^(NSString *newDisplayName) {
            
            _pushNickname = newDisplayName;
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }];
        [self.navigationController pushViewController:display animated:YES];
    }
}


- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        
        return [self footerWithTip:self.systemNotificationTip];
    } else {
        
        return [self footerWithTip:self.displayNameTip];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    CGRect rect = CGRectZero;
    if (section == 0) {
        
        rect = [self frameFromLabel:self.systemNotificationTip];
    } else {
        
        rect = [self frameFromLabel:self.displayNameTip];
    }
    return rect.size.height + 20;
}

- (UIView *)footerWithTip:(UILabel *)label
{
    UIView *footer = [[UIView alloc] init];
    footer.backgroundColor = [UIColor clearColor];
    label.frame = [self frameFromLabel:label];
    [footer addSubview:label];
    return footer;
}

- (CGRect)frameFromLabel:(UILabel *)label
{
    label.frame = CGRectMake(15, 10, self.tableView.frame.size.width - 15, 11);
    CGSize size = [label sizeThatFits:CGSizeMake(label.frame.size.width, MAXFLOAT)];
    CGRect frame = CGRectMake(15, 10, self.tableView.frame.size.width, size.height);
    return frame;
}


#pragma mark - Actions

- (void)displayPush:(UISwitch *)sender
{
    if (sender.isOn) {
        _pushDisplayStyle = EMPushDisplayStyleMessageSummary;
    } else {
        _pushDisplayStyle = EMPushDisplayStyleSimpleBanner;
    }
    EMPushOptions *pushOptions = [[EMClient sharedClient] pushOptions];
    if (_pushDisplayStyle != pushOptions.displayStyle) {
        
        pushOptions.displayStyle = _pushDisplayStyle;
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [[EMClient sharedClient] updatePushNotificationOptionsToServerWithCompletion:^(EMError *aError) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if (aError) {
                
                [sender setOn:!sender.isOn animated:YES];
                if (pushOptions.displayStyle == EMPushDisplayStyleMessageSummary) {
                    pushOptions.displayStyle = EMPushDisplayStyleSimpleBanner;
                } else {
                    pushOptions.displayStyle = EMPushDisplayStyleMessageSummary;
                }
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message: [NSString stringWithFormat:@"%@:%d", NSLocalizedString(@"setting.push.changeFailed", @"Change Failed"), aError.code] delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"common.ok", @"OK"), nil];
                [alertView show];
            }
        }];
    }

}

- (void)activePush:(UISwitch *)sender
{
    if (sender.isOn) {
        
        _noDisturbStatus = EMPushNoDisturbStatusDay;
    } else {

        _noDisturbStatus = EMPushNoDisturbStatusClose;
    }
    EMPushOptions *pushOptions = [[EMClient sharedClient] pushOptions];
    if (_noDisturbStatus != pushOptions.noDisturbStatus) {
        
        pushOptions.noDisturbStatus = _noDisturbStatus;
        NSLog(@"%d",pushOptions.noDisturbStatus);
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [[EMClient sharedClient] updatePushNotificationOptionsToServerWithCompletion:^(EMError *aError) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if (aError) {
                
                [sender setOn:!sender.isOn animated:YES];
                if (pushOptions.noDisturbStatus == EMPushNoDisturbStatusDay) {
                    pushOptions.noDisturbStatus = EMPushNoDisturbStatusClose;
                } else {
                    pushOptions.noDisturbStatus = EMPushNoDisturbStatusDay;
                }
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"%@:%d",NSLocalizedString(@"setting.push.changeFailed", @"Change failed"),aError.code] delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"common.ok", @"OK"), nil];
                [alert show];
                
            } else {
                
                if (self.callBack) {
                    
                    self.callBack(_noDisturbStatus);
                }
            }

        }];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"RefreshPushOptions" object:nil];
}

@end
