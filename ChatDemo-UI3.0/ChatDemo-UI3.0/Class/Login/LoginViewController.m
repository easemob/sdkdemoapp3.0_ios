//
//  LoginViewController.m
//  ChatDemo-UI3.0
//
//  Created by dhc on 15/6/24.
//  Copyright (c) 2015年 easemob.com. All rights reserved.
//

#import "LoginViewController.h"

#import "EaseMob.h"
#import <EaseUI/NSString+Valid.h>
#import <EaseUI/UIViewController+HUD.h>

@interface LoginViewController ()

@property (strong, nonatomic) UITextField *usernameTextField;
@property (strong, nonatomic) UITextField *passwordTextField;
@property (strong, nonatomic) UIButton *registerButton;
@property (strong, nonatomic) UIButton *loginButton;

@end

@implementation LoginViewController

@synthesize usernameTextField = _usernameTextField;
@synthesize passwordTextField = _passwordTextField;
@synthesize registerButton = _registerButton;
@synthesize loginButton = _loginButton;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"AppName", @"EaseMobDemo");
    
    [self _setupSubviews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - layout subviews

- (void)_setupSubviews
{
    CGFloat oX = 30;
    CGFloat oY = 50;
    CGFloat space = 20;
    
    _usernameTextField = [[UITextField alloc] initWithFrame:CGRectMake(oX, oY, self.view.frame.size.width - 60, 30)];
    _usernameTextField.leftViewMode = UITextFieldViewModeAlways;
    _usernameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _usernameTextField.placeholder = NSLocalizedString(@"username", @"Username");
    _usernameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    UIImageView *userLeftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"account"]];
    userLeftView.contentMode = UIViewContentModeScaleAspectFit;
    userLeftView.frame = CGRectMake(0, 0, 30, 20);
    _usernameTextField.leftView = userLeftView;
    [self.view addSubview:_usernameTextField];
    
    UIView *userLine = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(_usernameTextField.frame), CGRectGetMaxY(_usernameTextField.frame), CGRectGetWidth(_usernameTextField.frame), 0.5)];
    userLine.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:userLine];
    
    _passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(oX, CGRectGetMaxY(_usernameTextField.frame) + space, self.view.frame.size.width - 60, 30)];
    _passwordTextField.leftViewMode = UITextFieldViewModeAlways;
    _passwordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _passwordTextField.placeholder = NSLocalizedString(@"password", @"Password");
    _passwordTextField.secureTextEntry = YES;
    UIImageView *pswdLeftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"password"]];
    pswdLeftView.contentMode = UIViewContentModeScaleAspectFit;
    pswdLeftView.frame = CGRectMake(0, 0, 30, 20);
    _passwordTextField.leftView = pswdLeftView;
    [self.view addSubview:_passwordTextField];
    
    UIView *pswdLine = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(_passwordTextField.frame), CGRectGetMaxY(_passwordTextField.frame), CGRectGetWidth(_passwordTextField.frame), 0.5)];
    pswdLine.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:pswdLine];
    
    _registerButton = [[UIButton alloc] initWithFrame:CGRectMake(oX, CGRectGetMaxY(_passwordTextField.frame) + space, 80, 44)];
    [_registerButton setTitle:NSLocalizedString(@"register", @"Register") forState:UIControlStateNormal];
    [_registerButton addTarget:self action:@selector(registerAction) forControlEvents:UIControlEventTouchUpInside];
    _registerButton.backgroundColor = [UIColor colorWithRed:87 / 255.0 green:186 / 255.0 blue:208 / 255.0 alpha:1.0];
    [self.view addSubview:_registerButton];
    
    oX = CGRectGetMaxX(_registerButton.frame) + space;
    _loginButton = [[UIButton alloc] initWithFrame:CGRectMake(oX, CGRectGetMinY(_registerButton.frame), CGRectGetMaxX(_passwordTextField.frame) - oX, CGRectGetHeight(_registerButton.frame))];
    [_loginButton setTitle:NSLocalizedString(@"login", @"Login") forState:UIControlStateNormal];
    [_loginButton addTarget:self action:@selector(loginAction) forControlEvents:UIControlEventTouchUpInside];
    _loginButton.backgroundColor = [UIColor colorWithRed:0 green:101 / 255.0 blue:123 / 255.0 alpha:1.0];
    [self.view addSubview:_loginButton];
}

//判断账号和密码是否为空
- (BOOL)_isAvailable
{
    BOOL ret = YES;
    UIAlertView *alertView = nil;
    NSString *username = _usernameTextField.text;
    NSString *password = _passwordTextField.text;
    if (username.length == 0 || password.length == 0) {
        ret = NO;
        alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", @"Prompt") message:NSLocalizedString(@"login.inputNameAndPswd", @"Please enter username and password") delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
        [alertView show];
    }
    else if ([self.usernameTextField.text isChinese]) {//判断是否是中文，但不支持中英文混编
        ret = NO;
        alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"login.nameNotSupportZh", @"Name does not support Chinese") message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
        [alertView show];
    }
    
    return ret;
}

#pragma mark - action

- (void)registerAction
{
    if([self _isAvailable])
    {
        //隐藏键盘
        [self.view endEditing:YES];
        
        [self showHudInView:self.view hint:NSLocalizedString(@"register.ongoing", @"Is to register...")];
        [[EaseMob sharedInstance].chatManager asyncRegisterNewAccount:_usernameTextField.text
                                                             password:_passwordTextField.text
                                                       withCompletion:
         ^(NSString *username, NSString *password, EMError *error) {
             [self hideHud];
             
             NSString *title = nil;
             if (!error) {
                 title = NSLocalizedString(@"register.success", @"Registered successfully, please log in");
             }else{
                 switch (error.errorCode) {
                     case EMErrorServerNotReachable:
                         title = NSLocalizedString(@"error.connectServerFail", @"Connect to the server failed!");
                         break;
                     case EMErrorServerDuplicatedAccount:
                         title = NSLocalizedString(@"register.repeat", @"You registered user already exists!");
                         break;
                     case EMErrorNetworkNotConnected:
                         title = NSLocalizedString(@"error.connectNetworkFail", @"No network connection!");
                         break;
                     case EMErrorServerTimeout:
                         title = NSLocalizedString(@"error.connectServerTimeout", @"Connect to the server timed out!");
                         break;
                     default:
                         title = NSLocalizedString(@"register.fail", @"Registration failed");
                         break;
                 }
             }
             
             UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
             [alertView show];
             
         } onQueue:nil];
    }
}

- (void)loginAction
{
    if([self _isAvailable])
    {
        [self showHudInView:self.view hint:NSLocalizedString(@"login.ongoing", @"Is Login...")];
        //异步登陆账号
        [[EaseMob sharedInstance].chatManager asyncLoginWithUsername:_usernameTextField.text
                                                            password:_passwordTextField.text
                                                          completion:
         ^(NSDictionary *loginInfo, EMError *error) {
             [self hideHud];
             
             if (loginInfo && !error) {
                 //获取群组列表
                 [[EaseMob sharedInstance].chatManager asyncFetchMyGroupsList];
                 
                 //设置是否自动登录
                 [[EaseMob sharedInstance].chatManager setIsAutoLoginEnabled:YES];
                 
                 //如果是从2.1.0升级，将2.1.0版本旧版的coredata数据导入新的数据库
                 EMError *error = [[EaseMob sharedInstance].chatManager importDataToNewDatabase];
                 if (!error) {
                     error = [[EaseMob sharedInstance].chatManager loadDataFromDatabase];
                 }
                 
                 //发送自动登陆状态通知
                 [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@YES];
                 
             }
             else
             {
                 NSString *title = nil;
                 switch (error.errorCode)
                 {
                     case EMErrorNotFound:
                         title = error.description;
                         break;
                     case EMErrorNetworkNotConnected:
                         title = NSLocalizedString(@"error.connectNetworkFail", @"No network connection!");
                         break;
                     case EMErrorServerNotReachable:
                         title = NSLocalizedString(@"error.connectServerFail", @"Connect to the server failed!");
                         break;
                     case EMErrorServerAuthenticationFailure:
                         title = error.description;
                         break;
                     case EMErrorServerTimeout:
                         title = NSLocalizedString(@"error.connectServerTimeout", @"Connect to the server timed out!");
                         break;
                     default:
                         title = NSLocalizedString(@"login.fail", @"Login failure");
                         break;
                 }
                 
                 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
                 [alertView show];
             }
         } onQueue:nil];
    }
}

@end
