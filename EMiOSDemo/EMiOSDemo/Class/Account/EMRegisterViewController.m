//
//  EMRegisterViewController.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2018/12/12.
//  Copyright © 2018 XieYajie. All rights reserved.
//

#import "EMRegisterViewController.h"

#import "EMGlobalVariables.h"
#import "EMDemoOptions.h"

#import "EMQRCodeViewController.h"
#import "EMSDKOptionsViewController.h"

@interface EMRegisterViewController ()<UITextFieldDelegate>

@property (nonatomic, strong) UITextField *appkeyField;
@property (nonatomic, strong) UIButton *appkeyRightView;

@property (nonatomic, strong) UITextField *nameField;

@property (nonatomic, strong) UITextField *pswdField;
@property (nonatomic, strong) UIButton *pswdRightView;

@end

@implementation EMRegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self _setupViews];
}

#pragma mark - Subviews

- (void)_setupViews
{
    [self addPopBackLeftItem];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"qr"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(qrCodeAction)];

    self.view.backgroundColor = [UIColor whiteColor];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"注册";
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.font = [UIFont systemFontOfSize:28];
    [self.view addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(15);
        make.top.equalTo(self.view);
        make.height.equalTo(@60);
    }];
    
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
    [self.view addSubview:self.appkeyField];
    [self.appkeyField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(30);
        make.right.equalTo(self.view).offset(-80);
        make.top.equalTo(titleLabel.mas_bottom).offset(10);
        make.height.equalTo(@40);
    }];
    
    self.appkeyRightView = [[UIButton alloc] init];
    self.appkeyRightView.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.appkeyRightView setTitle:@"更换" forState:UIControlStateNormal];
    [self.appkeyRightView setTitleColor:kColor_Blue forState:UIControlStateNormal];
    [self.appkeyRightView addTarget:self action:@selector(changeAppkeyAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.appkeyRightView];
    [self.appkeyRightView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.appkeyField);
        make.bottom.equalTo(self.appkeyField);
        make.left.equalTo(self.appkeyField.mas_right);
        make.right.equalTo(self.view).offset(-30);
    }];
    
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
    [self.view addSubview:self.nameField];
    [self.nameField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(30);
        make.right.equalTo(self.view).offset(-30);
        make.top.equalTo(self.appkeyField.mas_bottom).offset(20);
        make.height.equalTo(@45);
    }];
    
    self.pswdField = [[UITextField alloc] init];
    self.pswdField.delegate = self;
    self.pswdField.borderStyle = UITextBorderStyleNone;
    self.pswdField.placeholder = @"密码";
    self.pswdField.font = [UIFont systemFontOfSize:17];
    self.pswdField.returnKeyType = UIReturnKeyDone;
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
    [self.view addSubview:self.pswdField];
    [self.pswdField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.nameField);
        make.right.equalTo(self.nameField);
        make.top.equalTo(self.nameField.mas_bottom).offset(20);
        make.height.equalTo(self.nameField);
    }];
    
    UIButton *registerButton = [[UIButton alloc] init];
    registerButton.clipsToBounds = YES;
    registerButton.layer.cornerRadius = 5;
    registerButton.backgroundColor = kColor_Blue;
    registerButton.titleLabel.font = [UIFont systemFontOfSize:19];
    [registerButton setTitle:@"注册" forState:UIControlStateNormal];
    [registerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [registerButton addTarget:self action:@selector(registerAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:registerButton];
    [registerButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.nameField);
        make.right.equalTo(self.nameField);
        make.top.equalTo(self.pswdField.mas_bottom).offset(20);
        make.height.equalTo(@50);
    }];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    textField.layer.borderColor = kColor_Blue.CGColor;
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
            
            weakself.appkeyField.text = [EMDemoOptions sharedOptions].appkey;
            weakself.nameField.text = username;
            weakself.pswdField.text = pssword;
            
            if ([pssword length] == 0) {
                [weakself.pswdField becomeFirstResponder];
            }
        }];
        [self.navigationController presentViewController:controller animated:YES completion:nil];
    }
}

- (void)changeAppkeyAction
{
    __weak typeof(self) weakself = self;
    EMSDKOptionsViewController *controller = [[EMSDKOptionsViewController alloc] initWithEnableEdit:!gIsInitializedSDK finishCompletion:^(EMDemoOptions * _Nonnull aOptions) {
        weakself.appkeyField.text = aOptions.appkey;
    }];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)pswdSecureAction:(UIButton *)aButton
{
    aButton.selected = !aButton.selected;
    self.pswdField.secureTextEntry = !self.pswdField.secureTextEntry;
}

- (void)registerAction
{
    [self.view endEditing:YES];

    NSString *name = self.nameField.text;
    NSString *pswd = self.pswdField.text;
    
    if ([name length] == 0 || [pswd length] == 0) {
        [EMAlertController showErrorAlert:@"用户ID或者密码不能为空"];
        return;
    }
    
    if (!gIsInitializedSDK) {
        gIsInitializedSDK = YES;
        EMOptions *options = [[EMDemoOptions sharedOptions] toOptions];
        [[EMClient sharedClient] initializeSDKWithOptions:options];
    }
    
    __weak typeof(self) weakself = self;
    [self showHudInView:self.view hint:NSLocalizedString(@"login.ongoing", @"Is Login...")];
    [[EMClient sharedClient] registerWithUsername:name password:pswd completion:^(NSString *aUsername, EMError *aError) {
        [weakself hideHud];
        
        if (!aError) {
            if (weakself.successCompletion) {
                weakself.successCompletion(name, pswd);
            }
            
            [weakself.navigationController popViewControllerAnimated:YES];
            return ;
        }
        
        NSString *errorDes = @"注册失败，请重试";
        switch (aError.code) {
            case EMErrorServerNotReachable:
                errorDes = @"无法连接服务器";
                break;
            case EMErrorNetworkUnavailable:
                errorDes = @"网络未连接";
                break;
            case EMErrorUserAlreadyExist:
                errorDes = @"用户ID已存在";
                break;
            case EMErrorExceedServiceLimit:
                errorDes = @"请求过于频繁，请稍后再试";
                break;
            default:
                break;
        }
        [EMAlertController showErrorAlert:errorDes];
    }];
}

@end
