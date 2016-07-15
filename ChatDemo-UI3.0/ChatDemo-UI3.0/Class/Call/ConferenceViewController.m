//
//  ConferenceViewController.m
//  IosDemo
//
//  Created by XieYajie on 4/26/16.
//  Copyright © 2016 dxstudio.com. All rights reserved.
//

#import "ConferenceViewController.h"

#import "CallTableViewController.h"
#import "UIViewController+HUD.h"
#import "ChatDemoHelper.h"

@interface ConferenceViewController ()<EMCallManagerDelegate, CallTableViewControllerDelegate>
{
    float _ox;
    float _oy;
    float _width;
    float _height;
}

@property (strong, nonatomic) LocalVideoView *localView;

@property (strong, nonatomic) NSMutableDictionary *remoteViews;

@property (strong, nonatomic) EMCallSession *conference;

@property (strong, nonatomic) NSString *from;
@property (strong, nonatomic) NSString *joinConfId;
@property (strong, nonatomic) UIView *inviteView;
@property (strong, nonatomic) UITextField *inviteField;

@end

@implementation ConferenceViewController

- (instancetype)initWithConferenceId:(NSString *)aConfId
                                from:(NSString *)aFrom
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.from = aFrom;
        self.joinConfId = aConfId;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UIBarButtonItem *exitItem = [[UIBarButtonItem alloc] initWithTitle:@" 退出 " style:UIBarButtonItemStylePlain target:self action:@selector(exitConfernece)];
    UIBarButtonItem *subItem = [[UIBarButtonItem alloc] initWithTitle:@" 订阅 " style:UIBarButtonItemStylePlain target:self action:@selector(subStream)];
    if ([self.joinConfId length] == 0) {
        UIBarButtonItem *inviteItem = [[UIBarButtonItem alloc] initWithTitle:@" 邀请 " style:UIBarButtonItemStylePlain target:self action:@selector(inviteToJoin)];
        self.navigationItem.rightBarButtonItems = @[exitItem, inviteItem, subItem];
    }
    else{
        self.navigationItem.rightBarButtonItems = @[exitItem, subItem];
    }
    
    self.remoteViews = [[NSMutableDictionary alloc] init];
    
    _ox = 10;
    _oy = 80;
    _width = 120;
    _height = 140;
    
    self.localView = [[LocalVideoView alloc] initWithFrame:CGRectMake(_ox, _oy, _width, _height)];
    self.localView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:self.localView];
    _ox = 150;
    
    [[EMClient sharedClient].callManager addDelegate:self delegateQueue:nil];
    
    if ([self.joinConfId length] > 0) {
        [self showHint:@"正在加入会议..."];
    }
    else {
        [self showHint:@"正在创建会议..."];
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        EMError *error = nil;
        if ([self.joinConfId length] > 0) {
            self.conference = [[EMClient sharedClient].callManager joinConferenceWithConfId:self.joinConfId password:@"" localVideoView:self.localView error:&error];
        }
        else{
            self.conference = [[EMClient sharedClient].callManager createAndJoinConferenceWithType:EMCallTypeVoice password:@"" localVideoView:self.localView error:&error];
        }
        
        [self hideHud];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                self.conference = nil;
                [self.navigationController popViewControllerAnimated:YES];
            }
            else{
                [self _setupSubviews];
            }
        });
    });
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

- (UIView *)inviteView
{
    if (_inviteView == nil) {
        _inviteView = [[UIView alloc] initWithFrame:CGRectMake(50, 80, self.view.frame.size.width - 100, 150)];
        _inviteView.backgroundColor = [UIColor lightGrayColor];
        _inviteView.layer.cornerRadius = 5;
        
        _inviteField = [[UITextField alloc] initWithFrame:CGRectMake(20, 30, _inviteView.frame.size.width - 40, 40)];
        _inviteField.backgroundColor = [UIColor whiteColor];
        _inviteField.clipsToBounds = YES;
        _inviteField.layer.cornerRadius = 5;
        _inviteField.placeholder = @"要邀请的人的username";
        [_inviteView addSubview:_inviteField];
        
        UIButton *cancleButton = [[UIButton alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(_inviteField.frame) + 30, 80, 35)];
        cancleButton.backgroundColor = [UIColor greenColor];
        cancleButton.layer.cornerRadius = 5;
        cancleButton.clipsToBounds = YES;
        [cancleButton setTitle:@"取消" forState:UIControlStateNormal];
        [cancleButton addTarget:self action:@selector(cancleInviteAction) forControlEvents:UIControlEventTouchUpInside];
        [_inviteView addSubview:cancleButton];
        
        UIButton *okButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_inviteField.frame) - 80, CGRectGetMaxY(_inviteField.frame) + 30, 80, 35)];
        okButton.backgroundColor = [UIColor redColor];
        okButton.layer.cornerRadius = 5;
        okButton.clipsToBounds = YES;
        [okButton setTitle:@"邀请" forState:UIControlStateNormal];
        [okButton addTarget:self action:@selector(inviteAction) forControlEvents:UIControlEventTouchUpInside];
        [_inviteView addSubview:okButton];
    }
    
    return _inviteView;
}

#pragma mark - CallTableViewControllerDelegate

- (void)streamController:(CallTableViewController *)aController
       didSelectedStream:(EMCallStream *)aStream
{
    if (!aStream) {
        return;
    }
    
    NSString *subName = aStream.userName;
    
    EMError *error = nil;
    
    RemoteVideoView *remoteView = [[RemoteVideoView alloc] initWithFrame:CGRectMake(_ox, _oy, _width, _height)];
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

- (void)didRecvConferenceMemberEntered:(EMCallSession *)aConference
                           enteredName:(NSString *)aEnteredName
{
    if ([aConference.callId isEqualToString: self.conference.callId]) {
        NSString *message = [NSString stringWithFormat:@"%@ 已加入会议", aEnteredName];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Enter 通知" message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

- (void)didRecvConferenceMemberExited:(EMCallSession *)aConference
                           exitedName:(NSString *)aExitedName
{
    if ([aConference.callId isEqualToString: self.conference.callId]) {
        NSString *message = [NSString stringWithFormat:@"%@ 已退出会议", aExitedName];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Exit 通知" message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        
        RemoteVideoView *view = [self.remoteViews objectForKey:aExitedName];
        if (view) {
            [view removeFromSuperview];
        }
    }
}

- (void)didRecvConferenceMemberPubed:(EMCallSession *)aConference
                           pubedName:(NSString *)aPubedName
{
    if ([aConference.callId isEqualToString: self.conference.callId]) {
        NSString *message = [NSString stringWithFormat:@"%@ 已上传数据流", aPubedName];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Pub 通知" message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

- (void)didRecvConferenceMembersUpdated:(EMCallSession *)aConference
{
    if ([aConference.callId isEqualToString: self.conference.callId]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"成员通知" message:@"会议成员已更新" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

- (void)didRecvConferenceClosed:(EMCallSession *)aConference
{
    if ([aConference.callId isEqualToString: self.conference.callId]) {
        [self.navigationController popViewControllerAnimated:YES];
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"会议通知" message:@"会议已关闭" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

#pragma mark - action

- (void)exitConfernece
{
    if (!self.conference) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    if ([self.joinConfId length] == 0) {
        [[EMClient sharedClient].callManager destroyConferenceWithCallId:self.conference.callId error:nil];
    }
    else{
        [[EMClient sharedClient].callManager leaveConferenceWithCallId:self.conference.callId error:nil];
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
        CallTableViewController *controller = [[CallTableViewController alloc] initWithDataSource:streams];
        controller.delegate = self;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (void)inviteToJoin
{
    [self.view endEditing:YES];
    [self.view addSubview:self.inviteView];
}

- (void)cancleInviteAction
{
    [_inviteField resignFirstResponder];
    _inviteField.text = @"";
    [_inviteView removeFromSuperview];
}

- (void)inviteAction
{
    [_inviteField resignFirstResponder];
    
    if ([_inviteField.text length] > 0) {
        NSString *inviteStr = [NSString stringWithFormat:@"inviteJoinConf.%@", [self.conference getConferenceId]];
        EMCmdMessageBody *body = [[EMCmdMessageBody alloc] initWithAction:inviteStr];
        NSString *from = [[EMClient sharedClient] currentUsername];
        EMMessage *cmdMessage = [[EMMessage alloc] initWithConversationID:self.conference.callId from:from to:_inviteField.text body:body ext:nil];
        [[EMClient sharedClient].chatManager asyncSendMessage:cmdMessage progress:nil completion:nil];
    }
    
    _inviteField.text = @"";
    [_inviteView removeFromSuperview];
}

@end
