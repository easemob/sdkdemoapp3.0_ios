//
//  EMMessageStatusView.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/25.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EMMessageStatusView.h"
#import "LoadingCALayer.h"
#import "OneLoadingAnimationView.h"

@interface EMMessageStatusView()

@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIButton *failButton;
@property (nonatomic, strong) UIActivityIndicatorView *activityView;

@property (strong, nonatomic) IBOutlet OneLoadingAnimationView *loadingView;//加载view

@property (nonatomic, strong) NSTimer *timer;

@end

@implementation EMMessageStatusView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.hidden = YES;
        self.backgroundColor = [UIColor clearColor];
    }
    
    return self;
}

#pragma mark - Subviews

- (UILabel *)label
{
    if (_label == nil) {
        _label = [[UILabel alloc] init];
        _label.textColor = [UIColor grayColor];
        _label.font = [UIFont systemFontOfSize:13];
    }
    
    return _label;
}

- (UIButton *)failButton
{
    if (_failButton == nil) {
        _failButton = [[UIButton alloc] init];
        [_failButton setImage:[UIImage imageNamed:@"icon叹号"] forState:UIControlStateNormal];
        [_failButton addTarget:self action:@selector(failButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _failButton;
}

- (UIView *)loadingView
{
    if (_loadingView == nil) {
        _loadingView = [[OneLoadingAnimationView alloc]initWithRadius:9.0];
        //_loadingView.backgroundColor = [UIColor lightGrayColor];
    }
    return _loadingView;
}

- (UIActivityIndicatorView *)activityView
{
    if (_activityView == nil) {
        if (@available(iOS 13.0, *)) {
            _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
        } else {
            _activityView = [[UIActivityIndicatorView alloc]init];
        }
        _activityView.color = kColor_Blue;
    }
    
    return _activityView;
}

#pragma mark - Public

- (void)setSenderStatus:(EMMessageStatus)aStatus
            isReadAcked:(BOOL)aIsReadAcked
{
    if (aStatus == EMMessageStatusDelivering) {
        self.hidden = NO;
        [_label removeFromSuperview];
        [_failButton removeFromSuperview];
        /*
        [self addSubview:self.activityView];
        [self.activityView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
            make.width.equalTo(@20);
        }];
        [self.activityView startAnimating];*/
        
        [self addSubview:self.loadingView];
        [self.loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
            make.width.equalTo(@20);
        }];
        [self.loadingView startAnimation];
    
    } else if (aStatus == EMMessageStatusFailed) {
        self.hidden = NO;
        [_label removeFromSuperview];
        
        //[_activityView stopAnimating];
        //[_activityView removeFromSuperview];
        
        [_loadingView stopTimer];
        [_loadingView removeFromSuperview];
        [self addSubview:self.failButton];
        [self.failButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
            make.width.equalTo(@20);
        }];
    } else if (aStatus == EMMessageStatusSucceed) {
        self.hidden = NO;
        [_failButton removeFromSuperview];
        /*
        [_activityView stopAnimating];
        [_activityView removeFromSuperview];
        */
        [_loadingView stopTimer];
        [_loadingView removeFromSuperview];
        self.label.text = aIsReadAcked ? @"已读" : nil;
        [self addSubview:self.label];
        [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    } else {
        self.hidden = YES;
        [_label removeFromSuperview];
        [_failButton removeFromSuperview];
        
        //[_activityView stopAnimating];
        //[_activityView removeFromSuperview];
        [_loadingView stopTimer];
        [_loadingView removeFromSuperview];
    }
}

#pragma mark - Action

- (void)failButtonAction
{
    if (self.resendCompletion) {
        self.resendCompletion();
    }
}

@end
