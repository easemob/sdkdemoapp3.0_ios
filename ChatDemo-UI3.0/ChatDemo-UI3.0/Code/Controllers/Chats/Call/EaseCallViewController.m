//
//  EaseCallViewController.m
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 16/9/26.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "EaseCallViewController.h"
#import "EaseCallManager.h"
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

- (void)setupSubViews
{
    self.timeLabel.hidden = YES;
    self.nameLabel.text = _callSession.remoteUsername;
    if (_isCaller) {
        
        self.statusLabel.text = @"Calling";
        self.statusLabel.hidden = NO;
        [self.cancelCallButton setHidden:YES];
        [self.answerCallButton setHidden:YES];
        [self.rejectCallButton setHidden:NO];
        self.silenceButton.enabled = YES;
        self.speakerOutButton.enabled = YES;
        self.switchCameraButton.enabled = YES;
        self.minimizeButton.enabled = YES;
        if (_callSession.type == EMCallTypeVideo) {
            _avatarView.hidden = YES;
        }
    } else {
        
        self.statusLabel.text = @"Incoming Call";
        [self.rejectCallButton setHidden:YES];
        [self.cancelCallButton setImage:[UIImage imageNamed:@"Button_End"] forState:UIControlStateNormal];
    }
    
    if (_callSession.type == EMCallTypeVideo) {
        
        [self.view addGestureRecognizer:self.tapRecognizer];
        
        [self _initializeVideoView];
        
        _showVideoInfoButton.enabled = NO;
        _avatarView.hidden = YES;
        
        [self.view bringSubviewToFront:_topView];
        [self.view bringSubviewToFront:_actionView];
    }
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    [self setupSubViews];

}

- (void)hideLocalView:(BOOL)hidden
{
    _callSession.localVideoView.hidden = hidden;
}

- (void)_initializeVideoView
{
    //1.对方窗口
    _callSession.remoteVideoView = [[EMCallRemoteView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:_callSession.remoteVideoView];
    
    //2.自己窗口
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
        
        [[EMClient sharedClient].callManager pauseVoiceWithSession:_callSession.sessionId error:nil];
    } else {
        
        [[EMClient sharedClient].callManager resumeVoiceWithSession:_callSession.sessionId error:nil];
    }
}


- (IBAction)minimizeAction:(UIButton *)sender
{
    NSLog(@"minimizeAction");
}


- (IBAction)rejectCallAction:(UIButton *)sender
{
    [_timeTimer invalidate];

    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:_audioCategory error:nil];
    [audioSession setActive:YES error:nil];
    
    [[EaseCallManager sharedManager] hangupCallWithReason:EMCallEndReasonDecline];
    
}

- (IBAction)cancelCallAction:(UIButton *)sender
{
    if (_isCaller) {
        
        [self close];
        [EaseCallManager sharedManager].callController = nil;
    } else {
        
        [self rejectCallAction:nil];
    }

}

- (BOOL)isVideo:(EMCallType)type
{
    return type == EMCallTypeVoice ? NO : YES;
}

- (IBAction)answerCallAction:(UIButton *)sender {
    
    if (_isCaller) {
        
#warning - call again
//        [self close];
        NSString *username = [_callSession.remoteUsername copy];
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
        [[EMClient sharedClient].callManager pauseVideoWithSession:_callSession.sessionId error:nil];
    } else {
        [[EMClient sharedClient].callManager resumeVideoWithSession:_callSession.sessionId error:nil];
    }
}



@end
