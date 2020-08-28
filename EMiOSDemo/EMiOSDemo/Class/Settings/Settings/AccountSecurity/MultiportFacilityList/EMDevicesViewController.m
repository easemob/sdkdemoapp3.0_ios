//
//  EMDevicesViewController.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 20/06/2017.
//  Copyright © 2017 XieYajie. All rights reserved.
//

#import "EMDevicesViewController.h"

#import "EMDemoOptions.h"

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
    
    self.title = @"登录设备列表";
    self.view.backgroundColor = [UIColor colorWithRed:249/255.0 green:249/255.0 blue:249/255.0 alpha:1.0];
    
    self.showRefreshHeader = YES;
    self.tableView.rowHeight = 66;
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
    
    UIImageView *imgView = [[UIImageView alloc]init];
    [cell.contentView addSubview:imgView];
    [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(cell.contentView);
        make.left.equalTo(cell.contentView).offset(16);
        make.width.height.equalTo(@40);
    }];
    [cell.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(imgView.mas_right).offset(15);
        make.top.equalTo(cell.contentView).offset(10);
        make.right.equalTo(cell.contentView).offset(15);
    }];
    [cell.detailTextLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(imgView.mas_right).offset(15);
        make.bottom.equalTo(cell.contentView).offset(-10);
        make.right.equalTo(cell.contentView).offset(15);
    }];
    
    cell.textLabel.font = [UIFont systemFontOfSize:14.0];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:14.0];
    cell.textLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
    cell.detailTextLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
    
    EMDeviceConfig *options = [self.dataSource objectAtIndex:indexPath.row];
    
    NSRange range = [options.resource rangeOfString:@"_"];
    
    NSString *str = [options.resource substringToIndex:range.location];
    
    if ([str isEqualToString:@"ios"])
        imgView.image = [UIImage imageNamed:@"ios"];
    if ([str isEqualToString:@"android"])
        imgView.image = [UIImage imageNamed:@"android"];
    if ([str isEqualToString:@"webim"])
        imgView.image = [UIImage imageNamed:@"web"];
    if ([str isEqualToString:@"win"])
        imgView.image = [UIImage imageNamed:@"win"];
    if ([str isEqualToString:@"desktop"]) 
        imgView.image = [UIImage imageNamed:@"iMac"];
    
    cell.textLabel.text = options.deviceName;
    if ([options.deviceName length] == 0) {
        cell.textLabel.text = options.resource;
    }
    
    cell.detailTextLabel.text = options.deviceUUID;
    cell.separatorInset = UIEdgeInsetsMake(0, 16, 0, 0);
    return cell;
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
