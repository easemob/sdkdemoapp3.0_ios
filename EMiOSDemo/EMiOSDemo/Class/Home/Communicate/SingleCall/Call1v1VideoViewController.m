//
//  Call1v1VideoViewController.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2018/9/19.
//  Copyright © 2018 XieYajie. All rights reserved.
//

#import "Call1v1VideoViewController.h"
#import "EMVideoInfoViewController.h"
#import "EMButton.h"

#define TAG_MINVIDEOVIEW_LOCAL 100
#define TAG_MINVIDEOVIEW_REMOTE 200

@interface Call1v1VideoViewController ()

@property (nonatomic, strong) UIView *minVideoView;
@property (nonatomic, strong) EMButton *switchCameraButton;
@property (nonatomic, strong) EMVideoInfoViewController *videoInfoController;
@property (nonatomic, strong) UIView *backView;
@end

@implementation Call1v1VideoViewController
@synthesize callStatus = _callStatus;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self _setupSubviews];
    [self _setBackground];
    if (!isHeadphone()) {
        [self speakerButtonAction];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Subviews

- (void)_setupSubviews
{
    CGFloat color = 51 / 255.0;
    self.view.backgroundColor = [UIColor colorWithRed:color green:color blue:color alpha:1.0];
    
    self.statusLabel.textColor = [UIColor whiteColor];
    self.timeLabel.textColor = [UIColor whiteColor];
    self.remoteNameLabel.textColor = [UIColor whiteColor];
    
    CGFloat width = 80;
    CGFloat height = 50;
    CGFloat padding = ([UIScreen mainScreen].bounds.size.width - width * 4) / 5;
    
    /*
    [self.microphoneButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.switchCameraButton.mas_right).offset(padding);
        make.bottom.equalTo(self.switchCameraButton);
    }];
    
    EMButton *videoButton = [[EMButton alloc] initWithTitle:@"视频" target:self action:@selector(videoButtonAction:)];
    [videoButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [videoButton setTitleColor:[UIColor grayColor] forState:UIControlStateSelected];
    [videoButton setImage:[UIImage imageNamed:@"video_white"] forState:UIControlStateNormal];
    [videoButton setImage:[UIImage imageNamed:@"video_gray"] forState:UIControlStateSelected];
    
    [self.view addSubview:videoButton];
    [videoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.microphoneButton.mas_right).offset(padding);
        make.bottom.equalTo(self.switchCameraButton);
    }];

    [self.speakerButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(videoButton.mas_right).offset(padding);
        make.bottom.equalTo(self.switchCameraButton);
    }];*/
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
    /*
    [@[self.switchCameraButton, self.microphoneButton, videoButton, self.speakerButton] mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(width);
        make.height.mas_equalTo(height);
    }];*/
    /*
    [self.waitImgView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-20);
        make.bottom.equalTo(self.switchCameraButton.mas_top).offset(-30);
    }];*/
    
    //初始化自己视频显示的页面
    width = 80;
    CGSize size = [UIScreen mainScreen].bounds.size;
    height = size.height / size.width * width;
    /*
    self.videoInfoController = [[EMVideoInfoViewController alloc]init];
    self.videoInfoController.callSession = self.callSession;
    [self.view addSubview:self.videoInfoController.view];
    [self.videoInfoController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-15);
        make.width.height.equalTo(@200);
    }];*/
    
    self.minVideoView = [[UIView alloc] init];
    self.minVideoView.tag = TAG_MINVIDEOVIEW_REMOTE;
    self.minVideoView.backgroundColor = [UIColor blackColor];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(exchangeVideoViewAction:)];
    [self.minVideoView addGestureRecognizer:tap];
    [self.view addSubview:self.minVideoView];
    [self.minVideoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(100);
        make.width.mas_equalTo(90);
        make.height.mas_equalTo(120);
        make.right.equalTo(self.view).offset(-15);
    }];
    
    self.callSession.localVideoView = [[EMCallLocalView alloc] init];
    self.callSession.localVideoView.scaleMode = EMCallViewScaleModeAspectFill;
    [self.view insertSubview:self.callSession.localVideoView atIndex:0];
    [self.callSession.localVideoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    self.switchCameraButton = [[EMButton alloc] initWithTitle:@"切换摄像头" target:self action:@selector(switchCameraButtonAction:)];
    [self.switchCameraButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.switchCameraButton setTitleColor:[UIColor grayColor] forState:UIControlStateSelected];
    [self.switchCameraButton setImage:[UIImage imageNamed:@"switchCamera_white"] forState:UIControlStateNormal];
    [self.switchCameraButton setImage:[UIImage imageNamed:@"switchCamera_gray"] forState:UIControlStateSelected];
    [self.view addSubview:self.switchCameraButton];
    [self.switchCameraButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(RTC_BUTTON_PADDING);
        make.bottom.equalTo(self.speakerButton.mas_top).offset(-40);
    }];
}

- (void)_setRemoteVideoViewFrame
{
    if (self.minButton.isSelected) {
        [self.floatingView addSubview:self.callSession.remoteVideoView];
        [self.callSession.remoteVideoView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.floatingView);
        }];
        return;
    }
    
    if (self.minVideoView.tag == TAG_MINVIDEOVIEW_REMOTE) {
        [self.minVideoView addSubview:self.callSession.remoteVideoView];
        [self.view bringSubviewToFront:self.minVideoView];
        [self.callSession.remoteVideoView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.minVideoView);
        }];
    } else {
        self.callSession.remoteVideoView.scaleMode = EMCallViewScaleModeAspectFill;
        [self.view addSubview:self.callSession.remoteVideoView];
        [self.view sendSubviewToBack:self.callSession.remoteVideoView];
        [self.callSession.remoteVideoView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
}

- (void)_setupRemoteVideoView
{
    if (self.callSession.remoteVideoView == nil) {
        self.callSession.remoteVideoView = [[EMCallRemoteView alloc] init];
        self.callSession.remoteVideoView.backgroundColor = [UIColor clearColor];
        self.callSession.remoteVideoView.scaleMode = EMCallViewScaleModeAspectFit;
        self.callSession.remoteVideoView.userInteractionEnabled = YES;
    }
    
    [self _setRemoteVideoViewFrame];
}

//背景图
- (void)_setBackground
{
    self.backView = [[UIView alloc]init];
    self.backView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.backView];
    [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.centerY.equalTo(self.view.mas_centerY).offset(-150);
        make.width.height.equalTo(@230);
    }];
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
    [self.backView addSubview:outerLayer];
    [outerLayer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.backView);
        make.width.height.equalTo(@230);
    }];
    outerLayer.layer.cornerRadius = 115;
    [self.backView addSubview:middleLayer];
    [middleLayer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.backView);
        make.width.height.equalTo(@170);
    }];
    middleLayer.layer.cornerRadius = 85;
    [self.backView addSubview:insideLayer];
    [insideLayer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.backView);
        make.width.height.equalTo(@120);
    }];
    insideLayer.layer.cornerRadius = 60;
    UIImageView *avatarImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"defaultAvatar"]];
    [self.backView addSubview:avatarImage];
    [avatarImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.backView);
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
    self.minVideoView.hidden = YES;
    self.speakerButton.hidden = YES;
    self.microphoneButton.hidden = YES;
}

#pragma mark - Super Public

- (void)setCallStatus:(EMCallSessionStatus)callStatus
{
    [super setCallStatus:callStatus];
    
    if (callStatus == EMCallSessionStatusAccepted) {
        self.speakerButton.hidden = NO;
        self.microphoneButton.hidden = NO;
        self.minVideoView.hidden = NO;
        self.remoteNameLabel.hidden = YES;
        self.statusLabel.hidden = YES;
        [self.backView removeFromSuperview];
        if (!self.callSession.remoteVideoView) {
            [self _setupRemoteVideoView];
            [self.videoInfoController startTimer:1];
        }
    }
}

#pragma mark - EMStreamViewDelegate

- (void)streamViewDidTap:(EMStreamView *)aVideoView
{
    [super streamViewDidTap:aVideoView];
    
    if (self.callSession.remoteVideoView) {
        [self.callSession.remoteVideoView removeFromSuperview];
        [self _setRemoteVideoViewFrame];
    }
}

#pragma mark - Action

- (void)exchangeVideoViewAction:(UITapGestureRecognizer *)aTap
{
    if (aTap.state != UIGestureRecognizerStateEnded) {
        return;
    }
    
    [self.callSession.localVideoView removeFromSuperview];
    [self.callSession.remoteVideoView removeFromSuperview];
    //[self.waitImgView removeFromSuperview];
    if (self.minVideoView.tag == TAG_MINVIDEOVIEW_LOCAL) {
        self.minVideoView.tag = TAG_MINVIDEOVIEW_REMOTE;
        
        [self.view addSubview:self.callSession.localVideoView];
        [self.view sendSubviewToBack:self.callSession.localVideoView];
        [self.callSession.localVideoView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        
        if (self.callSession.remoteVideoView) {
            [self.minVideoView addSubview:self.callSession.remoteVideoView];
            [self.callSession.remoteVideoView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self.minVideoView);
            }];
        } else {
            /*[self.minVideoView addSubview:self.waitImgView];
            [self.waitImgView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self.minVideoView);\
            }];*/
        }
    } else if (self.minVideoView.tag == TAG_MINVIDEOVIEW_REMOTE) {
        self.minVideoView.tag = TAG_MINVIDEOVIEW_LOCAL;
        
        [self.minVideoView addSubview:self.callSession.localVideoView];
        [self.callSession.localVideoView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.minVideoView);
        }];
        
        if (self.callSession.remoteVideoView) {
            self.callSession.remoteVideoView.scaleMode = EMCallViewScaleModeAspectFill;
            [self.view addSubview:self.callSession.remoteVideoView];
            [self.view sendSubviewToBack:self.callSession.remoteVideoView];
            [self.callSession.remoteVideoView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self.view);
            }];
        } else {
            /*[self.view addSubview:self.waitImgView];
            [self.view sendSubviewToBack:self.waitImgView];
            [self.waitImgView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.view).offset(20);
                make.right.equalTo(self.view).offset(-20);
                make.bottom.equalTo(self.switchCameraButton.mas_top).offset(-30);
            }];*/
        }
    }
}

- (void)switchCameraButtonAction:(EMButton *)aButton
{
    aButton.selected = !aButton.selected;
    [self.callSession switchCameraPosition:!aButton.selected];
}

- (void)videoButtonAction:(EMButton *)aButton
{
    aButton.selected = !aButton.isSelected;
    if (aButton.isSelected) {
        [self.callSession pauseVideo];
    } else {
        [self.callSession resumeVideo];
    }
}

- (void)minimizeAction
{
    self.minButton.selected = YES;
    
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:self.floatingView];
    [keyWindow bringSubviewToFront:self.floatingView];
    [self.floatingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@80);
        make.top.equalTo(keyWindow.mas_top).offset(80);
        make.right.equalTo(keyWindow.mas_right).offset(-40);
    }];
    
    if (self.callSession.remoteVideoView) {
        [self.callSession.remoteVideoView removeFromSuperview];
        self.floatingView.displayView = self.callSession.remoteVideoView;
        [self.floatingView addSubview:self.callSession.remoteVideoView];
        self.floatingView.enableVoice = self.floatingView.enableVoice;
        [self.callSession.remoteVideoView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.floatingView);
        }];
    }
    
    [self dismissViewControllerAnimated:NO completion:nil];
}

@end
