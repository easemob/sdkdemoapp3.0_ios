//
//  EMConferenceViewController.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2018/9/20.
//  Copyright © 2018 XieYajie. All rights reserved.
//

#import "EMConferenceViewController.h"

@interface EMConferenceViewController ()

@property (nonatomic, strong) UIButton *gridButton;
@property (nonatomic, strong) EMStreamView *currentBigView;

@end

@implementation EMConferenceViewController

- (instancetype)initWithType:(EMConferenceType)aType
                    password:(NSString *)aPassword
                 inviteUsers:(NSArray *)aInviteUsers
                      chatId:(NSString *)aChatId
                    chatType:(EMChatType)aChatType
{
    self = [super init];
    if (self) {
        _isCreater = YES;
        _type = aType;
        _password = aPassword;
        _chatId = aChatId;
        _chatType = aChatType;
        
        _inviteUsers = [[NSMutableArray alloc] initWithArray:aInviteUsers];
    }
    
    return self;
}

- (instancetype)initWithJoinConfId:(NSString *)aConfId
                          password:(NSString *)aPassword
                              type:(EMConferenceType)aType
                            chatId:(NSString *)aChatId
                          chatType:(EMChatType)aChatType
{
    self = [super init];
    if (self) {
        _isCreater = NO;
        _joinConfId = aConfId;
        _password = aPassword;
        _type = aType;
        _chatId = aChatId;
        _chatType = aChatType;
        
        _inviteType = ConfInviteTypeUser;
        if (aChatType == EMChatTypeGroupChat) {
            _inviteType = ConfInviteTypeGroup;
        } else if (aChatType == EMChatTypeChatRoom) {
            _inviteType = ConfInviteTypeChatroom;
        }
        
        _inviteUsers = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self _initializeConferenceController];
    [self _setupConferenceControllerSubviews];
    
    if (!isHeadphone()) {
        [self speakerButtonAction];
    }
    
    //本地摄像头方向
    self.isUseBackCamera = [[[NSUserDefaults standardUserDefaults] objectForKey:@"em_IsUseBackCamera"] boolValue];
    self.switchCameraButton.selected = self.isUseBackCamera;
    
    //多人实时音视频默认使用扬声器
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
    [audioSession setActive:YES error:nil];
    
    //注册SDK回调监听
    [[EMClient sharedClient].conferenceManager addDelegate:self delegateQueue:nil];
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

- (void)dealloc
{
    _conference = nil;
}

#pragma mark - Subviews

- (void)_initializeConferenceController
{
    self.streamIds = [[NSMutableArray alloc] init];
    _streamItemDict = [[NSMutableDictionary alloc] init];
    _talkingStreamIds = [[NSMutableArray alloc] init];
    
    self.videoViewBorder = 0;
    float width = ([[UIScreen mainScreen] bounds].size.width - self.videoViewBorder) / kConferenceVideoMaxCol;
    self.videoViewSize = CGSizeMake(width, width);
}

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
    
    self.gridButton = [[UIButton alloc] init];
    self.gridButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.gridButton setImage:[UIImage imageNamed:@"grid_white"] forState:UIControlStateNormal];
    [self.gridButton addTarget:self action:@selector(gridAction) forControlEvents:UIControlEventTouchUpInside];
    self.gridButton.hidden = YES;
    [self.view addSubview:self.gridButton];
    [self.gridButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(-30);
        make.left.equalTo(self.view).offset(25);
        make.width.height.equalTo(@40);
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
        [self _subStream:aStream];
    }
}

- (void)streamDidUpdate:(EMCallConference *)aConference
           removeStream:(EMCallStream *)aStream
{
    if ([aConference.callId isEqualToString:self.conference.callId]) {
        [self _removeStream:aStream];
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
    
    EMStreamItem *videoItem = [self.streamItemDict objectForKey:aStream.streamId];
    if (!videoItem.stream) {
        return;
    }
    
    if (videoItem.stream.enableVideo != aStream.enableVideo) {
        videoItem.videoView.enableVideo = aStream.enableVideo;
    }
    
    if (videoItem.stream.enableVoice != aStream.enableVoice) {
        videoItem.videoView.enableVoice = aStream.enableVoice;
    }
    
    videoItem.stream = aStream;
}

- (void)streamStartTransmitting:(EMCallConference *)aConference
                       streamId:(NSString *)aStreamId
{
    if ([aConference.callId isEqualToString:self.conference.callId]) {
        EMStreamItem *videoItem = [self.streamItemDict objectForKey:aStreamId];
        if (videoItem && videoItem.videoView) {
            videoItem.videoView.status = StreamStatusConnected;
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
        EMStreamItem *videoItem = [self.streamItemDict objectForKey:streamId];
        if (videoItem && videoItem.videoView) {
            videoItem.videoView.status = StreamStatusTalking;
        }
        
        [self.talkingStreamIds removeObject:streamId];
    }
    
    for (NSString *streamId in self.talkingStreamIds) {
        EMStreamItem *videoItem = [self.streamItemDict objectForKey:streamId];
        if (videoItem && videoItem.videoView) {
            videoItem.videoView.status = StreamStatusNormal;
        }
    }
    
    [self.talkingStreamIds removeAllObjects];
    [self.talkingStreamIds addObjectsFromArray:aStreamIds];
}

#pragma mark - EMStreamViewDelegate

- (void)streamViewDidTap:(EMStreamView *)aVideoView
{
    if (!aVideoView.enableVideo) {
        return;
    }
    
    BOOL isFullscreen = [aVideoView.ext boolValue];
    aVideoView.ext = @(!isFullscreen);
    self.gridButton.hidden = isFullscreen;
    [aVideoView.displayView removeFromSuperview];
    if (!isFullscreen) {
        self.currentBigView = aVideoView;
        [self.view addSubview:aVideoView.displayView];
        [self.view sendSubviewToBack:aVideoView.displayView];
        [self.view sendSubviewToBack:self.scrollView];
        [aVideoView.displayView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    } else {
        [aVideoView addSubview:aVideoView.displayView];
        [aVideoView.displayView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(aVideoView);
        }];
        self.currentBigView = nil;
    }
}

#pragma mark - Video Views

- (CGRect)getNewVideoViewFrame
{
    NSInteger count = [self.streamItemDict count];
    
    NSInteger row = count / kConferenceVideoMaxCol;
    NSInteger col = count % kConferenceVideoMaxCol;
    CGRect frame = CGRectMake(col * (self.videoViewSize.width + self.videoViewBorder), row * (self.videoViewSize.height + self.videoViewBorder), self.videoViewSize.width, self.videoViewSize.height);
    
    return frame;
}

- (EMStreamItem *)setupNewStreamItemWithName:(NSString *)aName
                                 displayView:(UIView *)aDisplayView
                                      stream:(EMCallStream *)aStream
{
    CGRect frame = [self getNewVideoViewFrame];
    EMStreamView *videoView = [[EMStreamView alloc] initWithFrame:frame];
    videoView.delegate = self;
    videoView.nameLabel.text = aName;
    videoView.displayView = aDisplayView;
    [videoView addSubview:aDisplayView];
    [videoView sendSubviewToBack:aDisplayView];
    [aDisplayView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(videoView);
    }];
    [self.scrollView addSubview:videoView];
    
    if (CGRectGetMaxY(frame) > self.scrollView.contentSize.height) {
        self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, CGRectGetMaxY(frame));
    }
    
    EMStreamItem *retItem = [[EMStreamItem alloc] init];
    retItem.videoView = videoView;
    retItem.stream = aStream;
    if ([aStream.streamId length] > 0) {
        [self.streamItemDict setObject:retItem forKey:aStream.streamId];
        [self.streamIds addObject:aStream.streamId];
    }
    
    return retItem;
}

#pragma mark - Stream

- (void)pubLocalStreamWithEnableVideo:(BOOL)aEnableVideo
                           completion:(void (^)(NSString *aPubStreamId, EMError *aError))aCompletionBlock
{
    //上传流的过程中，不允许操作视频按钮
    self.videoButton.enabled = NO;
    self.switchCameraButton.enabled = NO;
    
    EMStreamParam *pubConfig = [[EMStreamParam alloc] init];
    pubConfig.streamName = [EMClient sharedClient].currentUsername;
    pubConfig.enableVideo = aEnableVideo;
    
    EMCallOptions *options = [[EMClient sharedClient].callManager getCallOptions];
    pubConfig.isFixedVideoResolution = options.isFixedVideoResolution;
    pubConfig.maxVideoKbps = (int)options.maxVideoKbps;
    pubConfig.maxAudioKbps = (int)options.maxAudioKbps;
    pubConfig.videoResolution = options.videoResolution;
    
    pubConfig.isBackCamera = self.switchCameraButton.isSelected;
    
    EMCallLocalView *localView = [[EMCallLocalView alloc] init];
    localView.scaleMode = EMCallViewScaleModeAspectFill;
    pubConfig.localView = localView;
    
    __weak typeof(self) weakself = self;
    [[EMClient sharedClient].conferenceManager publishConference:self.conference streamParam:pubConfig completion:^(NSString *aPubStreamId, EMError *aError) {
        if (aError) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"上传本地视频流失败，请重试" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
            
            if (aCompletionBlock) {
                aCompletionBlock(nil, aError);
            }
            
            return ;
            
            //TODO: 后续处理是怎么样的
        }
        
        weakself.videoButton.enabled = YES;
        weakself.videoButton.selected = aEnableVideo;
        weakself.switchCameraButton.enabled = aEnableVideo;
        
        weakself.pubStreamId = aPubStreamId;
        
        EMStreamItem *videoItem = [self setupNewStreamItemWithName:pubConfig.streamName displayView:localView stream:nil];
        videoItem.videoView.enableVideo = aEnableVideo;
        [weakself.streamItemDict setObject:videoItem forKey:aPubStreamId];
        [weakself.streamIds addObject:aPubStreamId];
        
        if (aCompletionBlock) {
            aCompletionBlock(aPubStreamId, nil);
        }
    }];
}

- (void)_subStream:(EMCallStream *)aStream
{
    EMCallRemoteView *remoteView = [[EMCallRemoteView alloc] init];
    remoteView.scaleMode = EMCallViewScaleModeAspectFill;
    EMStreamItem *videoItem = [self setupNewStreamItemWithName:aStream.userName displayView:remoteView stream:aStream];
    videoItem.videoView.enableVideo = aStream.enableVideo;
    
    __weak typeof(self) weakSelf = self;
    [[EMClient sharedClient].conferenceManager subscribeConference:self.conference streamId:aStream.streamId remoteVideoView:remoteView completion:^(EMError *aError) {
        if (aError) {
            NSString *message = [NSString stringWithFormat:NSLocalizedString(@"alert.conference.subFail", @"Sub stream-%@ failed!"), aStream.userName];
            [weakSelf showHint:message];
            [weakSelf.streamItemDict removeObjectForKey:aStream.streamId];
            return ;
        }
        
        videoItem.videoView.enableVoice = aStream.enableVoice;
    }];
}

- (void)_removeStream:(EMCallStream *)aStream
{
    NSInteger index = [self.streamIds indexOfObject:aStream.streamId];
    [self.streamIds removeObjectAtIndex:index];
    
    EMStreamItem *removeItem = [self.streamItemDict objectForKey:aStream.streamId];
    CGRect prevFrame = removeItem.videoView.frame;
    [removeItem.videoView removeFromSuperview];
    [self.streamItemDict removeObjectForKey:aStream.streamId];
    
    for (NSInteger i = index; i < [self.streamIds count]; i++) {
        NSString *streamId = [self.streamIds objectAtIndex:i];
        EMStreamItem *item = [self.streamItemDict objectForKey:streamId];
        CGRect frame = item.videoView.frame;
        item.videoView.frame = prevFrame;
        prevFrame = frame;
    }
}

#pragma mark - Member

- (void)sendInviteMessageWithConversationId:(NSString *)aConversationId
                                   chatType:(EMChatType)aChatType
{
    NSString *tmpStr = self.type == EMConferenceTypeLive ? @"邀请你加入互动会议" : @"邀请你加入会议";
    NSString *currentUser = [EMClient sharedClient].currentUsername;
    EMTextMessageBody *textBody = [[EMTextMessageBody alloc] initWithText:[[NSString alloc] initWithFormat:@"%@ %@: %@", currentUser, tmpStr, self.conference.confId]];
    NSMutableDictionary *ext = [[NSMutableDictionary alloc] initWithDictionary:@{@"em_conference_op":@"invite",@"em_conference_id":self.conference.confId, @"em_conference_password":self.password, @"em_conference_type":@(self.type)}];
    //为了兼容旧版本
    if (self.type != EMConferenceTypeLive) {
        [ext setObject:self.conference.confId forKey:@"conferenceId"];
        [ext setObject:@{@"inviter":currentUser, @"group_id":@""} forKey:@"msg_extension"];
    }
    //添加会话相关属性
    if ([self.chatId length] > 0) {
        [ext setObject:self.chatId forKey:@"em_conference_chatId"];
        [ext setObject:@(self.chatType) forKey:@"em_conference_chatType"];
    }
    
    EMMessage *message = [[EMMessage alloc] initWithConversationID:aConversationId from:currentUser to:aConversationId body:textBody ext:ext];
    message.chatType = aChatType;
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

- (void)gridAction
{
    if (self.currentBigView) {
        [self streamViewDidTap:self.currentBigView];
        
//        EMStreamView *videoView = self.currentBigView;
//        self.currentBigView = nil;
//        [videoView addSubview:videoView.displayView];
//        [videoView.displayView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.edges.equalTo(videoView);
//        }];
    }
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