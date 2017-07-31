//
//  EMDevicesViewController.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 20/06/2017.
//  Copyright © 2017 XieYajie. All rights reserved.
//

#import "EMDevicesViewController.h"

#import "ChatViewController.h"

#define KALERT_GET_ALL 1
#define KALERT_KICK_ALL 2
#define KALERT_KICK_ONE 3

@interface EMDevicesViewController ()

@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) NSIndexPath *willKickDeviceIndex;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;

@end

@implementation EMDevicesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"setting.deviceResources", @"List of logged devices");
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"setting.kickAllDevices", @"KickAll") style:UIBarButtonItemStylePlain target:self action:@selector(kickAllAction)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    self.tableView.rowHeight = 50;
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showTextFieldAlertView:) name:@"showAlertController" object:nil];
    
    [self _setupRefresh];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showAlertController" object:[NSNumber numberWithInt:KALERT_GET_ALL]];
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

- (void)_setupRefresh
{
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(_headerRefreshAction) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
}

- (void)_showTextFieldAlertView:(NSNotification *)aNotif
{
    int tag = 0;
    if (aNotif && aNotif.object) {
        tag = [aNotif.object intValue];
    }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"getPermission", @"Get Permission") message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = NSLocalizedString(@"username", @"Username");
    }];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = NSLocalizedString(@"password", @"Password");
        textField.secureTextEntry = YES;
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"Cancel") style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:cancelAction];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UITextField *usernameField = alertController.textFields.firstObject;
        self.username = usernameField.text;
        
        UITextField *passwordField = alertController.textFields.lastObject;
        self.password = passwordField.text;
        
        if ([EMClient sharedClient].isLoggedIn && ![self.username isEqualToString:[EMClient sharedClient].currentUsername]) {
            [self.refreshControl endRefreshing];
            [self showHint:@"请输入当前登录账号"];
            return ;
        }
        
        if (tag == KALERT_GET_ALL) {
            [self fetchDataFromServer];
        } else if (tag == KALERT_KICK_ALL) {
            [self kickAllDevices];
        } else if (tag == KALERT_KICK_ONE) {
            [self kickOneDevice];
        }
    }];
    [alertController addAction:okAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
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
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
        cell.selectionStyle = UITableViewCellSeparatorStyleNone;
    }
    
    EMDeviceConfig *options = [self.dataSource objectAtIndex:indexPath.row];
    cell.textLabel.text = options.deviceName;
    if ([options.deviceName length] == 0) {
        cell.textLabel.text = options.deviceUUID;
    }
    
    if ([cell.textLabel.text length] == 0) {
        cell.textLabel.text = options.resource;
    }
    
    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        self.willKickDeviceIndex = indexPath;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"showAlertController" object:[NSNumber numberWithInt:KALERT_KICK_ONE]];
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

- (void)kickAllAction
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showAlertController" object:[NSNumber numberWithInt:KALERT_KICK_ALL]];
}

- (void)kickAllDevices
{
    [self showHudInView:self.view hint:NSLocalizedString(@"wait", @"Waiting...")];
    __weak typeof(self) weakself = self;
    [[EMClient sharedClient] kickAllDevicesWithUsername:self.username password:self.password completion:^(EMError *aError) {
        [weakself hideHud];
        if (!aError) {
            [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@NO];
        } else {
            [weakself showHint:aError.errorDescription];
        }
    }];
}

- (void)kickOneDevice
{
    [self showHudInView:self.view hint:NSLocalizedString(@"wait", @"Waiting...")];
    __weak typeof(self) weakself = self;
    
    EMDeviceConfig *device = [self.dataSource objectAtIndex:self.willKickDeviceIndex.row];
    [[EMClient sharedClient] kickDevice:device username:self.username password:self.password completion:^(EMError *aError) {
        [weakself hideHud];
        if (!aError) {
            NSString *deviceName = [UIDevice currentDevice].name;
            if ([deviceName isEqualToString:device.deviceName]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@NO];
            } else {
                [weakself.dataSource removeObjectAtIndex:weakself.willKickDeviceIndex.row];
                [weakself.tableView deleteRowsAtIndexPaths:@[weakself.willKickDeviceIndex] withRowAnimation:UITableViewRowAnimationFade];
            }
        } else {
            [weakself showHint:aError.errorDescription];
        }
        weakself.willKickDeviceIndex = nil;
    }];
}

#pragma mark - Data

- (void)_headerRefreshAction
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showAlertController" object:[NSNumber numberWithInt:KALERT_GET_ALL]];
}

- (void)fetchDataFromServer
{
    [self showHudInView:self.view hint:NSLocalizedString(@"loadData", @"Load data...")];
    __weak typeof(self) weakself = self;
    [[EMClient sharedClient] getLoggedInDevicesFromServerWithUsername:self.username password:self.password completion:^(NSArray *aList, EMError *aError) {
        [weakself hideHud];
        [weakself.refreshControl endRefreshing];
        if (!aError) {
            [weakself.dataSource removeAllObjects];
            [weakself.dataSource addObjectsFromArray:aList];
            [weakself.tableView reloadData];
        } else {
            [weakself showHint:aError.errorDescription];
        }
    }];
}

@end
