//
//  EMAuthorizationView.m
//  EaseIM
//
//  Created by 娜塔莎 on 2020/7/2.
//  Copyright © 2020 娜塔莎. All rights reserved.
//

#import "EMAuthorizationView.h"
#import "LoadingCALayer.h"
#import "OneLoadingAnimationView.h"

@interface EMAuthorizationView()

@property (nonatomic, strong) UIImageView *arrowView;
@property (nonatomic, strong) CAGradientLayer *gl;
@property (nonatomic, strong) CAGradientLayer *backGl;
@property (nonatomic, strong) UILabel *authorizationLabel;

@property (strong, nonatomic) IBOutlet OneLoadingAnimationView *loadingView;//加载view

@property (assign) EMAuthorizationType authorizationType;

@end

@implementation EMAuthorizationView

- (instancetype)initWithAuthType:(EMAuthorizationType)authorizationType
{
    if (self = [super init]) {
        _authorizationType = authorizationType;
        [self _setupauthorizationBtn];
    }
    return self;
}

//授权按钮
- (void)_setupauthorizationBtn
{
    self.authorizationBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    _authorizationBtn.backgroundColor = [UIColor blackColor];
    _authorizationBtn.layer.cornerRadius = 25;
    _authorizationBtn.alpha = 0.3;
    [self addSubview:_authorizationBtn];
    [_authorizationBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self);
        make.height.equalTo(@55);
    }];
    
    self.authorizationLabel = [[UILabel alloc] init];
    _authorizationLabel.numberOfLines = 0;
    _authorizationLabel.font = [UIFont systemFontOfSize:16];
    _authorizationLabel.text = self.authorizationType == EMAuthLogin ? @"登 录" : @"注 册";
    [_authorizationLabel setTextColor:[UIColor whiteColor]];
    _authorizationLabel.textAlignment = NSTextAlignmentCenter;
    _authorizationLabel.alpha = 0.3;
    [self addSubview:_authorizationLabel];
    [_authorizationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.authorizationBtn);
        make.centerX.equalTo(self.authorizationBtn);
        make.width.equalTo(@85);
        make.height.equalTo(@23);
    }];
    
    self.arrowView = [[UIImageView alloc]init];
    self.arrowView.layer.cornerRadius = 21;
    //self.arrowView.image = [UIImage imageNamed:@"unableClick"];
    [self addSubview:self.arrowView];
    [self.arrowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@43);
        make.right.equalTo(self.authorizationBtn.mas_right).offset(-6);
        make.top.equalTo(self.authorizationBtn.mas_top).offset(6);
        make.height.equalTo(@43);
    }];
}

#pragma mark - Public
//原始视图
- (void)originalView
{
    if (_authorizationType < 1 || _authorizationType > 2) return;
    self.authorizationLabel.text = self.authorizationType == EMAuthLogin ? @"登 录" : @"注 册";
    [self.loadingView stopTimer];
    [self.loadingView removeFromSuperview];
}

//加载视图
- (void)beingLoadedView
{
    //self.arrowView.image = [UIImage imageNamed:@""];
    [self.arrowView addSubview:self.loadingView];
    [self.loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(self.arrowView).offset(11.5);
        make.width.equalTo(@22);
    }];
    [self.loadingView startAnimation];
    if (_authorizationType < 1 || _authorizationType > 2) return;
    self.authorizationLabel.text = self.authorizationType == EMAuthLogin ? @"正在登录..." : @"注册中...";
}

#pragma mark - Action

//设置授权按钮背景UI
- (void)setupAuthBtnBgcolor:(BOOL)isOperation
{
    if (isOperation) {
        [self.backGl removeFromSuperlayer];
        [_authorizationBtn.layer addSublayer:self.gl];
        _authorizationBtn.alpha = 1;
        _authorizationLabel.alpha = 1;
        [_authorizationLabel setTextColor:[UIColor colorWithRed:244/255.0 green:244/255.0 blue:244/255.0 alpha:1.0]];
        //_arrowView.image = [UIImage imageNamed:@"enableClick"];
        return;
    }
    [self.gl removeFromSuperlayer];
    [_authorizationBtn.layer addSublayer:self.backGl];
    _authorizationBtn.alpha = 0.3;
    _authorizationLabel.alpha = 0.3;
    [_authorizationLabel setTextColor:[UIColor whiteColor]];
    //_arrowView.image = [UIImage imageNamed:@"unableClick"];
}

#pragma mark - Getter

- (CAGradientLayer *)backGl{
    if(_backGl == nil) {
        _backGl = [CAGradientLayer layer];
        _backGl.frame = CGRectMake(0,0,_authorizationBtn.frame.size.width,55);
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
        _gl.frame = CGRectMake(0,0,_authorizationBtn.frame.size.width,55);
        _gl.startPoint = CGPointMake(0.15, 0.5);
        _gl.endPoint = CGPointMake(1, 0.5);
        _gl.colors = @[(__bridge id)[UIColor colorWithRed:4/255.0 green:174/255.0 blue:240/255.0 alpha:1.0].CGColor, (__bridge id)[UIColor colorWithRed:90/255.0 green:93/255.0 blue:208/255.0 alpha:1.0].CGColor];
        _gl.locations = @[@(0), @(1.0f)];
        _gl.cornerRadius = 25;
    }
    
    return _gl;
}

- (UIView *)loadingView
{
    if (_loadingView == nil) {
        _loadingView = [[OneLoadingAnimationView alloc]initWithRadius:10.5];
    }
    return _loadingView;
}

@end
