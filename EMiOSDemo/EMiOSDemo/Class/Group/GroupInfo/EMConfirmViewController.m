//
//  EMConfirmViewController.m
//  EMiOSDemo
//
//  Created by 娜塔莎 on 2019/12/4.
//  Copyright © 2019 娜塔莎. All rights reserved.
//

#import "EMConfirmViewController.h"

@interface EMConfirmViewController ()
@property (nonatomic, strong) NSString *memberName;

@end

@implementation EMConfirmViewController

- (instancetype)initWithMembername:(NSString *)name
{
    self = [super init];
       if (self) {
           _memberName = name;
       }
       
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _setupSuviews];
}

- (void)_setupSuviews
{
    self.view.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.6];
    
    UIView *confirmView = [[UIView alloc]init];
    confirmView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:confirmView];
    [confirmView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(16);
        make.right.equalTo(self.view).offset(-16);
        make.height.equalTo(@200);
        make.centerY.centerX.equalTo(self.view);
    }];
    
    UILabel *content = [[UILabel alloc]init];
    content.text = @"是否移交群主给该成员";
    content.textColor = [UIColor colorWithRed:66/255.0 green:66/255.0 blue:66/255.0 alpha:1.0];
    content.textAlignment = NSTextAlignmentCenter;
    content.font = [UIFont systemFontOfSize:20.0];
    [confirmView addSubview:content];
    [content mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(confirmView).offset(30);
        make.left.equalTo(confirmView).offset(62);
        make.right.equalTo(confirmView).offset(-62);
        make.height.equalTo(@28);
    }];
    
    UIView *memberView = [[UIView alloc]init];
    memberView.backgroundColor = [UIColor colorWithRed:249/255.0 green:249/255.0 blue:249/255.0 alpha:1.0];
    [confirmView addSubview:memberView];
    [memberView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(content).offset(24);
        make.left.equalTo(confirmView).offset(32);
        make.right.equalTo(confirmView).offset(-32);
        make.height.equalTo(@90);
    }];
    UIImageView *avatarView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"user_avatar_blue"]];
    [memberView addSubview:avatarView];
    [avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(memberView).offset(22);
        make.bottom.equalTo(memberView).offset(-22);
        make.width.equalTo(@46);
    }];
    UILabel *nameLabel = [[UILabel alloc]init];
    nameLabel.text = self.memberName;
    nameLabel.textColor = [UIColor blackColor];
    nameLabel.font = [UIFont systemFontOfSize:18.0];
    [memberView addSubview:nameLabel];
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(avatarView.mas_right).offset(10);
        make.top.equalTo(memberView).offset(32);
        make.bottom.equalTo(memberView).offset(-32);
        make.right.equalTo(memberView).offset(-10);
    }];
    
    UIButton *cancelBtn = [[UIButton alloc]init];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:18.0];
    [cancelBtn setBackgroundColor:[UIColor whiteColor]];
    cancelBtn.layer.borderWidth = 1;
    cancelBtn.layer.borderColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0].CGColor;
    [confirmView addSubview:cancelBtn];
    cancelBtn.tag = 0;
    [cancelBtn addTarget:self action:@selector(confirmAction:) forControlEvents:UIControlEventTouchUpInside];
    [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.equalTo(confirmView);
        make.height.equalTo(@56);
        make.width.equalTo(@(confirmView.frame.size.width/2));
    }];
    
    UIButton *confirmBtn = [[UIButton alloc]init];
    [confirmBtn setTitle:@"确认移交" forState:UIControlStateNormal];
    confirmBtn.titleLabel.font = [UIFont systemFontOfSize:18.0];
    [confirmBtn.titleLabel setTextColor:[UIColor colorWithRed:255/255.0 green:43/255.0 blue:43/255.0 alpha:1.0]];
    [confirmBtn setBackgroundColor:[UIColor whiteColor]];
    confirmBtn.layer.borderWidth = 1;
    confirmBtn.layer.borderColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0].CGColor;
    [confirmView addSubview:confirmBtn];
    confirmBtn.tag = 1;
    [confirmBtn addTarget:self action:@selector(confirmAction:) forControlEvents:UIControlEventTouchUpInside];
    [confirmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.bottom.equalTo(confirmView);
        make.height.equalTo(@56);
        make.width.equalTo(@(confirmView.frame.size.width/2));
    }];
    
    
}

#pragma mark - Action

- (void)confirmAction:(UIButton *)btn
{
    BOOL confirm = false;
    if (btn.tag == 1) {
        confirm = true;
    }
    BOOL isPop = YES;
    if (_doneCompletion) {
        isPop = _doneCompletion(confirm);
    }
    
    if (isPop) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}


@end
