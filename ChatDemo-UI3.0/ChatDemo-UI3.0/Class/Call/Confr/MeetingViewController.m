//
//  MeetingViewController.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2018/9/20.
//  Copyright © 2018 XieYajie. All rights reserved.
//

#import "MeetingViewController.h"

@interface MeetingViewController ()

@end

@implementation MeetingViewController

- (instancetype)initWithPassword:(NSString *)aPassword
                     inviteUsers:(NSArray *)aInviteUsers
                          chatId:(NSString *)aChatId
                        chatType:(EMChatType)aChatType
{
    self = [super initWithType:EMConferenceTypeLargeCommunication password:aPassword inviteUsers:aInviteUsers chatId:aChatId chatType:aChatType];
    if (self) {
    }
    
    return self;
}

- (instancetype)initWithJoinConfId:(NSString *)aConfId
                          password:(NSString *)aPassword
                            chatId:(NSString *)aChatId
                          chatType:(EMChatType)aChatType
{
    self = [super initWithJoinConfId:aConfId password:aPassword type:EMConferenceTypeLargeCommunication chatId:aChatId chatType:aChatType];
    if (self) {
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.switchCameraButton.enabled = NO;
    
    [self _createOrJoinConference];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - EMConference

- (void)_createOrJoinConference
{
    __weak typeof(self) weakself = self;
    void (^block)(EMCallConference *aCall, NSString *aPassword, EMError *aError) = ^(EMCallConference *aCall, NSString *aPassword, EMError *aError) {
        if (aError) {
            [self hangupAction];
            
            NSString *msg = weakself.isCreater ? @"创建会议失败" : @"加入会议失败";
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"错误" message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
            
            return ;
        }
        
        weakself.conference = aCall;
        weakself.password = aPassword;
        
        [weakself pubLocalStreamWithEnableVideo:NO completion:nil];
        
        //如果是创建者并且是从会话中触发
        if (self.isCreater && [self.chatId length] > 0) {
            [self sendInviteMessageWithConversationId:self.chatId chatType:self.chatType];
        }
        
        //如果是创建者，进行邀请人操作
        if (weakself.isCreater) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                for (NSString *username in weakself.inviteUsers) {
                    [weakself sendInviteMessageWithConversationId:username chatType:EMChatTypeChat];
                }
            });
        }
    };
    
    if (self.isCreater) {
        [[EMClient sharedClient].conferenceManager createAndJoinConferenceWithType:self.type password:self.password completion:block];
    } else {
        [[EMClient sharedClient].conferenceManager joinConferenceWithConfId:self.joinConfId password:self.password completion:^(EMCallConference *aCall, EMError *aError) {
            block(aCall, weakself.password, aError);
        }];
    }
}

#pragma mark - Action

- (void)microphoneButtonAction
{
    [super microphoneButtonAction];
    
    if ([self.pubStreamId length] > 0) {
        EMConferenceVideoItem *videoItem = [self.streamItemDict objectForKey:self.pubStreamId];
        if (videoItem) {
            videoItem.videoView.enableVoice = !self.microphoneButton.isSelected;
        }
    }
}

- (void)videoButtonAction:(EMButton *)aButton
{
    [super videoButtonAction:aButton];
    
    EMConferenceVideoItem *videoItem = [self.streamItemDict objectForKey:self.pubStreamId];
    videoItem.videoView.enableVideo = aButton.isSelected;
    self.switchCameraButton.enabled = aButton.isSelected;
    
    if (aButton.selected) {
        BOOL isUseBackCamera = [[[NSUserDefaults standardUserDefaults] objectForKey:@"em_IsUseBackCamera"] boolValue];
        if (isUseBackCamera != self.isUseBackCamera) {
            self.switchCameraButton.selected = self.isUseBackCamera;
            [[EMClient sharedClient].conferenceManager updateConferenceWithSwitchCamera:self.conference];
        }
    }
}

- (void)inviteButtonAction:(EMButton *)aButton
{
    NSMutableArray *members = [[NSMutableArray alloc] init];
    [members addObject:[EMClient sharedClient].currentUsername];
    for (NSString *key in self.streamItemDict) {
        EMConferenceVideoItem *item = [self.streamItemDict objectForKey:key];
        if (item.stream) {
            [members addObject:item.stream.userName];
        }
    }
    ConfInviteUsersViewController *controller = [[ConfInviteUsersViewController alloc] initWithType:self.inviteType isCreate:NO excludeUsers:members groupOrChatroomId:self.chatId];

    __weak typeof(self) weakself = self;
    [controller setDoneCompletion:^(NSArray *aInviteUsers) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            for (NSString *username in aInviteUsers) {
                [weakself sendInviteMessageWithConversationId:username chatType:EMChatTypeChat];
            }
        });
    }];
    
    [self.navigationController pushViewController:controller animated:YES];
}

@end
