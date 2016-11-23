//
//  ConferenceViewController.m
//  IosDemo
//
//  Created by XieYajie on 4/26/16.
//  Copyright © 2016 dxstudio.com. All rights reserved.
//

#import "ConferenceViewController.h"

#import "DemoCallManager.h"
#import "StreamTableViewController.h"
#import "UserTableViewController.h"

@interface ConferenceViewController ()<EMCallManagerDelegate, StreamTableViewControllerDelegate>
{
    float _ox;
    float _oy;
    float _width;
    float _height;
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

@property (strong, nonatomic) EMCallConference *conference;
@property (strong, nonatomic) EMCallLocalView *localView;
@property (strong, nonatomic) NSMutableDictionary *remoteViews;

@end

@implementation ConferenceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
//    UIBarButtonItem *exitItem = [[UIBarButtonItem alloc] initWithTitle:@"退出" style:UIBarButtonItemStylePlain target:self action:@selector(exitConfernece)];
//    UIBarButtonItem *subItem = [[UIBarButtonItem alloc] initWithTitle:@"订阅" style:UIBarButtonItemStylePlain target:self action:@selector(subStream)];
//    UIBarButtonItem *inviteItem = [[UIBarButtonItem alloc] initWithTitle:@"邀请" style:UIBarButtonItemStylePlain target:self action:@selector(inviteUser)];
//    self.navigationItem.rightBarButtonItems = @[exitItem, subItem, inviteItem];
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationInviteUser:) name:@"selecteInviteUser" object:nil];
    
    self.remoteViews = [[NSMutableDictionary alloc] init];
    
//    _ox = 10;
//    _oy = 80;
//    _width = 120;
//    _height = 140;
//    
//    self.localView = [[EMCallLocalView alloc] initWithFrame:CGRectMake(_ox, _oy, _width, _height)];
//    self.localView.backgroundColor = [UIColor lightGrayColor];
//    [self.view addSubview:self.localView];
//    _ox = 150;
//    
//    [[EMClient sharedClient].callManager addDelegate:self delegateQueue:nil];
//    EMError *error = nil;
//    self.conference = [[EMClient sharedClient].callManager joinConferenceWithConfId:@"0001|testConference" password:@"" localVideoView:self.localView error:&error];
//    if (error) {
//        self.conference = nil;
////        dispatch_async(dispatch_get_main_queue(), ^{
//        [self.navigationController popViewControllerAnimated:YES];
////        });
//    }
//    else{
//        [self _setupSubviews];
//    }
//    
////    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
////        
////        
////    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private

- (void)_setupSubviews
{
//    //2.自己窗口
//    CGFloat width = 80;
//    CGFloat height = _callSession.remoteView.frame.size.height / _callSession.remoteView.frame.size.width * width;
//    _callSession.localView = [[LocalVideoView alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 90, CGRectGetMaxY(_statusLabel.frame), width, height)];
}

#pragma mark - StreamTableViewControllerDelegate

- (void)streamController:(StreamTableViewController *)aController
       didSelectedStream:(EMCallStream *)aStream
{
    if (!aStream) {
        return;
    }
    
    NSString *subName = aStream.userName;
    
    EMError *error = nil;
    
    EMCallRemoteView *remoteView = [[EMCallRemoteView alloc] initWithFrame:CGRectMake(_ox, _oy, _width, _height)];
    remoteView.backgroundColor = [UIColor redColor];
    [self.view addSubview:remoteView];
    
    if (_ox >= 150) {
        _ox = 10;
        _oy += 20 + _height;
    }
    else{
        _ox = 150;
    }
    
    [[EMClient sharedClient].callManager subscribeConferenceStream:self.conference.callId stream:aStream remoteVideoView:remoteView error:&error];
    if (error) {
        [remoteView removeFromSuperview];
    }
    else{
        [self.remoteViews setObject:remoteView forKey:subName];
    }
}

#pragma mark - EMCallManagerDelegate

- (void)didReceiveCallMemberEntered:(EMCallSession *)aConference
                        enteredName:(NSString *)aEnteredName
{
    if ([aConference.callId isEqualToString: self.conference.callId]) {
        NSString *message = [NSString stringWithFormat:@"%@ 已加入会议", aEnteredName];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Enter 通知" message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

- (void)didReceiveCallMemberExited:(EMCallSession *)aConference
                        exitedName:(NSString *)aExitedName
{
    if ([aConference.callId isEqualToString: self.conference.callId]) {
        NSString *message = [NSString stringWithFormat:@"%@ 已退出会议", aExitedName];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Exit 通知" message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        
        EMCallRemoteView *view = [self.remoteViews objectForKey:aExitedName];
        if (view) {
            [view removeFromSuperview];
        }
    }
}

- (void)didReceiveCallMemberPubed:(EMCallSession *)aConference
                        pubedName:(NSString *)aPubedName
{
    if ([aConference.callId isEqualToString: self.conference.callId]) {
        NSString *message = [NSString stringWithFormat:@"%@ 已上传数据流", aPubedName];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Pub 通知" message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

- (void)didReceiveCallMembersUpdated:(EMCallSession *)aConference
{
    if ([aConference.callId isEqualToString: self.conference.callId]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"成员通知" message:@"会议成员已更新" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

- (void)didReceiveCallTerminated:(EMCallSession *)aConference
                          reason:(EMCallEndReason)aReason
                           error:(EMError *)aError
{
    if ([aConference.callId isEqualToString: self.conference.callId]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"会议通知" message:@"会议已关闭" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

#pragma mark - notification

- (void)notificationInviteUser:(NSNotification *)notification
{
    NSString *username = (NSString *)notification.object;
    NSString *from = [[EMClient sharedClient] currentUsername];
    EMCmdMessageBody *body = [[EMCmdMessageBody alloc] initWithAction:@"inviteToJoinConference"];
    NSDictionary *ext = @{@"callId": self.conference.callId};
    EMMessage *message = [[EMMessage alloc] initWithConversationID:username from:from to:username body:body ext:ext];
    message.chatType = EMChatTypeChat;
    [[EMClient sharedClient].chatManager sendMessage:message progress:^(int progress) {
        //
    } completion:^(EMMessage *message, EMError *error) {
        //
    }];
}

#pragma mark - action

- (void)exitConfernece
{
    if (!self.conference) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    [[EMClient sharedClient].callManager leaveConferenceWithCallId:self.conference.callId error:nil];
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
    UserTableViewController *controller = [[UserTableViewController alloc] initWithDataSource:contacts];
    [self.navigationController pushViewController:controller animated:YES];
}

@end
