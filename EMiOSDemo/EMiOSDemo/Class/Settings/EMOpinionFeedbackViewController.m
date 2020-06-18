//
//  EMOpinionFeedbackViewController.m
//  EMiOSDemo
//
//  Created by 娜塔莎 on 2020/6/10.
//  Copyright © 2020 娜塔莎. All rights reserved.
//

#import "EMOpinionFeedbackViewController.h"

@interface EMOpinionFeedbackViewController ()
{
    CGFloat offset;
}

@property (nonatomic, strong) UIButton *bugFeedbackBtn;
@property (nonatomic, strong) UIButton *experienceKartunBtn;

@property (nonatomic, strong) UITextView *opinionDescTextView;

@property (nonatomic, strong) UITextField *mailTextFiled;
@property (nonatomic, strong) UITextField *imTextFiled;

@property (nonatomic, strong) UIButton *commitBtn;

@property (nonatomic, strong) UILabel *bugTypeLabel;

@property (nonatomic, strong) UIButton *currentBtnType;

@end

@implementation EMOpinionFeedbackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    offset = 0.0;
    [self _setupSubviews];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

- (void)_setupSubviews
{
    [self addPopBackLeftItem];
    self.title = @"意见反馈";
    self.view.backgroundColor = [UIColor colorWithRed:249/255.0 green:249/255.0 blue:249/255.0 alpha:1.0];
    
    self.bugTypeLabel = [[UILabel alloc]init];
    _bugTypeLabel.font = [UIFont systemFontOfSize:16.0];
    _bugTypeLabel.text = @"选择问题类型：";
    [self.view addSubview:_bugTypeLabel];
    [_bugTypeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(20);
        make.left.equalTo(self.view).offset(16);
    }];
    
    self.bugFeedbackBtn = [[UIButton alloc] init];
    self.bugFeedbackBtn.layer.borderWidth = 1;
    self.bugFeedbackBtn.layer.borderColor = [UIColor blackColor].CGColor;
    [self.bugFeedbackBtn addTarget:self action:@selector(checkboxAction:) forControlEvents:UIControlEventTouchUpInside];
    self.bugFeedbackBtn.tag = 0;
    [self.bugFeedbackBtn setImage:[UIImage imageNamed:@"ios"] forState:UIControlStateSelected];
    [self.view addSubview:self.bugFeedbackBtn];
    [self.bugFeedbackBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@25);
        make.top.equalTo(self.bugTypeLabel.mas_bottom).offset(20);
        make.left.equalTo(self.view).offset(16);
    }];
    
    UILabel *bugFeedback = [[UILabel alloc]init];
    bugFeedback.font = [UIFont systemFontOfSize:14.0];
    bugFeedback.text = @"BUG反馈";
    [self.view addSubview:bugFeedback];
    [bugFeedback mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.bugFeedbackBtn);
        make.left.equalTo(self.bugFeedbackBtn.mas_right).offset(16);
    }];
    
    self.experienceKartunBtn = [[UIButton alloc] init];
    self.experienceKartunBtn.layer.borderWidth = 1;
    self.experienceKartunBtn.layer.borderColor = [UIColor blackColor].CGColor;
    [self.experienceKartunBtn addTarget:self action:@selector(checkboxAction:) forControlEvents:UIControlEventTouchUpInside];
    self.experienceKartunBtn.tag = 1;
    [self.experienceKartunBtn setImage:[UIImage imageNamed:@"ios"] forState:UIControlStateSelected];
    [self.view addSubview:self.experienceKartunBtn];
    [self.experienceKartunBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@25);
        make.top.equalTo(self.bugFeedbackBtn.mas_bottom).offset(20);
        make.left.equalTo(self.view).offset(16);
    }];
    
    UILabel *experienceKartun = [[UILabel alloc]init];
    experienceKartun.font = [UIFont systemFontOfSize:14.0];
    experienceKartun.text = @"使用卡顿";
    [self.view addSubview:experienceKartun];
    [experienceKartun mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.experienceKartunBtn);
        make.left.equalTo(self.experienceKartunBtn.mas_right).offset(16);
    }];
    
    UILabel *opinionDesc = [[UILabel alloc]init];
    opinionDesc.font = [UIFont systemFontOfSize:16.0];
    opinionDesc.text = @"问题描述：";
    [self.view addSubview:opinionDesc];
    [opinionDesc mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.experienceKartunBtn.mas_bottom).offset(30);
        make.left.equalTo(self.view).offset(16);
    }];
    
    self.opinionDescTextView = [[UITextView alloc]init];
    self.opinionDescTextView.layer.borderWidth = 1;
    self.opinionDescTextView.layer.borderColor = [UIColor blackColor].CGColor;
    [self.view addSubview:self.opinionDescTextView];
    [self.opinionDescTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(opinionDesc.mas_bottom).offset(10);
        make.left.equalTo(self.view).offset(16);
        make.right.equalTo(self.view).offset(-16);
        make.height.equalTo(@120);
    }];
    
    UILabel *contactWay = [[UILabel alloc]init];
    contactWay.font = [UIFont systemFontOfSize:16.0];
    contactWay.text = @"您的联系方式：";
    [self.view addSubview:contactWay];
    [contactWay mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.opinionDescTextView.mas_bottom).offset(20);
        make.left.equalTo(self.view).offset(16);
    }];
    
    UILabel *email = [[UILabel alloc]init];
    email.font = [UIFont systemFontOfSize:16.0];
    email.text = @"邮箱：";
    [self.view addSubview:email];
    [email mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(contactWay.mas_bottom).offset(20);
        make.left.equalTo(self.view).offset(16);
    }];
    
    UILabel *im = [[UILabel alloc]init];
    im.font = [UIFont systemFontOfSize:16.0];
    im.text = @"Q Q：";
    [self.view addSubview:im];
    [im mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(email.mas_bottom).offset(20);
        make.left.equalTo(self.view).offset(16);
    }];
    
    self.mailTextFiled = [[UITextField alloc]init];
    self.mailTextFiled.font = [UIFont systemFontOfSize:10.0];
    self.mailTextFiled.layer.borderWidth = 1;
    self.mailTextFiled.layer.borderColor = [UIColor blackColor].CGColor;
    [self.view addSubview:self.mailTextFiled];
    [self.mailTextFiled mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(email);
        make.right.equalTo(self.view).offset(-16);
        make.width.equalTo(@(self.view.frame.size.width - 100));
        make.height.equalTo(@30);
    }];
    
    self.imTextFiled = [[UITextField alloc]init];
    self.imTextFiled.font = [UIFont systemFontOfSize:10.0];
    self.imTextFiled.layer.borderWidth = 1;
    self.imTextFiled.layer.borderColor = [UIColor blackColor].CGColor;
    [self.view addSubview:self.imTextFiled];
    [self.imTextFiled mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(im);
        make.right.equalTo(self.view).offset(-16);
        make.width.equalTo(@(self.view.frame.size.width - 100));
        make.height.equalTo(@30);
    }];
    
    self.commitBtn = [[UIButton alloc]init];
    [self.commitBtn setTitle:@"提交" forState:UIControlStateNormal];
    [self.commitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.commitBtn.backgroundColor = [UIColor systemBlueColor];
    self.commitBtn.layer.cornerRadius = 10.0;
    [self.commitBtn.titleLabel setFont:[UIFont systemFontOfSize:16.0]];
    [self.commitBtn addTarget:self action:@selector(commitAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.commitBtn];
    [self.commitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-16);
        make.width.equalTo(@100);
        make.height.equalTo(@40);
    }];
}

# pragma mark - Action
//复选框checkbox
- (void)checkboxAction:(UIButton *)btn
{
    if (!self.currentBtnType) {
        btn.selected = YES;
        self.currentBtnType = btn;
    } else {
        if (self.currentBtnType == btn) {
            btn.selected = NO;
            self.currentBtnType = nil;
        } else {
            self.currentBtnType.selected = NO;
            btn.selected = YES;
            self.currentBtnType = btn;
        }
    }
}

//提交
- (void)commitAction
{
    if (!self.currentBtnType) {
        [self showHint:@"请选择反馈问题类型！"];
    } else {
        
    }
}

#pragma mark - KeyBoard

- (void)keyBoardWillShow:(NSNotification *)note
{
    // 获取用户信息
    NSDictionary *userInfo = [NSDictionary dictionaryWithDictionary:note.userInfo];
    // 获取键盘高度
    CGRect keyBoardBounds  = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyBoardHeight = keyBoardBounds.size.height;
    
    // 定义好动作
    void (^animation)(void) = ^void(void) {
        [self.bugTypeLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            self->offset = (self.imTextFiled.frame.origin.y + 20) - (self.view.frame.size.height - keyBoardHeight);
            make.top.equalTo(self.view).offset(-self->offset);
        }];
    };
    
    if ((self.imTextFiled.frame.origin.y + 20) > (self.view.frame.size.height - keyBoardHeight)) {
        animation();
    }
}

- (void)keyBoardWillHide:(NSNotification *)note
{
    // 定义好动作
    void (^animation)(void) = ^void(void) {
        [self.bugTypeLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view).offset(20);
        }];
    };
    if (self->offset > 0.0) {
        animation();
    }
}

@end
