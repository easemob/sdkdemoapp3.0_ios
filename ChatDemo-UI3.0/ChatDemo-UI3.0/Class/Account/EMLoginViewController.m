//
//  EMLoginViewController.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2018/12/11.
//  Copyright © 2018 XieYajie. All rights reserved.
//

#import "EMLoginViewController.h"

#import "Masonry.h"
#import "MBProgressHUD.h"

#import "EMDevicesViewController.h"
#import "EMRegisterViewController.h"
#import "EMQRCodeViewController.h"

@interface EMLoginViewController ()<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UITableViewCell *titleCell;

@property (nonatomic, strong) UITableViewCell *appkeyCell;
@property (nonatomic, strong) UITextField *appkeyField;

@property (nonatomic, strong) UITableViewCell *nameCell;
@property (nonatomic, strong) UITextField *nameField;

@property (nonatomic, strong) UITableViewCell *pswdCell;
@property (nonatomic, strong) UITextField *pswdField;
@property (nonatomic, strong) UIButton *pswdRightView;

@property (nonatomic, strong) UITableViewCell *buttonCell;
@property (nonatomic, strong) UIButton *loginTypeButton;

@end

@implementation EMLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self _setupSubviews];
    
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}

#pragma mark - Subviews

- (void)_setupSubviews
{
    self.navigationController.navigationBarHidden = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *leftButton = [[UIButton alloc] init];
    [leftButton setImage:[UIImage imageNamed:@"device"] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(devicesAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:leftButton];
    [leftButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(5);
        make.top.equalTo(self.view).offset(20);
        make.width.height.equalTo(@50);
    }];
    
    UIButton *rightButton = [[UIButton alloc] init];
    [rightButton setImage:[UIImage imageNamed:@"qr"] forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(qrCodeAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:rightButton];
    [rightButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view).offset(5);
        make.top.equalTo(leftButton);
        make.width.height.equalTo(@50);
    }];
    
    [self _setupTableView];
}

- (void)_setupTableView
{
    self.tableView = [[UITableView alloc] init];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(70);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    
    self.titleCell = [self _setupCell];
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"登录";
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.font = [UIFont systemFontOfSize:28];
    [self.titleCell.contentView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleCell.contentView).offset(15);
        make.top.equalTo(self.titleCell.contentView);
        make.bottom.equalTo(self.titleCell.contentView);
    }];
    
    self.appkeyCell = [self _setupCell];
    self.appkeyField = [[UITextField alloc] init];
    self.appkeyField.borderStyle = UITextBorderStyleNone;
    self.appkeyField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.appkeyField.placeholder = @"应用appkey";
    self.appkeyField.text = @"easemob-demo#chatdemoui";
    self.appkeyField.keyboardType = UIKeyboardTypeNamePhonePad;
    self.appkeyField.returnKeyType = UIReturnKeyDone;
    self.appkeyField.font = [UIFont systemFontOfSize:15];
    self.appkeyField.rightViewMode = UITextFieldViewModeWhileEditing;
    [self.appkeyCell.contentView addSubview:self.appkeyField];
    [self.appkeyField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.appkeyCell.contentView).offset(15);
        make.right.equalTo(self.appkeyCell.contentView).offset(50);
        make.top.equalTo(self.appkeyCell.contentView);
        make.bottom.equalTo(self.appkeyCell.contentView);
    }];
    
    UIButton *changeButton = [[UIButton alloc] init];
    changeButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [changeButton setTitle:@"更换" forState:UIControlStateNormal];
    [changeButton setTitleColor:[UIColor colorWithRed:45 / 255.0 green:116 / 255.0 blue:215 / 255.0 alpha:1.0] forState:UIControlStateNormal];
    [changeButton addTarget:self action:@selector(changeAppkeyAction) forControlEvents:UIControlEventTouchUpInside];
    [self.appkeyCell.contentView addSubview:changeButton];
    [changeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.appkeyCell.contentView).offset(-15);
        make.top.equalTo(self.appkeyCell.contentView);
        make.bottom.equalTo(self.appkeyCell.contentView);
        make.width.equalTo(@50);
    }];
    
    self.nameCell = [self _setupCell];
    self.nameField = [[UITextField alloc] init];
    self.nameField.delegate = self;
    self.nameField.borderStyle = UITextBorderStyleNone;
    self.nameField.placeholder = @"用户ID";
    self.nameField.keyboardType = UIKeyboardTypeNamePhonePad;
    self.nameField.returnKeyType = UIReturnKeyDone;
    self.nameField.font = [UIFont systemFontOfSize:17];
    self.nameField.rightViewMode = UITextFieldViewModeWhileEditing;
    self.nameField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.nameField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    self.nameField.leftViewMode = UITextFieldViewModeAlways;
    self.nameField.layer.cornerRadius = 5;
    self.nameField.layer.borderWidth = 1;
    self.nameField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [self.nameCell.contentView addSubview:self.nameField];
    [self.nameField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.nameCell.contentView).offset(30);
        make.right.equalTo(self.nameCell.contentView).offset(-30);
        make.top.equalTo(self.nameCell.contentView).offset(20);
        make.bottom.equalTo(self.nameCell.contentView);
    }];
    
    self.pswdCell = [self _setupCell];
    self.pswdField = [[UITextField alloc] init];
    self.pswdField.delegate = self;
    self.pswdField.borderStyle = UITextBorderStyleNone;
    self.pswdField.placeholder = @"密码";
    self.pswdField.font = [UIFont systemFontOfSize:17];
    self.pswdField.returnKeyType = UIReturnKeyDone;
//    self.pswdField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.pswdField.secureTextEntry = YES;
    self.pswdRightView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 20)];
    [self.pswdRightView setImage:[UIImage imageNamed:@"secure"] forState:UIControlStateNormal];
    [self.pswdRightView setImage:[UIImage imageNamed:@"unsecure"] forState:UIControlStateSelected];
    [self.pswdRightView addTarget:self action:@selector(pswdSecureAction:) forControlEvents:UIControlEventTouchUpInside];
    self.pswdField.rightView = self.pswdRightView;
    self.pswdField.rightViewMode = UITextFieldViewModeAlways;
    self.pswdField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    self.pswdField.leftViewMode = UITextFieldViewModeAlways;
    self.pswdField.layer.cornerRadius = 5;
    self.pswdField.layer.borderWidth = 1;
    self.pswdField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [self.pswdCell.contentView addSubview:self.pswdField];
    [self.pswdField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.pswdCell.contentView).offset(30);
        make.right.equalTo(self.pswdCell.contentView).offset(-30);
        make.top.equalTo(self.pswdCell.contentView).offset(20);
        make.bottom.equalTo(self.pswdCell.contentView);
    }];
    
    [self _setupButtonCell];
}

- (UITableViewCell *)_setupCell
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
    return cell;
}

- (void)_setupButtonCell
{
    self.buttonCell = [self _setupCell];
    
    UIButton *loginButton = [[UIButton alloc] init];
    loginButton.clipsToBounds = YES;
    loginButton.layer.cornerRadius = 5;
    loginButton.backgroundColor = [UIColor colorWithRed:45 / 255.0 green:116 / 255.0 blue:215 / 255.0 alpha:1.0];
    loginButton.titleLabel.font = [UIFont systemFontOfSize:19];
    [loginButton setTitle:@"登录" forState:UIControlStateNormal];
    [loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [loginButton addTarget:self action:@selector(loginAction) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonCell.contentView addSubview:loginButton];
    [loginButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.buttonCell.contentView).offset(30);
        make.right.equalTo(self.buttonCell.contentView).offset(-30);
        make.top.equalTo(self.buttonCell.contentView).offset(20);
        make.height.equalTo(@50);
    }];
    
    UIButton *registerButton = [[UIButton alloc] init];
    registerButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [registerButton setTitle:@"新用户注册" forState:UIControlStateNormal];
    [registerButton setTitleColor:[UIColor colorWithRed:45 / 255.0 green:116 / 255.0 blue:215 / 255.0 alpha:1.0] forState:UIControlStateNormal];
    [registerButton addTarget:self action:@selector(registerAction) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonCell.contentView addSubview:registerButton];
    [registerButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(loginButton.mas_bottom).offset(10);
        make.left.equalTo(loginButton);
        make.bottom.equalTo(self.buttonCell.contentView);
    }];
    
    self.loginTypeButton = [[UIButton alloc] init];
    self.loginTypeButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.loginTypeButton setTitle:@"使用token登录" forState:UIControlStateNormal];
    [self.loginTypeButton setTitle:@"使用密码登录" forState:UIControlStateNormal];
    [self.loginTypeButton setTitleColor:[UIColor colorWithRed:45 / 255.0 green:116 / 255.0 blue:215 / 255.0 alpha:1.0] forState:UIControlStateNormal];
    [self.loginTypeButton addTarget:self action:@selector(loginTypeChangeAction) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonCell.contentView addSubview:self.loginTypeButton];
    [self.loginTypeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(registerButton);
        make.right.equalTo(loginButton);
        make.bottom.equalTo(registerButton);
    }];
}

#pragma mark - Private

- (void)_saveLoginUsername
{
    NSString *username = [[EMClient sharedClient] currentUsername];
    if (username && username.length > 0) {
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        [ud setObject:username forKey:[NSString stringWithFormat:@"em_lastLogin_username"]];
        [ud synchronize];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    switch (indexPath.row) {
        case 0:
            cell = self.titleCell;
            break;
        case 1:
            cell = self.appkeyCell;
            break;
        case 2:
            cell = self.nameCell;
            break;
        case 3:
            cell = self.pswdCell;
            break;
        case 4:
            cell = self.buttonCell;
            break;
            
        default:
            cell = [self _setupCell];
            break;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 65;
    switch (indexPath.row) {
        case 0:
        case 1:
            height = 60;
            break;
        case 4:
            height = 100;
            break;
            
        default:
            break;
    }
    
    return height;
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    textField.layer.borderColor = [UIColor colorWithRed:45 / 255.0 green:116 / 255.0 blue:215 / 255.0 alpha:1.0].CGColor;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    textField.layer.borderColor = [UIColor lightGrayColor].CGColor;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
        return NO;
    }
    
    return YES;
}

#pragma mark - Action

- (void)devicesAction
{
    [self.view endEditing:YES];
    
    EMDevicesViewController *devicesController = [[EMDevicesViewController alloc] initWithStyle:UITableViewStylePlain];
    [self.navigationController pushViewController:devicesController animated:YES];
}

- (void)qrCodeAction
{
    [self.view endEditing:YES];
    
    EMQRCodeViewController *controller = [[EMQRCodeViewController alloc] init];
    [self.navigationController presentViewController:controller animated:YES completion:nil];
}

- (void)changeAppkeyAction
{
    [self.appkeyField becomeFirstResponder];
}

- (void)pswdSecureAction:(UIButton *)aButton
{
    aButton.selected = !aButton.selected;
    self.pswdField.secureTextEntry = !self.pswdField.secureTextEntry;
}

- (void)loginAction
{
    [self.view endEditing:YES];
    
    BOOL isTokenLogin = self.loginTypeButton.selected;
    NSString *name = self.nameField.text;
    NSString *pswd = self.pswdField.text;

    if ([name length] == 0 || [pswd length] == 0) {
        NSString *errorDes = isTokenLogin ? @"用户ID或者token不能为空" : @"用户ID或者密码不能为空";
        //TODO:错误提示
        TTAlertNoTitle(errorDes);
        return;
    }
    
    __weak typeof(self) weakself = self;
    void (^finishBlock) (NSString *aName, EMError *aError) = ^(NSString *aName, EMError *aError) {
        [weakself hideHud];
        
        if (!aError) {
            //设置是否自动登录
            [[EMClient sharedClient].options setIsAutoLogin:YES];
            //保存最近一次登录用户名
            [weakself _saveLoginUsername];
            //发送自动登录状态通知
            [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:[NSNumber numberWithBool:YES]];
            
            return ;
        }
        
        NSString *errorDes = @"登录失败，请重试";
        switch (aError.code) {
            case EMErrorUserNotFound:
                errorDes = @"用户ID不存在";
                break;
            case EMErrorNetworkUnavailable:
                errorDes = @"网络未连接";
                break;
            case EMErrorServerNotReachable:
                errorDes = @"无法连接服务器";
                break;
            case EMErrorUserAuthenticationFailed:
                errorDes = aError.errorDescription;
                break;
            case EMErrorUserLoginTooManyDevices:
                errorDes = @"登录设备数已达上限";
                break;
            default:
                break;
        }
        //TODO:错误提示
        TTAlertNoTitle(errorDes);
    };
    
    [self showHudInView:self.view hint:NSLocalizedString(@"login.ongoing", @"Is Login...")];
    if (isTokenLogin) {
        [[EMClient sharedClient] loginWithUsername:name token:pswd completion:finishBlock];
    } else {
        [[EMClient sharedClient] loginWithUsername:name password:pswd completion:finishBlock];
    }
}

- (void)registerAction
{
    [self.view endEditing:YES];
    
    EMRegisterViewController *controller = [[EMRegisterViewController alloc] init];
    
    __weak typeof(self) weakself = self;
    [controller setSuccessCompletion:^(NSString * _Nonnull aName, NSString * _Nonnull aPswd) {
        if ([weakself.nameField.text length] == 0 && [weakself.pswdField.text length] == 0) {
            weakself.nameField.text = aName;
            if (!weakself.loginTypeButton.selected) {
                weakself.pswdField.text = aPswd;
            }
        }
    }];
    
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)loginTypeChangeAction
{
    [self.view endEditing:YES];
    
    self.loginTypeButton.selected = !self.loginTypeButton.selected;
    if (self.loginTypeButton.selected) {
        self.pswdField.placeholder = @"token";
        self.pswdField.secureTextEntry = NO;
        self.pswdField.rightView = nil;
        self.pswdField.rightViewMode = UITextFieldViewModeNever;
        self.pswdField.clearButtonMode = UITextFieldViewModeWhileEditing;
    } else {
        self.pswdField.placeholder = @"密码";
        self.pswdField.secureTextEntry = !self.pswdRightView.selected;
        self.pswdField.rightView = self.pswdRightView;
        self.pswdField.rightViewMode = UITextFieldViewModeAlways;
        self.pswdField.clearButtonMode = UITextFieldViewModeNever;
    }
}

@end
