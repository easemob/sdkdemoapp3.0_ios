//
//  Call1v1AudioViewController.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2018/9/19.
//  Copyright © 2018 XieYajie. All rights reserved.
//

#import "Call1v1AudioViewController.h"

#import "EMButton.h"

#import "SingleCallController.h"

@interface Call1v1AudioViewController ()

@property (nonatomic, strong) CAGradientLayer *backGl;

@end

@implementation Call1v1AudioViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view.layer insertSublayer:self.backGl atIndex:0];
    [self _setBackground];
    [self _setupSubviews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Subviews

- (void)_setupSubviews
{
    [self.microphoneButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(RTC_BUTTON_PADDING);
        make.bottom.equalTo(self.view).offset(-20);
        make.width.mas_equalTo(RTC_BUTTON_WIDTH);
        make.height.mas_equalTo(RTC_BUTTON_HEIGHT);
    }];
    
    [self.speakerButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view).offset(-RTC_BUTTON_PADDING);
        make.bottom.equalTo(self.view).offset(-20);
        make.width.mas_equalTo(RTC_BUTTON_WIDTH);
        make.height.mas_equalTo(RTC_BUTTON_HEIGHT);
    }];
    
    [self.waitImgView removeFromSuperview];
    /*
    [self.waitImgView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-20);
        make.bottom.equalTo(self.microphoneButton.mas_top).offset(-40);
    }];*/
    
    self.floatingView.bgView.image = [UIImage imageNamed:@"floating_voice"];
    self.floatingView.bgView.layer.borderWidth = 0;
    self.floatingView.isLockedBgView = YES;
}

//背景图
- (void)_setBackground
{
    UIView *outerLayer = [[UIView alloc] init];
    outerLayer.layer.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0].CGColor;
    outerLayer.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.02].CGColor;
    outerLayer.layer.shadowOffset = CGSizeMake(0,0);
    outerLayer.layer.shadowOpacity = 1;
    outerLayer.layer.shadowRadius = 15;
    outerLayer.alpha = 0.1;
    UIView *middleLayer = [[UIView alloc] init];
    middleLayer.layer.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0].CGColor;
    middleLayer.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.04].CGColor;
    middleLayer.layer.shadowOffset = CGSizeMake(0,0);
    middleLayer.layer.shadowOpacity = 1;
    middleLayer.layer.shadowRadius = 12;
    middleLayer.alpha = 0.19;
    UIView *insideLayer = [[UIView alloc] init];
    insideLayer.layer.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0].CGColor;
    insideLayer.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.04].CGColor;
    insideLayer.layer.shadowOffset = CGSizeMake(0,0);
    insideLayer.layer.shadowOpacity = 1;
    insideLayer.layer.shadowRadius = 12;
    insideLayer.alpha = 0.3;
    [self.view addSubview:outerLayer];
    [outerLayer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.centerY.equalTo(self.view.mas_centerY).offset(-80);
        make.width.height.equalTo(@230);
    }];
    outerLayer.layer.cornerRadius = 115;
    [self.view addSubview:middleLayer];
    [middleLayer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.centerY.equalTo(self.view.mas_centerY).offset(-80);
        make.width.height.equalTo(@170);
    }];
    middleLayer.layer.cornerRadius = 85;
    [self.view addSubview:insideLayer];
    [insideLayer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.centerY.equalTo(self.view.mas_centerY).offset(-80);
        make.width.height.equalTo(@120);
    }];
    insideLayer.layer.cornerRadius = 60;
    UIImageView *avatarImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"defaultAvatar"]];
    [self.view addSubview:avatarImage];
    [avatarImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.centerY.equalTo(self.view.mas_centerY).offset(-80);
        make.width.height.equalTo(@80);
    }];
    avatarImage.layer.cornerRadius = 40;
    
    [self.remoteNameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(outerLayer.mas_bottom).offset(25);
        make.centerX.equalTo(self.view);
        make.left.right.equalTo(self.view);
        make.height.equalTo(@30);
    }];
    [self.statusLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.remoteNameLabel.mas_bottom).offset(2);
        make.centerX.equalTo(self.view);
        make.left.right.equalTo(self.view);
    }];
}

#pragma mark - Action

- (void)minimizeAction
{
    self.minButton.selected = YES;
    
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:self.floatingView];
    [keyWindow bringSubviewToFront:self.floatingView];
    [self.floatingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@50);
        make.top.equalTo(keyWindow.mas_top).offset(80);
        make.right.equalTo(keyWindow.mas_right).offset(-40);
    }];
    
    [self dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark - Getter

- (CAGradientLayer *)backGl{
    if(_backGl == nil) {
        _backGl = [CAGradientLayer layer];
        _backGl.frame = CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height);
        _backGl.startPoint = CGPointMake(0.5, 0);
        _backGl.endPoint = CGPointMake(0.5, 1);
        _backGl.colors = @[(__bridge id)[UIColor colorWithRed:187/255.0 green:187/255.0 blue:187/255.0 alpha:1.0].CGColor, (__bridge id)[UIColor colorWithRed:133/255.0 green:133/255.0 blue:133/255.0 alpha:1.0].CGColor];
        _backGl.locations = @[@(0), @(1.0f)];
    }
    return _backGl;
}

@end
