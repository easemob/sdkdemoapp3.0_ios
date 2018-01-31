//
//  ConferenceViewController.m
//  IosDemo
//
//  Created by XieYajie on 4/26/16.
//  Copyright © 2016 dxstudio.com. All rights reserved.
//

#import "ConferenceViewController.h"

#import <Hyphenate/Hyphenate.h>

#import "DemoCallManager.h"
#import "DemoConfManager.h"
#import "EMConfUserSelectionViewController.h"

//3.3.9 new 自定义视频数据
#import "VideoCustomCamera.h"

@implementation EMConfUserView

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [self addGestureRecognizer:tap];
}

- (void)tapAction:(UITapGestureRecognizer *)aTap
{
    if (aTap.state == UIGestureRecognizerStateEnded) {
        if (_delegate && [_delegate respondsToSelector:@selector(tapUserViewWithStreamId:)]) {
            [_delegate tapUserViewWithStreamId:self.viewId];
        }
    }
}

@end

@interface ConferenceViewController ()<EMConferenceManagerDelegate, EMConfUserViewDelegate, AVCaptureVideoDataOutputSampleBufferDelegate>
{
    float _top;
    float _width;
    float _height;
    float _border;
    
    NSString *_conferenceId;
    BOOL _isCreater;
}

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
//@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@property (weak, nonatomic) IBOutlet UIView *displayCallView;

@property (weak, nonatomic) IBOutlet UIView *actionView;
@property (weak, nonatomic) IBOutlet UIButton *speakerOutButton;
@property (weak, nonatomic) IBOutlet UIButton *silenceButton;
@property (weak, nonatomic) IBOutlet UIButton *switchCameraButton;
@property (weak, nonatomic) IBOutlet UIButton *hangupButton;

@property (weak, nonatomic) IBOutlet UIView *voiceAddButton;
@property (weak, nonatomic) IBOutlet UIView *videoAddButton;

@property (strong, nonatomic) UIButton *minButton;
@property (strong, nonatomic) NSString *currentMaxStreamId;
//@property (nonatomic) int timeLength;
//@property (strong, nonatomic) NSTimer *timeTimer;

@property (strong, nonatomic) NSString *creater;
@property (strong, nonatomic) NSString *pubStreamId;

@property (strong, nonatomic) __block EMCallConference *conference;
@property (strong, nonatomic) EMCallLocalView *localView;
@property (strong, nonatomic) NSMutableArray *streamIdList;
@property (strong, nonatomic) NSMutableDictionary *streamViews;
@property (strong, nonatomic) NSMutableDictionary *streamsDic;

//3.3.9 new 自定义视频数据
@property (weak, nonatomic) IBOutlet UIView *videoFormatView;
@property (weak, nonatomic) IBOutlet UIButton *videoMoreButton;

@property (nonatomic) VideoInputModeType videoModel;
@property (strong, nonatomic) VideoCustomCamera *videoCamera;

@end

@implementation ConferenceViewController

- (instancetype)initWithConferenceId:(NSString *)aConfId
                             creater:(NSString *)aCreater
                                type:(EMCallType)aType
{
    self = [super init];
    if (self) {
        _conferenceId = aConfId;
        _type = aType;
        _isCreater = NO;
        _creater = aCreater;
    }
    
    return self;
}

- (instancetype)initWithType:(EMCallType)aType
{
    self = [super init];
    if (self) {
        _type = aType;
        _isCreater = YES;
        _creater = [EMClient sharedClient].currentUsername;
    }
    
    return self;
}

//3.3.9 new 自定义视频数据
- (instancetype)initVideoCallWithIsCustomData:(BOOL)aIsCustom
{
    self = [self initWithType:EMCallTypeVideo];
    if (self) {
        _videoModel = VIDEO_INPUT_MODE_NONE;
        if (aIsCustom) {
            _videoModel = VIDEO_INPUT_MODE_SAMPLE_BUFFER;
        }
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationController.navigationBarHidden = YES;
    
    [[DemoCallManager sharedManager] setIsCalling:YES];
    [[EMClient sharedClient].conferenceManager addDelegate:self delegateQueue:nil];
    
    self.streamIdList = [[NSMutableArray alloc] init];
    self.streamViews = [[NSMutableDictionary alloc] init];
    self.streamsDic = [[NSMutableDictionary alloc] init];
    
    [self _setupSubviews];
    [self _createOrJoinConference];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.navigationController.navigationBarHidden = NO;
}

- (void)dealloc
{
    [self closeVideoCamera];
    [[EMClient sharedClient].conferenceManager removeDelegate:self];
}

#pragma mark - getter

- (UIButton *)minButton
{
    if (_minButton == nil) {
        _minButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 20, 50, 50)];
        [_minButton setImage:[UIImage imageNamed:@"Button_Minimize"] forState:UIControlStateNormal];
        [_minButton addTarget:self action:@selector(minAction) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _minButton;
}

#pragma mark - Private

- (void)_setupSubviews
{
    [self.silenceButton setImage:[UIImage imageNamed:@"Button_Mute_active"] forState:UIControlStateSelected];
    
    CGSize boundSize = [[UIScreen mainScreen] bounds].size;
    int maxHeight = 0;
    _top = 0;
    if (self.type == EMCallTypeVoice) {
        [self.speakerOutButton setImage:[UIImage imageNamed:@"Button_Speaker_active"] forState:UIControlStateSelected];
        
        _border = 20;
        maxHeight = (self.displayCallView.frame.size.height - _border) / 2;
        _width = (boundSize.width - _border * 4) / 3;
        _height = MIN(_width, maxHeight);
        _width = _height;
        
    } else if (self.type == EMCallTypeVideo) {
        [self.switchCameraButton setImage:[UIImage imageNamed:@"Button_Camera_active"] forState:UIControlStateSelected];
        self.speakerOutButton.hidden = YES;
        self.switchCameraButton.hidden = NO;
        
        self.view.backgroundColor = [UIColor colorWithRed:33 / 255.0 green:41 / 255.0 blue:48 / 255.0 alpha:1.0];
        self.videoAddButton.layer.borderWidth = 1;
        self.voiceAddButton.layer.borderColor = [UIColor grayColor].CGColor;
        
        
        _border = 5;
        maxHeight = (self.displayCallView.frame.size.height - 5) / 2;
        _width = (boundSize.width - _border * 2) / 3;
        _height = MIN(_width, maxHeight);
        _width = _height;
    }
    
    NSString *loginUser = [EMClient sharedClient].currentUsername;
    if (self.type == EMCallTypeVoice) {
        [self _setupUserVoiceViewWithUserName:loginUser streamId:loginUser];
        [self _layoutVoiceAddButton];
    } else {
        [self _setupUserVideoViewWithUserName:loginUser streamId:loginUser];
        [self _layoutVideoAddButton];
        
        self.videoMoreButton.hidden = YES;
        if (self.videoModel != VIDEO_INPUT_MODE_NONE) {
            self.videoMoreButton.hidden = NO;
        }
    }
}

- (EMConfUserView *)_setupUserVoiceViewWithUserName:(NSString *)aUserName
                                           streamId:(NSString *)aStreamId
{
    int count = (int )[self.streamViews count] + 1;
    int row = count < 4 ? 0 : 1;
    int col = 0;
    if (count == 2 || count == 5) {
        col = 1;
    } else if (count == 3 || count == 6) {
        col = 2;
    }
    CGFloat ox = _border + col * (_width + _border);
    CGFloat oy = _top + row * (_height + 10);
    
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"EMConfUserVoiceView" owner:self options:nil];
    EMConfUserView *userView = [nib objectAtIndex:0];
    userView.viewId = aStreamId;
    
    userView.frame = CGRectMake(ox, oy, _width, _height);
    userView.nameLabel.text = aUserName;
    
    [self.displayCallView addSubview:userView];
    [self.streamViews setObject:userView forKey:aStreamId];
    
    return userView;
}

- (void)_layoutVoiceAddButton
{
    if (!_isCreater) {
        return;
    }
    
    if ([self.streamViews count] == 6) {
        self.voiceAddButton.hidden = YES;
        [self.voiceAddButton removeFromSuperview];
    } else {
        int count = (int )[self.streamViews count] + 1;
        int row = count < 4 ? 0 : 1;
        int col = 0;
        if (count == 2 || count == 5) {
            col = 1;
        } else if (count == 3 || count == 6) {
            col = 2;
        }
        CGFloat ox = _border + col * (_width + _border);
        CGFloat oy = _top + row * (_height + 10);
        self.voiceAddButton.frame = CGRectMake(ox, oy, _width, _height);
        
        if (self.voiceAddButton.hidden == YES) {
            [self.displayCallView addSubview:self.voiceAddButton];
            self.voiceAddButton.hidden = NO;
        }
    }
}

- (EMConfUserView *)_setupUserVideoViewWithUserName:(NSString *)aUserName
                                           streamId:(NSString *)aStreamId
{
    int count = (int )[self.streamViews count] + 1;
    int row = count < 4 ? 0 : 1;
    int col = 0;
    if (count == 2 || count == 5) {
        col = 1;
    } else if (count == 3 || count == 6) {
        col = 2;
    }
    CGFloat ox = col * (_width + _border);
    CGFloat oy = _top + row * (_height + 10);
    
    BOOL isLocal = [[EMClient sharedClient].currentUsername isEqualToString:aUserName];
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"EMConfUserVideoView" owner:self options:nil];
    EMConfUserView *userView = [nib objectAtIndex:0];
    userView.viewId = aStreamId;
    userView.delegate = self;
    userView.frame = CGRectMake(ox, oy, _width, _height);
    userView.nameLabel.text = aUserName;
    
    [self.displayCallView addSubview:userView];
    [self.streamViews setObject:userView forKey:aStreamId];
    
    if (isLocal) {
        [userView.imgView removeFromSuperview];
        
        EMCallLocalView *localView = [[EMCallLocalView alloc] initWithFrame:CGRectMake(0, 0, userView.topView.frame.size.width, userView.topView.frame.size.height)];
        localView.tag = 100;
        localView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        localView.scaleMode = EMCallViewScaleModeAspectFill;
        [userView.topView addSubview:localView];
        [userView.topView sendSubviewToBack:localView];
    } else {
        EMCallRemoteView *remoteView = [[EMCallRemoteView alloc] initWithFrame:CGRectMake(0, 0, userView.topView.frame.size.width, userView.topView.frame.size.height)];
        remoteView.tag = 100;
        remoteView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        remoteView.scaleMode = EMCallViewScaleModeAspectFill;
        [userView.topView addSubview:remoteView];
        [userView.topView sendSubviewToBack:remoteView];
    }
    
    return userView;
}

- (void)_layoutVideoAddButton
{
    if (!_isCreater) {
        return;
    }
    
    if ([self.streamViews count] == 6) {
        self.videoAddButton.hidden = YES;
        [self.videoAddButton removeFromSuperview];
    } else {
        int count = (int )[self.streamViews count] + 1;
        int row = count < 4 ? 0 : 1;
        int col = 0;
        if (count == 2 || count == 5) {
            col = 1;
        } else if (count == 3 || count == 6) {
            col = 2;
        }
        CGFloat ox = col * (_width + _border);
        CGFloat oy = _top + row * (_height + 10);
        self.videoAddButton.frame = CGRectMake(ox, oy, _width, _height);
        
        if (self.videoAddButton.hidden == YES) {
            [self.displayCallView addSubview:self.videoAddButton];
            self.videoAddButton.hidden = NO;
        }
    }
}

#pragma mark - private EMConferenceManager

- (void)_createOrJoinConference
{
    NSString *loginUser = [EMClient sharedClient].currentUsername;
    
    EMStreamParam *pubConfig = [[EMStreamParam alloc] init];
    pubConfig.streamName = loginUser;
    pubConfig.enableVideo = self.type == EMCallTypeVideo ? YES : NO;
    
    __weak typeof(self) weakSelf = self;
    void (^block)(EMCallConference *aCall, NSString *aPassword, EMError *aError) = ^(EMCallConference *aCall, NSString *aPassword, EMError *aError) {
        if (aError) {
            weakSelf.conference = nil;
            self.navigationController.navigationBarHidden = NO;
            [self.navigationController popViewControllerAnimated:NO];

            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"alert.conference.createFail", @"Create or Join conference failed!") delegate:nil cancelButtonTitle:NSLocalizedString(@"sure", @"OK") otherButtonTitles:nil, nil];
            [alertView show];
        } else {
            weakSelf.conference = aCall;
            //上传自己的数据流
            EMCallLocalView *localView = nil;
            EMConfUserView *userView = [self.streamViews objectForKey:loginUser];
            if (self.type == EMCallTypeVideo) {
                localView = (EMCallLocalView *)[userView.topView viewWithTag:100];
            }
            pubConfig.localView = localView;

            //3.3.9 new 自定义视频数据
            if (self.videoModel != VIDEO_INPUT_MODE_NONE) {
                pubConfig.enableCustomizeVideoData = YES;
            }

            [[EMClient sharedClient].conferenceManager publishConference:weakSelf.conference streamParam:pubConfig completion:^(NSString *pubStreamId, EMError *aError) {
                if (aError) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"alert.conference.pubFail", @"Pub stream failed!") delegate:nil cancelButtonTitle:NSLocalizedString(@"sure", @"OK") otherButtonTitles:nil, nil];
                    [alertView show];
                } else {
                    weakSelf.pubStreamId = pubStreamId;
                    [weakSelf.streamIdList removeObject:loginUser];
                    [weakSelf.streamIdList insertObject:pubStreamId atIndex:0];

                    userView.viewId = pubStreamId;
                    [weakSelf.streamViews removeObjectForKey:loginUser];
                    [weakSelf.streamViews setObject:userView forKey:pubStreamId];

                    //3.3.9 new 自定义视频数据
                    if (weakSelf.videoModel != VIDEO_INPUT_MODE_NONE) {
                        [weakSelf openVideoCamera];
                    }
                }
            }];
        }
    };
    
    if (_isCreater) {
        [[EMClient sharedClient].conferenceManager createAndJoinConferenceWithPassword:@"" completion:block];
    } else {
        [[EMClient sharedClient].conferenceManager joinConferenceWithConfId:_conferenceId password:@"" completion:^(EMCallConference *aCall, EMError *aError) {
            block(aCall, @"", aError);
        }];
    }
}

- (void)_inviteUser:(NSString *)aUserName
{
    NSMutableDictionary *ext = [[NSMutableDictionary alloc] init];
    [ext setObject:[EMClient sharedClient].currentUsername forKey:@"creater"];
    [ext setObject:[NSNumber numberWithInteger:self.type] forKey:@"type"];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:ext options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    EMError *error = nil;
    __weak typeof(self) weakSelf = self;
    [[EMClient sharedClient].conferenceManager inviteUserToJoinConference:self.conference userName:aUserName password:nil ext:jsonString error:&error];
    if (error) {
        [weakSelf showHint:NSLocalizedString(@"alert.conference.inviteFail", @"Invite failed!")];
    }
    else {
        [weakSelf showHint:NSLocalizedString(@"alert.conference.inviteSuccess", @"Invite successful!")];
    }
    
//    NSString *currentUser = [EMClient sharedClient].currentUsername;
//    EMCmdMessageBody *cmdChat = [[EMCmdMessageBody alloc] initWithAction:@"inviteToJoinConference"];
//    EMMessage *message = [[EMMessage alloc] initWithConversationID:aUserName from:currentUser to:aUserName body:cmdChat ext:@{@"confId":self.conference.confId, @"creater":currentUser, @"type":[NSNumber numberWithInteger:self.type]}];
//    message.chatType = EMChatTypeChat;
//    [[EMClient sharedClient].chatManager sendMessage:message progress:nil completion:nil];
}

- (void)_subStream:(EMCallStream *)aStream
{
    [self.streamIdList addObject:aStream.streamId];
    
    EMCallRemoteView *remoteView = nil;
    if (self.type == EMCallTypeVideo) {
        EMConfUserView *userView = [self _setupUserVideoViewWithUserName:aStream.userName streamId:aStream.streamId];
        [self _layoutVideoAddButton];
        remoteView = (EMCallRemoteView *)[userView.topView viewWithTag:100];
    } else {
        [self _setupUserVoiceViewWithUserName:aStream.userName streamId:aStream.streamId];
        [self _layoutVoiceAddButton];
    }
    
    __weak typeof(self) weakSelf = self;
    [[EMClient sharedClient].conferenceManager subscribeConference:self.conference streamId:aStream.streamId remoteVideoView:remoteView completion:^(EMError *aError) {
        if (aError) {
            NSString *message = [NSString stringWithFormat:NSLocalizedString(@"alert.conference.subFail", @"Sub stream-%@ failed!"), weakSelf.creater];
            [weakSelf showHint:message];
        }
    }];
}

- (void)_removeStream:(EMCallStream *)aStream
{
    NSInteger index = [self.streamIdList indexOfObject:aStream.streamId];
    [self.streamIdList removeObject:aStream.streamId];
    
    EMConfUserView *userView = [self.streamViews objectForKey:aStream.streamId];
    [self.streamViews removeObjectForKey:aStream.streamId];

    CGRect frame = userView.frame;
    [userView removeFromSuperview];
    
    for (; index < [self.streamIdList count]; index++) {
        NSString *sId = [self.streamIdList objectAtIndex:index];
        UIView *view = [self.streamViews objectForKey:sId];
        CGRect tmpFrame = view.frame;
        view.frame = frame;
        frame = tmpFrame;
    }

    if (self.type == EMCallTypeVoice) {
        [self _layoutVoiceAddButton];
    } else {
        [self _layoutVideoAddButton];
    }
}

- (void)_userViewDidConnectedWithStreamId:(NSString *)aStreamId
{
    EMConfUserView *userView = [self.streamViews objectForKey:aStreamId];
    if (userView) {
        userView.statusImgView.image = [UIImage imageNamed:@"conf_connected"];
        if (self.type == EMCallTypeVideo) {
            [userView.imgView removeFromSuperview];
        }
    }
}

- (void)conferenceNetworkDidChange:(EMCallConference *)aSession
                            status:(EMCallNetworkStatus)aStatus
{
    NSString *str = @"";
    switch (aStatus) {
        case EMCallNetworkStatusNormal:
            str = NSLocalizedString(@"network.conference.normal", @"Network changes: the network is normal");
            break;
        case EMCallNetworkStatusUnstable:
            str = NSLocalizedString(@"network.conference.unstable", @"Network changes: the network is unstable");
            break;
        case EMCallNetworkStatusNoData:
            str = NSLocalizedString(@"network.conference.dis", @"Network changes: the network is disconnect");
            break;
            
        default:
            break;
    }
    if ([str length] > 0) {
        [self showHint:str];
    }
}

#pragma mark - private timer

//- (void)_timeTimerAction:(id)sender
//{
//    self.timeLength += 1;
//    int hour = self.timeLength / 3600;
//    int m = (self.timeLength - hour * 3600) / 60;
//    int s = self.timeLength - hour * 3600 - m * 60;
//    
//    if (hour > 0) {
//        self.statusLabel.text = [NSString stringWithFormat:@"%i:%i:%i", hour, m, s];
//    }
//    else if(m > 0){
//        self.statusLabel.text = [NSString stringWithFormat:@"%i:%i", m, s];
//    }
//    else{
//        self.statusLabel.text = [NSString stringWithFormat:@"00:%i", s];
//    }
//}
//
//- (void)_startTimeTimer
//{
//    self.timeLength = 0;
//    self.timeTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(_timeTimerAction:) userInfo:nil repeats:YES];
//}
//
//- (void)_stopTimeTimer
//{
//    if (self.timeTimer) {
//        [self.timeTimer invalidate];
//        self.timeTimer = nil;
//    }
//}

#pragma mark - EMConferenceManagerDelegate

- (void)userDidJoin:(EMCallConference *)aConference
               user:(NSString *)aUserName
{
    if ([aConference.callId isEqualToString: self.conference.callId]) {
        NSString *message = [NSString stringWithFormat:NSLocalizedString(@"hint.conference.userJoin", @"User %@ has been joined to the conference"), aUserName];
        [self showHint:message];
    }
}

- (void)userDidLeave:(EMCallConference *)aConference
                user:(NSString *)aUserName
{
    if ([aConference.callId isEqualToString:self.conference.callId]) {
        NSString *message = [NSString stringWithFormat:NSLocalizedString(@"hint.conference.userLeave", @"User %@ has been leaved from the conference"), aUserName];
        [self showHint:message];
    }
}

- (void)streamDidUpdate:(EMCallConference *)aConference
              addStream:(EMCallStream *)aStream
{
    if ([aConference.callId isEqualToString:self.conference.callId]) {
        [self.streamsDic setObject:aStream forKey:aStream.streamId];
        [self _subStream:aStream];
    }
}

- (void)streamDidUpdate:(EMCallConference *)aConference
           removeStream:(EMCallStream *)aStream
{
    if ([aConference.callId isEqualToString:self.conference.callId]) {
        [self.streamsDic removeObjectForKey:aStream.streamId];
        [self _removeStream:aStream];
    }
}

- (void)conferenceDidEnd:(EMCallConference *)aConference
                  reason:(EMCallEndReason)aReason
                   error:(EMError *)aError
{
    if ([aConference.callId isEqualToString:self.conference.callId]) {
        [[DemoCallManager sharedManager] setIsCalling:NO];
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"alert.conference.closed", @"Conference has been closed") delegate:nil cancelButtonTitle:NSLocalizedString(@"sure", @"OK") otherButtonTitles:nil, nil];
        [alertView show];
        
        self.conference = nil;
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)streamDidUpdate:(EMCallConference *)aConference
                 stream:(EMCallStream *)aStream
{
    if ([aConference.callId isEqualToString:self.conference.callId] && aStream != nil) {
        [self.streamsDic setObject:aStream forKey:aStream.streamId];
    }
}

- (void)streamStartTransmitting:(EMCallConference *)aConference
                       streamId:(NSString *)aStreamId
{
    if ([aConference.callId isEqualToString:self.conference.callId]) {
        if ([aStreamId isEqualToString:self.pubStreamId]) {
            [self _userViewDidConnectedWithStreamId:aStreamId];
        } else if ([self.streamIdList containsObject:aStreamId]) {
            [self _userViewDidConnectedWithStreamId:aStreamId];
        }
    }
}

#pragma mark - EMConfUserViewDelegate

- (void)tapUserViewWithStreamId:(NSString *)aStreamId
{
    self.currentMaxStreamId = aStreamId;
    EMConfUserView *userView = [self.streamViews objectForKey:aStreamId];
    UIView *displayView = [userView.topView viewWithTag:100];
    if (displayView) {
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        displayView.frame = CGRectMake(0, 0, window.bounds.size.width, window.bounds.size.height);
        [displayView addSubview:self.minButton];
        [displayView removeFromSuperview];
        [window addSubview:displayView];
    }
}

#pragma mark - action

- (IBAction)addUserAction:(id)sender
{
    NSMutableArray *usernames = [[NSMutableArray alloc] initWithArray:[[EMClient sharedClient].contactManager getContacts]];
    NSArray *streams = [self.streamsDic allValues];
    for (EMCallStream *stream in streams) {
        if ([usernames containsObject:stream.userName]) {
            [usernames removeObject:stream.userName];
        }
    }
    
    EMConfUserSelectionViewController *controller = [[EMConfUserSelectionViewController alloc] initWithDataSource:usernames selectedUsers:nil];
    [controller setSelecteUserFinishedCompletion:^(NSArray *selectedUsers) {
        for (NSString *userName in selectedUsers) {
            [self _inviteUser:userName];
        }
        
        [self _layoutVoiceAddButton];
    }];
    
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)speakerOutAction:(id)sender
{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    if (self.speakerOutButton.selected) {
        [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:nil];
    }else {
        [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
    }
    [audioSession setActive:YES error:nil];
    self.speakerOutButton.selected = !self.speakerOutButton.selected;
}

- (IBAction)switchCameraAction:(id)sender
{
    //3.3.9 new 自定义视频数据
    self.switchCameraButton.selected = !self.switchCameraButton.selected;
    if (self.videoModel == VIDEO_INPUT_MODE_NONE) {
        [[EMClient sharedClient].conferenceManager updateConferenceWithSwitchCamera:self.conference];
    } else {
        [self.videoCamera swapCameraWithPosition:(self.switchCameraButton.selected ? AVCaptureDevicePositionBack : AVCaptureDevicePositionFront)];
    }
}

- (IBAction)silenceAction:(id)sender
{
    self.silenceButton.selected = !self.silenceButton.selected;
    [[EMClient sharedClient].conferenceManager updateConference:self.conference isMute:self.silenceButton.selected];
}

- (void)minAction
{
    EMConfUserView *userView = [self.streamViews objectForKey:self.currentMaxStreamId];
    self.currentMaxStreamId = nil;
    
    UIView *displayView = self.minButton.superview;
    [self.minButton removeFromSuperview];
    displayView.frame = CGRectMake(0, 0, userView.topView.frame.size.width, userView.topView.frame.size.height);
    displayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [displayView removeFromSuperview];
    [userView.topView addSubview:displayView];
}

- (IBAction)hangupAction:(id)sender
{
    //3.3.9 new 自定义视频数据
    [self closeVideoCamera];
    
    [[DemoCallManager sharedManager] setIsCalling:NO];
    
    if (self.conference == nil) {
        self.navigationController.navigationBarHidden = NO;
        [self.navigationController popViewControllerAnimated:NO];
        return;
    }
    
//    if (_isCreater) {
//        NSString *localName = [EMClient sharedClient].currentUsername;
//        EMTextMessageBody *body = [[EMTextMessageBody alloc] initWithText:[NSString stringWithFormat:@"%@ 结束了多人会议", localName]];
//        EMMessage *message = [[EMMessage alloc] initWithConversationID:_conversationId from:localName to:_conversationId body:body ext:nil];
//        message.chatType = EMChatTypeGroupChat;
//        [[EMClient sharedClient].chatManager sendMessage:message progress:nil completion:nil];
//    }
    
    [[EMClient sharedClient].conferenceManager leaveConference:self.conference completion:nil];
    
    self.conference = nil;
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController popViewControllerAnimated:NO];
}

#pragma mark - 3.3.9 new 自定义视频数据

#pragma mark AVCaptureVideoDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput*)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection*)connection
{
    if(!self.conference || [self.pubStreamId length] == 0 || self.videoModel == VIDEO_INPUT_MODE_NONE){
        return;
    }

    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    if (imageBuffer == NULL) {
        return ;
    }
    
    CVOptionFlags lockFlags = kCVPixelBufferLock_ReadOnly;
    CVReturn ret = CVPixelBufferLockBaseAddress(imageBuffer, lockFlags);
    if (ret != kCVReturnSuccess) {
        return ;
    }
    
    static size_t const kYPlaneIndex = 0;
    static size_t const kUVPlaneIndex = 1;
    uint8_t* yPlaneAddress = (uint8_t*)CVPixelBufferGetBaseAddressOfPlane(imageBuffer, kYPlaneIndex);
    size_t yPlaneHeight = CVPixelBufferGetHeightOfPlane(imageBuffer, kYPlaneIndex);
    size_t yPlaneWidth = CVPixelBufferGetWidthOfPlane(imageBuffer, kYPlaneIndex);
    size_t yPlaneBytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer, kYPlaneIndex);
    size_t uvPlaneHeight = CVPixelBufferGetHeightOfPlane(imageBuffer, kUVPlaneIndex);
    size_t uvPlaneBytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer, kUVPlaneIndex);
    size_t frameSize = yPlaneBytesPerRow * yPlaneHeight + uvPlaneBytesPerRow * uvPlaneHeight;
    
    // set uv for gray color
    uint8_t * uvPlaneAddress = yPlaneAddress + yPlaneBytesPerRow * yPlaneHeight;
    memset(uvPlaneAddress, 0x7F, uvPlaneBytesPerRow * uvPlaneHeight);
    if(self.videoModel == VIDEO_INPUT_MODE_DATA){
        [[EMClient sharedClient].conferenceManager inputVideoData:[NSData dataWithBytes:yPlaneAddress length:frameSize] conference:self.conference publishedStreamId:self.pubStreamId widthInPixels:yPlaneWidth heightInPixels:yPlaneHeight format:EMCallVideoFormatNV12 rotation:0 completion:nil];
    }
    
    CVPixelBufferUnlockBaseAddress(imageBuffer, lockFlags);
    
    if(self.videoModel == VIDEO_INPUT_MODE_SAMPLE_BUFFER) {
        [[EMClient sharedClient].conferenceManager inputVideoSampleBuffer:sampleBuffer conference:self.conference publishedStreamId:self.pubStreamId format:EMCallVideoFormatNV12 rotation:0 completion:nil];
    } else if(self.videoModel == VIDEO_INPUT_MODE_PIXEL_BUFFER) {
        [[EMClient sharedClient].conferenceManager inputVideoPixelBuffer:imageBuffer conference:self.conference publishedStreamId:self.pubStreamId format:EMCallVideoFormatNV12 rotation:0 completion:nil];
    }
}

- (IBAction)moreAction:(id)sender
{
    self.videoFormatView.hidden = NO;
}

- (IBAction)videoModelValueChanged:(UISegmentedControl *)sender
{
    NSInteger index = sender.selectedSegmentIndex;
    switch (index) {
        case 0:
            self.videoModel = VIDEO_INPUT_MODE_SAMPLE_BUFFER;
            break;
        case 1:
            self.videoModel = VIDEO_INPUT_MODE_PIXEL_BUFFER;
            break;
        case 2:
            self.videoModel = VIDEO_INPUT_MODE_DATA;
            break;
            
        default:
            break;
    }
}

- (IBAction)closeVideoFormatViewAction:(id)sender
{
    self.videoFormatView.hidden = YES;
}

- (void)openVideoCamera
{
    if(self.videoCamera){
        return ;
    }
    
    self.videoCamera = [[VideoCustomCamera alloc] initWithQueue:dispatch_get_main_queue()];
    [self.videoCamera syncSetDataDelegate:self onDone:nil];
    BOOL ok = [self.videoCamera syncOpenWithWidth:640 height:480 onDone:nil];
    if(!ok){
        [self.videoCamera syncClose:nil];
        self.videoCamera = nil;
    }
    
}

- (void)closeVideoCamera
{
    if(self.videoCamera){
        [self.videoCamera syncClose:^(id obj, NSError *error) {}];
        self.videoCamera = nil;
    }
}

@end
