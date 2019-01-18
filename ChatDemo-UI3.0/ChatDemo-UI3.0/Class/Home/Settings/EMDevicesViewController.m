//
//  EMDevicesViewController.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 20/06/2017.
//  Copyright © 2017 XieYajie. All rights reserved.
//

#import "EMDevicesViewController.h"

#import "EMDemoOptions.h"
#import "EMAlertController.h"

#define KALERT_GET_ALL 1
#define KALERT_KICK_ALL 2
#define KALERT_KICK_ONE 3

@interface EMDevicesViewController ()

@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;

@property (nonatomic) BOOL isAuthed;

@end

@implementation EMDevicesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _setupSubviews];
    
    EMDemoOptions *options = [EMDemoOptions sharedOptions];
    self.username = options.loggedInUsername;
    self.password = options.loggedInPassword;
    if ([self.username length] > 0 && [self.password length] > 0) {
        self.isAuthed = YES;
    }
    [self tableViewDidTriggerHeaderRefresh];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSMutableArray *)dataSource
{
    if (_dataSource == nil) {
        _dataSource = [[NSMutableArray alloc] init];
    }
    
    return _dataSource;
}


#pragma mark - Subviews

- (void)_setupSubviews
{
    [self addPopBackLeftItem];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@""] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(kickAllDevicesAction)];
    
    self.title = @"登录设备列表";
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.showRefreshHeader = YES;
    self.tableView.rowHeight = 60;
    self.tableView.tableFooterView = [[UIView alloc] init];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"UITableViewCell"];
        cell.selectionStyle = UITableViewCellSeparatorStyleNone;
    }
    
    EMDeviceConfig *options = [self.dataSource objectAtIndex:indexPath.row];
    cell.textLabel.text = options.deviceName;
    if ([options.deviceName length] == 0) {
        cell.textLabel.text = options.resource;
    }
    
    cell.detailTextLabel.text = options.deviceUUID;
    
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //在iOS8.0上，必须加上这个方法才能出发左划操作
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self deleteCellAction:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    /*if ([EMClient sharedClient].isLoggedIn) {
        EMDeviceConfig *options = [self.dataSource objectAtIndex:indexPath.row];
        NSString *chatter = [NSString stringWithFormat:@"%@/%@", [EMClient sharedClient].currentUsername, options.resource];
        ChatViewController *controller = [[ChatViewController alloc] initWithConversationChatter:chatter conversationType:EMConversationTypeChat];
        controller.title = chatter;
        //controller.from = [NSString stringWithFormat:@"%@/%@", [EMClient sharedClient].currentUsername, [EMClient sharedClient].resource];
        [self.navigationController pushViewController:controller animated:YES];
    }*/
}

#pragma mark - Action

- (void)deleteCellAction:(NSIndexPath *)aIndexPath
{
    EMDeviceConfig *device = [self.dataSource objectAtIndex:aIndexPath.row];
    
    __weak typeof(self) weakself = self;
    [self showHudInView:self.view hint:NSLocalizedString(@"wait", @"Waiting...")];
    [[EMClient sharedClient] kickDevice:device username:self.username password:self.password completion:^(EMError *aError) {
        [weakself hideHud];
        if (!aError) {
            NSString *deviceName = [UIDevice currentDevice].name;
            if ([deviceName isEqualToString:device.deviceName]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@NO];
            } else {
                [weakself.dataSource removeObjectAtIndex:aIndexPath.row];
                [weakself.tableView deleteRowsAtIndexPaths:@[aIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            }
        } else {
            [EMAlertController showErrorAlert:aError.errorDescription];
        }
    }];
}

- (void)kickAllDevicesAction
{
    [self showHudInView:self.view hint:NSLocalizedString(@"wait", @"Waiting...")];
    __weak typeof(self) weakself = self;
    [[EMClient sharedClient] kickAllDevicesWithUsername:self.username password:self.password completion:^(EMError *aError) {
        [weakself hideHud];
        if (aError) {
            [EMAlertController showErrorAlert:aError.errorDescription];
        } else {
//            [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@NO];
        }
    }];
}

#pragma mark - Data

- (void)_fetchDevicesFromServer
{
    __weak typeof(self) weakself = self;
    [[EMClient sharedClient] getLoggedInDevicesFromServerWithUsername:self.username password:self.password completion:^(NSArray *aList, EMError *aError) {
        [weakself hideHud];
        if (!aError) {
            weakself.isAuthed = YES;
            [weakself.dataSource removeAllObjects];
            [weakself.dataSource addObjectsFromArray:aList];
            [weakself.tableView reloadData];
        } else {
            if (aError.code == EMErrorUserAuthenticationFailed) {
                weakself.isAuthed = NO;
            }
            [weakself showHint:aError.errorDescription];
        }
        [weakself tableViewDidFinishTriggerHeader:YES reload:NO];
    }];
}

- (void)tableViewDidTriggerHeaderRefresh
{
    if (!self.isAuthed) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"获取权限" message:nil preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = @"输入当前账号的密码";
            textField.secureTextEntry = YES;
        }];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:cancelAction];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            UITextField *passwordField = alertController.textFields.firstObject;
            self.password = passwordField.text;
            
            if ([EMClient sharedClient].isLoggedIn && ![self.username isEqualToString:[EMClient sharedClient].currentUsername]) {
                [self.tableView.refreshControl endRefreshing];
                [self showHint:@"请输入当前登录账号密码"];
                return ;
            }
            
            [self _fetchDevicesFromServer];
        }];
        [alertController addAction:okAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
    } else {
        [self _fetchDevicesFromServer];
    }
}

@end
