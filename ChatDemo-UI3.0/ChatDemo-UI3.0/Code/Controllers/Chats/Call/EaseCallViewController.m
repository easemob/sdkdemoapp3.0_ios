//
//  EaseCallViewController.m
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 16/9/26.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "EaseCallViewController.h"
#import "EaseCallManager.h"
#import "EaseVideoInfoViewController.h"
#import "UIImageView+HeadImage.h"
@interface EaseCallViewController ()
{

    BOOL _isCaller;
    NSString *_status;
    int _timeLength;
    
    NSString * _audioCategory;
}
@property (nonatomic, strong) UITapGestureRecognizer *tapRecognizer;


@end

@implementation EaseCallViewController


- (instancetype)initWithCallSession:(EMCallSession *)session isCaller:(BOOL)isCaller status:(NSString *)status
{
    if (session.type == EMCallTypeVoice) {
        
        self = [self initWithNibName:@"EaseCallView_Voice" bundle:nil];
    } else {
        
        self = [self initWithNibName:@"EaseCallView_Video" bundle:nil];
    }
    _callSession = session;
    _isCaller = isCaller;
    
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupSubViews];
    
}


#pragma mark - Tap hide video actions
- (UITapGestureRecognizer *)tapRecognizer
{
    if (!_tapRecognizer) {
        
        _tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapAction:)];
    }
    return _tapRecognizer;
}


- (void)viewTapAction:(UITapGestureRecognizer *)tap
{
    _topView.hidden = !_topView.hidden;
    _actionView.hidden = !_actionView.hidden;
    
}



#pragma mark - reload UI

- (void)setupSubViews
{
    self.timeLabel.hidden = YES;
    self.nameLabel.text = _callSession.remoteName;
    
    [self.speakerOutButton setImage:[UIImage imageNamed:@"Button_Speaker active"] forState:UIControlStateSelected | UIControlStateHighlighted];
    [self.switchCameraButton setImage:[UIImage imageNamed:@"Button_Camera switch active"] forState:UIControlStateSelected | UIControlStateHighlighted];
    if (_isCaller) {
        
        [self reloadCallingUI];
    } else {
        
        [self reloadCalledUI];
    }
    
    if (_callSession.type == EMCallTypeVideo) {
        
        [self.view addGestureRecognizer:self.tapRecognizer];
        [self _initializeVideoView];
        _showVideoInfoButton.enabled = NO;

        [self.view bringSubviewToFront:_topView];
        [self.view bringSubviewToFront:_actionView];
    }
}



- (void)reloadCallingUI
{
    self.statusLabel.text = NSLocalizedString(@"call.calling", @"Calling");
    self.statusLabel.hidden = NO;
    [self.cancelCallButton setHidden:YES];
    [self.answerCallButton setHidden:YES];
    [self.rejectCallButton setHidden:NO];
    self.silenceButton.enabled = YES;
    self.speakerOutButton.enabled = YES;
    self.switchCameraButton.enabled = YES;
    self.minimizeButton.enabled = YES;
    [self.avatarView imageWithUsername:_callSession.remoteName placeholderImage:[UIImage imageNamed:@"default_avatar"]];
    if (_callSession.type == EMCallTypeVideo) {
        _avatarView.hidden = YES;
    }
}

- (void)reloadCalledUI
{
    if (_callSession.type == EMCallTypeVideo) {
        self.statusLabel.text = NSLocalizedString(@"call.incomingVideoCall", @"Incoming video call");
    } else {
        self.statusLabel.text = NSLocalizedString(@"call.incomingCall", @"Incoming call");
    }
    
    [self.avatarView imageWithUsername:_callSession.remoteName placeholderImage:[UIImage imageNamed:@"default_avatar"]];
    if (_callSession.type == EMCallTypeVideo) {
        _avatarView.hidden = YES;
    }
    
    self.speakerOutButton.hidden = YES;
    self.switchCameraButton.hidden = YES;
    self.silenceButton.hidden = YES;
    self.minimizeButton.hidden = YES;
    self.showVideoInfoButton.hidden = YES;
    
    [self.rejectCallButton setHidden:YES];
    [self.cancelCallButton setImage:[UIImage imageNamed:@"Button_End"] forState:UIControlStateNormal];
}

- (void)reloadConnectedUI
{
    self.statusLabel.hidden = YES;
    self.timeLabel.hidden = NO;
    [self startTimer];
    self.cancelCallButton.hidden = YES;
    self.answerCallButton.hidden = YES;
    self.rejectCallButton.hidden = NO;
    self.showVideoInfoButton.enabled = YES;
    
    self.speakerOutButton.hidden = NO;
    self.switchCameraButton.hidden = NO;
    self.silenceButton.hidden = NO;
    self.minimizeButton.hidden = NO;
    self.showVideoInfoButton.hidden = NO;
    
    if (_callSession.type == EMCallTypeVideo) {
        _speakerOutButton.selected = YES;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            AVAudioSession *audioSession = [AVAudioSession sharedInstance];
            [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
            [audioSession setActive:YES error:nil];
        });
        
        [self _setupRemoteView];
    }
}

- (void)_setupRemoteView
{
    //1.对方窗口
    if (_callSession.type == EMCallTypeVideo && _callSession.remoteVideoView == nil) {
        NSLog(@"\n########################_setupRemoteView");
        _callSession.remoteVideoView = [[EMCallRemoteView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        _callSession.remoteVideoView.hidden = YES;
        _callSession.remoteVideoView.backgroundColor = [UIColor clearColor];
        _callSession.remoteVideoView.scaleMode = EMCallViewScaleModeAspectFill;
        [self.view addSubview:_callSession.remoteVideoView];
        [self.view sendSubviewToBack:_callSession.remoteVideoView];
        
        WEAK_SELF
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            weakSelf.callSession.remoteVideoView.hidden = NO;
        });
    }
}

- (void)reloadCallDisconnectedUI
{
    self.statusLabel.hidden = NO;
    self.speakerOutButton.enabled = NO;
    self.silenceButton.enabled = NO;
    self.minimizeButton.enabled = NO;
    self.switchCameraButton.enabled = NO;
    self.rejectCallButton.hidden = YES;
    self.cancelCallButton.hidden = NO;
    self.answerCallButton.hidden = NO;
    self.timeLabel.hidden = YES;
    self.showVideoInfoButton.enabled = NO;
}

- (void)_initializeVideoView
{
    CGFloat width = 80;
    CGFloat height = KScreenHeight / KScreenWidth * width;
    _callSession.localVideoView = [[EMCallLocalView alloc] initWithFrame:CGRectMake(KScreenWidth - 90, CGRectGetMinY(_showVideoInfoButton.frame), width, height)];
    [self.view addSubview:_callSession.localVideoView];
    
}

#pragma mark - Actions

- (IBAction)speakerOutAction:(UIButton *)sender
{
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    if (_speakerOutButton.selected) {
        
        [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:nil];
    }else {
        
        [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
    }
    [audioSession setActive:YES error:nil];
    
    sender.selected = !sender.isSelected;
}

- (IBAction)silenceAction:(UIButton *)sender
{
    sender.selected = !sender.isSelected;
    if (_silenceButton.selected) {
        [_callSession pauseVoice];
    } else {
        [_callSession resumeVoice];
    }
}


- (IBAction)minimizeAction:(UIButton *)sender
{
    NSLog(@"minimizeAction");
}

- (IBAction)rejectCallAction:(UIButton *)sender
{
    [self reloadAudioSession];
    [[EaseCallManager sharedManager] hangupCallWithReason:EMCallEndReasonHangup];
}

- (void)reloadAudioSession
{
    [_timeTimer invalidate];
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:_audioCategory error:nil];
    [audioSession setActive:YES error:nil];
}

- (IBAction)cancelCallAction:(UIButton *)sender
{
    if (_isCaller) {
        
        [self close];
        [EaseCallManager sharedManager].callController = nil;
    } else {
        
        [self reloadAudioSession];
        [[EaseCallManager sharedManager] hangupCallWithReason:EMCallEndReasonDecline];
    }
}

- (BOOL)isVideo:(EMCallType)type
{
    return type == EMCallTypeVoice ? NO : YES;
}

- (IBAction)answerCallAction:(UIButton *)sender {
    
    if (_isCaller) {
        
        NSString *username = [_callSession.remoteName copy];
        BOOL isVideo = [self isVideo:_callSession.type];
        _callSession = nil;
        
        [[EaseCallManager sharedManager] makeCallWithUsername:username isVideo:isVideo];
        
    } else {
        
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        _audioCategory = audioSession.category;
        if(![_audioCategory isEqualToString:AVAudioSessionCategoryPlayAndRecord]) {
            
            [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
            [audioSession setActive:YES error:nil];
        }
    
        [[EaseCallManager sharedManager] answerCall];
    }
}


- (void)close
{
    _callSession.remoteVideoView.hidden = YES;
    _callSession = nil;
    
    if (_timeTimer) {
        [_timeTimer invalidate];
        _timeTimer = nil;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_CALL object:nil];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[AVAudioSession sharedInstance] setActive:NO error:nil];
        [self dismissViewControllerAnimated:YES completion:nil];
    });
    
}

#pragma mark - Timer reload time
- (void)startTimer
{
    _timeLength = 0;
    _timeTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timeTimerAction:) userInfo:nil repeats:YES];
}

- (void)stopTimer
{
    if (_timeTimer) {
        [_timeTimer invalidate];
        _timeTimer = nil;
    }
}

- (void)timeTimerAction:(id)sender
{
    _timeLength += 1;
    int hour = _timeLength / 3600;
    int m = (_timeLength - hour * 3600) / 60;
    int s = _timeLength - hour * 3600 - m * 60;
    
    if (hour > 0) {
        _timeLabel.text = [NSString stringWithFormat:@"%i:%i:%i", hour, m, s];
    }
    else if(m > 0){
        _timeLabel.text = [NSString stringWithFormat:@"%i:%i", m, s];
    }
    else{
        _timeLabel.text = [NSString stringWithFormat:@"00:%i", s];
    }
}

#pragma mark - Video

- (IBAction)showVideoData:(UIButton *)sender
{
    EaseVideoInfoViewController *videoInfo = [[EaseVideoInfoViewController alloc] initWithNibName:@"EaseVideoInfoViewController" bundle:nil];
    videoInfo.callSession = _callSession;
    videoInfo.currentTime = _timeLabel.text;
    [videoInfo startTimer:_timeLength];
    [self presentViewController:videoInfo animated:YES completion:nil];
}

- (IBAction)switchCamera:(UIButton *)sender
{
    [_callSession switchCameraPosition:_switchCameraButton.selected];
    _switchCameraButton.selected = !_switchCameraButton.selected;
}

- (IBAction)pauseVideoAction:(id)sender
{
    _silenceButton.selected = !_silenceButton.selected;
    if (_silenceButton.selected) {
        [_callSession pauseVideo];
    } else {
        [_callSession resumeVideo];
    }
}



@end
