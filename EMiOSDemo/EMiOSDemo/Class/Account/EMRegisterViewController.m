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

#import "EMErrorAlertViewController.h"
#import "LoadingCALayer.h"
#import "OneLoadingAnimationView.h"

@interface EMRegisterViewController ()<UITextFieldDelegate>

@property (nonatomic, strong) UITextField *appkeyField;
@property (nonatomic, strong) UIButton *appkeyRightView;

@property (nonatomic, strong) UITextField *nameField;

@property (nonatomic, strong) UITextField *pswdField;
@property (nonatomic, strong) UIButton *pswdRightView;

@property (nonatomic, strong) UITextField *confirmPswdField;

@property (nonatomic, strong) UIButton *registeButton;
@property (nonatomic, strong) UIView *viewArrow;
@property (nonatomic, strong) CAGradientLayer *gl;
@property (nonatomic, strong) CAGradientLayer *backGl;
@property (nonatomic, strong) UILabel *registeLabel;

@property (nonatomic) BOOL isRegiste;

@property (strong, nonatomic) IBOutlet OneLoadingAnimationView *loadingView;//加载view

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
    self.registeLabel.text = @"注 册";
    [self.loadingView removeFromSuperview];
}

#pragma mark - Subviews

- (void)_setupViews
{
    //[self addPopBackLeftItem];
    //self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"qr"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(qrCodeAction)];

    //self.view.backgroundColor = [UIColor whiteColor];
    
    UIImageView *imageView=[[UIImageView alloc]initWithFrame:self.view.bounds];
    imageView.image=[UIImage imageNamed:@"BootPage"];
    [self.view insertSubview:imageView atIndex:0];
    
    UIButton *backButton = [[UIButton alloc]init];
    [backButton setBackgroundImage:[UIImage imageNamed:@"24 ／ arrows ／ arrow-left"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backBackion) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    [backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(44);
        make.left.equalTo(self.view).offset(24);
        make.height.equalTo(@24);
        make.width.equalTo(@24);
    }];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"注册账号";
    titleLabel.textColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0];
    titleLabel.font = [UIFont systemFontOfSize:18];
    [self.view addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(backButton.mas_bottom).offset(30);
        make.height.equalTo(@30);
        make.width.equalTo(@80);
    }];
    /*
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
    */
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
        make.top.equalTo(titleLabel.mas_bottom).offset(20);
        make.height.equalTo(@45);
    }];
    
    self.pswdField = [[UITextField alloc] init];
        self.pswdField.backgroundColor = [UIColor whiteColor];
        self.pswdField.delegate = self;
        self.pswdField.borderStyle = UITextBorderStyleNone;
        self.pswdField.placeholder = @"密码";
        self.pswdField.font = [UIFont systemFontOfSize:17];
        self.pswdField.returnKeyType = UIReturnKeyDone;
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
        self.confirmPswdField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        self.confirmPswdField.leftViewMode = UITextFieldViewModeAlways;
        self.confirmPswdField.layer.cornerRadius = 25;
        self.confirmPswdField.layer.borderWidth = 1;
        self.confirmPswdField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [self.view addSubview:self.confirmPswdField];
    [self.confirmPswdField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.pswdField);
        make.right.equalTo(self.pswdField);
        make.top.equalTo(self.pswdField.mas_bottom).offset(20);
        make.height.equalTo(self.pswdField);
    }];
    
    self.registeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _registeButton.layer.cornerRadius = 25;
    _registeButton.alpha = 0.3;
    _registeButton.backgroundColor = [UIColor blackColor];
    [_registeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_registeButton addTarget:self action:@selector(registeAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_registeButton];
    [_registeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(30);
        make.right.equalTo(self.view).offset(-30);
        make.top.equalTo(self.confirmPswdField.mas_bottom).offset(60);
        make.height.equalTo(@55);
    }];
    
    self.registeLabel = [[UILabel alloc] init];
    _registeLabel.numberOfLines = 0;
    _registeLabel.font = [UIFont systemFontOfSize:16];
    _registeLabel.text = @"注 册";
    [_registeLabel setTextColor:[UIColor whiteColor]];
    _registeLabel.textAlignment = NSTextAlignmentCenter;
    _registeLabel.alpha = 0.3;
    [self.view addSubview:_registeLabel];
    [_registeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.registeButton);
        make.centerX.equalTo(self.registeButton);
        make.width.equalTo(@70);
        make.height.equalTo(@23);
   }];
    
    self.viewArrow = [[UIView alloc] init];
    _viewArrow.layer.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0].CGColor;
    _viewArrow.alpha = 0.3;
    _viewArrow.layer.cornerRadius = 21;
    [self.view addSubview:_viewArrow];
    [_viewArrow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@43);
        make.right.equalTo(self.registeButton.mas_right).offset(-6);
        make.top.equalTo(self.registeButton.mas_top).offset(6);
        make.height.equalTo(@43);
    }];
}

- (void)backBackion
{
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (CAGradientLayer *)backGl{
    if(_backGl == nil) {
        _backGl = [CAGradientLayer layer];
        _backGl.frame = CGRectMake(0,0,_registeButton.frame.size.width,55);
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
        _gl.frame = CGRectMake(0,0,_registeButton.frame.size.width,55);
        _gl.startPoint = CGPointMake(0.15, 0.5);
        _gl.endPoint = CGPointMake(1, 0.5);
        _gl.colors = @[(__bridge id)[UIColor colorWithRed:4/255.0 green:174/255.0 blue:240/255.0 alpha:1.0].CGColor, (__bridge id)[UIColor colorWithRed:90/255.0 green:93/255.0 blue:208/255.0 alpha:1.0].CGColor];
        _gl.locations = @[@(0), @(1.0f)];
        _gl.cornerRadius = 25;
    }
    
    return _gl;
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    textField.layer.borderColor = kColor_Blue.CGColor;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    textField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    if(self.nameField.text.length > 0 && self.pswdField.text.length > 0 && self.confirmPswdField.text.length > 0){
        [self.backGl removeFromSuperlayer];
        [_registeButton.layer addSublayer:self.gl];
        _registeButton.alpha = 1;
        _registeLabel.alpha = 1;
        [_registeLabel setTextColor:[UIColor colorWithRed:244/255.0 green:244/255.0 blue:244/255.0 alpha:1.0]];
        
        _viewArrow.alpha = 1;
        _viewArrow.layer.backgroundColor = ([UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0].CGColor);;
        
        self.isRegiste = true;
    } else {
        [self.gl removeFromSuperlayer];
        [_registeButton.layer addSublayer:self.backGl];
        _registeButton.alpha = 0.3;
        _registeLabel.alpha = 0.3;
        [_registeLabel setTextColor:[UIColor whiteColor]];
        
        _viewArrow.layer.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0].CGColor;
        _viewArrow.alpha = 0.3;
        self.isRegiste = false;
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
            
            weakself.appkeyField.text = [EMDemoOptions sharedOptions].appkey;
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
        weakself.appkeyField.text = aOptions.appkey;
    }];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)pswdSecureAction:(UIButton *)aButton
{
    aButton.selected = !aButton.selected;
    self.pswdField.secureTextEntry = !self.pswdField.secureTextEntry;
}

- (void)registeAction
{
    if(!_isRegiste) {
        return;
    }
    
    [self.view endEditing:YES];

    NSString *name = self.nameField.text;
    NSString *pswd = self.pswdField.text;
    NSString *confirmPwd = self.confirmPswdField.text;
    
    /*
    if ([name length] == 0 || [pswd length] == 0) {
        [EMAlertController showErrorAlert:@"用户ID或者密码不能为空"];
        return;
    }*/
    
    if(![pswd isEqualToString:confirmPwd]) {
        EMErrorAlertViewController *errorAlerController = [[EMErrorAlertViewController alloc]initWithErrorReason:@"两次输入密码不一致"];
        errorAlerController.modalPresentationStyle = 0;
        [self presentViewController:errorAlerController animated:NO completion:nil];
        return;
    }
    
    if (!gIsInitializedSDK) {
        gIsInitializedSDK = YES;
        EMOptions *options = [[EMDemoOptions sharedOptions] toOptions];
        [[EMClient sharedClient] initializeSDKWithOptions:options];
    }
    
    __weak typeof(self) weakself = self;
    //[self showHudInView:self.view hint:NSLocalizedString(@"register.ongoing", @"Is Login...")];
    self.registeLabel.text = @"注册中...";
    [self.viewArrow addSubview:self.loadingView];
    [self.loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(self.viewArrow).offset(11.5);
        make.width.equalTo(@22);
    }];
    [[EMClient sharedClient] registerWithUsername:name password:pswd completion:^(NSString *aUsername, EMError *aError) {
        [weakself hideHud];
        
        if (!aError) {
            if (weakself.successCompletion) {
                weakself.successCompletion(name, pswd);
            }
            
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
                errorDes = @"用户ID已存在";
                break;
            case EMErrorExceedServiceLimit:
                errorDes = @"请求过于频繁，请稍后再试";
                break;
            default:
                break;
        }
        EMErrorAlertViewController *errorAlerController = [[EMErrorAlertViewController alloc]initWithErrorReason:errorDes];
        errorAlerController.modalPresentationStyle = 0;
        [self presentViewController:errorAlerController animated:NO completion:nil];
    }];
}

- (UIView *)loadingView
{
    if (_loadingView == nil) {
        _loadingView = [[OneLoadingAnimationView alloc]initWithRadius:10.5];
    }
    return _loadingView;
}

@end
