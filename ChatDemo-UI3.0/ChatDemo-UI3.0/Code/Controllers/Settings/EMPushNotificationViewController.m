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

@property (nonatomic, strong) UILabel *footerTip;

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

- (UILabel *)footerTip
{
    if (!_footerTip) {
        
        _footerTip = [[UILabel alloc] init];
        _footerTip.backgroundColor = [UIColor clearColor];
        _footerTip.textAlignment = NSTextAlignmentLeft;
        _footerTip.lineBreakMode = NSLineBreakByWordWrapping;
        _footerTip.numberOfLines = 0;
        _footerTip.textColor = RGBACOLOR(112, 126, 137, 1.0);
        _footerTip.font = [UIFont systemFontOfSize:11];
        _footerTip.text = NSLocalizedString(@"setting.push.tip", @"The display name will appear in Apple's push notification system.");
     }
    return _footerTip;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self configBackButton];
    
    [self refreshPushOptions];
    
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
    BOOL enablePush = _noDisturbStatus == EMPushNoDisturbStatusClose ? YES: NO;
    [self.displaySwitch setOn:display animated:YES];
    [self.pushSwitch setOn:enablePush animated:YES];
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"PushCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    
    if (indexPath.row == 0) {
        
        cell.textLabel.text = NSLocalizedString(@"setting.push.display", @"Display on lickscreen");
        self.displaySwitch.frame = CGRectMake(self.tableView.frame.size.width - 65, 8, 50, 30);
        [cell.contentView addSubview:self.displaySwitch];
    } else if (indexPath.row == 1) {
        
        cell.textLabel.text = NSLocalizedString(@"setting.push.enable", @"Push Notifications");
        self.pushSwitch.frame = CGRectMake(self.tableView.frame.size.width - 65, 8, 50, 30);
        [cell.contentView addSubview:self.pushSwitch];
    } else {
        
        cell.textLabel.text = NSLocalizedString(@"setting.push.displayname", @"Push notification display name");
        cell.detailTextLabel.text = _pushNickname;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 2) {
        
        EMPushDisplaynameViewController *display = [[EMPushDisplaynameViewController alloc] init];
        display.title = NSLocalizedString(@"setting.push.display", @"Push Notification Display");
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
    UIView *footer = [[UIView alloc] init];
    footer.backgroundColor = [UIColor clearColor];
    self.footerTip.frame = CGRectMake(15, 10, self.tableView.frame.size.width - 15, 11);
    CGSize size = [self.footerTip sizeThatFits:CGSizeMake(self.footerTip.frame.size.width, MAXFLOAT)];
    self.footerTip.frame = CGRectMake(15, 10, self.tableView.frame.size.width, size.height);
    [footer addSubview:self.footerTip];
    
    return footer;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 30;
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
        [[EMClient sharedClient] updatePushNotificationOptionsToServerWithCompletion:^(EMError *aError) {
            if (aError) {
                NSLog(@"%u",aError.code);
            }
        }];
    }

}

- (void)activePush:(UISwitch *)sender
{
    if (sender.isOn) {
        
        _noDisturbStatus = EMPushNoDisturbStatusClose;
    } else {
        // NO Notification
        _noDisturbStatus = EMPushNoDisturbStatusDay;
    }
    EMPushOptions *pushOptions = [[EMClient sharedClient] pushOptions];
    if (_noDisturbStatus != pushOptions.noDisturbStatus) {
        
        pushOptions.noDisturbStatus = _noDisturbStatus;
        [[EMClient sharedClient] updatePushNotificationOptionsToServerWithCompletion:^(EMError *aError) {
            if (aError) {
                
                NSLog(@"%u",aError.code);
            } else {
                
                if (self.callBack) {
                    
                    self.callBack(_noDisturbStatus);
                }
            }
        }];
    }
}

@end
