//
//  EMErrorAlertViewController.m
//  EaseIM
//
//  Created by 娜塔莎 on 2019/11/14.
//  Copyright © 2019 娜塔莎. All rights reserved.
//

#import "EMErrorAlertViewController.h"

@interface EMErrorAlertViewController ()

@property (nonatomic, strong) UILabel *descLabel;

@end

@implementation EMErrorAlertViewController

- (instancetype)initWithErrorReason:(NSString *)errorReason {
    self = [super init];
    if (self) {
        self.descLabel.text = errorReason;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _setupSubView];
    [self startTimer];
}

- (void)_setupSubView {
    
    self.view.backgroundColor = [UIColor colorWithRed:36/255.0 green:42/255.0 blue:56/255.0 alpha:1.0];
    
    UIView *backView = [[UIView alloc]init];
    backView.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.6];
    [self.view addSubview:backView];
    [backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.centerY.equalTo(self.view);
        make.width.equalTo(@240);
        make.height.equalTo(@140);
    }];
    
    UIImageView *imgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon_failure"]];
    [backView addSubview:imgView];
    [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(backView.mas_top).offset(20);
        make.height.width.equalTo(@41);
        make.centerX.equalTo(backView);
    }];
    
    self.descLabel.font = [UIFont systemFontOfSize:14];
    _descLabel.textColor = [UIColor whiteColor];
    _descLabel.textAlignment = NSTextAlignmentCenter;
    [backView addSubview:_descLabel];
    [_descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(imgView.mas_bottom).offset(20);
        make.centerX.equalTo(backView);
        make.width.equalTo(backView);
        make.height.equalTo(@20);
    }];
    
}

- (void)startTimer {
    [self performSelector:@selector(btnClickedAction) withObject:nil afterDelay:2];
}

- (void)btnClickedAction {
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (UILabel *)descLabel {
    if (_descLabel == nil) {
        _descLabel = [[UILabel alloc]init];
    }
    return _descLabel;
}

@end
