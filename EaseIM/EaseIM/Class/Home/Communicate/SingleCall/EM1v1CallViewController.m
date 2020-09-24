//
//  EM1v1CallViewController.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2018/9/19.
//  Copyright © 2018 XieYajie. All rights reserved.
//

#import "EM1v1CallViewController.h"

#import "EMGlobalVariables.h"

@interface EM1v1CallViewController ()

@property (nonatomic, strong) NSTimer *callDurationTimer;
@property (nonatomic) int callDuration;

@end

@implementation EM1v1CallViewController

- (instancetype)initWithCallSession:(EMCallSession *)aCallSession
{
    self = [super init];
    if (self) {
        _callSession = aCallSession;
        _callStatus = EMCallSessionStatusDisconnected;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    [self _setup1v1CallControllerSubviews];
    
    self.remoteNameLabel.text = self.callSession.remoteName;
    self.timeLabel.hidden = YES;
    self.answerButton.enabled = NO;
    self.callStatus = self.callSession.status;
    //[self.waitImgView startAnimating];
    [self floatingView];//初始化视频小窗
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [self clearDataAndView];
}

- (void)clearDataAndView
{
    [self _stopCallDurationTimer];
    
    [_floatingView removeFromSuperview];
    _floatingView = nil;
}

#pragma mark - Subviews

- (void)_setup1v1CallControllerSubviews
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.statusLabel.text = @"正在建立连接...";
    
    self.timeLabel = [[UILabel alloc] init];
    self.timeLabel.backgroundColor = [UIColor clearColor];
    self.timeLabel.font = [UIFont systemFontOfSize:15];
    self.timeLabel.textColor = [UIColor whiteColor];
    self.timeLabel.textAlignment = NSTextAlignmentRight;
    self.timeLabel.text = @"00:00";
    [self.view addSubview:self.timeLabel];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.hangupButton.mas_top).offset(-18);
        make.centerX.equalTo(self.view);
    }];
    
    self.remoteNameLabel = [[UILabel alloc] init];
    self.remoteNameLabel.backgroundColor = [UIColor clearColor];
    self.remoteNameLabel.font = [UIFont systemFontOfSize:19];
    self.remoteNameLabel.textColor = [UIColor blackColor];
    self.remoteNameLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.remoteNameLabel];
    [self.remoteNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.statusLabel.mas_bottom).offset(15);
        make.left.equalTo(self.statusLabel.mas_left).offset(5);
        make.right.equalTo(self.view).offset(-15);
    }];
    /*
    self.waitImgView = [[UIImageView alloc] init];
    self.waitImgView.contentMode = UIViewContentModeScaleAspectFit;
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (int i = 25; i < 88; i++) {
        NSString *name = [[NSString alloc] initWithFormat:@"animate_000%@", @(i)];
        [array addObject:[UIImage imageNamed:name]];
    }
    [self.waitImgView setAnimationImages:array];
    [self.view addSubview:self.waitImgView];
    [self.waitImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-20);
    }];*/
    
    [self.minButton setImage:[UIImage imageNamed:@"cuteFirstView"] forState:UIControlStateNormal];
    
    if (self.callSession.isCaller) {
        //监测耳机状态，如果是插入耳机状态，不显示扬声器按钮
        self.speakerButton.hidden = isHeadphone();
        self.answerButton.hidden = YES;
        [self.hangupButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view);
            make.bottom.equalTo(self.view).offset(-20);
            make.width.mas_equalTo(RTC_BUTTON_WIDTH);
            make.height.mas_equalTo(RTC_BUTTON_HEIGHT);
        }];
    } else {
        self.microphoneButton.hidden = YES;
        self.speakerButton.hidden = YES;
        self.answerButton = [[EMButton alloc] initWithTitle:@"接听" target:self action:@selector(answerAction)];
        [self.answerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.answerButton setImage:[UIImage imageNamed:@"answer"] forState:UIControlStateNormal];
        [self.answerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [self.view addSubview:self.answerButton];
        [self.answerButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.view).offset(-35);
            make.bottom.equalTo(self.view).offset(-20);
            make.width.mas_equalTo(RTC_BUTTON_WIDTH);
            make.height.mas_equalTo(RTC_BUTTON_HEIGHT);
        }];
        
        [self.hangupButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view).offset(35);
            make.bottom.equalTo(self.view).offset(-20);
            make.width.mas_equalTo(RTC_BUTTON_WIDTH);
            make.height.mas_equalTo(RTC_BUTTON_HEIGHT);
        }];
    }
}

#pragma mark - Floating View

- (EMStreamView *)floatingView
{
    if (_floatingView == nil) {
        _floatingView = [[EMStreamView alloc] init];
        _floatingView.enableVideo = self.callSession.type == EMCallTypeVideo ? YES : NO;
        _floatingView.delegate = self;
    }
    
    return _floatingView;
}

- (void)_updateFloatingViewWithCallStatus:(EMCallSessionStatus)callStatus
{
    if (!_floatingView) {
        return;
    }
    
    switch (callStatus) {
        case EMCallSessionStatusConnecting:
        {
            _floatingView.status = StreamStatusConnecting;
        }
            break;
        case EMCallSessionStatusConnected:
        case EMCallSessionStatusAccepted:
        {
            _floatingView.status = StreamStatusConnected;
        }
            break;
            
        default:
            _floatingView.status = StreamStatusNormal;
            break;
    }
}

- (void)_updateFloatingViewWithStreamingStatus:(EMCallStreamingStatus)aStatus
{
    //空值，所以未初始化之前不会有任何内容，即就是不会设置上静音图标
    if (!_floatingView) {
        return;
    }
    
    switch (aStatus) {
        case EMCallStreamStatusVoicePause:
            _floatingView.enableVoice = NO;
            break;
        case EMCallStreamStatusVoiceResume:
            _floatingView.enableVoice = YES;
            break;
        case EMCallStreamStatusVideoPause:
            _floatingView.enableVideo = NO;
            break;
        case EMCallStreamStatusVideoResume:
            _floatingView.enableVideo = YES;
            break;
            
        default:
            break;
    }
}

#pragma mark - Timer

- (void)_updateCallDuration
{
    self.callDuration += 1;
    int hour = self.callDuration / 3600;
    int m = (self.callDuration - hour * 3600) / 60;
    int s = self.callDuration - hour * 3600 - m * 60;
    
    if (hour > 0) {
        self.timeLabel.text = [NSString stringWithFormat:@"%@:%@:%@", 0 <= hour && hour < 10 ? [NSString stringWithFormat:@"0%d",hour] : [NSString stringWithFormat:@"%d",hour], 0 <= m && m < 10 ? [NSString stringWithFormat:@"0%d",m] : [NSString stringWithFormat:@"%d",m], 0 <= s && s < 10 ? [NSString stringWithFormat:@"0%d",s] : [NSString stringWithFormat:@"%d",s]];
    }
    else if(m > 0){
        self.timeLabel.text = [NSString stringWithFormat:@"%@:%@", 0 <= m && m < 10 ? [NSString stringWithFormat:@"0%d",m] : [NSString stringWithFormat:@"%d",m], 0 <= s && s < 10 ? [NSString stringWithFormat:@"0%d",s] : [NSString stringWithFormat:@"%d",s]];
    }
    else{
        self.timeLabel.text = [NSString stringWithFormat:@"00:%@", 0 <= s && s < 10 ? [NSString stringWithFormat:@"0%d",s] : [NSString stringWithFormat:@"%d",s]];
    }
    [SingleCallController sharedManager].callDurationTime = self.timeLabel.text;
}

- (void)_startCallDurationTimer
{
    [self _stopCallDurationTimer];

    self.callDuration = 0;
    self.callDurationTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(_updateCallDuration) userInfo:nil repeats:YES];
}

- (void)_stopCallDurationTimer
{
    if (self.callDurationTimer) {
        [self.callDurationTimer invalidate];
        self.callDurationTimer = nil;
    }
}

#pragma mark - EMStreamViewDelegate

- (void)streamViewDidTap:(EMStreamView *)aVideoView
{
    self.minButton.selected = NO;
    [self.floatingView removeFromSuperview];
    
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    UIViewController *rootViewController = window.rootViewController;
    self.modalPresentationStyle = 0;
    [rootViewController presentViewController:self animated:NO completion:nil];
}

#pragma mark - Status

- (void)setCallStatus:(EMCallSessionStatus)callStatus
{
    if (_callStatus >= callStatus) {
        return;
    }
    
    switch (callStatus) {
        case EMCallSessionStatusConnecting:
        {
            self.statusLabel.text = @"正在建立连接...";
        }
            break;
        case EMCallSessionStatusConnected:
        {
            if (self.callType == EMCallTypeVoice) {
                self.statusLabel.text = @"邀请你进行语音通话...";
            } else if (self.callType == EMCallTypeVideo) {
                self.statusLabel.text = @"邀请你进行视频通话...";
            } else {
                self.statusLabel.text = @"正在等待对方接受邀请...";
            }
            self.answerButton.enabled = YES;
        }
            break;
        case EMCallSessionStatusAccepted:
        {
            [self _startCallDurationTimer];
            self.statusLabel.text = @"通话中...";
            self.statusLabel.hidden = YES;
            self.timeLabel.hidden = NO;
            //[self.waitImgView stopAnimating];
            [self.answerButton removeFromSuperview];
            [self.hangupButton mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self.view);
                make.bottom.equalTo(self.view).offset(-20);
                make.width.mas_equalTo(RTC_BUTTON_WIDTH);
                make.height.mas_equalTo(RTC_BUTTON_HEIGHT);
            }];
            
            NSString *connectStr = @"";
            if (self.callSession.connectType == EMCallConnectTypeRelay) {
                connectStr = @"Relay";
            } else if (self.callSession.connectType == EMCallConnectTypeDirect) {
                connectStr = @"Direct";
            }
            self.remoteNameLabel.text = [NSString stringWithFormat:@"%@  --  %@", self.callSession.remoteName, connectStr];
            
            [self.hangupButton setTitle:@"挂断" forState:UIControlStateNormal];
            self.speakerButton.hidden = isHeadphone();
            self.microphoneButton.hidden = NO;
            [self.microphoneButton setEnabled:YES];
            [self.speakerButton setEnabled:YES];
            [self.microphoneButton setImage:[UIImage imageNamed:@"microphone-connect-default"] forState:UIControlStateNormal];
            [self.microphoneButton setImage:[UIImage imageNamed:@"microphone-connect-selected"] forState:UIControlStateSelected];
            [self.speakerButton setImage:[UIImage imageNamed:@"loudspeaker-connect-default"] forState:UIControlStateNormal];
            [self.speakerButton setImage:[UIImage imageNamed:@"loudspeaker-connect-selected"] forState:UIControlStateSelected];
            
            if (self.microphoneButton.isSelected) {
                [self.callSession pauseVoice];
            }
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (!self.microphoneButton.isSelected && self.speakerButton.isSelected) {
                    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
                    [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
                    [audioSession setActive:YES error:nil];
                }
            });
        }
            break;
            
        default:
            break;
    }
    
    [self _updateFloatingViewWithCallStatus:callStatus];
}

- (void)updateStreamingStatus:(EMCallStreamingStatus)aStatus
{
    NSString *str = @"对方数据流状态有更新";
    switch (aStatus) {
        case EMCallStreamStatusVoicePause:
            str = @"对方已静音";
            break;
        case EMCallStreamStatusVoiceResume:
            str = @"对方解除静音";
            break;
        case EMCallStreamStatusVideoPause:
            str = @"对方禁止上传视频";
            break;
        case EMCallStreamStatusVideoResume:
            str = @"对方恢复上传视频";
            break;
            
        default:
            break;
    }
    
    [self showHint:str];
    
    [self _updateFloatingViewWithStreamingStatus:aStatus];
}

#pragma mark - Action
//点击麦克风
- (void)microphoneButtonAction
{
    self.microphoneButton.selected = !self.microphoneButton.selected;
    if (self.microphoneButton.isSelected) {
        [self.callSession pauseVoice];
    } else {
        [self.callSession resumeVoice];
    }
}

- (void)speakerButtonAction
{
    [super speakerButtonAction];
}

- (void)minimizeAction
{
}
//1v1挂断触发事件
- (void)hangupAction
{
    [self clearDataAndView];
    
    NSString *callId = self.callSession.callId;
    /*
    //EMCallEndReason reason = EMCallEndReasonHangup;
    EMCallEndReason reason = EMCallEndReasonHangup;
    if (self.callDuration < 1 && !self.callSession.isCaller) {
        reason = EMCallEndReasonNoResponse;
        //reason = EMCallEndReasonDecline;
    }*/
    EMCallEndReason reason = EMCallEndReasonFailed;
    [[SingleCallController sharedManager] endCallWithId:callId reason:reason];
    _callSession = nil;
}

- (void)answerAction
{
    [[SingleCallController sharedManager] answerCall:self.callSession.callId];
    self.callStatus = EMCallSessionStatusAccepted;
}

- (void)setNetwork:(EMCallNetworkStatus)status {
    NSString *showInfo = @"";
    switch (status) {
        case EMCallNetworkStatusNormal:
        {
            showInfo = @"网络恢复正常";
        }
            break;
        case EMCallNetworkStatusUnstable:
        {
            showInfo = @"网络状态不稳定";
        }
            break;
        case EMCallNetworkStatusNoData:
        {
            showInfo = @"";
        }
            break;
        default:
            break;
    }
    if (showInfo.length == 0) {
        return;
    }
    [self showHint:showInfo];
}

@end
