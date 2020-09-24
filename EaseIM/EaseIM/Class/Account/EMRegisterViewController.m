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
#import "EMAlertController.h"
#import "EMErrorAlertViewController.h"
#import "LoadingCALayer.h"
#import "OneLoadingAnimationView.h"

#import "EMRightViewToolView.h"
#import "EMUserAgreementView.h"
#import "EMAuthorizationView.h"
#import "EMProtocolViewController.h"

@interface EMRegisterViewController ()<UITextFieldDelegate, EMUserProtocol>

@property (nonatomic, strong) UITextField *nameField;
@property (nonatomic, strong) EMRightViewToolView *userIdRightView;

@property (nonatomic, strong) UITextField *pswdField;
@property (nonatomic, strong) EMRightViewToolView *pswdRightView;

@property (nonatomic, strong) UITextField *confirmPswdField;
@property (nonatomic, strong) EMRightViewToolView *confirmPswdRightView;

@property (nonatomic, strong) EMUserAgreementView *userAgreementView;//用户协议
@property (nonatomic, strong) EMAuthorizationView *authorizationView;//授权操作视图

@property (nonatomic) BOOL isRegiste;

@end

@implementation EMRegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self _setupViews];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    [self.authorizationView originalView];//恢复原始视图
}

#pragma mark - Subviews

- (void)_setupViews
{
    //[self addPopBackLeftItem];
    //self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"qr"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(qrCodeAction)];

    //backView.backgroundColor = [UIColor whiteColor];
    
    UIImageView *imageView=[[UIImageView alloc]initWithFrame:self.view.bounds];
    imageView.image = [UIImage imageNamed:@"BootPage"];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view insertSubview:imageView atIndex:0];
    
    UIView *backView = [[UIView alloc]init];
    backView.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.3];
    [self.view addSubview:backView];
    [backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    UIButton *backButton = [[UIButton alloc]init];
    [backButton setBackgroundImage:[UIImage imageNamed:@"back_left"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backBackion) forControlEvents:UIControlEventTouchUpInside];
    [backView addSubview:backButton];
    [backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(backView).offset(44 + EMVIEWTOPMARGIN);
        make.left.equalTo(backView).offset(24);
        make.height.equalTo(@24);
        make.width.equalTo(@24);
    }];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"注册账号";
    titleLabel.textColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0];
    titleLabel.font = [UIFont systemFontOfSize:18];
    [backView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(backView);
        make.top.equalTo(backButton.mas_bottom).offset(30);
        make.height.equalTo(@30);
        make.width.equalTo(@80);
    }];
    
    self.nameField = [[UITextField alloc] init];
    self.nameField.backgroundColor = [UIColor whiteColor];
    self.nameField.delegate = self;
    self.nameField.borderStyle = UITextBorderStyleNone;
    self.nameField.placeholder = @"用户名";
    self.nameField.returnKeyType = UIReturnKeyDone;
    self.nameField.font = [UIFont systemFontOfSize:17];
    self.nameField.rightViewMode = UITextFieldViewModeWhileEditing;
    self.nameField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.nameField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 18, 10)];
    self.nameField.leftViewMode = UITextFieldViewModeAlways;
    self.nameField.layer.cornerRadius = 25;
    self.nameField.layer.borderWidth = 1;
    self.nameField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.userIdRightView = [[EMRightViewToolView alloc]initRightViewWithViewType:EMUsernameRightView];
    [self.userIdRightView.rightViewBtn addTarget:self action:@selector(clearUserIdAction) forControlEvents:UIControlEventTouchUpInside];
    self.nameField.rightView = self.userIdRightView;
    self.userIdRightView.hidden = YES;
    [backView addSubview:self.nameField];
    [self.nameField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(backView).offset(30);
        make.right.equalTo(backView).offset(-30);
        make.top.equalTo(titleLabel.mas_bottom).offset(20);
        make.height.equalTo(@55);
    }];
    
    self.pswdField = [[UITextField alloc] init];
    self.pswdField.backgroundColor = [UIColor whiteColor];
    self.pswdField.delegate = self;
    self.pswdField.borderStyle = UITextBorderStyleNone;
    self.pswdField.placeholder = @"密码";
    self.pswdField.font = [UIFont systemFontOfSize:17];
    self.pswdField.returnKeyType = UIReturnKeyDone;
    self.pswdField.secureTextEntry = YES;
    self.pswdRightView = [[EMRightViewToolView alloc]initRightViewWithViewType:EMPswdRightView];
    [self.pswdRightView.rightViewBtn addTarget:self action:@selector(pswdSecureAction:) forControlEvents:UIControlEventTouchUpInside];
    self.pswdField.rightView = self.pswdRightView;
    self.pswdRightView.hidden = YES;
    self.pswdField.rightViewMode = UITextFieldViewModeAlways;
    self.pswdField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 18, 10)];
    self.pswdField.leftViewMode = UITextFieldViewModeAlways;
    self.pswdField.layer.cornerRadius = 25;
    self.pswdField.layer.borderWidth = 1;
    self.pswdField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [backView addSubview:self.pswdField];
    [self.pswdField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.nameField);
        make.right.equalTo(self.nameField);
        make.top.equalTo(self.nameField.mas_bottom).offset(20);
        make.height.equalTo(self.nameField);
    }];
    
    self.confirmPswdField = [[UITextField alloc] init];
    self.confirmPswdField.backgroundColor = [UIColor whiteColor];
    self.confirmPswdField.delegate = self;
    self.confirmPswdField.borderStyle = UITextBorderStyleNone;
    self.confirmPswdField.placeholder = @"确认密码";
    self.confirmPswdField.font = [UIFont systemFontOfSize:17];
    self.confirmPswdField.returnKeyType = UIReturnKeyDone;
    self.confirmPswdField.secureTextEntry = YES;
    self.confirmPswdRightView = [[EMRightViewToolView alloc]initRightViewWithViewType:EMPswdRightView];
    [self.confirmPswdRightView.rightViewBtn addTarget:self action:@selector(confirmPswdSecureAction:) forControlEvents:UIControlEventTouchUpInside];
    self.confirmPswdField.rightView = self.confirmPswdRightView;
    self.confirmPswdRightView.hidden = YES;
    self.confirmPswdField.rightViewMode = UITextFieldViewModeAlways;
    self.confirmPswdField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 18, 10)];
    self.confirmPswdField.leftViewMode = UITextFieldViewModeAlways;
    self.confirmPswdField.layer.cornerRadius = 25;
    self.confirmPswdField.layer.borderWidth = 1;
    self.confirmPswdField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [backView addSubview:self.confirmPswdField];
    [self.confirmPswdField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.pswdField);
        make.right.equalTo(self.pswdField);
        make.top.equalTo(self.pswdField.mas_bottom).offset(20);
        make.height.equalTo(self.pswdField);
    }];
    
    self.userAgreementView = [[EMUserAgreementView alloc]initUserAgreement];
    self.userAgreementView.delegate = self;
    [self.userAgreementView.userAgreementBtn addTarget:self action:@selector(confirmProtocol) forControlEvents:UIControlEventTouchUpInside];
    [backView addSubview:_userAgreementView];
    [_userAgreementView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.confirmPswdField.mas_bottom).offset(6);
        make.left.equalTo(self.confirmPswdField.mas_left).offset(15);
        make.right.equalTo(backView);
        make.height.equalTo(@(ComponentHeight));
    }];
    
    self.authorizationView = [[EMAuthorizationView alloc]initWithAuthType:EMAuthRegiste];
    [self.authorizationView.authorizationBtn addTarget:self action:@selector(registeAction) forControlEvents:UIControlEventTouchUpInside];
    self.authorizationView.userInteractionEnabled = YES;
    [backView addSubview:self.authorizationView];
    [self.authorizationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(backView).offset(30);
        make.right.equalTo(backView).offset(-30);
        make.top.equalTo(self.userAgreementView.mas_bottom).offset(40);
        make.height.equalTo(@55);
    }];
}

- (void)backBackion
{
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    textField.layer.borderColor = kColor_Blue.CGColor;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    textField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    if(![self.nameField.text isEqualToString:@""] && ![self.pswdField.text isEqualToString:@""] && ![self.confirmPswdField.text isEqualToString:@""] && self.userAgreementView.userAgreementBtn.isSelected){
        [self.authorizationView setupAuthBtnBgcolor:YES];  
        self.isRegiste = true;
    } else {
        [self.authorizationView setupAuthBtnBgcolor:NO];
        self.isRegiste = false;
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
        return NO;
    }
    if (textField == self.nameField) {
        self.userIdRightView.hidden = NO;
        if ([self.nameField.text length] <= 1 && [string isEqualToString:@""])
            self.userIdRightView.hidden = YES;
    }
    if (textField == self.pswdField) {
        NSString *updatedString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        textField.text = updatedString;
        self.pswdRightView.hidden = NO;
        if ([self.pswdField.text length] <= 0 && [string isEqualToString:@""]) {
            self.pswdRightView.hidden = YES;
            self.pswdField.secureTextEntry = YES;
            [self.pswdRightView.rightViewBtn setSelected:NO];
        }
        return NO;
    }
    if (textField == self.confirmPswdField) {
        NSString *updatedString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        textField.text = updatedString;
        self.confirmPswdRightView.hidden = NO;
        if ([self.pswdField.text length] <= 0 && [string isEqualToString:@""]) {
            self.confirmPswdRightView.hidden = YES;
            self.confirmPswdField.secureTextEntry = YES;
            [self.confirmPswdRightView.rightViewBtn setSelected:NO];
        }
        return NO;
    }
    return YES;
}

- (void)textFieldDidChangeSelection:(UITextField *)textField
{
    UITextRange *rang = textField.markedTextRange;
    if (rang == nil) {
        if(![self.nameField.text isEqualToString:@""] && ![self.pswdField.text isEqualToString:@""] && ![self.confirmPswdField.text isEqualToString:@""] && self.userAgreementView.userAgreementBtn.isSelected){
            [self.authorizationView setupAuthBtnBgcolor:YES];
            self.isRegiste = true;
            return;
        }
        [self.authorizationView setupAuthBtnBgcolor:NO];
        self.isRegiste = false;
    }
}

#pragma mark - EMUserProtocol

- (void)didTapUserProtocol:(NSString *)protocolUrl sign:(NSString *)sign
{
    EMProtocolViewController *protocolController = [[EMProtocolViewController alloc]initWithUrl:protocolUrl sign:sign];
    protocolController.modalPresentationStyle = 0;
    [self presentViewController:protocolController animated:NO completion:nil];
}

#pragma mark - Action

- (void)confirmProtocol
{
    if(![self.nameField.text isEqualToString:@""] && ![self.pswdField.text isEqualToString:@""] && ![self.confirmPswdField.text isEqualToString:@""] && self.userAgreementView.userAgreementBtn.isSelected){
        [self.authorizationView setupAuthBtnBgcolor:YES];
        self.isRegiste = true;
        return;
    }
    [self.authorizationView setupAuthBtnBgcolor:NO];
    self.isRegiste = false;
}

//清除用户名
- (void)clearUserIdAction
{
    self.nameField.text = @"";
    self.userIdRightView.hidden = YES;
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

//隐藏/显示 密码
- (void)pswdSecureAction:(UIButton *)aButton
{
    aButton.selected = !aButton.selected;
    self.pswdField.secureTextEntry = !self.pswdField.secureTextEntry;
}
//隐藏/显示 确认密码
- (void)confirmPswdSecureAction:(UIButton *)aButton
{
    aButton.selected = !aButton.selected;
    self.confirmPswdField.secureTextEntry = !self.confirmPswdField.secureTextEntry;
}

- (void)registeAction
{
    if(!_isRegiste) {
        return;
    }
    
    [self.view endEditing:YES];
    
    if (!self.userAgreementView.userAgreementBtn.selected) {
        [EMAlertController showErrorAlert:@"请选择同意服务条款与隐私协议！"];
        return;
    }

    NSString *name = self.nameField.text;
    NSString *pswd = self.pswdField.text;
    NSString *confirmPwd = self.confirmPswdField.text;
    
    /*
    if ([name length] == 0 || [pswd length] == 0) {
        [EMAlertController showErrorAlert:@"用户ID或者密码不能为空"];
        return;
    }*/
    
    if(![pswd isEqualToString:confirmPwd]) {
        [EMAlertController showErrorAlert:@"两次输入密码不一致,请重新输入"];
        /*
        EMErrorAlertViewController *errorAlerController = [[EMErrorAlertViewController alloc]initWithErrorReason:@"两次输入密码不一致"];
        errorAlerController.modalPresentationStyle = 0;
        [self presentViewController:errorAlerController animated:NO completion:nil];*/
        return;
    }
    
    if (!gIsInitializedSDK) {
        gIsInitializedSDK = YES;
        EMOptions *options = [[EMDemoOptions sharedOptions] toOptions];
        [[EMClient sharedClient] initializeSDKWithOptions:options];
    }
    
    __weak typeof(self) weakself = self;
    [self.authorizationView beingLoadedView];//正在加载视图
    [[EMClient sharedClient] registerWithUsername:name password:pswd completion:^(NSString *aUsername, EMError *aError) {
        [weakself hideHud];
        
        if (!aError) {
            [EMAlertController showSuccessAlert:@"注册成功，请登录"];
            if (weakself.successCompletion) {
                weakself.successCompletion(name);
            }
            [weakself.authorizationView originalView];
            [weakself dismissViewControllerAnimated:NO completion:nil];
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
                errorDes = @"注册用户名已存在，请重新输入";
                break;
            case EMErrorExceedServiceLimit:
                errorDes = @"请求过于频繁，请稍后再试";
                break;
            default:
                break;
        }
        [EMAlertController showErrorAlert:errorDes];
        [self.authorizationView originalView];//恢复原始视图
        /*
        EMErrorAlertViewController *errorAlerController = [[EMErrorAlertViewController alloc]initWithErrorReason:errorDes];
        errorAlerController.modalPresentationStyle = 0;
        [self presentViewController:errorAlerController animated:NO completion:nil];
        [weakself.authorizationView setupAuthBtnBgcolor:YES];*/
    }];
}
@end
