//
//  DemoConfManager.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 23/11/2016.
//  Copyright © 2016 XieYajie. All rights reserved.
//

#import "DemoConfManager.h"

#if DEMO_CALL == 1

#import <Hyphenate/Hyphenate.h>

#import "DemoCallManager.h"
#import "MainViewController.h"

#import "MeetingViewController.h"
#import "Live2ViewController.h"

static DemoConfManager *confManager = nil;

@interface DemoConfManager()<EMConferenceManagerDelegate, EMChatManagerDelegate>

@property (strong, nonatomic) UINavigationController *confNavController;

@end

#endif

@implementation DemoConfManager

#if DEMO_CALL == 1

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self _initManager];
    }
    
    return self;
}

+ (instancetype)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        confManager = [[DemoConfManager alloc] init];
    });
    
    return confManager;
}

- (void)dealloc
{
    [[EMClient sharedClient].conferenceManager removeDelegate:self];
    [[EMClient sharedClient].chatManager removeDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - private

- (void)_initManager
{
    [[EMClient sharedClient].chatManager addDelegate:self delegateQueue:nil];
    [[EMClient sharedClient].conferenceManager addDelegate:self delegateQueue:nil];
}

#pragma mark - EMChatManagerDelegate

- (void)messagesDidReceive:(NSArray *)aMessages
{
    for (EMMessage *message in aMessages) {
        NSString *conferenceId = [message.ext objectForKey:@"em_conference_id"];
        if ([conferenceId length] == 0) {
            continue;
        }
        
        NSString *op = [message.ext objectForKey:@"em_conference_op"];
        if ([op isEqualToString:@"request_tobe_speaker"] || [op isEqualToString:@"request_tobe_audience"]) {
            EMConferenceViewController *controller =  self.confNavController.viewControllers[0];
            if ([controller isKindOfClass:[Live2ViewController class]]) {
                Live2ViewController *liveController = (Live2ViewController *)controller;
                [liveController handleRoleChangedMessage:message];
            }
        }
    }
}

#pragma mark - conference

- (void)inviteMemberWithConfType:(EMConferenceType)aConfType
                      inviteType:(ConfInviteType)aInviteType
                  conversationId:(NSString *)aConversationId
                        chatType:(EMChatType)aChatType
{
    if (self.isCalling || [DemoCallManager sharedManager].isCalling) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"错误" message:@"有通话正在进行" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        
        return;
    }
    
    ConfInviteUsersViewController *controller = [[ConfInviteUsersViewController alloc] initWithType:aInviteType isCreate:YES excludeUsers:@[[EMClient sharedClient].currentUsername] groupOrChatroomId:aConversationId];
    
    __weak typeof(self) weakSelf = self;
    [controller setDoneCompletion:^(NSArray *aInviteUsers) {
        weakSelf.isCalling = YES;
        
        EMConferenceViewController *controller = nil;
        if (aConfType != EMConferenceTypeLive) {
            controller = [[MeetingViewController alloc] initWithType:EMConferenceTypeLargeCommunication password:@"" inviteUsers:aInviteUsers chatId:aConversationId chatType:aChatType];
        } else {
            controller = [[Live2ViewController alloc] initWithType:EMConferenceTypeLive password:@"" inviteUsers:aInviteUsers chatId:aConversationId chatType:aChatType];
        }
        controller.inviteType = aInviteType;
        
        weakSelf.confNavController = [[UINavigationController alloc] initWithRootViewController:controller];
        [weakSelf.mainController presentViewController:weakSelf.confNavController animated:NO completion:nil];
    }];
    [self.mainController presentViewController:controller animated:NO completion:nil];
}

- (void)handleMessageToJoinConference:(EMMessage *)aMessage
{
    //如果正在进行1v1通话，不处理
    if ([DemoCallManager sharedManager].isCalling) {
        return;
    }
    
    //新版属性
    NSString *conferenceId = [aMessage.ext objectForKey:@"em_conference_id"];
    NSString *password = [aMessage.ext objectForKey:@"em_conference_password"];
    //如果新版属性不存在，判断旧版本属性
    if ([conferenceId length] == 0) {
        conferenceId = [aMessage.ext objectForKey:@"conferenceId"];
        password = [aMessage.ext objectForKey:@"password"];
    }
    
    //如果conferenceId不存在，则不处理
    if ([conferenceId length] == 0) {
        return;
    }
    
    EMConferenceViewController *controller = nil;
    NSString *op = [aMessage.ext objectForKey:@"em_conference_op"];
    do {
        //如果“em_conference_op”属性存在，说明是新版
        if ([op length] == 0) {
            controller = [[MeetingViewController alloc] initWithJoinConfId:conferenceId password:password type:EMConferenceTypeLargeCommunication chatId:nil chatType:EMChatTypeChat];
            break;
        }
        
        if (![op isEqualToString:@"invite"]) {
            break;
        }
        
        EMConferenceType type = (EMConferenceType)[[aMessage.ext objectForKey:@"em_conference_type"] integerValue];
        NSString *chatId = [aMessage.ext objectForKey:@"em_conference_chatId"];
        EMChatType chatType = (EMChatType)[[aMessage.ext objectForKey:@"em_conference_chatType"] integerValue];
        if (type == EMConferenceTypeLive) {
            NSString *admin = [aMessage.ext objectForKey:@"em_conference_admin"];
            if ([admin length] == 0) {
                admin = aMessage.from;
            }
            controller = [[Live2ViewController alloc] initWithJoinConfId:conferenceId password:password admin:admin chatId:chatId chatType:chatType];
        } else {
            controller = [[MeetingViewController alloc] initWithJoinConfId:conferenceId password:password type:EMConferenceTypeLargeCommunication chatId:chatId chatType:chatType];
        }
        
    } while (0);
    
    if (controller) {
        self.isCalling = YES;
        self.confNavController = [[UINavigationController alloc] initWithRootViewController:controller];
        [self.mainController presentViewController:self.confNavController animated:NO completion:nil];
    }
}

- (void)endConference:(EMCallConference *)aCall
            isDestroy:(BOOL)aIsDestroy
{
    self.isCalling = NO;
    self.confNavController = nil;
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:nil];
    [audioSession setActive:YES error:nil];
    
    [[EMClient sharedClient].conferenceManager stopMonitorSpeaker:aCall];
    
    if (aIsDestroy) {
        [[EMClient sharedClient].conferenceManager destroyConferenceWithId:aCall.confId completion:nil];
    } else {
        [[EMClient sharedClient].conferenceManager leaveConference:aCall completion:nil];
    }
    
    [[DemoCallManager sharedManager] setIsCalling:NO];
}


#endif

@end
