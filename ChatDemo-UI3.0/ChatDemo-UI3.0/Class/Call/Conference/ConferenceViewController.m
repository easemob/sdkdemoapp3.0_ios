//
//  ConferenceViewController.m
//  IosDemo
//
//  Created by XieYajie on 4/26/16.
//  Copyright © 2016 dxstudio.com. All rights reserved.
//

#import "ConferenceViewController.h"

#import <Hyphenate/Hyphenate.h>

#import "DemoConfManager.h"
#import "EMConfUserSelectionViewController.h"

@implementation EMConfUserView

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [self addGestureRecognizer:tap];
}

- (void)tapAction:(UITapGestureRecognizer *)aTap
{
    if (aTap.state == UIGestureRecognizerStateEnded) {
        if (_delegate && [_delegate respondsToSelector:@selector(tapUserView:)]) {
            [_delegate tapUserView:self.nameLabel.text];
        }
    }
}

@end

@interface ConferenceViewController ()<EMConferenceManagerDelegate, EMConfUserViewDelegate>
{
    float _top;
    float _width;
    float _height;
    float _border;
    
    NSString *_callId;
    NSString *_conversationId;
    BOOL _isConnected;
    NSString *_creater;
    BOOL _isCreater;
}

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@property (weak, nonatomic) IBOutlet UIView *remotesView;

@property (weak, nonatomic) IBOutlet UIView *actionView;
@property (weak, nonatomic) IBOutlet UIButton *speakerOutButton;
@property (weak, nonatomic) IBOutlet UIButton *silenceButton;
@property (weak, nonatomic) IBOutlet UIButton *switchCameraButton;
@property (weak, nonatomic) IBOutlet UIButton *hangupButton;

@property (weak, nonatomic) IBOutlet UIView *voiceAddButton;
@property (weak, nonatomic) IBOutlet UIView *videoAddButton;

@property (strong, nonatomic) __block EMCallConference *conference;
@property (strong, nonatomic) NSMutableArray *memberNames;
@property (strong, nonatomic) EMCallLocalView *localView;
@property (strong, nonatomic) NSMutableDictionary *userViews;

@property (strong, nonatomic) UIButton *minButton;
@property (strong, nonatomic) NSString *currentMaxUserName;
@property (nonatomic) int timeLength;
@property (strong, nonatomic) NSTimer *timeTimer;

@property (strong, nonatomic) NSString *creater;

@end

@implementation ConferenceViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        _callId = nil;
        _isConnected = NO;
    }
    
    return self;
}

- (instancetype)initWithCallId:(NSString *)aCallId
                       creater:(NSString *)aCreater
                    otherUsers:(NSArray *)aOthers
                          type:(EMCallType)aType
                conversationId:(NSString *)aConversationId
{
    self = [super init];
    if (self) {
        _callId = aCallId;
        _type = aType;
        _isCreater = NO;
        _creater = aCreater;
        _conversationId = aConversationId;
        
        _userViews = [[NSMutableDictionary alloc] init];
        _memberNames = [[NSMutableArray alloc] init];
        [_memberNames addObject:[EMClient sharedClient].currentUsername];
        [_memberNames addObjectsFromArray:aOthers];
    }
    
    return self;
}

- (instancetype)initWithUsers:(NSArray *)aUserNams
                         type:(EMCallType)aType
               conversationId:(NSString *)aConversationId
{
    self = [super init];
    if (self) {
        _type = aType;
        _isCreater = YES;
        _creater = [EMClient sharedClient].currentUsername;
        _conversationId = aConversationId;

        _userViews = [[NSMutableDictionary alloc] init];
        _memberNames = [[NSMutableArray alloc] init];
        [_memberNames addObjectsFromArray:aUserNams];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationController.navigationBarHidden = YES;
    
    [self _setupSubviews];
    
//    [[EMClient sharedClient].conferenceManager setBuilder:self];
    [[EMClient sharedClient].conferenceManager addDelegate:self delegateQueue:nil];
    
    EMError *error = nil;
    EMCallLocalView *localView = nil;
    if (self.type == EMCallTypeVideo) {
        EMConfUserView *userView = [self.userViews objectForKey:[EMClient sharedClient].currentUsername];
        localView = (EMCallLocalView *)[userView.topView viewWithTag:100];
    }
    __weak typeof(self) weakSelf = self;
    void (^block)() = ^(EMError *aError){
        if (aError) {
            weakSelf.conference = nil;
            self.navigationController.navigationBarHidden = NO;
            [self.navigationController popViewControllerAnimated:NO];
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"创建会议失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
        } else {
            for (NSString *userName in weakSelf.memberNames) {
                [weakSelf _inviteUser:userName];
            }
            
            //订阅
            [weakSelf _subUserStream:weakSelf.creater];
            for (NSString *userName in self.memberNames) {
                [weakSelf _subUserStream:userName];
            }
        }
    };
    
    if (_isCreater) {
        EMCallPubConfig *pubConfig = [[EMCallPubConfig alloc] init];
        pubConfig.username = [EMClient sharedClient].currentUsername;
        pubConfig.enableVideo = self.type == EMCallTypeVideo ? YES : NO;
        [[EMClient sharedClient].conferenceManager createAndJoinConferencePassword:@"" pubConfig:pubConfig localVideoView:localView completion:^(EMCallConference *aCall, EMError *aError) {
            weakSelf.conference = aCall;
            block(aError);
        }];
    } else {
        self.conference = [[EMClient sharedClient].conferenceManager joinConferenceWithId:_callId password:@"" localVideoView:localView error:&error];
    }
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
//    [[EMClient sharedClient].conferenceManager setBuilder:nil];
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
    if (_isConnected == NO) {
        self.statusLabel.text = @"正在连接...";
    }
    
    [self.silenceButton setImage:[UIImage imageNamed:@"Button_Mute active"] forState:UIControlStateSelected];
    
    CGSize boundSize = [[UIScreen mainScreen] bounds].size;
    int maxHeight = 0;
    _top = 0;
    if (self.type == EMCallTypeVoice) {
        [self.speakerOutButton setImage:[UIImage imageNamed:@"Button_Speaker active"] forState:UIControlStateSelected];
        
        _border = 20;
        maxHeight = (self.remotesView.frame.size.height - _border) / 2;
        _width = (boundSize.width - _border * 4) / 3;
        _height = MIN(_width, maxHeight);
        _width = _height;
        
        [self _setupUserVoiceView:_creater];
        for (NSString *userName in self.memberNames) {
            [self _setupUserVoiceView:userName];
        }
        
        [self _layoutVoiceAddButton];
    } else if (self.type == EMCallTypeVideo) {
        [self.switchCameraButton setImage:[UIImage imageNamed:@"Button_Camera switch active"] forState:UIControlStateSelected];
        self.speakerOutButton.hidden = YES;
        self.switchCameraButton.hidden = NO;
        
        self.view.backgroundColor = [UIColor colorWithRed:33 / 255.0 green:41 / 255.0 blue:48 / 255.0 alpha:1.0];
        self.videoAddButton.layer.borderWidth = 1;
        self.voiceAddButton.layer.borderColor = [UIColor grayColor].CGColor;
        
        
        _border = 5;
        maxHeight = (self.remotesView.frame.size.height - 5) / 2;
        _width = (boundSize.width - _border * 2) / 3;
        _height = MIN(_width, maxHeight);
        _width = _height;
        
        [self _setupUserVideoView:_creater];
        for (NSString *userName in self.memberNames) {
            [self _setupUserVideoView:userName];
        }
        [self _layoutVideoAddButton];
    }
}

- (EMConfUserView *)_setupUserVoiceView:(NSString *)aUserName
{
    int count = (int )[self.userViews count] + 1;
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
    
    userView.frame = CGRectMake(ox, oy, _width, _height);
    userView.nameLabel.text = aUserName;
    
    [self.remotesView addSubview:userView];
    [self.userViews setObject:userView forKey:aUserName];
    
    return userView;
}

- (void)_layoutVoiceAddButton
{
    if (!_isCreater) {
        return;
    }
    
    if ([self.userViews count] == 6) {
        self.voiceAddButton.hidden = YES;
        [self.voiceAddButton removeFromSuperview];
    } else {
        int count = (int )[self.userViews count] + 1;
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
            [self.remotesView addSubview:self.voiceAddButton];
            self.voiceAddButton.hidden = NO;
        }
    }
}

- (EMConfUserView *)_setupUserVideoView:(NSString *)aUserName
{
    int count = (int )[self.userViews count] + 1;
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
    userView.delegate = self;
    userView.frame = CGRectMake(ox, oy, _width, _height);
    userView.nameLabel.text = aUserName;
    
    [self.remotesView addSubview:userView];
    [self.userViews setObject:userView forKey:aUserName];
    
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
    
    if ([self.userViews count] == 6) {
        self.videoAddButton.hidden = YES;
        [self.videoAddButton removeFromSuperview];
    } else {
        int count = (int )[self.userViews count] + 1;
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
            [self.remotesView addSubview:self.videoAddButton];
            self.videoAddButton.hidden = NO;
        }
    }
}

- (void)_removeUser:(NSString *)aUserName
{
    UIView *userView = [self.userViews objectForKey:aUserName];
    [self.userViews removeObjectForKey:aUserName];
    
    NSInteger index = [self.memberNames indexOfObject:aUserName];
    [self.memberNames removeObject:aUserName];
    
    CGRect frame = userView.frame;
    [userView removeFromSuperview];
    
    for (; index < [self.memberNames count]; index++) {
        NSString *name = [self.memberNames objectAtIndex:index];
        UIView *view = [self.userViews objectForKey:name];
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

#pragma mark - private EMConferenceManager

- (void)_inviteUser:(NSString *)aUserName
{
    NSMutableDictionary *ext = [[NSMutableDictionary alloc] init];
    [ext setObject:[EMClient sharedClient].currentUsername forKey:@"creater"];
    [ext setObject:[NSNumber numberWithInteger:self.type] forKey:@"type"];
    NSMutableArray *members = [[NSMutableArray alloc] init];
    [members addObjectsFromArray:self.memberNames];
    [members removeObject:[EMClient sharedClient].currentUsername];
    [members removeObject:aUserName];
    [ext setObject:members forKey:@"others"];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:ext options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    EMError *error = nil;
    [[EMClient sharedClient].conferenceManager inviteUserToJoinConference:self.conference.callId userName:aUserName ext:jsonString error:&error];
    if (error) {
        [self showHint:@"邀请发送失败，请重新发送"];
    }
    else {
        [self showHint:@"邀请发送成功"];
    }
}

- (void)_subUserStream:(NSString *)aUserName
{
    EMCallRemoteView *remoteView = nil;
    if (self.type == EMCallTypeVideo) {
        EMConfUserView *userView = [self.userViews objectForKey:aUserName];
        remoteView = (EMCallRemoteView *)[userView.topView viewWithTag:100];
    }
    
//    EMCallStream *stream = [self.conference getSubscribableStreamForUserName:aUserName];
//    if (stream) {
//        EMError *error = nil;
//        [[EMClient sharedClient].conferenceManager subscribeConferenceStream:self.conference.callId stream:stream remoteVideoView:remoteView error:&error];
//        if (error) {
//            NSString *message = [NSString stringWithFormat:@"订阅 %@ 失败", _creater];
//            [self showHint:message];
//        }
//    }
}

#pragma mark - private timer

- (void)_timeTimerAction:(id)sender
{
    self.timeLength += 1;
    int hour = self.timeLength / 3600;
    int m = (self.timeLength - hour * 3600) / 60;
    int s = self.timeLength - hour * 3600 - m * 60;
    
    if (hour > 0) {
        self.statusLabel.text = [NSString stringWithFormat:@"%i:%i:%i", hour, m, s];
    }
    else if(m > 0){
        self.statusLabel.text = [NSString stringWithFormat:@"%i:%i", m, s];
    }
    else{
        self.statusLabel.text = [NSString stringWithFormat:@"00:%i", s];
    }
}

- (void)_startTimeTimer
{
    self.timeLength = 0;
    self.timeTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(_timeTimerAction:) userInfo:nil repeats:YES];
}

- (void)_stopTimeTimer
{
    if (self.timeTimer) {
        [self.timeTimer invalidate];
        self.timeTimer = nil;
    }
}

#pragma mark - EMConferenceBuilderDelegate

- (EMCallRemoteView *)mutilConference:(EMCallConference *)aConference
                     videoViewForUser:(NSString *)aUserName
{
    if (![aConference.callId isEqualToString:self.conference.callId]) {
        return nil;
    }
    
    EMConfUserView *userView = [self.userViews objectForKey:aUserName];
    if (!userView) {
        return nil;
    }
    
    UIView *view = [userView.topView viewWithTag:100];
    if ([view isKindOfClass:[EMCallRemoteView class]]) {
        return (EMCallRemoteView *)view;
    } else {
        return nil;
    }
}

#pragma mark - EMConferenceManagerDelegate

- (void)userDidJoinConference:(EMCallConference *)aConference
                         user:(EMCallMember *)aMember
{
    if ([aConference.callId isEqualToString: self.conference.callId]) {
        NSString *username = aMember.username;
        NSString *message = [NSString stringWithFormat:@"%@ 已加入会议", username];
        [self showHint:message];
        
        if (![self.memberNames containsObject:username]) {
            [self.memberNames addObject:username];
            if (self.type == EMCallTypeVoice) {
                [self _setupUserVoiceView:username];
                [self _layoutVoiceAddButton];
            } else {
                [self _setupUserVideoView:username];
                [self _layoutVideoAddButton];
            }
        }
    }
}

- (void)userDidLeaveConference:(EMCallConference *)aConference
                          user:(EMCallMember *)aMember
{
    if ([aConference.callId isEqualToString:self.conference.callId]) {
        NSString *username = aMember.username;
        NSString *message = [NSString stringWithFormat:@"%@ 已退出会议", username];
        [self showHint:message];
        
        [self _removeUser:username];
    }
}

- (void)userDidPubConferenceStream:(EMCallConference *)aConference
                              user:(EMCallMember *)aMember
{
    if ([aConference.callId isEqualToString:self.conference.callId]) {
        NSString *username = aMember.username;
        NSString *message = [NSString stringWithFormat:@"%@ 已上传数据流", username];
        [self showHint:message];
        
        [self _subUserStream:username];
    }
}

- (void)conferenceMembersDidUpdate:(EMCallConference *)aConference
{
    if ([aConference.callId isEqualToString:self.conference.callId]) {
        [self showHint:@"会议成员已更新"];
    }
}

- (void)conferenceDidEnd:(EMCallConference *)aConference
                  reason:(EMCallEndReason)aReason
                   error:(EMError *)aError
{
    if ([aConference.callId isEqualToString:self.conference.callId]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"会议通知" message:@"会议已关闭" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }
    
    self.conference = nil;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)conferenceStreamBeginTransmite:(EMCallConference *)aConference
                                stream:(EMCallStream *)aStream
{
//    if ([aConference.callId isEqualToString:self.conference.callId]) {
//        NSString *userName = aStream.userName;
//        if ([userName length] == 0) {
//            return;
//        }
//        
//        if (!_isConnected) {
//            [self _startTimeTimer];
//        }
//        
//        EMConfUserView *userView = [self.userViews objectForKey:userName];
//        if (userView) {
//            userView.statusImgView.image = [UIImage imageNamed:@"conf_connected"];
//            if (self.type == EMCallTypeVideo) {
//                [userView.imgView removeFromSuperview];
//            }
//        }
//    }
}

#pragma mark - EMConfUserViewDelegate

- (void)tapUserView:(NSString *)aUserName
{
    self.currentMaxUserName = aUserName;
    EMConfUserView *userView = [self.userViews objectForKey:aUserName];
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
    NSArray *contacts = [[EMClient sharedClient].contactManager getContacts];
    NSMutableArray *usernames = [[NSMutableArray alloc] init];
    for (NSString *username in contacts) {
        if (![self.memberNames containsObject:username]) {
            [usernames addObject:username];
        }
    }
    
    NSMutableArray *selectedUsers = [[NSMutableArray alloc] init];
    [selectedUsers addObject:[EMClient sharedClient].currentUsername];
    [selectedUsers addObjectsFromArray:self.memberNames];
    EMConfUserSelectionViewController *controller = [[EMConfUserSelectionViewController alloc] initWithDataSource:usernames selectedUsers:selectedUsers];
    [controller setSelecteUserFinishedCompletion:^(NSArray *selectedUsers) {
        [self.memberNames addObjectsFromArray:selectedUsers];
        
        for (NSString *userName in selectedUsers) {
            [self _setupUserVoiceView:userName];
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
//    [self.conference switchCameraPosition:self.switchCameraButton.selected];
//    self.switchCameraButton.selected = !self.switchCameraButton.selected;
}

- (IBAction)silenceAction:(id)sender
{
//    self.silenceButton.selected = !self.silenceButton.selected;
//    if (self.silenceButton.selected) {
//        [self.conference pauseLocalVoice];
//    } else {
//        [self.conference resumeLocalVoice];
//    }
}

- (void)minAction
{
    EMConfUserView *userView = [self.userViews objectForKey:self.currentMaxUserName];
    self.currentMaxUserName = nil;
    
    UIView *displayView = self.minButton.superview;
    [self.minButton removeFromSuperview];
    displayView.frame = CGRectMake(0, 0, userView.topView.frame.size.width, userView.topView.frame.size.height);
    displayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [displayView removeFromSuperview];
    [userView.topView addSubview:displayView];
}

- (IBAction)hangupAction:(id)sender
{
    if (!self.conference) {
        self.navigationController.navigationBarHidden = NO;
        [self.navigationController popViewControllerAnimated:NO];
        return;
    }
    
    if (_isCreater) {
        [[EMClient sharedClient].conferenceManager destroyConferenceWithId:self.conference.callId error:nil];
        
        NSString *localName = [EMClient sharedClient].currentUsername;
        EMTextMessageBody *body = [[EMTextMessageBody alloc] initWithText:[NSString stringWithFormat:@"%@ 结束了多人会议", localName]];
        EMMessage *message = [[EMMessage alloc] initWithConversationID:_conversationId from:localName to:_conversationId body:body ext:nil];
        message.chatType = EMChatTypeGroupChat;
        [[EMClient sharedClient].chatManager sendMessage:message progress:nil completion:nil];
        
    } else {
        [[EMClient sharedClient].conferenceManager leaveConferenceWithId:self.conference.callId error:nil];
    }
    
    self.conference = nil;
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController popViewControllerAnimated:NO];
}

@end
