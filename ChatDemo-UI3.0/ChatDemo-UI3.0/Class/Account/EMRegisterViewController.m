//
//  EMRegisterViewController.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2018/12/12.
//  Copyright © 2018 XieYajie. All rights reserved.
//

#import "EMRegisterViewController.h"

#import "Masonry.h"

#import "EMAlertController.h"

@interface EMRegisterViewController ()<UITextFieldDelegate>

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
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"back_gary"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(backAction)];

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
        make.top.equalTo(titleLabel.mas_bottom).offset(20);
        make.height.equalTo(@45);
    }];
    
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
    registerButton.backgroundColor = [UIColor colorWithRed:45 / 255.0 green:116 / 255.0 blue:215 / 255.0 alpha:1.0];
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

- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
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
    
    __weak typeof(self) weakself = self;
    [self showHudInView:self.view hint:NSLocalizedString(@"login.ongoing", @"Is Login...")];
    [[EMClient sharedClient] registerWithUsername:name password:pswd completion:^(NSString *aUsername, EMError *aError) {
        [weakself hideHud];
        
        if (!aError) {
            if (weakself.successCompletion) {
                weakself.successCompletion(name, pswd);
            }
            [weakself backAction];
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
