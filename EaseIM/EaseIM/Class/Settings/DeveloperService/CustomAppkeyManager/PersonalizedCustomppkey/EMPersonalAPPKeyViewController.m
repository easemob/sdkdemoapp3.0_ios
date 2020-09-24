//
//  EMPersonalAPPKeyViewController.m
//  EaseIM
//
//  Created by 娜塔莎 on 2020/6/12.
//  Copyright © 2020 娜塔莎. All rights reserved.
//

#import "EMPersonalAPPKeyViewController.h"
#import "EMDemoOptions.h"
#import "EMTextView.h"

@interface EMPersonalAPPKeyViewController ()<UITextViewDelegate>

@property (nonatomic, strong)EMTextView *appkeyTextView;

@property (nonatomic, strong)EMTextView *aspCertNameTextView;

@property (nonatomic)BOOL isCorrectAppkey;//是否已输入appkey

@end

@implementation EMPersonalAPPKeyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isCorrectAppkey = NO;
    self.view.layer.backgroundColor = [UIColor colorWithRed:249/255.0 green:249/255.0 blue:249/255.0 alpha:1.0].CGColor;
    [self _setupSubviews];
}

#pragma mark - Subviews

- (void)_setupSubviews
{
    [self addPopBackLeftItem];
    self.title = @"添加自定义APPKey";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"提交" style:UIBarButtonItemStylePlain target:self action:@selector(addAppkeyAction)];
    
    UILabel *appkeyLabel = [[UILabel alloc]init];
    appkeyLabel.text = @"Appkey";
    appkeyLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
    appkeyLabel.font = [UIFont systemFontOfSize:14.0f];
    [self.view addSubview:appkeyLabel];
    [appkeyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(20);
        make.left.equalTo(self.view).offset(20);
    }];
    
    self.appkeyTextView = [[EMTextView alloc]init];
    self.appkeyTextView.delegate = self;
    self.appkeyTextView.placeholder = @"必填";
    self.appkeyTextView.textContainerInset = UIEdgeInsetsMake(8, 20, 8, 20);
    self.appkeyTextView.font = [UIFont systemFontOfSize:14.0];
    self.appkeyTextView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.appkeyTextView];
    [self.appkeyTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(appkeyLabel.mas_bottom).offset(10);
        make.height.equalTo(@80);
    }];
    
    UILabel *apnsNameLabel = [[UILabel alloc]init];
    apnsNameLabel.text = @"Aps Cert Name";
    apnsNameLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
    apnsNameLabel.font = [UIFont systemFontOfSize:14.0f];
    [apnsNameLabel sizeToFit];
    [self.view addSubview:apnsNameLabel];
    [apnsNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.appkeyTextView.mas_bottom).offset(20);
        make.left.equalTo(self.view).offset(20);
    }];
    
    self.aspCertNameTextView = [[EMTextView alloc]init];
    self.aspCertNameTextView.placeholder = @"选填";
    self.aspCertNameTextView.font = [UIFont systemFontOfSize:14.0];
    self.aspCertNameTextView.textContainerInset = UIEdgeInsetsMake(8, 20, 8, 20);
    [self.view addSubview:self.aspCertNameTextView];
    [self.aspCertNameTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(apnsNameLabel.mas_bottom).offset(10);
        make.height.equalTo(@80);
    }];
    
    UIButton *configurationBtn = [[UIButton alloc]init];
    configurationBtn.backgroundColor = [UIColor clearColor];
    [configurationBtn setTitle:@"配置说明" forState:UIControlStateNormal];
    [configurationBtn setTitleColor:[UIColor colorWithRed:4/255.0 green:174/255.0 blue:240/255.0 alpha:1.0] forState:UIControlStateNormal];
    [configurationBtn.titleLabel setFont:[UIFont systemFontOfSize:14.0]];
    configurationBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [configurationBtn addTarget:self action:@selector(configurationDetail) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:configurationBtn];
    [configurationBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.aspCertNameTextView.mas_bottom).offset(20);
        make.height.equalTo(@20);
    }];
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

#pragma mark - UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if (!self.isCorrectAppkey) {
        self.appkeyTextView.text = @"";
        self.appkeyTextView.textColor = [UIColor blackColor];
    }
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    self.isCorrectAppkey = YES;
}

# pragma mark - Action
//添加自定义appkey
- (void)addAppkeyAction
{
    if ([self.appkeyTextView.text length] == 0) {
        [self.view endEditing:YES];
        self.isCorrectAppkey = NO;
        self.appkeyTextView.text = @" 请填入您的appkey";
        self.appkeyTextView.textColor = [UIColor systemRedColor];
        return;
    }
    if (self.isCorrectAppkey) {
        [EMDemoOptions.sharedOptions.locationAppkeyArray insertObject:self.appkeyTextView.text atIndex:0];
        if ([self.aspCertNameTextView.text length] != 0) {
            EMDemoOptions.sharedOptions.apnsCertName = self.aspCertNameTextView.text;
        }
        [EMDemoOptions.sharedOptions archive];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

//配置说明
- (void)configurationDetail
{
    
}

@end
