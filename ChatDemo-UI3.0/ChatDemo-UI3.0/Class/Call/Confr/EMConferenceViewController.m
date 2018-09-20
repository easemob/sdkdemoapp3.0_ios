//
//  EMConferenceViewController.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2018/9/20.
//  Copyright © 2018 XieYajie. All rights reserved.
//

#import "EMConferenceViewController.h"

#import "DemoConfManager.h"

@interface EMConferenceViewController ()

@property (nonatomic, strong) NSMutableArray *inviteUsers;

@end

@implementation EMConferenceViewController

- (instancetype)initWithType:(EMConferenceType)aType
                 inviteUsers:(NSArray *)aInviteUsers
{
    self = [super init];
    if (self) {
        _type = aType;
        _inviteUsers = [[NSMutableArray alloc] initWithArray:aInviteUsers];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self _setupConferenceControllerSubviews];
    if (!isHeadphone()) {
        [self speakerButtonAction];
    }
    
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
    [self.switchCameraButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.switchCameraButton setTitleColor:[UIColor grayColor] forState:UIControlStateSelected];
    [self.switchCameraButton setImage:[UIImage imageNamed:@"switchCamera_white"] forState:UIControlStateNormal];
    [self.switchCameraButton setImage:[UIImage imageNamed:@"switchCamera_gray"] forState:UIControlStateSelected];
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
    
    EMButton *videoButton = [[EMButton alloc] initWithTitle:@"视频" target:self action:@selector(videoButtonAction:)];
    [videoButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [videoButton setTitleColor:[UIColor grayColor] forState:UIControlStateSelected];
    [videoButton setImage:[UIImage imageNamed:@"video_white"] forState:UIControlStateNormal];
    [videoButton setImage:[UIImage imageNamed:@"video_gray"] forState:UIControlStateSelected];
    [self.view addSubview:videoButton];
    [videoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.microphoneButton.mas_right).offset(padding);
        make.bottom.equalTo(self.switchCameraButton);
    }];
    
    [self.speakerButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [self.speakerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.speakerButton setImage:[UIImage imageNamed:@"speaker_gray"] forState:UIControlStateNormal];
    [self.speakerButton setImage:[UIImage imageNamed:@"speaker_white"] forState:UIControlStateSelected];
    [self.speakerButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(videoButton.mas_right).offset(padding);
        make.bottom.equalTo(self.switchCameraButton);
    }];
    
    [@[inviteButton, self.switchCameraButton, self.microphoneButton, videoButton, self.speakerButton] mas_makeConstraints:^(MASConstraintMaker *make) {
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

#pragma mark - Member

- (void)_inviteUser:(NSString *)aUserName
{
//    NSString *currentUser = [EMClient sharedClient].currentUsername;
//    EMTextMessageBody *textBody = [[EMTextMessageBody alloc] initWithText:[[NSString alloc] initWithFormat:@"%@ 邀请你加入会议: %@", currentUser, self.conference.confId]];
//    EMMessage *message = [[EMMessage alloc] initWithConversationID:aUserName from:currentUser to:aUserName body:textBody ext:@{@"em_conference_op":@"invite", @"conferenceId":self.conference.confId, @"password":self.password, @"em_conference_type":@(self.conferenceType), @"msg_extension":@{@"inviter":currentUser, @"group_id":@""}}];
//    message.chatType = EMChatTypeChat;
//    [[EMClient sharedClient].chatManager sendMessage:message progress:nil completion:nil];
    
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
    aButton.selected = !aButton.selected;
    [[EMClient sharedClient].conferenceManager updateConferenceWithSwitchCamera:self.conference];
}

- (void)videoButtonAction:(EMButton *)aButton
{
    aButton.selected = !aButton.isSelected;
    [[EMClient sharedClient].conferenceManager updateConference:self.conference enableVideo:aButton.selected];
    
    //TODO: 更新View
}

- (void)minimizeAction
{
    
}

- (void)hangupAction
{
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    
    [[DemoConfManager sharedManager] endConference:self.conference];

    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
