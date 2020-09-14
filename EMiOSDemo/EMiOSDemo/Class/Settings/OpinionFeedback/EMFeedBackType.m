//
//  EMFeedBackType.m
//  EMIMDEMO
//
//  Created by 娜塔莎 on 2020/2/19.
//  Copyright © 2020 zmw. All rights reserved.
//

#import "EMFeedBackType.h"

@interface EMFeedBackType()

@property (nonatomic, strong) UIButton *bugFeedbackBtn;
@property (nonatomic, strong) UIButton *experienceKartunBtn;
@property (nonatomic, strong) UIButton *currentBtnType;

@end

@implementation EMFeedBackType

- (instancetype)init
{
    if (self = [super init]) {
        [self _setupSuviews];
    }
    return self;
}

- (void)_setupSuviews
{
    self.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.4];
    
    UIView *confirmView = [[UIView alloc]init];
    confirmView.backgroundColor = [UIColor whiteColor];
    confirmView.layer.cornerRadius = 8;
    [self addSubview:confirmView];
    [confirmView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(16);
        make.right.equalTo(self).offset(-16);
        make.height.equalTo(@240);
        make.centerY.centerX.equalTo(self);
    }];
    
    UILabel *content = [[UILabel alloc]init];
    content.text = @"选择类型";
    content.textColor = [UIColor colorWithRed:66/255.0 green:66/255.0 blue:66/255.0 alpha:1.0];
    content.textAlignment = NSTextAlignmentCenter;
    content.font = [UIFont fontWithName:@"PingFangSC" size: 20];
    [confirmView addSubview:content];
    [content mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(confirmView).offset(20);
        make.left.equalTo(confirmView).offset(32);
        make.right.equalTo(confirmView).offset(-32);
        make.height.equalTo(@28);
    }];
    
    self.bugFeedbackBtn = [[UIButton alloc] init];
    [self.bugFeedbackBtn addTarget:self action:@selector(checkboxAction:) forControlEvents:UIControlEventTouchUpInside];
    self.bugFeedbackBtn.tag = 0;
    [self.bugFeedbackBtn setBackgroundImage:[UIImage imageNamed:@"currentAppkey"] forState:UIControlStateSelected];
    [self.bugFeedbackBtn setBackgroundImage:[UIImage imageNamed:@"optionalAppkey"] forState:UIControlStateNormal];
    [confirmView addSubview:self.bugFeedbackBtn];
    [self.bugFeedbackBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@25);
        make.top.equalTo(content.mas_bottom).offset(20);
        make.left.equalTo(confirmView).offset(16);
    }];
    
    UILabel *bugFeedback = [[UILabel alloc]init];
    bugFeedback.font = [UIFont systemFontOfSize:14.0];
    bugFeedback.text = @"BUG反馈";
    [confirmView addSubview:bugFeedback];
    [bugFeedback mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.bugFeedbackBtn);
        make.left.equalTo(self.bugFeedbackBtn.mas_right).offset(16);
    }];
    
    self.experienceKartunBtn = [[UIButton alloc] init];
    [self.experienceKartunBtn addTarget:self action:@selector(checkboxAction:) forControlEvents:UIControlEventTouchUpInside];
    self.experienceKartunBtn.tag = 1;
    [self.experienceKartunBtn setBackgroundImage:[UIImage imageNamed:@"currentAppkey"] forState:UIControlStateSelected];
    [self.experienceKartunBtn setBackgroundImage:[UIImage imageNamed:@"optionalAppkey"] forState:UIControlStateNormal];
    [confirmView addSubview:self.experienceKartunBtn];
    [self.experienceKartunBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@25);
        make.top.equalTo(self.bugFeedbackBtn.mas_bottom).offset(25);
        make.left.equalTo(confirmView).offset(16);
    }];
    
    UILabel *experienceKartun = [[UILabel alloc]init];
    experienceKartun.font = [UIFont systemFontOfSize:14.0];
    experienceKartun.text = @"使用卡顿";
    [self addSubview:experienceKartun];
    [experienceKartun mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.experienceKartunBtn);
        make.left.equalTo(self.experienceKartunBtn.mas_right).offset(16);
    }];
    
    UIButton *cancelBtn = [[UIButton alloc]init];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [cancelBtn setTitleColor:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0] forState:UIControlStateNormal];
    [cancelBtn setBackgroundColor:[UIColor whiteColor]];
    cancelBtn.layer.borderWidth = 1;
    cancelBtn.layer.borderColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0].CGColor;
    cancelBtn.layer.cornerRadius = 8;
    [confirmView addSubview:cancelBtn];
    cancelBtn.tag = 0;
    [cancelBtn addTarget:self action:@selector(confirmAction:) forControlEvents:UIControlEventTouchUpInside];
    CGFloat width = ([UIScreen mainScreen].bounds.size.width-32)/2;
    [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.equalTo(confirmView);
        make.height.equalTo(@55);
        make.width.mas_equalTo(width);
    }];
    
    UIButton *confirmBtn = [[UIButton alloc]init];
    [confirmBtn setTitle:@"确定" forState:UIControlStateNormal];
    confirmBtn.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [confirmBtn setTitleColor:[UIColor colorWithRed:255/255.0 green:43/255.0 blue:43/255.0 alpha:1.0] forState:UIControlStateNormal];
    [confirmBtn setBackgroundColor:[UIColor whiteColor]];
    confirmBtn.layer.borderWidth = 1;
    confirmBtn.layer.borderColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0].CGColor;
    confirmBtn.layer.cornerRadius = 8;
    [confirmView addSubview:confirmBtn];
    confirmBtn.tag = 1;
    [confirmBtn addTarget:self action:@selector(confirmAction:) forControlEvents:UIControlEventTouchUpInside];
    [confirmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.bottom.equalTo(confirmView);
        make.height.equalTo(@55);
        make.width.mas_equalTo(width);
    }];
}

#pragma mark - Action

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

- (void)confirmAction:(UIButton *)btn
{
    BOOL confirm = false;
    if (btn.tag == 1) {
        confirm = true;
    }
    if (_doneCompletion && confirm) {
        _doneCompletion(self.currentBtnType.tag == 0 ? @"BUG反馈" : @"使用卡顿");
    }
    [self removeFromSuperview];
}

@end
