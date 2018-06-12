//
//  ConferenceViewController.m
//  IosDemo
//
//  Created by XieYajie on 4/26/16.
//  Copyright © 2016 dxstudio.com. All rights reserved.
//

#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>
#import "ConferenceViewController.h"

#import "DemoCallManager.h"
#import "DemoConfManager.h"
#import "EMConfUserSelectionViewController.h"

//3.3.9 new 自定义视频数据
#import "VideoCustomCamera.h"

#define kMaxCol 4

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

- (void)setIsMuted:(BOOL)isMuted
{
    _isMuted = isMuted;
    if (isMuted) {
        self.statusImgView.image = [UIImage imageNamed:@"conf_mute"];
    } else {
        self.statusImgView.image = nil;
    }
}

- (void)setStatus:(EMAudioStatus)status
{
    if (self.isMuted) {
        return;
    }
    
    if (_status != status) {
        _status = status;
        switch (_status) {
            case EMAudioStatusNone:
                self.statusImgView.image = [UIImage imageNamed:@"conf_ring"];
                break;
            case EMAudioStatusConnected:
                self.statusImgView.image = nil;
                break;
            case EMAudioStatusTalking:
                self.statusImgView.image = [UIImage imageNamed:@"conf_talking"];
                break;
                
            default:
                break;
        }
    }
}

@end

@interface ConferenceViewController ()<EMConferenceManagerDelegate, EMConfUserViewDelegate, AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic, strong) CTCallCenter *callCenter;

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *displayView;

@property (weak, nonatomic) IBOutlet UIView *actionView;
@property (weak, nonatomic) IBOutlet UIButton *muteButton;
@property (weak, nonatomic) IBOutlet UIButton *speakerOutButton;
@property (weak, nonatomic) IBOutlet UIButton *enableCameraButton;
@property (weak, nonatomic) IBOutlet UIButton *switchCameraButton;
@property (weak, nonatomic) IBOutlet UIButton *hangupButton;

@property (strong, nonatomic) UIButton *minButton;
@property (strong, nonatomic) NSString *currentMaxStreamId;

@property (nonatomic) float itemBorder;
@property (nonatomic) CGSize itemSize;

@property (nonatomic) BOOL isCreater;
@property (strong, nonatomic) NSString *createrName;
@property (strong, nonatomic) NSString *pubStreamId;
@property (strong, nonatomic) NSString *conferenceId;
@property (strong, nonatomic) __block EMCallConference *conference;

@property (strong, nonatomic) EMCallLocalView *localView;
@property (strong, nonatomic) NSMutableDictionary *streamViews;
@property (strong, nonatomic) NSMutableDictionary *streamsDic;
@property (strong, nonatomic) NSMutableArray *streamIds;
@property (strong, nonatomic) NSMutableArray *talkingStreamIds;

//3.3.9 new 自定义视频数据
@property (weak, nonatomic) IBOutlet UIView *videoFormatView;
@property (weak, nonatomic) IBOutlet UIButton *videoMoreButton;

@property (nonatomic) VideoInputModeType videoModel;
@property (strong, nonatomic) VideoCustomCamera *videoCamera;

@end

@implementation ConferenceViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        _isCreater = YES;
        _createrName = [EMClient sharedClient].currentUsername;
    }
    
    return self;
}

- (instancetype)initWithConferenceId:(NSString *)aConfId
                             creater:(NSString *)aCreater
{
    self = [super init];
    if (self) {
        _conferenceId = aConfId;
        _isCreater = NO;
        _createrName = aCreater;
    }
    
    return self;
}

//3.3.9 new 自定义视频数据
- (instancetype)initVideoCallWithIsCustomData:(BOOL)aIsCustom
{
    self = [self init];
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
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    [[DemoCallManager sharedManager] setIsCalling:YES];
    [[EMClient sharedClient].conferenceManager addDelegate:self delegateQueue:nil];
    
    self.streamViews = [[NSMutableDictionary alloc] init];
    self.streamsDic = [[NSMutableDictionary alloc] init];
    self.streamIds = [[NSMutableArray alloc] init];
    self.talkingStreamIds = [[NSMutableArray alloc] init];
    
    self.itemBorder = 10;
    CGSize boundSize = [[UIScreen mainScreen] bounds].size;
    float width = (boundSize.width - self.itemBorder * (kMaxCol + 1)) / kMaxCol;
    self.itemSize = CGSizeMake(width, width);
    
    [self _setupSubviews];
    [self _createOrJoinConference];
    
    __weak typeof(self) weakSelf = self;
    self.callCenter = [[CTCallCenter alloc] init];
    self.callCenter.callEventHandler = ^(CTCall* call) {
        if(call.callState == CTCallStateConnected) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf hangupAction:nil];
            });
        }
    };
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
    [[EMClient sharedClient].conferenceManager stopMonitorSpeaker:self.conference];
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

#pragma mark - Subviews

- (void)_setupSubviews
{
    [self.speakerOutButton setImage:[UIImage imageNamed:@"Button_Speaker_active"] forState:UIControlStateSelected];
    [self.muteButton setImage:[UIImage imageNamed:@"Button_Mute_active"] forState:UIControlStateSelected];
    [self.enableCameraButton setImage:[UIImage imageNamed:@"conf_camera_on"] forState:UIControlStateSelected];
    
    self.videoMoreButton.hidden = YES;
    //3.3.9 new 自定义视频数据
    if (self.videoModel != VIDEO_INPUT_MODE_NONE) {
        self.videoMoreButton.hidden = NO;
        self.enableCameraButton.hidden = YES;
        self.switchCameraButton.hidden = NO;
    }
    
    NSString *loginUser = [EMClient sharedClient].currentUsername;
    [self _setupUserViewWithUserName:loginUser streamId:loginUser];
}

- (EMConfUserView *)_setupUserViewWithUserName:(NSString *)aUserName
                                      streamId:(NSString *)aStreamId
{
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"EMConfUserView" owner:self options:nil];
    EMConfUserView *userView = [nib objectAtIndex:0];
    userView.viewId = aStreamId;
    userView.delegate = self;
    userView.nameLabel.text = aUserName;
    
    NSInteger index = [self.streamViews count];
    NSInteger col = index % kMaxCol;
    NSInteger row = index / kMaxCol;
    userView.frame = CGRectMake(col * (self.itemSize.width + self.itemBorder) + self.itemBorder, row * (self.itemSize.height + self.itemBorder) + self.itemBorder, self.itemSize.width, self.itemSize.height);
    [self.displayView addSubview:userView];
    [self.streamViews setObject:userView forKey:aStreamId];
    
    float height = CGRectGetMaxY(userView.frame) + self.itemBorder;
    if (height > self.displayView.contentSize.height) {
        self.displayView.scrollEnabled = YES;
        self.displayView.contentSize = CGSizeMake(self.displayView.contentSize.width, height);
    }
    
    return userView;
}

#pragma mark - private EMConferenceManager

- (void)_createOrJoinConference
{
    NSString *loginUser = [EMClient sharedClient].currentUsername;
    
    EMStreamParam *pubConfig = [[EMStreamParam alloc] init];
    pubConfig.streamName = loginUser;
    pubConfig.enableVideo = NO;
    
    __weak typeof(self) weakSelf = self;
    void (^block)(EMCallConference *aCall, NSString *aPassword, EMError *aError) = ^(EMCallConference *aCall, NSString *aPassword, EMError *aError) {
        if (aError) {
            weakSelf.conference = nil;
            self.navigationController.navigationBarHidden = NO;
            [self.navigationController popViewControllerAnimated:NO];
            [DemoCallManager sharedManager].isCalling = NO;

            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"alert.conference.createFail", @"Create or Join conference failed!") delegate:nil cancelButtonTitle:NSLocalizedString(@"sure", @"OK") otherButtonTitles:nil, nil];
            [alertView show];
        } else {
            weakSelf.conference = aCall;
            
            EMConfUserView *userView = [weakSelf.streamViews objectForKey:loginUser];
            if ([EMClient sharedClient].conferenceManager.mode == EMConferenceModeLarge) {
                userView.mixLabel.hidden = NO;
            }
            
            self.localView = [[EMCallLocalView alloc] initWithFrame:CGRectMake(0, 0, userView.videoView.frame.size.width, userView.videoView.frame.size.height)];
            self.localView.tag = 100;
            self.localView.backgroundColor = [UIColor blackColor];
            self.localView.scaleMode = EMCallViewScaleModeAspectFill;
            pubConfig.localView = self.localView;
            pubConfig.enableVideo = NO;
            
            //3.3.9 new 自定义视频数据
            if (self.videoModel != VIDEO_INPUT_MODE_NONE) {
                pubConfig.enableCustomizeVideoData = YES;
                pubConfig.enableVideo = YES;
                [userView.videoView addSubview:self.localView];
            }
            
            [[EMClient sharedClient].conferenceManager publishConference:weakSelf.conference streamParam:pubConfig completion:^(NSString *pubStreamId, EMError *aError) {
                if (aError) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"alert.conference.pubFail", @"Pub stream failed!") delegate:nil cancelButtonTitle:NSLocalizedString(@"sure", @"OK") otherButtonTitles:nil, nil];
                    [alertView show];
                } else {
                    weakSelf.pubStreamId = pubStreamId;
                    
                    EMConfUserView *resetView = [weakSelf.streamViews objectForKey:loginUser];
                    resetView.viewId = pubStreamId;
                    [weakSelf.streamViews removeObjectForKey:loginUser];
                    [weakSelf.streamViews setObject:resetView forKey:pubStreamId];

                    //3.3.9 new 自定义视频数据
                    if (weakSelf.videoModel != VIDEO_INPUT_MODE_NONE) {
                        [weakSelf openVideoCamera];
                    }
                    
                    [[EMClient sharedClient].conferenceManager startMonitorSpeaker:weakSelf.conference timeInterval:300 completion:nil];
                }
            }];
        }
    };
    
    if (self.isCreater) {
        [[EMClient sharedClient].conferenceManager createAndJoinConferenceWithPassword:@"" completion:block];
    } else {
        [[EMClient sharedClient].conferenceManager joinConferenceWithConfId:_conferenceId password:@"" completion:^(EMCallConference *aCall, EMError *aError) {
            block(aCall, @"", aError);
        }];
    }
}

- (void)_inviteUser:(NSString *)aUserName
{
    NSString *currentUser = [EMClient sharedClient].currentUsername;
    EMTextMessageBody *textBody = [[EMTextMessageBody alloc] initWithText:[[NSString alloc] initWithFormat:@"Invite %@ to join conference: %@", aUserName, self.conference.confId]];
    EMMessage *message = [[EMMessage alloc] initWithConversationID:aUserName from:currentUser to:aUserName body:textBody ext:@{@"conferenceId":self.conference.confId, @"password":@"", @"msg_extension":@{@"inviter":currentUser, @"group_id":@""}}];
    message.chatType = EMChatTypeChat;
    [[EMClient sharedClient].chatManager sendMessage:message progress:nil completion:nil];
    
//    NSMutableDictionary *ext = [[NSMutableDictionary alloc] init];
//    [ext setObject:[EMClient sharedClient].currentUsername forKey:@"creater"];
//    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:ext options:NSJSONWritingPrettyPrinted error:nil];
//    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//
//    EMError *error = nil;
//    __weak typeof(self) weakSelf = self;
//    [[EMClient sharedClient].conferenceManager inviteUserToJoinConference:self.conference userName:aUserName password:nil ext:jsonString error:&error];
//    if (error) {
//        [weakSelf showHint:NSLocalizedString(@"alert.conference.inviteFail", @"Invite failed!")];
//    } else {
//        [weakSelf showHint:NSLocalizedString(@"alert.conference.inviteSuccess", @"Invite successful!")];
//    }
}

- (void)_subStream:(EMCallStream *)aStream
{
    [self.streamIds addObject:aStream.streamId];
    EMConfUserView *userView = [self _setupUserViewWithUserName:aStream.userName streamId:aStream.streamId];
    userView.isMuted = !aStream.enableVoice;
    
    EMCallRemoteView *remoteView = nil;
    if (aStream.enableVideo) {
        remoteView = [[EMCallRemoteView alloc] initWithFrame:CGRectMake(0, 0, userView.videoView.frame.size.width, userView.videoView.frame.size.height)];
        remoteView.tag = 100;
        remoteView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        remoteView.scaleMode = EMCallViewScaleModeAspectFill;
        [userView.videoView addSubview:remoteView];
    }
    
    __weak typeof(self) weakSelf = self;
    [[EMClient sharedClient].conferenceManager subscribeConference:self.conference streamId:aStream.streamId remoteVideoView:remoteView completion:^(EMError *aError) {
        if (aError) {
            NSString *message = [NSString stringWithFormat:NSLocalizedString(@"alert.conference.subFail", @"Sub stream-%@ failed!"), aStream.userName];
            [weakSelf showHint:message];
        }
    }];
}

- (void)_removeStream:(EMCallStream *)aStream
{
    NSInteger index = [self.streamIds indexOfObject:aStream.streamId];
    EMConfUserView *userView = [self.streamViews objectForKey:aStream.streamId];
    [self.streamViews removeObjectForKey:aStream.streamId];

    CGRect frame = userView.frame;
    [userView removeFromSuperview];
    [self.streamIds removeObject:aStream.streamId];

    for (; index < [self.streamIds count]; index++) {
        NSString *sId = [self.streamIds objectAtIndex:index];
        UIView *view = [self.streamViews objectForKey:sId];
        CGRect tmpFrame = view.frame;
        view.frame = frame;
        frame = tmpFrame;
    }
}

- (void)_userViewDidConnectedWithStreamId:(NSString *)aStreamId
{
    EMConfUserView *userView = [self.streamViews objectForKey:aStreamId];
    if (userView) {
        userView.status = EMAudioStatusConnected;
    }
}

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
        EMCallStream *oldStream = [self.streamsDic objectForKey:aStream.streamId];
        if (oldStream) {
            if (oldStream.enableVideo != aStream.enableVideo) {
                EMConfUserView *userView = [self.streamViews objectForKey:aStream.streamId];
                EMCallRemoteView *displayView = [userView.videoView viewWithTag:100];
                if (displayView == nil && aStream.enableVideo) {
                    displayView = [[EMCallRemoteView alloc] initWithFrame:CGRectMake(0, 0, userView.videoView.frame.size.width, userView.videoView.frame.size.height)];
                    displayView.tag = 100;
                    displayView.scaleMode = EMCallViewScaleModeAspectFill;
                    [userView.videoView addSubview:displayView];
                    
                    [[EMClient sharedClient].conferenceManager updateConference:self.conference streamId:aStream.streamId remoteVideoView:displayView completion:nil];
                }
                displayView.hidden = !aStream.enableVideo;
            } else if (oldStream.enableVoice != aStream.enableVoice) {
                EMConfUserView *userView = [self.streamViews objectForKey:aStream.streamId];
                userView.isMuted = !aStream.enableVoice;
                if (aStream.enableVoice) {
                    userView.status = EMAudioStatusConnected;
                }
            }
            
            [self.streamsDic setObject:aStream forKey:aStream.streamId];
        }
    }
}

- (void)streamStartTransmitting:(EMCallConference *)aConference
                       streamId:(NSString *)aStreamId
{
    if ([aConference.callId isEqualToString:self.conference.callId]) {
        if ([aStreamId isEqualToString:self.pubStreamId]) {
            [self _userViewDidConnectedWithStreamId:aStreamId];
        } else if ([self.streamViews objectForKey:aStreamId]) {
            [self _userViewDidConnectedWithStreamId:aStreamId];
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

- (void)conferenceSpeakerDidChange:(EMCallConference *)aConference
                 speakingStreamIds:(NSArray *)aStreamIds
{
    if (![aConference.callId isEqualToString:self.conference.callId]) {
        return;
    }
    
    for (NSString *streamId in aStreamIds) {
        EMConfUserView *userView = [self.streamViews objectForKey:streamId];
        userView.status = EMAudioStatusTalking;
        
        [self.talkingStreamIds removeObject:streamId];
    }
    
    for (NSString *streamId in self.talkingStreamIds) {
        EMConfUserView *userView = [self.streamViews objectForKey:streamId];
        userView.status = EMAudioStatusConnected;
    }
    
    [self.talkingStreamIds removeAllObjects];
    [self.talkingStreamIds addObjectsFromArray:aStreamIds];
}

#pragma mark - EMConfUserViewDelegate

- (void)tapUserViewWithStreamId:(NSString *)aStreamId
{
    self.currentMaxStreamId = aStreamId;
    EMConfUserView *userView = [self.streamViews objectForKey:aStreamId];
    UIView *displayView = [userView.videoView viewWithTag:100];
    if (displayView) {
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        displayView.frame = CGRectMake(0, 0, window.bounds.size.width, window.bounds.size.height);
        [displayView addSubview:self.minButton];
        [displayView removeFromSuperview];
        [window addSubview:displayView];
    }
}

#pragma mark - action

- (IBAction)inviteMemberAction:(id)sender
{
    NSMutableArray *usernames = [[NSMutableArray alloc] initWithArray:[[EMClient sharedClient].contactManager getContacts]];
    NSArray *streams = [self.streamsDic allValues];
    for (EMCallStream *stream in streams) {
        if ([usernames containsObject:stream.userName]) {
            [usernames removeObject:stream.userName];
        }
    }
    
    __weak typeof(self) weakself = self;
    EMConfUserSelectionViewController *controller = [[EMConfUserSelectionViewController alloc] initWithDataSource:usernames selectedUsers:nil];
    [controller setGetContactsCompletion:^NSArray *{
        NSMutableArray *usernames = [[NSMutableArray alloc] initWithArray:[[EMClient sharedClient].contactManager getContacts]];
        if ([usernames count] == 0) {
            usernames = [[NSMutableArray alloc] initWithArray:[[EMClient sharedClient].contactManager getContactsFromServerWithError:nil]];
        }
        
        NSArray *streams = [self.streamsDic allValues];
        for (EMCallStream *stream in streams) {
            if ([usernames containsObject:stream.userName]) {
                [usernames removeObject:stream.userName];
            }
        }

        return usernames;
    }];
    
    [controller setSelecteUserFinishedCompletion:^(NSArray *selectedUsers) {
        for (NSString *userName in selectedUsers) {
            [weakself _inviteUser:userName];
        }
    }];
    
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)muteButtonAction:(id)sender
{
    self.muteButton.selected = !self.muteButton.selected;
    [[EMClient sharedClient].conferenceManager updateConference:self.conference isMute:self.muteButton.selected];
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

- (IBAction)enableCameraAction:(id)sender
{
    self.enableCameraButton.selected = !self.enableCameraButton.selected;
    self.switchCameraButton.hidden = !self.enableCameraButton.selected;
    
    [[EMClient sharedClient].conferenceManager updateConference:self.conference enableVideo:self.enableCameraButton.selected];
    
    if (self.enableCameraButton.selected) {
        NSString *key = self.pubStreamId;
        if ([key length] == 0) {
            key = [EMClient sharedClient].currentUsername;
        }
        EMConfUserView *userView = [self.streamViews objectForKey:key];
        [userView.videoView addSubview:self.localView];
        [userView.videoView sendSubviewToBack:self.localView];
    } else {
        [self.localView removeFromSuperview];
    }
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

- (void)minAction
{
    EMConfUserView *userView = [self.streamViews objectForKey:self.currentMaxStreamId];
    self.currentMaxStreamId = nil;
    
    UIView *displayView = self.minButton.superview;
    [self.minButton removeFromSuperview];
    displayView.frame = CGRectMake(0, 0, userView.videoView.frame.size.width, userView.videoView.frame.size.height);
    displayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [displayView removeFromSuperview];
    [userView.videoView addSubview:displayView];
}

- (IBAction)hangupAction:(id)sender
{
    //3.3.9 new 自定义视频数据
    [self closeVideoCamera];
    
    [[DemoCallManager sharedManager] setIsCalling:NO];
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:nil];
    [audioSession setActive:YES error:nil];
    
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
    
    [[EMClient sharedClient].conferenceManager stopMonitorSpeaker:self.conference];
    [[EMClient sharedClient].conferenceManager leaveConference:self.conference completion:nil];
    
    self.conference = nil;
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController popViewControllerAnimated:NO];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
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
