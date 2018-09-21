//
//  EMConferenceViewController.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2018/9/20.
//  Copyright © 2018 XieYajie. All rights reserved.
//

#import "EMConferenceViewController.h"

@interface EMConferenceViewController ()

@end

@implementation EMConferenceViewController

- (instancetype)initWithType:(EMConferenceType)aType
                    password:(NSString *)aPassword
                 inviteUsers:(NSArray *)aInviteUsers
{
    self = [super init];
    if (self) {
        _type = aType;
        _password = aPassword;
        _isCreater = YES;
        
        _inviteUsers = [[NSMutableArray alloc] initWithArray:aInviteUsers];
        _streamItemDict = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (instancetype)initWithJoinConfId:(NSString *)aConfId
                          password:(NSString *)aPassword
                              type:(EMConferenceType)aType
{
    self = [super init];
    if (self) {
        _joinConfId = aConfId;
        _password = aPassword;
        _type = aType;
        _isCreater = NO;
        
        _inviteUsers = [[NSMutableArray alloc] init];
        _streamItemDict = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.videoViewBorder = 10;
    float width = ([[UIScreen mainScreen] bounds].size.width - self.videoViewBorder) / kConferenceVideoMaxCol;
    self.videoViewSize = CGSizeMake(width, width);
    
    [self _setupConferenceControllerSubviews];
    if (!isHeadphone()) {
        [self speakerButtonAction];
    }
    
    self.isUseBackCamera = [[[NSUserDefaults standardUserDefaults] objectForKey:@"em_IsUseBackCamera"] boolValue];
    self.switchCameraButton.selected = self.isUseBackCamera;
    
    [[EMClient sharedClient].conferenceManager addDelegate:self delegateQueue:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    _conference = nil;
}

#pragma mark - Subviews

- (void)_setupConferenceControllerSubviews
{
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    CGFloat color = 51 / 255.0;
    self.view.backgroundColor = [UIColor colorWithRed:color green:color blue:color alpha:1.0];
    
    self.statusLabel.textColor = [UIColor whiteColor];
    self.statusLabel.text = self.type == EMConferenceTypeLive ? @"直播会议": @"多人会议";
    
    [self.hangupButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-40);
        make.width.height.equalTo(@60);
    }];
    
    CGFloat width = 80;
    CGFloat height = 50;
    CGFloat padding = ([UIScreen mainScreen].bounds.size.width - width * 4) / 5;
    EMButton *inviteButton = [[EMButton alloc] initWithTitle:@"邀请成员" target:self action:@selector(inviteButtonAction:)];
    [inviteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [inviteButton setImage:[UIImage imageNamed:@"invite_white"] forState:UIControlStateNormal];
    [self.view addSubview:inviteButton];
    [inviteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(padding);
        make.bottom.equalTo(self.hangupButton.mas_top).offset(-40);
    }];
    
    self.switchCameraButton = [[EMButton alloc] initWithTitle:@"切换摄像头" target:self action:@selector(switchCameraButtonAction:)];
    [self.switchCameraButton setTitle:@"禁用" forState:UIControlStateDisabled];
    [self.switchCameraButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.switchCameraButton setTitleColor:[UIColor grayColor] forState:UIControlStateSelected];
    [self.switchCameraButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    [self.switchCameraButton setImage:[UIImage imageNamed:@"switchCamera_white"] forState:UIControlStateNormal];
    [self.switchCameraButton setImage:[UIImage imageNamed:@"switchCamera_gray"] forState:UIControlStateSelected];
    [self.switchCameraButton setImage:[UIImage imageNamed:@"switchCamera_gray"] forState:UIControlStateDisabled];
    [self.view addSubview:self.switchCameraButton];
    [self.switchCameraButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(padding);
        make.bottom.equalTo(inviteButton.mas_top).offset(-20);
    }];
    
    [self.microphoneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.microphoneButton setTitleColor:[UIColor grayColor] forState:UIControlStateSelected];
    [self.microphoneButton setImage:[UIImage imageNamed:@"micphone_white"] forState:UIControlStateNormal];
    [self.microphoneButton setImage:[UIImage imageNamed:@"micphone_gray"] forState:UIControlStateSelected];
    [self.microphoneButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.switchCameraButton.mas_right).offset(padding);
        make.bottom.equalTo(self.switchCameraButton);
    }];
    
    self.videoButton = [[EMButton alloc] initWithTitle:@"视频" target:self action:@selector(videoButtonAction:)];
    [self.videoButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [self.videoButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.videoButton setImage:[UIImage imageNamed:@"video_gray"] forState:UIControlStateNormal];
    [self.videoButton setImage:[UIImage imageNamed:@"video_white"] forState:UIControlStateSelected];
    [self.view addSubview:self.videoButton];
    [self.videoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.microphoneButton.mas_right).offset(padding);
        make.bottom.equalTo(self.switchCameraButton);
    }];
    
    [self.speakerButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [self.speakerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.speakerButton setImage:[UIImage imageNamed:@"speaker_gray"] forState:UIControlStateNormal];
    [self.speakerButton setImage:[UIImage imageNamed:@"speaker_white"] forState:UIControlStateSelected];
    [self.speakerButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.videoButton.mas_right).offset(padding);
        make.bottom.equalTo(self.switchCameraButton);
    }];
    
    [@[inviteButton, self.switchCameraButton, self.microphoneButton, self.videoButton, self.speakerButton] mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(width);
        make.height.mas_equalTo(height);
    }];
    
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.backgroundColor = [UIColor redColor];
    [self.view addSubview:self.scrollView];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.top.equalTo(self.statusLabel.mas_bottom).offset(10);
        make.bottom.equalTo(self.switchCameraButton.mas_top).offset(-10);
    }];
}

#pragma mark - EMConferenceManagerDelegate

- (void)memberDidJoin:(EMCallConference *)aConference
               member:(EMCallMember *)aMember
{
    if ([aConference.callId isEqualToString: self.conference.callId]) {
        NSString *message = [NSString stringWithFormat:NSLocalizedString(@"hint.conference.userJoin", @"User %@ has been joined to the conference"), aMember.memberName];
        [self showHint:message];
    }
}

- (void)memberDidLeave:(EMCallConference *)aConference
                member:(EMCallMember *)aMember
{
    if ([aConference.callId isEqualToString:self.conference.callId]) {
        NSString *message = [NSString stringWithFormat:NSLocalizedString(@"hint.conference.userLeave", @"User %@ has been leaved from the conference"), aMember.memberName];
        [self showHint:message];
    }
}

- (void)streamDidUpdate:(EMCallConference *)aConference
              addStream:(EMCallStream *)aStream
{
    if ([aConference.callId isEqualToString:self.conference.callId]) {
//        [self _subStream:aStream];
    }
}

- (void)streamDidUpdate:(EMCallConference *)aConference
           removeStream:(EMCallStream *)aStream
{
    if ([aConference.callId isEqualToString:self.conference.callId]) {
//        [self.streamsDic removeObjectForKey:aStream.streamId];
//        [self _removeStream:aStream];
    }
}

- (void)conferenceDidEnd:(EMCallConference *)aConference
                  reason:(EMCallEndReason)aReason
                   error:(EMError *)aError
{
    if ([aConference.callId isEqualToString:self.conference.callId]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"alert.conference.closed", @"Conference has been closed") delegate:nil cancelButtonTitle:NSLocalizedString(@"sure", @"OK") otherButtonTitles:nil, nil];
        [alertView show];
        
        [self hangupAction];
    }
}

- (void)streamDidUpdate:(EMCallConference *)aConference
                 stream:(EMCallStream *)aStream
{
    if (![aConference.callId isEqualToString:self.conference.callId] || aStream == nil) {
        return;
    }
    
//    EMCallStream *oldStream = [self.streamsDic objectForKey:aStream.streamId];
//    if (oldStream) {
//        if (oldStream.enableVideo != aStream.enableVideo) {
//            EMConfUserView *userView = [self.streamViews objectForKey:aStream.streamId];
//            EMCallRemoteView *displayView = [userView.videoView viewWithTag:100];
//            if (displayView == nil && aStream.enableVideo) {
//                displayView = [[EMCallRemoteView alloc] initWithFrame:CGRectMake(0, 0, userView.videoView.frame.size.width, userView.videoView.frame.size.height)];
//                displayView.tag = 100;
//                displayView.scaleMode = EMCallViewScaleModeAspectFill;
//                [userView.videoView addSubview:displayView];
//
//                [[EMClient sharedClient].conferenceManager updateConference:self.conference streamId:aStream.streamId remoteVideoView:displayView completion:nil];
//            }
//            displayView.hidden = !aStream.enableVideo;
//        } else if (oldStream.enableVoice != aStream.enableVoice) {
//            EMConfUserView *userView = [self.streamViews objectForKey:aStream.streamId];
//            userView.isMuted = !aStream.enableVoice;
//            if (aStream.enableVoice) {
//                userView.status = EMAudioStatusConnected;
//            }
//        }
//
//        [self.streamsDic setObject:aStream forKey:aStream.streamId];
//    }
}

- (void)streamStartTransmitting:(EMCallConference *)aConference
                       streamId:(NSString *)aStreamId
{
    if ([aConference.callId isEqualToString:self.conference.callId]) {
//        if ([aStreamId isEqualToString:self.pubStreamId]) {
//            [self _userViewDidConnectedWithStreamId:aStreamId];
//        } else if ([self.streamViews objectForKey:aStreamId]) {
//            [self _userViewDidConnectedWithStreamId:aStreamId];
//        }
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
    
//    for (NSString *streamId in aStreamIds) {
//        EMConfUserView *userView = [self.streamViews objectForKey:streamId];
//        userView.status = EMAudioStatusTalking;
//
//        [self.talkingStreamIds removeObject:streamId];
//    }
//
//    for (NSString *streamId in self.talkingStreamIds) {
//        EMConfUserView *userView = [self.streamViews objectForKey:streamId];
//        userView.status = EMAudioStatusConnected;
//    }
//
//    [self.talkingStreamIds removeAllObjects];
//    [self.talkingStreamIds addObjectsFromArray:aStreamIds];
}

#pragma mark - Member

- (void)inviteUser:(NSString *)aUserName
{
    NSString *currentUser = [EMClient sharedClient].currentUsername;
    EMTextMessageBody *textBody = [[EMTextMessageBody alloc] initWithText:[[NSString alloc] initWithFormat:@"%@ 邀请你加入会议: %@", currentUser, self.conference.confId]];
    NSMutableDictionary *ext = [[NSMutableDictionary alloc] initWithDictionary:@{@"em_conference_op":@"invite",@"em_conference_id":self.conference.confId, @"em_conference_password":self.password, @"em_conference_type":@(self.type)}];
    //为了兼容旧版本
    if (self.type != EMConferenceTypeLive) {
        [ext setObject:self.conference.confId forKey:@"conferenceId"];
        [ext setObject:@{@"inviter":currentUser, @"group_id":@""} forKey:@"msg_extension"];
    }
    EMMessage *message = [[EMMessage alloc] initWithConversationID:aUserName from:currentUser to:aUserName body:textBody ext:ext];
    message.chatType = EMChatTypeChat;
    [[EMClient sharedClient].chatManager sendMessage:message progress:nil completion:nil];
}

#pragma mark - Action

- (void)microphoneButtonAction
{
    self.microphoneButton.selected = !self.microphoneButton.isSelected;
    [[EMClient sharedClient].conferenceManager updateConference:self.conference isMute:self.microphoneButton.selected];
}

- (void)inviteButtonAction:(EMButton *)aButton
{
    
}

- (void)switchCameraButtonAction:(EMButton *)aButton
{
    self.isUseBackCamera = !self.isUseBackCamera;
    aButton.selected = !aButton.selected;
    if (self.conference) {
        [[EMClient sharedClient].conferenceManager updateConferenceWithSwitchCamera:self.conference];
    }
}

- (void)videoButtonAction:(EMButton *)aButton
{
    aButton.selected = !aButton.isSelected;
    if (self.conference) {
        [[EMClient sharedClient].conferenceManager updateConference:self.conference enableVideo:aButton.selected];
    }
    
    //TODO: 更新View
}

- (void)minimizeAction
{
    
}

- (void)hangupAction
{
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    
    BOOL isDestroy = NO;
    if (self.type == EMConferenceTypeLive && self.isCreater) {
        isDestroy = YES;
    }
    [[DemoConfManager sharedManager] endConference:self.conference isDestroy:isDestroy];

    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
