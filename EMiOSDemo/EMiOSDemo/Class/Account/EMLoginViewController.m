//
//  EMLoginViewController.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2018/12/11.
//  Copyright © 2018 XieYajie. All rights reserved.
//

#import "EMLoginViewController.h"

#import "MBProgressHUD.h"

#import "EMDevicesViewController.h"
#import "EMRegisterViewController.h"
#import "EMQRCodeViewController.h"
#import "EMSDKOptionsViewController.h"

#import "EMGlobalVariables.h"
#import "EMDemoOptions.h"

#import "EMErrorAlertViewController.h"

@interface EMLoginViewController ()<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UITableViewCell *titleCell;
@property (nonatomic, strong) UIImageView *titleImageView;
/*
@property (nonatomic, strong) UITableViewCell *appkeyCell;
@property (nonatomic, strong) UITextField *appkeyField;
@property (nonatomic, strong) UIButton *appkeyButton;
*/
@property (nonatomic, strong) UITableViewCell *nameCell;
@property (nonatomic, strong) UITextField *nameField;

@property (nonatomic, strong) UITableViewCell *pswdCell;
@property (nonatomic, strong) UITextField *pswdField;
@property (nonatomic, strong) UIButton *pswdRightView;

@property (nonatomic, strong) UITableViewCell *buttonCell;
@property (nonatomic, strong) UIButton *loginTypeButton;

@property (nonatomic, strong) UIButton *loginButton;
@property (nonatomic, strong) UIView *viewArrow;
@property (nonatomic, strong) CAGradientLayer *gl;
@property (nonatomic, strong) CAGradientLayer *backGl;
@property (nonatomic, strong) UILabel *loginLabel;

@property (nonatomic) BOOL isLogin;

@end

@implementation EMLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.isLogin = false;
    [self _setupSubviews];
    
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}
- (BOOL)prefersStatusBarHidden
{
    return NO;
}

#pragma mark - Subviews

- (void)_setupSubviews
{
    //self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    //[self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"BootPage"] forBarMetrics:UIBarMetricsDefault];
    //[self.navigationController.navigationBar.layer setMasksToBounds:YES];
    
    //self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"device_disable"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(devicesAction)];
    //self.navigationItem.leftBarButtonItem.enabled = NO;
    
    //self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"qr"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(qrCodeAction)];
    
    //self.view.backgroundColor = [UIColor whiteColor];
    [self _setupTableView];
}

- (void)_setupTableView
{
    UIImageView *imageView=[[UIImageView alloc]initWithFrame:self.view.bounds];
    imageView.image=[UIImage imageNamed:@"BootPage"];
    [self.view insertSubview:imageView atIndex:0];
    /*
    self.tableView = [[UITableView alloc] init];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    [self.tableView setBackgroundView:imageView];*/
    
    //self.titleCell = [self _setupCell];
    self.titleImageView = [[UIImageView alloc]init];
    self.titleImageView.image = [UIImage imageNamed:@"编组 4"];
    [self.view addSubview:self.titleImageView];
    [self.titleImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.width.equalTo(@73.32);
        make.height.equalTo(@79.94);
        make.top.equalTo(self.view.mas_top).offset(96);
    }];
    /*
    self.appkeyCell = [self _setupCell];
    self.appkeyField = [[UITextField alloc] init];
    self.appkeyField.delegate = self;
    self.appkeyField.enabled = NO;
    self.appkeyField.borderStyle = UITextBorderStyleNone;
    self.appkeyField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.appkeyField.placeholder = @"应用appkey";
    self.appkeyField.text = [EMDemoOptions sharedOptions].appkey;
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
    
    self.appkeyButton = [[UIButton alloc] init];
    self.appkeyButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.appkeyButton setTitle:@"更换" forState:UIControlStateNormal];
    [self.appkeyButton setTitleColor:kColor_Blue forState:UIControlStateNormal];
    [self.appkeyButton addTarget:self action:@selector(changeAppkeyAction) forControlEvents:UIControlEventTouchUpInside];
    [self.appkeyCell.contentView addSubview:self.appkeyButton];
    [self.appkeyButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.appkeyCell.contentView).offset(-15);
        make.top.equalTo(self.appkeyCell.contentView);
        make.bottom.equalTo(self.appkeyCell.contentView);
        make.width.equalTo(@50);
    }];
    */
    //self.nameCell = [self _setupCell];
    self.nameField = [[UITextField alloc] init];
    self.nameField.backgroundColor = [UIColor whiteColor];
    self.nameField.delegate = self;
    self.nameField.borderStyle = UITextBorderStyleNone;
    self.nameField.placeholder = @"用户名";
    self.nameField.returnKeyType = UIReturnKeyDone;
    self.nameField.font = [UIFont systemFontOfSize:17];
    self.nameField.rightViewMode = UITextFieldViewModeWhileEditing;
    self.nameField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.nameField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    self.nameField.leftViewMode = UITextFieldViewModeAlways;
    self.nameField.layer.cornerRadius = 25;
    self.nameField.layer.borderWidth = 1;
    self.nameField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [self.view addSubview:self.nameField];
    [self.nameField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(30);
        make.right.equalTo(self.view).offset(-30);
        make.top.equalTo(self.titleImageView.mas_bottom).offset(20);
        make.height.equalTo(@55);
    }];
    
    //self.pswdCell = [self _setupCell];
    self.pswdField = [[UITextField alloc] init];
    self.pswdField.backgroundColor = [UIColor whiteColor];
    self.pswdField.delegate = self;
    self.pswdField.borderStyle = UITextBorderStyleNone;
    self.pswdField.placeholder = @"密码";
    self.pswdField.font = [UIFont systemFontOfSize:17];
    self.pswdField.returnKeyType = UIReturnKeyDone;
//    self.pswdField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.pswdField.secureTextEntry = YES;
    self.pswdRightView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 35)];
    [self.pswdRightView setImage:[UIImage imageNamed:@"secure"] forState:UIControlStateNormal];
    [self.pswdRightView setImage:[UIImage imageNamed:@"显示密码"] forState:UIControlStateSelected];
    [self.pswdRightView addTarget:self action:@selector(pswdSecureAction:) forControlEvents:UIControlEventTouchUpInside];
    self.pswdField.rightView = self.pswdRightView;
    self.pswdField.rightViewMode = UITextFieldViewModeAlways;
    self.pswdField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    self.pswdField.leftViewMode = UITextFieldViewModeAlways;
    self.pswdField.layer.cornerRadius = 25;
    self.pswdField.layer.borderWidth = 1;
    self.pswdField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [self.view addSubview:self.pswdField];
    [self.pswdField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(30);
        make.right.equalTo(self.view).offset(-30);
        make.top.equalTo(self.nameField.mas_bottom).offset(20);
        make.height.equalTo(@55);
    }];
    
    [self _setupButtonCell];
}

- (UITableViewCell *)_setupCell
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)_setupButtonCell
{
    //self.buttonCell = [self _setupCell];
    
    self.loginButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _loginButton.backgroundColor = [UIColor blackColor];
    _loginButton.layer.cornerRadius = 25;
    _loginButton.alpha = 0.3;

    [_loginButton addTarget:self action:@selector(loginAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_loginButton];
    [_loginButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(30);
        make.right.equalTo(self.view).offset(-30);
        make.top.equalTo(self.pswdField.mas_bottom).offset(40);
        make.height.equalTo(@55);
    }];
    
    self.loginLabel = [[UILabel alloc] init];
    _loginLabel.numberOfLines = 0;
    _loginLabel.font = [UIFont systemFontOfSize:16];
    _loginLabel.text = @"登 录";
    [_loginLabel setTextColor:[UIColor whiteColor]];
    _loginLabel.textAlignment = NSTextAlignmentCenter;
    _loginLabel.alpha = 0.3;
    [self.view addSubview:_loginLabel];
    [_loginLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.loginButton);
        make.centerX.equalTo(self.loginButton);
        make.width.equalTo(@45);
        make.height.equalTo(@23);
    }];
    
    
    self.viewArrow = [[UIView alloc] init];
    _viewArrow.layer.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0].CGColor;
    _viewArrow.alpha = 0.3;
    _viewArrow.layer.cornerRadius = 21;
    [self.view addSubview:_viewArrow];
    [_viewArrow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@43);
        make.right.equalTo(self.loginButton.mas_right).offset(-6);
        make.top.equalTo(self.loginButton.mas_top).offset(6);
        make.height.equalTo(@43);
    }];
    
    UIButton *registerButton = [[UIButton alloc] init];
    registerButton.titleLabel.font = [UIFont systemFontOfSize:12];
    [registerButton setTitle:@"账户注册" forState:UIControlStateNormal];
    [registerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [registerButton addTarget:self action:@selector(registerAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:registerButton];
    [registerButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@70);
        make.height.equalTo(@17);
        make.left.equalTo(self.loginButton);
        make.bottom.equalTo(self.view.mas_bottom).offset(-60);
    }];
    
    UIButton *serverConfigurationBtn = [[UIButton alloc] init];
    serverConfigurationBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [serverConfigurationBtn setTitle:@"服务器配置" forState:UIControlStateNormal];
    [serverConfigurationBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [serverConfigurationBtn addTarget:self action:@selector(changeAppkeyAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:serverConfigurationBtn];
    [serverConfigurationBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@80);
        make.height.equalTo(@17);
        make.centerX.equalTo(self.loginButton);
        make.bottom.equalTo(self.view.mas_bottom).offset(-60);
    }];
    
    self.loginTypeButton = [[UIButton alloc] init];
    self.loginTypeButton.titleLabel.font = [UIFont systemFontOfSize:12];
    [self.loginTypeButton setTitle:@"token登录" forState:UIControlStateNormal];
    [self.loginTypeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.loginTypeButton addTarget:self action:@selector(loginTypeChangeAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.loginTypeButton];
    [self.loginTypeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@80);
        make.height.equalTo(@17);
        make.right.equalTo(self.loginButton);
        make.bottom.equalTo(self.view.mas_bottom).offset(-60);
    }];
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
        //case 1:
            //cell = self.appkeyCell;
            //break;
        case 1:
            cell = self.nameCell;
            break;
        case 2:
            cell = self.pswdCell;
            break;
        case 3:
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
            height = 80;
            break;
        case 3:
            height = 105;
            break;
        default:
            break;
    }
    
    return height;
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    textField.layer.borderColor = kColor_Blue.CGColor;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    textField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    // gradient
    if(self.nameField.text.length > 0 && self.pswdField.text.length > 0){
        [self.backGl removeFromSuperlayer];
        [_loginButton.layer addSublayer:self.gl];
        _loginButton.alpha = 1;
        _loginLabel.alpha = 1;
        [_loginLabel setTextColor:[UIColor colorWithRed:244/255.0 green:244/255.0 blue:244/255.0 alpha:1.0]];
        
        _viewArrow.alpha = 1;
        _viewArrow.layer.backgroundColor = ([UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0].CGColor);;
        
        self.isLogin = true;
    } else {
        [self.gl removeFromSuperlayer];
        [_loginButton.layer addSublayer:self.backGl];
        _loginButton.alpha = 0.3;
        _loginLabel.alpha = 0.3;
        [_loginLabel setTextColor:[UIColor whiteColor]];
        
        _viewArrow.layer.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0].CGColor;
        _viewArrow.alpha = 0.3;
        self.isLogin = false;
    }
    
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
    
    if (gIsInitializedSDK) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"(づ｡◕‿‿◕｡)づ" message:@"当前appkey以及环境配置已生效，如果需要更改需要重启客户端" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            exit(0);
        }];
        [alertController addAction:okAction];
        
        [alertController addAction: [UIAlertAction actionWithTitle:@"取消" style: UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }]];
        alertController.modalPresentationStyle = 0;
        [self presentViewController:alertController animated:YES completion:nil];
    } else {
        EMQRCodeViewController *controller = [[EMQRCodeViewController alloc] init];
        
        __weak typeof(self) weakself = self;
        [controller setScanFinishCompletion:^(NSDictionary *aJsonDic) {
            NSString *username = [aJsonDic objectForKey:@"Username"];
            NSString *pssword = [aJsonDic objectForKey:@"Password"];
            if ([username length] == 0) {
                return ;
            }
            
            [EMDemoOptions updateAndSaveServerOptions:aJsonDic];
            
            //weakself.appkeyField.text = [EMDemoOptions sharedOptions].appkey;
            weakself.nameField.text = username;
            weakself.pswdField.text = pssword;
            
            if ([pssword length] == 0) {
                [weakself.pswdField becomeFirstResponder];
            }
        }];
        controller.modalPresentationStyle = 0;
        [self.navigationController presentViewController:controller animated:YES completion:nil];
    }
}

- (void)changeAppkeyAction
{
    __weak typeof(self) weakself = self;
    EMSDKOptionsViewController *controller = [[EMSDKOptionsViewController alloc] initWithEnableEdit:!gIsInitializedSDK finishCompletion:^(EMDemoOptions * _Nonnull aOptions) {
        //weakself.appkeyField.text = aOptions.appkey;
    }];
    
    controller.modalPresentationStyle = 0;
    [self presentViewController:controller animated:NO completion:nil];
}

- (void)pswdSecureAction:(UIButton *)aButton
{
    aButton.selected = !aButton.selected;
    self.pswdField.secureTextEntry = !self.pswdField.secureTextEntry;
}

- (void)loginAction
{
    if(!(self.isLogin)) {
        return;
    }
    [self.view endEditing:YES];
    
    BOOL isTokenLogin = self.loginTypeButton.selected;
    NSString *name = self.nameField.text;
    NSString *pswd = self.pswdField.text;

    /*
    if ([name length] == 0 || [pswd length] == 0) {
        NSString *errorDes = isTokenLogin ? @"用户ID或者token不能为空" : @"用户ID或者密码不能为空";
        [EMAlertController showErrorAlert:errorDes];
        return;
    }
    */
    if (!gIsInitializedSDK) {
        gIsInitializedSDK = YES;
        EMOptions *options = [[EMDemoOptions sharedOptions] toOptions];
        
        [[EMClient sharedClient] initializeSDKWithOptions:options];
    }
    
    __weak typeof(self) weakself = self;
    void (^finishBlock) (NSString *aName, EMError *aError) = ^(NSString *aName, EMError *aError) {
        [weakself hideHud];
        
        if (!aError) {
            //设置是否自动登录
            [[EMClient sharedClient].options setIsAutoLogin:YES];
            
            EMDemoOptions *options = [EMDemoOptions sharedOptions];
            options.isAutoLogin = YES;
            options.loggedInUsername = aName;
            options.loggedInPassword = pswd;
            [options archive];
            
            //发送自动登录状态通知
            [[NSNotificationCenter defaultCenter] postNotificationName:ACCOUNT_LOGIN_CHANGED object:[NSNumber numberWithBool:YES]];
            
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
            case EMErrorUserLoginOnAnotherDevice:
                errorDes = @"已在其他设备登陆";
                break;
                case EMErrorUserRemoved:
                errorDes = @"当前帐号已被后台删除";
            break;
            default:
                break;
        }
        //[EMAlertController showErrorAlert:errorDes];
        EMErrorAlertViewController *errorAlerController = [[EMErrorAlertViewController alloc]initWithErrorReason:errorDes];
        errorAlerController.modalPresentationStyle = 0;
        [self presentViewController:errorAlerController animated:NO completion:nil];
    };
    
    [self showHudInView:self.view hint:NSLocalizedString(@"login.ongoing", @"Is Login...")];
    if (isTokenLogin) {
        [[EMClient sharedClient] loginWithUsername:[name lowercaseString] token:pswd completion:finishBlock];
    } else {
        [[EMClient sharedClient] loginWithUsername:[name lowercaseString] password:pswd completion:finishBlock];
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
    
    controller.modalPresentationStyle = 0;
    [self presentViewController:controller animated:NO completion:nil];
    //[self.navigationController pushViewController:controller animated:YES];
}

- (void)loginTypeChangeAction
{
    [self.view endEditing:YES];
    
    self.loginTypeButton.selected = !self.loginTypeButton.selected;
    if (self.loginTypeButton.selected) {
        //self.titleLabel.text = @"使用token登录";
        self.pswdField.placeholder = @"token";
        self.pswdField.secureTextEntry = NO;
        self.pswdField.rightView = nil;
        self.pswdField.rightViewMode = UITextFieldViewModeNever;
        self.pswdField.clearButtonMode = UITextFieldViewModeWhileEditing;
        [self.loginTypeButton setTitle:@"密码登录" forState:UIControlStateNormal];
    } else {
        //self.titleLabel.text = @"登录";
        self.pswdField.placeholder = @"密码";
        self.pswdField.secureTextEntry = !self.pswdRightView.selected;
        self.pswdField.rightView = self.pswdRightView;
        self.pswdField.rightViewMode = UITextFieldViewModeAlways;
        self.pswdField.clearButtonMode = UITextFieldViewModeNever;
        [self.loginTypeButton setTitle:@"token登录" forState:UIControlStateNormal];
    }
}

- (CAGradientLayer *)backGl{
    if(_backGl == nil) {
        _backGl = [CAGradientLayer layer];
        _backGl.frame = CGRectMake(0,0,_loginButton.frame.size.width,55);
        _backGl.startPoint = CGPointMake(0.15, 0.5);
        _backGl.endPoint = CGPointMake(1, 0.5);
        _backGl.colors = @[(__bridge id)[UIColor blackColor].CGColor, (__bridge id)[UIColor blackColor].CGColor];
        _backGl.locations = @[@(0), @(1.0f)];
        _backGl.cornerRadius = 25;
    }
    return _backGl;
}

- (CAGradientLayer *)gl{
    if(_gl == nil){
        _gl = [CAGradientLayer layer];
        _gl.frame = CGRectMake(0,0,_loginButton.frame.size.width,55);
        _gl.startPoint = CGPointMake(0.15, 0.5);
        _gl.endPoint = CGPointMake(1, 0.5);
        _gl.colors = @[(__bridge id)[UIColor colorWithRed:4/255.0 green:174/255.0 blue:240/255.0 alpha:1.0].CGColor, (__bridge id)[UIColor colorWithRed:90/255.0 green:93/255.0 blue:208/255.0 alpha:1.0].CGColor];
        _gl.locations = @[@(0), @(1.0f)];
        _gl.cornerRadius = 25;
    }
    
    return _gl;
}

@end
