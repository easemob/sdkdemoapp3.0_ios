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
    
    NSString *_callId;
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

@property (strong, nonatomic) EMCallConference *conference;
@property (strong, nonatomic) NSMutableArray *remoteNames;
@property (strong, nonatomic) EMCallLocalView *localView;
@property (strong, nonatomic) NSMutableDictionary *userViews;

@end

@implementation ConferenceViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        _callId = nil;
    }
    
    return self;
}

- (instancetype)initWithCallId:(NSString *)aCallId
{
    self = [super init];
    if (self) {
        _callId = aCallId;
    }
    
    return self;
}

- (instancetype)initWithUsers:(NSArray *)aUserNams
{
    self = [super init];
    if (self) {
        _userViews = [[NSMutableDictionary alloc] init];
        _remoteNames = [[NSMutableArray alloc] init];
        [_remoteNames addObjectsFromArray:aUserNams];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationController.navigationBarHidden = YES;
    
    [self _setupSubviews];
    
//    [[EMClient sharedClient].conferenceManager setBuilder:self];
//    [[EMClient sharedClient].conferenceManager addDelegate:self delegateQueue:nil];
//
//
//
//    
//    EMError *error = nil;
//    if (_callId == nil) {
//        self.conference = [[EMClient sharedClient].conferenceManager createAndJoinConferenceWithType:EMCallTypeVideo password:nil localVideoView:self.localView error:&error];
//    } else {
//        self.conference = [[EMClient sharedClient].conferenceManager joinConferenceWithId:_callId password:@"" localVideoView:self.localView error:&error];
//    }
//    
//    if (error) {
//        self.conference = nil;
//        [self.navigationController popViewControllerAnimated:YES];
//    }
//    else{
//        [self _setupSubviews];
//    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
//    [[EMClient sharedClient].conferenceManager setBuilder:nil];
//    [[EMClient sharedClient].conferenceManager removeDelegate:self];
}

#pragma mark - Private

- (void)_setupSubviews
{
//    //2.自己窗口
//    CGFloat width = 80;
//    CGFloat height = _callSession.remoteView.frame.size.height / _callSession.remoteView.frame.size.width * width;
//    _callSession.localView = [[LocalVideoView alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 90, CGRectGetMaxY(_statusLabel.frame), width, height)];
    
    CGSize boundSize = [[UIScreen mainScreen] bounds].size;
    int maxHeight = (self.remotesView.frame.size.height - 20) / 2;
    if (self.conference.type == EMCallTypeVoice) {
        _top = 0;
        _border = 20;
        _width = (boundSize.width - _border * 4) / 3;
        _height = MIN(_width, maxHeight);
        _width = _height;
        [self _setupUserVoiceView:[[EMClient sharedClient] currentUsername]];
        for (NSString *userName in self.remoteNames) {
            [self _setupUserVoiceView:userName];
        }
        [self _layoutVoiceAddButton];
    } else if (self.conference.type == EMCallTypeVideo) {
        
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
//        remoteView.backgroundColor = [UIColor redColor];
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
//        NSString *message = [NSString stringWithFormat:@"%@ 已加入会议", aUsername];
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Enter 通知" message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//        [alertView show];
    }
}

- (void)userDidLeaveConference:(EMCallConference *)aConference
                          user:(NSString *)aUsername
{
    if ([aConference.callId isEqualToString:self.conference.callId]) {
        NSString *message = [NSString stringWithFormat:@"%@ 已退出会议", aUsername];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Exit 通知" message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        
        EMCallRemoteView *view = [self.userViews objectForKey:aUsername];
        if (view) {
            [view removeFromSuperview];
            [self.userViews removeObjectForKey:aUsername];
        }
        
        CGFloat ox = _border;
        CGFloat oy = _top;
        for (NSString *key in self.userViews) {
            if (ox >= _width + _border) {
                ox = _border;
                oy += _border + _height;
            }
            else{
                ox = _width + _border * 2;
            }
            
            UIView *view = [self.userViews objectForKey:key];
            view.frame = CGRectMake(ox, oy, _width, _height);
        }
    }
}

- (void)userDidPubConferenceStream:(EMCallConference *)aConference
                              user:(NSString *)aUsername
{
    if ([aConference.callId isEqualToString:self.conference.callId]) {
//        NSString *message = [NSString stringWithFormat:@"%@ 已上传数据流", aUsername];
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Pub 通知" message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//        [alertView show];
        
        EMCallStream *stream = nil;
        NSArray *streams = [self.conference getSubscribableStreams];
        for (EMCallStream *obj in streams) {
            if ([obj.userName isEqualToString:aUsername]) {
                stream = obj;
                break;
            }
        }
        
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

- (void)conferenceMembersDidUpdate:(EMCallConference *)aConference
{
    if ([aConference.callId isEqualToString:self.conference.callId]) {
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"成员通知" message:@"会议成员已更新" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//        [alertView show];
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
            userView.statusImgView.backgroundColor = [UIColor greenColor];
        }
    }
}

#pragma mark - notification

- (void)notificationInviteUser:(NSNotification *)notification
{
    NSString *username = (NSString *)notification.object;
//    NSString *from = [[EMClient sharedClient] currentUsername];
//    EMCmdMessageBody *body = [[EMCmdMessageBody alloc] initWithAction:@"inviteToJoinConference"];
//    NSDictionary *ext = @{@"callId": self.conference.callId};
//    EMMessage *message = [[EMMessage alloc] initWithConversationID:username from:from to:username body:body ext:ext];
//    message.chatType = EMChatTypeChat;
//    [[EMClient sharedClient].chatManager sendMessage:message progress:^(int progress) {
//        //
//    } completion:^(EMMessage *message, EMError *error) {
//        //
//    }];
    
    EMError *error = nil;
    [[EMClient sharedClient].conferenceManager inviteUserToJoinConference:self.conference.callId userName:username ext:nil error:&error];
    if (error) {
        [self showHint:@"邀请发送失败，请重新发送"];
    }
    else {
        [self showHint:@"邀请发送成功"];
    }
}


#pragma mark - action

- (IBAction)inviteUserAction:(id)sender
{
    NSArray *contacts = [[EMClient sharedClient].contactManager getContacts];
    NSMutableArray *usernames = [[NSMutableArray alloc] init];
    for (NSString *username in contacts) {
        if (![self.remoteNames containsObject:username]) {
            [usernames addObject:username];
        }
    }
    EMConfUserSelectionViewController *controller = [[EMConfUserSelectionViewController alloc] initWithDataSource:usernames];
    [controller setSelecteUserFinishedCompletion:^(NSArray *selectedUsers) {
        //
    }];
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)hangupAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)exitConfernece
{
    if (!self.conference) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    if (_callId == nil) {
         [[EMClient sharedClient].conferenceManager destroyConferenceWithId:self.conference.callId error:nil];
    } else {
         [[EMClient sharedClient].conferenceManager leaveConferenceWithId:self.conference.callId error:nil];
    }
   
    self.conference = nil;
    [self.navigationController popViewControllerAnimated:YES];
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

- (void)inviteUser
{
    NSArray *contacts = [[EMClient sharedClient].contactManager getContacts];
    NSMutableArray *usernames = [[NSMutableArray alloc] init];
    for (NSString *username in contacts) {
        if (![self.remoteNames containsObject:username]) {
            [usernames addObject:username];
        }
    }
    EMConfUserSelectionViewController *controller = [[EMConfUserSelectionViewController alloc] initWithDataSource:usernames];
    [self.navigationController pushViewController:controller animated:YES];
}

@end
