//
//  ConferenceViewController.m
//  IosDemo
//
//  Created by XieYajie on 4/26/16.
//  Copyright © 2016 dxstudio.com. All rights reserved.
//

#import "ConferenceViewController.h"

#import "EMClient+Conference.h"
#import "IEMConferenceManager.h"

#import "DemoConfManager.h"
#import "StreamTableViewController.h"
#import "EMConfUserSelectionViewController.h"

@implementation EMConfUserVoiceView

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

@end

@interface ConferenceViewController ()<EMConferenceManagerDelegate, EMConferenceBuilderDelegate, StreamTableViewControllerDelegate>
{
    float _top;
    float _width;
    float _height;
    float _border;
    
    BOOL _isConnected;
    NSString *_callId;
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

@property (strong, nonatomic) EMCallConference *conference;
@property (strong, nonatomic) NSMutableArray *memberNames;
@property (strong, nonatomic) EMCallLocalView *localView;
@property (strong, nonatomic) NSMutableDictionary *userViews;

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
{
    self = [super init];
    if (self) {
        _callId = aCallId;
        _type = aType;
        _isCreater = NO;
        _creater = aCreater;
        
        _userViews = [[NSMutableDictionary alloc] init];
        _memberNames = [[NSMutableArray alloc] init];
        [_memberNames addObject:[EMClient sharedClient].currentUsername];
        [_memberNames addObjectsFromArray:aOthers];
    }
    
    return self;
}

- (instancetype)initWithUsers:(NSArray *)aUserNams
                         type:(EMCallType)aType
{
    self = [super init];
    if (self) {
        _type = aType;
        _isCreater = YES;
        _creater = [EMClient sharedClient].currentUsername;

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
    
    [[EMClient sharedClient].conferenceManager setBuilder:self];
    [[EMClient sharedClient].conferenceManager addDelegate:self delegateQueue:nil];
    
    EMError *error = nil;
    EMCallLocalView *localView = self.type == EMCallTypeVoice ? nil : nil;
    if (_isCreater) {
        self.conference = [[EMClient sharedClient].conferenceManager createAndJoinConferenceWithType:self.type password:nil localVideoView:localView error:&error];
    } else {
        self.conference = [[EMClient sharedClient].conferenceManager joinConferenceWithId:_callId password:@"" localVideoView:localView error:&error];
    }
    
    if (error) {
        self.conference = nil;
        self.navigationController.navigationBarHidden = NO;
        [self.navigationController popViewControllerAnimated:NO];
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"创建会议失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    } else {
        for (NSString *userName in self.memberNames) {
            [self _inviteUser:userName];
        }
        
        //订阅
        [self _subUserStream:_creater];
        for (NSString *userName in self.memberNames) {
            [self _subUserStream:userName];
        }
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
    [[EMClient sharedClient].conferenceManager setBuilder:nil];
    [[EMClient sharedClient].conferenceManager removeDelegate:self];
}

#pragma mark - Private

- (void)_setupSubviews
{
//    //2.自己窗口
//    CGFloat width = 80;
//    CGFloat height = _callSession.remoteView.frame.size.height / _callSession.remoteView.frame.size.width * width;
//    _callSession.localView = [[LocalVideoView alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 90, CGRectGetMaxY(_statusLabel.frame), width, height)];
    
    if (_isConnected == NO) {
        self.statusLabel.text = @"正在连接...";
    }
    
    CGSize boundSize = [[UIScreen mainScreen] bounds].size;
    int maxHeight = 0;
    _top = 0;
    if (self.conference.type == EMCallTypeVoice) {
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
    } else if (self.conference.type == EMCallTypeVideo) {
        _border = 10;
        maxHeight = (self.remotesView.frame.size.height - 10) / 2;
        _width = (boundSize.width - _border * 2) / 3;
        _height = MIN(_width, maxHeight);
        _width = _height;
        
        [self _setupUserVideoView:_creater];
    }
    
    //    self.localView = [[EMCallLocalView alloc] initWithFrame:CGRectMake(_border, _top, _width, _height)];
    //    self.localView.backgroundColor = [UIColor lightGrayColor];
    //    [self.view addSubview:self.localView];
}

- (EMConfUserVoiceView *)_setupUserVoiceView:(NSString *)aUserName
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
    EMConfUserVoiceView *userView = [nib objectAtIndex:0];
    
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

- (EMConfUserVoiceView *)_setupUserVideoView:(NSString *)aUserName
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
    EMConfUserVoiceView *userView = [nib objectAtIndex:0];
    
    userView.frame = CGRectMake(ox, oy, _width, _height);
    userView.nameLabel.text = aUserName;
    
    [self.remotesView addSubview:userView];
    [self.userViews setObject:userView forKey:aUserName];
    
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
    
    if (self.conference.type == EMCallTypeVoice) {
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
    [ext setObject:[NSNumber numberWithInteger:self.conference.type] forKey:@"type"];
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
    EMCallStream *stream = [self.conference getSubscribableStreamForUserName:aUserName];
    if (stream) {
        EMError *error = nil;
        [[EMClient sharedClient].conferenceManager subscribeConferenceStream:self.conference.callId stream:stream remoteVideoView:nil error:&error];
        if (error) {
            NSString *message = [NSString stringWithFormat:@"订阅 %@ 失败", _creater];
            [self showHint:message];
        }
    }
}

#pragma mark - StreamTableViewControllerDelegate

- (void)streamController:(StreamTableViewController *)aController
       didSelectedStream:(EMCallStream *)aStream
{
    if (!aStream) {
        return;
    }
    
    NSString *subName = aStream.userName;
    EMCallRemoteView *remoteView = [self.userViews objectForKey:subName];
    if (remoteView == nil) {
        int count = (int )[self.userViews count] + 2;
        int row = count / 2 - 1 + (count % 2 == 0 ? 0 : 1);
        int col = (count % 2 == 0 ? 1 : 0);
        CGFloat ox = _border + col * (_width + _border);
        CGFloat oy = _top + row * (_height + _border);
        remoteView = [[EMCallRemoteView alloc] initWithFrame:CGRectMake(ox, oy, _width, _height)];
        [self.userViews setObject:remoteView forKey:subName];
    }
    
    EMError *error = nil;
    [[EMClient sharedClient].conferenceManager subscribeConferenceStream:self.conference.callId stream:aStream remoteVideoView:remoteView error:&error];
    if (error) {
        [self.userViews removeObjectForKey:subName];
    }
    else{
        [self.view addSubview:remoteView];
    }
}

#pragma mark - EMConferenceBuilderDelegate

- (EMCallRemoteView *)mutilConference:(EMCallConference *)aConference
                     videoViewForUser:(NSString *)aUserName
{
    if (![aConference.callId isEqualToString:self.conference.callId]) {
        return nil;
    }
    
    EMCallRemoteView *remoteView = [self.userViews objectForKey:aUserName];
    if (remoteView == nil) {
        int count = (int )[self.userViews count] + 2;
        int row = count / 2 - 1 + (count % 2 == 0 ? 0 : 1);
        int col = (count % 2 == 0 ? 1 : 0);
        CGFloat ox = _border + col * (_width + _border);
        CGFloat oy = _top + _border + row * (_height + _border);
        EMCallRemoteView *remoteView = [[EMCallRemoteView alloc] initWithFrame:CGRectMake(ox, oy, _width, _height)];
        remoteView.backgroundColor = [UIColor redColor];
        [self.userViews setObject:remoteView forKey:aUserName];
    }
    
    return remoteView;
}

#pragma mark - EMConferenceManagerDelegate

- (void)userDidJoinConference:(EMCallConference *)aConference
                         user:(NSString *)aUsername
{
    if ([aConference.callId isEqualToString: self.conference.callId]) {
        NSString *message = [NSString stringWithFormat:@"%@ 已加入会议", aUsername];
        [self showHint:message];
        
        if (![self.memberNames containsObject:aUsername]) {
            [self.memberNames addObject:aUsername];
            if (self.conference.type == EMCallTypeVoice) {
                [self _setupUserVoiceView:aUsername];
                [self _layoutVoiceAddButton];
            } else {
                [self _setupUserVideoView:aUsername];
                [self _layoutVideoAddButton];
            }
        }
    }
}

- (void)userDidLeaveConference:(EMCallConference *)aConference
                          user:(NSString *)aUsername
{
    if ([aConference.callId isEqualToString:self.conference.callId]) {
        NSString *message = [NSString stringWithFormat:@"%@ 已退出会议", aUsername];
        [self showHint:message];
        
        [self _removeUser:aUsername];
    }
}

- (void)userDidPubConferenceStream:(EMCallConference *)aConference
                              user:(NSString *)aUsername
{
    if ([aConference.callId isEqualToString:self.conference.callId]) {
        NSString *message = [NSString stringWithFormat:@"%@ 已上传数据流", aUsername];
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Pub 通知" message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//        [alertView show];
        [self showHint:message];
        
        EMCallStream *stream = [self.conference getSubscribableStreamForUserName:aUsername];
        if (stream) {
            EMError *error = nil;
            [[EMClient sharedClient].conferenceManager subscribeConferenceStream:self.conference.callId stream:stream remoteVideoView:nil error:&error];
            if (error) {
                [self.userViews removeObjectForKey:aUsername];
            }
            else{
                //            [self _setupUserVoiceView:aUsername];
                //            [self _layoutVoiceAddButton];
            }
        }
    }
}

- (void)conferenceMembersDidUpdate:(EMCallConference *)aConference
{
    if ([aConference.callId isEqualToString:self.conference.callId]) {
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"成员通知" message:@"会议成员已更新" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//        [alertView show];
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
    if ([aConference.callId isEqualToString:self.conference.callId]) {
        NSString *userName = aStream.userName;
        if ([userName length] == 0) {
            return;
        }
        
        EMConfUserVoiceView *userView = [self.userViews objectForKey:userName];
        if (userView) {
            userView.statusImgView.image = [UIImage imageNamed:@"conf_connected"];
        }
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

- (IBAction)hangupAction:(id)sender
{
    if (!self.conference) {
        self.navigationController.navigationBarHidden = NO;
        [self.navigationController popViewControllerAnimated:NO];
        return;
    }
    
    if (_isCreater) {
        [[EMClient sharedClient].conferenceManager destroyConferenceWithId:self.conference.callId error:nil];
    } else {
        [[EMClient sharedClient].conferenceManager leaveConferenceWithId:self.conference.callId error:nil];
    }
    
    self.conference = nil;
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)subStream
{
    NSArray *streams = [self.conference getSubscribableStreams];
    if ([streams count] == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"没有可订阅的数据流" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }
    else{
        StreamTableViewController *controller = [[StreamTableViewController alloc] initWithDataSource:streams];
        controller.delegate = self;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

@end
