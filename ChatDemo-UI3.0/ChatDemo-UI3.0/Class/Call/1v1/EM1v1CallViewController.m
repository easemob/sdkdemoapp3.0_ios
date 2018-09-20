//
//  EM1v1CallViewController.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2018/9/19.
//  Copyright © 2018 XieYajie. All rights reserved.
//

#import "EM1v1CallViewController.h"

@interface EM1v1CallViewController ()

@property (nonatomic, strong) NSTimer *callDurationTimer;
@property (nonatomic) int callDuration;

@end

@implementation EM1v1CallViewController

#if DEMO_CALL == 1

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
    
    [self _setupBaseSubviews];
    
    self.remoteNameLabel.text = self.callSession.remoteName;
    self.timeLabel.hidden = YES;
    self.answerButton.enabled = NO;
    self.callStatus = self.callSession.status;
    [self.waitImgView startAnimating];
    
    //监测耳机状态，如果是插入耳机状态，不显示扬声器按钮
    self.speakerButton.hidden = isHeadphone();
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAudioRouteChanged:)   name:AVAudioSessionRouteChangeNotification object:[AVAudioSession sharedInstance]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [self _stopCallDurationTimer];
}

#pragma mark - Subviews

- (void)_setupBaseSubviews
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.statusLabel = [[UILabel alloc] init];
    self.statusLabel.backgroundColor = [UIColor clearColor];
    self.statusLabel.font = [UIFont systemFontOfSize:25];
    self.statusLabel.textColor = [UIColor blackColor];
    self.statusLabel.text = @"正在建立连接...";
    [self.view addSubview:self.statusLabel];
    [self.statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(35);
        make.left.equalTo(self.view).offset(15);
    }];
    
    self.timeLabel = [[UILabel alloc] init];
    self.timeLabel.backgroundColor = [UIColor clearColor];
    self.timeLabel.font = [UIFont systemFontOfSize:25];
    self.timeLabel.textColor = [UIColor blackColor];
    self.timeLabel.textAlignment = NSTextAlignmentRight;
    self.timeLabel.text = @"00:00";
    [self.view addSubview:self.timeLabel];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.statusLabel);
        make.right.equalTo(self.view).offset(-15);
    }];
    
    self.remoteNameLabel = [[UILabel alloc] init];
    self.remoteNameLabel.backgroundColor = [UIColor clearColor];
    self.remoteNameLabel.font = [UIFont systemFontOfSize:15];
    self.remoteNameLabel.textColor = [UIColor blackColor];
    [self.view addSubview:self.remoteNameLabel];
    [self.remoteNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.statusLabel.mas_bottom).offset(15);
        make.left.equalTo(self.statusLabel.mas_left).offset(5);
        make.right.equalTo(self.view).offset(-15);
    }];
    
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
    }];
    
    self.microphoneButton = [[EMButton alloc] initWithTitle:@"麦克风" target:self action:@selector(microphoneButtonAction)];
    [self.microphoneButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.microphoneButton setTitleColor:[UIColor grayColor] forState:UIControlStateSelected];
    [self.microphoneButton setImage:[UIImage imageNamed:@"micphone_gray"] forState:UIControlStateNormal];
    [self.microphoneButton setImage:[UIImage imageNamed:@""] forState:UIControlStateSelected];
    [self.view addSubview:self.microphoneButton];
    
    self.speakerButton = [[EMButton alloc] initWithTitle:@"扬声器" target:self action:@selector(speakerButtonAction)];
    [self.speakerButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [self.speakerButton setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
    [self.speakerButton setImage:[UIImage imageNamed:@"speaker_gray"] forState:UIControlStateNormal];
    [self.speakerButton setImage:[UIImage imageNamed:@""] forState:UIControlStateSelected];
    [self.view addSubview:self.speakerButton];
    
    self.minButton = [[UIButton alloc] init];
    self.minButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.minButton setImage:[UIImage imageNamed:@"minimize_gray"] forState:UIControlStateNormal];
    [self.minButton addTarget:self action:@selector(minimizeAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.minButton];
    [self.minButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(-30);
        make.right.equalTo(self.view).offset(-25);
        make.width.height.equalTo(@40);
    }];
    
    self.hangupButton = [[UIButton alloc] init];
    self.hangupButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.hangupButton setImage:[UIImage imageNamed:@"hangup"] forState:UIControlStateNormal];
    [self.hangupButton addTarget:self action:@selector(hangupAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.hangupButton];
    if (self.callSession.isCaller) {
        [self.hangupButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view);
            make.bottom.equalTo(self.view).offset(-40);
            make.width.height.equalTo(@60);
        }];
    } else {
        CGFloat size = 60;
        CGFloat padding = ([UIScreen mainScreen].bounds.size.width - size * 2) / 3;
        
        [self.hangupButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.view).offset(-40);
            make.right.equalTo(self.view).offset(-padding);
            make.width.height.mas_equalTo(size);
        }];
        
        self.answerButton = [[UIButton alloc] init];
        self.answerButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.answerButton setImage:[UIImage imageNamed:@"answer"] forState:UIControlStateNormal];
        [self.answerButton addTarget:self action:@selector(answerAction) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.answerButton];
        [self.answerButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.hangupButton);
            make.left.equalTo(self.view).offset(padding);
            make.width.height.mas_equalTo(size);
        }];
    }
}

#pragma mark - timer

- (void)_updateCallDuration
{
    self.callDuration += 1;
    int hour = self.callDuration / 3600;
    int m = (self.callDuration - hour * 3600) / 60;
    int s = self.callDuration - hour * 3600 - m * 60;
    
    if (hour > 0) {
        self.timeLabel.text = [NSString stringWithFormat:@"%i:%i:%i", hour, m, s];
    }
    else if(m > 0){
        self.timeLabel.text = [NSString stringWithFormat:@"%i:%i", m, s];
    }
    else{
        self.timeLabel.text = [NSString stringWithFormat:@"00:%i", s];
    }
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

#pragma mark - NSNotification

- (void)handleAudioRouteChanged:(NSNotification *)aNotif
{
    NSDictionary *interuptionDict = aNotif.userInfo;
    NSInteger routeChangeReason = [[interuptionDict valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    switch (routeChangeReason) {
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
        {
            //插入耳机
            dispatch_async(dispatch_get_main_queue(), ^{
                self.speakerButton.hidden = YES;
            });
        }
            break;
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
        {
            //拔出耳机
            dispatch_async(dispatch_get_main_queue(), ^{
                self.speakerButton.hidden = NO;
                if (self.speakerButton.isSelected) {
                    [self speakerButtonAction];
                }
            });
            
            AVAudioSession *audioSession = [AVAudioSession sharedInstance];
            [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:nil];
            [audioSession setActive:YES error:nil];
        }
            break;
        case AVAudioSessionRouteChangeReasonCategoryChange:
            // called at start - also when other audio wants to play
            break;
    }
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
            self.statusLabel.text = @"等待接听...";
            self.answerButton.enabled = YES;
        }
            break;
        case EMCallSessionStatusAccepted:
        {
            [self _startCallDurationTimer];
            
            self.statusLabel.text = @"通话中...";
            self.timeLabel.hidden = NO;
            [self.waitImgView stopAnimating];
            if (!self.callSession.isCaller) {
                [self.answerButton removeFromSuperview];
                [self.hangupButton mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.centerX.equalTo(self.view);
                    make.bottom.equalTo(self.view).offset(-40);
                    make.width.height.equalTo(@60);
                }];
            }
            
            NSString *connectStr = @"";
            if (self.callSession.connectType == EMCallConnectTypeRelay) {
                connectStr = @"Relay";
            } else if (self.callSession.connectType == EMCallConnectTypeDirect) {
                connectStr = @"Direct";
            }
            self.remoteNameLabel.text = [NSString stringWithFormat:@"%@  --  %@", self.callSession.remoteName, connectStr];
            
            if (self.speakerButton.isSelected) {
                AVAudioSession *audioSession = [AVAudioSession sharedInstance];
                [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
                [audioSession setActive:YES error:nil];
            }
            
            if (self.microphoneButton.isSelected) {
                [self.callSession pauseVoice];
            }
        }
            break;
            
        default:
            break;
    }
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
}

#pragma mark - Action

- (void)microphoneButtonAction
{
    self.microphoneButton.selected = !self.microphoneButton.isSelected;
    if (self.microphoneButton.isSelected) {
        [self.callSession pauseVoice];
    } else {
        [self.callSession resumeVoice];
    }
}

- (void)speakerButtonAction
{
    self.speakerButton.selected = !self.speakerButton.isSelected;
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    if (self.speakerButton.isSelected) {
        [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
    } else {
        [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:nil];
    }
    [audioSession setActive:YES error:nil];
}

- (void)minimizeAction
{
    
}

- (void)hangupAction
{
    [self _stopCallDurationTimer];
    
    NSString *callId = self.callSession.callId;
    _callSession = nil;
    
    EMCallEndReason reason = EMCallEndReasonHangup;
    if (self.callDuration < 1 && !self.callSession.isCaller) {
        reason = EMCallEndReasonDecline;
    }
    [[DemoCallManager sharedManager] endCallWithId:callId reason:reason];
}

- (void)answerAction
{
    [[DemoCallManager sharedManager] answerCall:self.callSession.callId];
    self.callStatus = EMCallSessionStatusAccepted;
}

#endif

@end
