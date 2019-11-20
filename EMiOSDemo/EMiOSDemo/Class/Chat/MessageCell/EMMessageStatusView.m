//
//  EMMessageStatusView.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/25.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EMMessageStatusView.h"
#import "LoadingCALayer.h"

@interface EMMessageStatusView()

@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIButton *failButton;
@property (nonatomic, strong) UIActivityIndicatorView *activityView;

@property (nonatomic, strong) UIView *loadingView;//加载view

@property (nonatomic) EMMessageStatus status;

@property (nonatomic) BOOL isReadAcked;

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong) LoadingCALayer *customLayer;

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
        _loadingView = [[UIView alloc]init];
    }
    return _loadingView;
}

- (LoadingCALayer *)customLayer
{
    if(_customLayer == nil) {
        _customLayer = [LoadingCALayer layer];
    }
    return _customLayer;
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
    if (_status != aStatus) {
        _status = aStatus;
        
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
            self.customLayer.position = CGPointMake(_loadingView.frame.size.width * 0.5, _loadingView.frame.size.height * 0.5);
            self.customLayer.bounds = CGRectMake(0, 0, _loadingView.frame.size.width, _loadingView.frame.size.height);
            [_loadingView.layer addSublayer:self.customLayer];
            [self setCirclePercent:0.1];
        } else if (aStatus == EMMessageStatusFailed) {
            self.hidden = NO;
            [_label removeFromSuperview];
            
            [_activityView stopAnimating];
            [_activityView removeFromSuperview];
            
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
            
            [_activityView stopAnimating];
            [_activityView removeFromSuperview];
            [_loadingView removeFromSuperview];
        }
    } else if (self.isReadAcked != aIsReadAcked && aStatus == EMMessageStatusSucceed) {
        self.label.text = aIsReadAcked ? @"已读" : nil;
    }
    self.isReadAcked = aIsReadAcked;
}

- (void)setCirclePercent:(CGFloat)percent {
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    __block CGFloat ori = 0.0;
    __block CGFloat countPercent = percent;
    __weak typeof(self) weakself = self;
    self.timer= [NSTimer timerWithTimeInterval:0.05 repeats:YES block:^(NSTimer * _Nonnull timer) {
        if (ori >= countPercent) {
            [timer invalidate];
            timer = nil;
            return ;
        }
        ori += 0.05;
        [weakself.customLayer custom_setValue:ori];
    }];
    NSRunLoop *currentLoop = [NSRunLoop currentRunLoop];
    [currentLoop addTimer:self.timer forMode:NSRunLoopCommonModes];
    [self.timer fire];
}

#pragma mark - Action

- (void)failButtonAction
{
    if (self.resendCompletion) {
        self.resendCompletion();
    }
}

@end
