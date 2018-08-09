//
//  LiveViewController.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2018/7/24.
//  Copyright © 2018 XieYajie. All rights reserved.
//

#import "LiveViewController.h"

#import "DemoCallManager.h"
#import "EMConfUserSelectionViewController.h"

#define kMaxCol 2

@implementation LiveVideoItem

@end

@interface LiveViewController ()<EMConferenceManagerDelegate>

@property (nonatomic) BOOL isCreater;
@property (nonatomic, strong) NSString *confrId;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *admin;

@property (nonatomic) IBOutlet UIButton *inviteButton;
@property (nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic) IBOutlet UIView *buttonsView;
@property (nonatomic) IBOutlet UIButton *leaveButton;
@property (nonatomic) IBOutlet UIButton *talkerButton;
@property (nonatomic) IBOutlet UIButton *switchCameraButton;
@property (nonatomic) IBOutlet UIButton *muteButton;
@property (nonatomic) IBOutlet UIButton *outButton;
@property (nonatomic) IBOutlet UIButton *enableVideoButton;

@property (nonatomic, strong) EMCallConference *conference;
@property (nonatomic, strong) EMCallLocalView *localVideoView;
@property (nonatomic, strong) NSString *pubStreamId;
@property (nonatomic, strong) NSMutableArray *streams;

@property (nonatomic) float itemBorder;
@property (nonatomic) CGSize itemSize;

@end

@implementation LiveViewController

- (instancetype)init
{
    self = [super initWithNibName:@"LiveViewController" bundle:nil];
    if (self) {
        _isCreater = YES;
    }
    
    return self;
}

- (instancetype)initWithPassword:(NSString *)aPassword
{
    self = [super initWithNibName:@"LiveViewController" bundle:nil];
    if (self) {
        _isCreater = YES;
        _password = aPassword;
    }
    
    return self;
}

- (instancetype)initWithConfrId:(NSString *)aConfId
                       password:(NSString *)aPassword
                          admin:(NSString *)aAdmin
{
    self = [super initWithNibName:@"LiveViewController" bundle:nil];
    if (self) {
        _isCreater = NO;
        _confrId = aConfId;
        _password = aPassword;
        _admin = aAdmin;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self _initSubviews];
    
    self.itemBorder = 10;
    float width = ([[UIScreen mainScreen] bounds].size.width - self.itemBorder * (kMaxCol + 1)) / kMaxCol;
    self.itemSize = CGSizeMake(width, width);
    self.streams = [[NSMutableArray alloc] init];
    
    [[EMClient sharedClient].conferenceManager addDelegate:self delegateQueue:nil];
    if (self.isCreater) {
        [self _createConference];
    } else {
        [self _joinConference];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.navigationController.navigationBarHidden = NO;
}

- (EMCallLocalView *)localVideoView
{
    if (_localVideoView == nil) {
        _localVideoView = [[EMCallLocalView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.scrollView.frame))];
        _localVideoView.backgroundColor = [UIColor blackColor];
        _localVideoView.scaleMode = EMCallViewScaleModeAspectFill;
    }
    
    return _localVideoView;
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

- (void)roleDidChanged:(EMCallConference *)aConference
{
    __weak typeof(self) weakself = self;
    if (aConference.role == EMConferenceRoleSpeaker && [self.pubStreamId length] == 0) {
        [self _pubLocalStreamWithEnableVideo:YES completion:^(NSString *aPubStreamId) {
            weakself.talkerButton.selected = aConference.role == EMConferenceRoleSpeaker ? YES : NO;
            [weakself _addLocalVideoView];
        }];
    } else if (aConference.role == EMConferenceRoleAudience && [self.pubStreamId length] > 0) {
        
        self.pubStreamId = nil;
        self.talkerButton.selected = NO;
        self.muteButton.hidden = YES;
        self.enableVideoButton.hidden = YES;
        
        [self _removeStream:nil];
    }
}

- (CGRect)_getLastViewFrame
{
    NSInteger count = [self.streams count];
    
    CGRect frame;
    if (count == 1) {
        frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.scrollView.frame));
    } else {
        NSInteger col = (count - 1) % kMaxCol;
        NSInteger row = (count - 1) / kMaxCol;
        frame = CGRectMake(col * (self.itemSize.width + self.itemBorder) + self.itemBorder, row * (self.itemSize.height + self.itemBorder) + self.itemBorder, self.itemSize.width, self.itemSize.height);
        
        if (count == 2) {
            LiveVideoItem *item = [self.streams objectAtIndex:0];
            item.videoView.frame = CGRectMake(self.itemBorder, self.itemBorder, self.itemSize.width, self.itemSize.height);
        }
    }
    
    return frame;
}

- (void)_addLocalVideoView
{
    LiveVideoItem *item = [[LiveVideoItem alloc] init];
    item.videoView = self.localVideoView;
    [self.streams addObject:item];
    
    CGRect frame = [self _getLastViewFrame];
    if (CGRectGetMaxY(frame) > self.scrollView.contentSize.height) {
        self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, CGRectGetMaxY(frame));
    }
    self.localVideoView.frame = frame;
    [self.scrollView addSubview:self.localVideoView];
}

- (void)_addStream:(EMCallStream *)aStream
{
    LiveVideoItem *item = [[LiveVideoItem alloc] init];
    item.stream = aStream;
    [self.streams addObject:item];
    
    CGRect frame = [self _getLastViewFrame];
    if (CGRectGetMaxY(frame) > self.scrollView.contentSize.height) {
        self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, CGRectGetMaxY(frame));
    }
    
    EMCallRemoteView *remoteView = [[EMCallRemoteView alloc] initWithFrame:frame];
    remoteView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    remoteView.scaleMode = EMCallViewScaleModeAspectFill;
    item.videoView = remoteView;
    [self.scrollView addSubview:remoteView];
    
    if (!aStream.enableVideo) {
        [self _resetVideoOffViewWithSuperView:remoteView isHidden:aStream.enableVideo];
    }
    
    __weak typeof(self) weakSelf = self;
    [[EMClient sharedClient].conferenceManager subscribeConference:self.conference streamId:aStream.streamId remoteVideoView:remoteView completion:^(EMError *aError) {
        if (aError) {
            NSString *message = [NSString stringWithFormat:NSLocalizedString(@"alert.conference.subFail", @"Sub stream-%@ failed!"), aStream.userName];
            [weakSelf showHint:message];
            [weakSelf.streams removeObject:item];
        }
    }];
}

- (void)streamDidUpdate:(EMCallConference *)aConference
              addStream:(EMCallStream *)aStream
{
    if ([aConference.callId isEqualToString:self.conference.callId]) {
        [self _addStream:aStream];
    }
}

- (void)_removeStream:(EMCallStream *)aStream
{
    CGRect prevFrame;
    LiveVideoItem *removeItem = nil;
    for (NSInteger i = 0; i < [self.streams count]; i++) {
        LiveVideoItem *item = [self.streams objectAtIndex:i];
        if ([item.stream.streamId isEqualToString:aStream.streamId] || (aStream == nil && item.stream == nil)) {
            prevFrame = item.videoView.frame;
            [item.videoView removeFromSuperview];
            removeItem = item;
        } else if (removeItem) {
            CGRect frame = item.videoView.frame;
            item.videoView.frame = prevFrame;
            prevFrame = frame;
        }
    }
    
    if (removeItem) {
        [self.streams removeObject:removeItem];
    }
    
    if ([self.streams count] == 1) {
        LiveVideoItem *item = [self.streams objectAtIndex:0];
        item.videoView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.scrollView.frame));
        [self _resetVideoOffViewFrameWithSuperView:item.videoView];
    }
}

- (void)streamDidUpdate:(EMCallConference *)aConference
           removeStream:(EMCallStream *)aStream
{
    if ([aConference.callId isEqualToString:self.conference.callId]) {
        [self _removeStream:aStream];
    }
}

- (void)streamDidUpdate:(EMCallConference *)aConference
                 stream:(EMCallStream *)aStream
{
    if (![aConference.callId isEqualToString:self.conference.callId]) {
        return;
    }
    
    LiveVideoItem *updateItem = nil;
    for (NSInteger i = 0; i < [self.streams count]; i++) {
        LiveVideoItem *item = [self.streams objectAtIndex:i];
        if ([item.stream.streamId isEqualToString:aStream.streamId] || (aStream == nil && item.stream == nil)) {
            updateItem = item;
            break;
        }
    }
    
    if (updateItem.stream.enableVideo != aStream.enableVideo) {
        [self _resetVideoOffViewWithSuperView:updateItem.videoView isHidden:aStream.enableVideo];
    }
    updateItem.stream = aStream;
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

#pragma mark - Subviews

- (void)_initSubviews
{
    self.leaveButton.clipsToBounds = YES;
    self.leaveButton.layer.cornerRadius = 25;
    
    [self.talkerButton setImage:[UIImage imageNamed:@"confr_unlink"] forState:UIControlStateSelected];
    
    [self.muteButton setImage:[UIImage imageNamed:@"Button_Mute_active"] forState:UIControlStateSelected];
    [self.outButton setImage:[UIImage imageNamed:@"Button_Speaker_active"] forState:UIControlStateSelected];
    [self.enableVideoButton setImage:[UIImage imageNamed:@"conf_camera_on"] forState:UIControlStateSelected];
    [self.switchCameraButton setImage:[UIImage imageNamed:@"Button_Camera_active"] forState:UIControlStateSelected];
    
    if (self.isCreater) {
        [self.scrollView addSubview:self.localVideoView];
        self.enableVideoButton.selected = YES;
        self.switchCameraButton.hidden = NO;
    }
    
    if ([self.conversationId length] > 0) {
        self.inviteButton.hidden = YES;
    }
}

- (void)_reloadSubviews
{
    self.talkerButton.hidden = self.isCreater;
    if (self.conference.role == EMConferenceRoleAudience) {
        self.talkerButton.hidden = NO;
    }
}

- (void)_resetVideoOffViewFrameWithSuperView:(UIView *)aSuperView
{
    UIImageView *imgView = [aSuperView viewWithTag:100];
    imgView.frame = CGRectMake(0, 0, CGRectGetWidth(aSuperView.frame), CGRectGetHeight(aSuperView.frame));
    [imgView layoutIfNeeded];
}

- (void)_resetVideoOffViewWithSuperView:(UIView *)aSuperView
                               isHidden:(BOOL)aIsHidden
{
    if (!aSuperView) {
        return;
    }
    
    UIImageView *imgView = [aSuperView viewWithTag:100];
    if ((aIsHidden && !imgView)) {
        return;
    }
    
    imgView.frame = CGRectMake(0, 0, CGRectGetWidth(aSuperView.frame), CGRectGetHeight(aSuperView.frame));
    if (imgView && imgView.hidden == aIsHidden) {
        return;
    }
    
    if (imgView == nil) {
        imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(aSuperView.frame), CGRectGetHeight(aSuperView.frame))];
        imgView.tag = 100;
        imgView.image = [UIImage imageNamed:@"confr_video_off"];
        imgView.contentMode = UIViewContentModeScaleAspectFill;
        imgView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [aSuperView addSubview:imgView];
    }
    
    imgView.hidden = aIsHidden;
}

#pragma mark - Action

- (void)_createConference
{
    __weak typeof(self) weakself = self;
    void (^block)(EMCallConference *aCall, NSString *aPassword, EMError *aError) = ^(EMCallConference *aCall, NSString *aPassword, EMError *aError) {
        if (aError) {
            weakself.conference = nil;
            [weakself.navigationController popViewControllerAnimated:YES];
            [DemoCallManager sharedManager].isCalling = NO;
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"创建会议失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
            
            return ;
        }
        
        weakself.conference = aCall;
        weakself.password = aPassword;
        
        if (weakself.isCreater && [weakself.conversationId length] > 0) {
            NSString *currentUser = [EMClient sharedClient].currentUsername;
            EMTextMessageBody *textBody = [[EMTextMessageBody alloc] initWithText:[[NSString alloc] initWithFormat:@"%@ 邀请加入互动视频会议: %@", currentUser, weakself.conference.confId]];
            EMMessage *message = [[EMMessage alloc] initWithConversationID:weakself.conversationId from:currentUser to:self.conversationId body:textBody ext:@{@"em_conference_op":@"invite", @"em_conference_id":weakself.conference.confId, @"em_conference_password":weakself.password, @"em_conference_type":@(EMConferenceTypeLive)}];
            message.chatType = weakself.chatType;
            [[EMClient sharedClient].chatManager sendMessage:message progress:nil completion:nil];
            [weakself showHint:@"已在群中发送邀请消息"];
            
            [weakself _pubLocalStreamWithEnableVideo:YES completion:^(NSString *aPubStreamId) {
                LiveVideoItem *item = [[LiveVideoItem alloc] init];
                weakself.localVideoView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.scrollView.frame));
                item.videoView = weakself.localVideoView;
                [weakself.streams addObject:item];
            }];
        }
    };
    
    [[EMClient sharedClient].conferenceManager createAndJoinConferenceWithType:EMConferenceTypeLive password:self.password completion:block];
}

- (void)_joinConference
{
    __weak typeof(self) weakself = self;
    void (^block)(EMCallConference *aCall, EMError *aError) = ^(EMCallConference *aCall, EMError *aError) {
        if (aError) {
            weakself.conference = nil;
            [weakself.navigationController popViewControllerAnimated:YES];
            [DemoCallManager sharedManager].isCalling = NO;
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"进入互动视频会议失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
            
            return ;
        }
        
        weakself.conference = aCall;
        [weakself _reloadSubviews];
    };
    
    [[EMClient sharedClient].conferenceManager joinConferenceWithConfId:self.confrId password:self.password completion:block];
}

- (void)_inviteUser:(NSString *)aUserName
{
    NSString *currentUser = [EMClient sharedClient].currentUsername;
    EMTextMessageBody *textBody = [[EMTextMessageBody alloc] initWithText:[[NSString alloc] initWithFormat:@"%@ 邀请你加入互动视频会议: %@", currentUser, self.conference.confId]];
    EMMessage *message = [[EMMessage alloc] initWithConversationID:aUserName from:currentUser to:aUserName body:textBody ext:@{@"em_conference_op":@"invite", @"em_conference_id":self.conference.confId, @"em_conference_password":self.password, @"em_conference_type":@(EMConferenceTypeLive)}];
    message.chatType = EMChatTypeChat;
    [[EMClient sharedClient].chatManager sendMessage:message progress:nil completion:nil];
}

- (void)_pubLocalStreamWithEnableVideo:(BOOL)aEnableVideo
                            completion:(void (^)(NSString *aPubStreamId))aCompletionBlock
{
    EMStreamParam *pubConfig = [[EMStreamParam alloc] init];
    pubConfig.streamName = [EMClient sharedClient].currentUsername;
    pubConfig.enableVideo = aEnableVideo;
    pubConfig.localView = self.localVideoView;
    
    EMCallOptions *options = [[EMClient sharedClient].callManager getCallOptions];
    pubConfig.isFixedVideoResolution = options.isFixedVideoResolution;
    pubConfig.maxVideoKbps = (int)options.maxVideoKbps;
    pubConfig.maxAudioKbps = (int)options.maxAudioKbps;
    pubConfig.videoResolution = options.videoResolution;
    
    pubConfig.isBackCamera = [[[NSUserDefaults standardUserDefaults] objectForKey:@"em_IsUseBackCamera"] boolValue];
    
    if (!aEnableVideo) {
        [self _resetVideoOffViewWithSuperView:self.localVideoView isHidden:aEnableVideo];
    }
    
    __weak typeof(self) weakself = self;
    [[EMClient sharedClient].conferenceManager publishConference:self.conference streamParam:pubConfig completion:^(NSString *aPubStreamId, EMError *aError) {
        if (aError) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"上传本地视频流失败，请重试" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
        } else {
            weakself.pubStreamId = aPubStreamId;
            weakself.muteButton.hidden = NO;
            weakself.enableVideoButton.hidden = NO;
            weakself.enableVideoButton.selected = aEnableVideo;
            
            if (aCompletionBlock) {
                aCompletionBlock(aPubStreamId);
            }
        }
    }];
}

- (IBAction)inviteMemberAction:(id)sender
{
    if ([self.conversationId length] > 0) {
        return;
    }
    
    NSMutableArray *usernames = [[NSMutableArray alloc] initWithArray:[[EMClient sharedClient].contactManager getContacts]];
    for (LiveVideoItem *item in self.streams) {
        if ([usernames containsObject:item.stream.userName]) {
            [usernames removeObject:item.stream.userName];
        }
    }
    
    __weak typeof(self) weakself = self;
    EMConfUserSelectionViewController *controller = [[EMConfUserSelectionViewController alloc] initWithDataSource:usernames selectedUsers:nil];
    [controller setGetContactsCompletion:^NSArray *{
        NSMutableArray *usernames = [[NSMutableArray alloc] initWithArray:[[EMClient sharedClient].contactManager getContacts]];
        if ([usernames count] == 0) {
            usernames = [[NSMutableArray alloc] initWithArray:[[EMClient sharedClient].contactManager getContactsFromServerWithError:nil]];
        }
        
        for (LiveVideoItem *item in self.streams) {
            if ([usernames containsObject:item.stream.userName]) {
                [usernames removeObject:item.stream.userName];
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

- (IBAction)talkerAction:(id)sender
{
    if (!self.isCreater) {
        if (!self.talkerButton.selected && self.conference.role != EMConferenceRoleAudience && [self.pubStreamId length] == 0) {
            __weak typeof(self) weakself = self;
            [self _pubLocalStreamWithEnableVideo:NO completion:^(NSString *aPubStreamId) {
                weakself.talkerButton.selected = YES;
                [weakself _addLocalVideoView];
            }];
            
            return;
        }
        
        NSString *op = @"";
        NSString *msg = @"";
        NSString *currentUser = [EMClient sharedClient].currentUsername;
        if (!self.talkerButton.selected) {
            op = @"request_tobe_speaker";
            msg = [[NSString alloc] initWithFormat:@"%@ 申请成为互动视频会议'%@'的主播", currentUser, self.conference.confId];
        } else {
            op = @"request_tobe_audience";
            msg = [[NSString alloc] initWithFormat:@"%@ 申请下麦互动视频会议'%@'", currentUser, self.conference.confId];
            
            __weak typeof(self) weakself = self;
            [[EMClient sharedClient].conferenceManager unpublishConference:self.conference streamId:self.pubStreamId completion:^(EMError *aError) {
                weakself.pubStreamId = nil;
                weakself.talkerButton.selected = NO;
                weakself.muteButton.hidden = YES;
    
                [weakself _removeStream:nil];
            }];
        }
        
        NSString *applyUid = [[EMClient sharedClient].conferenceManager getMemberNameWithAppkey:[EMClient sharedClient].options.appkey username:currentUser];
        EMTextMessageBody *textBody = [[EMTextMessageBody alloc] initWithText:msg];
        EMMessage *message = [[EMMessage alloc] initWithConversationID:self.admin from:currentUser to:self.admin body:textBody ext:@{@"em_conference_id":self.conference.confId, @"em_conference_password":self.password, @"em_member_name":applyUid, @"em_conference_op":op}];
        message.chatType = EMChatTypeChat;
        [[EMClient sharedClient].chatManager sendMessage:message progress:nil completion:nil];
        
        [self showHint:@"已经向管理员发送申请信息"];
    }
}

- (IBAction)muteAction:(id)sender
{
    self.muteButton.selected = !self.muteButton.selected;
    [[EMClient sharedClient].conferenceManager updateConference:self.conference isMute:self.muteButton.selected];
}

- (IBAction)speakerOutAction:(id)sender
{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    if (self.outButton.selected) {
        [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:nil];
    }else {
        [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
    }
    [audioSession setActive:YES error:nil];
    self.outButton.selected = !self.outButton.selected;
}

- (IBAction)enableVideoAction:(id)sender
{
    self.enableVideoButton.selected = !self.enableVideoButton.selected;
    self.switchCameraButton.hidden = !self.enableVideoButton.selected;
    
    [[EMClient sharedClient].conferenceManager updateConference:self.conference enableVideo:self.enableVideoButton.selected];
    
    [self _resetVideoOffViewWithSuperView:self.localVideoView isHidden:self.enableVideoButton.selected];
}

- (IBAction)switchCameraAction:(id)sender
{
    self.switchCameraButton.selected = !self.switchCameraButton.selected;
    [[EMClient sharedClient].conferenceManager updateConferenceWithSwitchCamera:self.conference];
}

- (IBAction)leaveAction:(id)sender
{
    __weak typeof(self) weakself = self;
    if (self.isCreater) {
        [[EMClient sharedClient].conferenceManager destroyConferenceWithId:self.conference.confId completion:^(EMError *aError) {
            weakself.conference = nil;
            [weakself.navigationController popViewControllerAnimated:YES];
            [DemoCallManager sharedManager].isCalling = NO;
        }];
    } else {
        [[EMClient sharedClient].conferenceManager leaveConference:self.conference completion:^(EMError *aError) {
            weakself.conference = nil;
            [weakself.navigationController popViewControllerAnimated:YES];
            [DemoCallManager sharedManager].isCalling = NO;
        }];
    }
}

#pragma mark - Public

- (void)handleMessage:(EMMessage *)aMessage
{
    NSString *confrId = [aMessage.ext objectForKey:@"em_conference_id"];
    if (![confrId isEqualToString:self.conference.confId]) {
        return;
    }

    EMTextMessageBody *textBody = (EMTextMessageBody *)aMessage.body;
    NSString *text = textBody.text;
    
    NSString *op = [aMessage.ext objectForKey:@"em_conference_op"];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:text message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"同意" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *applyer = [aMessage.ext objectForKey:@"em_member_name"];
        if ([op isEqualToString:@"request_tobe_speaker"]) {
            [[EMClient sharedClient].conferenceManager changeMemberRoleWithConfId:self.conference.confId memberNames:@[applyer] role:EMConferenceRoleSpeaker completion:^(EMError *aError) {
                //
            }];
        } else if ([op isEqualToString:@"request_tobe_audience"]) {
            [[EMClient sharedClient].conferenceManager changeMemberRoleWithConfId:self.conference.confId memberNames:@[applyer] role:EMConferenceRoleAudience completion:^(EMError *aError) {
                //
            }];
        }
    }];
    
    if ([op isEqualToString:@"request_tobe_speaker"]) {
        [alertController addAction: [UIAlertAction actionWithTitle:@"忽略" style: UIAlertActionStyleCancel handler:nil]];
    }
    
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
