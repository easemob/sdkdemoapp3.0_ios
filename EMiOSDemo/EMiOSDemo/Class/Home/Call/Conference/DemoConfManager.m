//
//  DemoConfManager.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 23/11/2016.
//  Copyright © 2016 XieYajie. All rights reserved.
//

#import "DemoConfManager.h"

#import <Hyphenate/Hyphenate.h>

#import "DemoCallManager.h"

#import "EMGlobalVariables.h"

#import "MeetingViewController.h"
#import "Live2ViewController.h"

static DemoConfManager *confManager = nil;

@interface DemoConfManager()<EMConferenceManagerDelegate, EMChatManagerDelegate>

@property (strong, nonatomic) UINavigationController *confNavController;

@end


@implementation DemoConfManager

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMakeConference:) name:CALL_MAKECONFERENCE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSelectConferenceCell:) name:CALL_SELECTCONFERENCECELL object:nil];
}

#pragma mark - EMChatManagerDelegate

- (void)messagesDidReceive:(NSArray *)aMessages
{
    for (EMMessage *message in aMessages) {
        NSString *conferenceId = [message.ext objectForKey:MSG_EXT_CALLID];
        if ([conferenceId length] == 0) {
            continue;
        }
        
        NSString *op = [message.ext objectForKey:MSG_EXT_CALLOP];
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
               popFromController:(UIViewController *)aController
{
    if (gIsCalling) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"错误" message:@"有通话正在进行" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        
        return;
    }
    
    ConfInviteUsersViewController *controller = [[ConfInviteUsersViewController alloc] initWithType:aInviteType isCreate:YES excludeUsers:@[[EMClient sharedClient].currentUsername] groupOrChatroomId:aConversationId];
    
    __weak typeof(self) weakSelf = self;
    [controller setDoneCompletion:^(NSArray *aInviteUsers) {
        gIsCalling = YES;
        
        EMConferenceViewController *controller = nil;
        if (aConfType != EMConferenceTypeLive) {
            controller = [[MeetingViewController alloc] initWithType:aConfType password:@"" inviteUsers:aInviteUsers chatId:aConversationId chatType:aChatType];
        } else {
            controller = [[Live2ViewController alloc] initWithType:aConfType password:@"" inviteUsers:aInviteUsers chatId:aConversationId chatType:aChatType];
        }
        controller.inviteType = aInviteType;
        
        weakSelf.confNavController = [[UINavigationController alloc] initWithRootViewController:controller];
        weakSelf.confNavController.modalPresentationStyle = 0;
        [aController presentViewController:weakSelf.confNavController animated:NO completion:nil];
    }];
    //互动会议模式不需要邀请成员
    if(aConfType != EMConferenceTypeLive){
        controller.modalPresentationStyle = 0;
        [aController presentViewController:controller animated:NO completion:nil];
    }else{
        gIsCalling = YES;
        
        EMConferenceViewController *controller = nil;
        if (aConfType != EMConferenceTypeLive) {
            controller = [[MeetingViewController alloc] initWithType:aConfType password:@"" inviteUsers:nil chatId:aConversationId chatType:aChatType];
        } else {
            controller = [[Live2ViewController alloc] initWithType:aConfType password:@"" inviteUsers:nil chatId:aConversationId chatType:aChatType];
        }
        controller.inviteType = aInviteType;
        
        weakSelf.confNavController = [[UINavigationController alloc] initWithRootViewController:controller];
        weakSelf.confNavController.modalPresentationStyle = 0;
        [aController presentViewController:weakSelf.confNavController animated:NO completion:nil];
    }
}
//关闭会议
- (void)endConference:(EMCallConference *)aCall
            isDestroy:(BOOL)aIsDestroy
{
    gIsCalling = NO;
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
    
    gIsCalling = NO;
}

#pragma mark - NSNotification
//会议发起人
- (void)handleMakeConference:(NSNotification *)aNotif
{
    NSDictionary *dic = aNotif.object;
    EMConferenceType type = (EMConferenceType)[[dic objectForKey:CALL_TYPE] integerValue];
    id model = [dic objectForKey:CALL_MODEL];
    
    NSString *conversationId = nil;
    ConfInviteType inviteType = ConfInviteTypeUser;
    EMChatType chatType = EMChatTypeChat;
    if ([model isKindOfClass:[EMConversationModel class]]) {
        EMConversationModel *cmodel = (EMConversationModel *)model;
        conversationId = cmodel.emModel.conversationId;
        chatType =(EMChatType)cmodel.emModel.type;
        if (cmodel.emModel.type == EMChatTypeGroupChat) {
            inviteType = ConfInviteTypeGroup;
        } else if (cmodel.emModel.type == EMChatTypeChatRoom) {
            inviteType = ConfInviteTypeChatroom;
        }
    }
    
    UIViewController *controller = [dic objectForKey:NOTIF_NAVICONTROLLER];
    if (controller == nil) {
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        controller = window.rootViewController;
    }
    
    [self inviteMemberWithConfType:type
                        inviteType:inviteType
                    conversationId:conversationId
                          chatType:chatType
                 popFromController:controller];
}
//会议接收者
- (void)handleSelectConferenceCell:(NSNotification *)aNotif
{
    id obj = aNotif.object;
    if (!obj || ![obj isKindOfClass:[EMMessage class]]) {
        return;
    }
    
    //如果正在进行1v1通话，不处理
    if (gIsCalling) {
        return;
    }
    
    EMMessage *msg = (EMMessage *)obj;
    //新版属性
    NSString *conferenceId = [msg.ext objectForKey:MSG_EXT_CALLID];
    NSString *password = [msg.ext objectForKey:MSG_EXT_CALLPSWD];
    //如果新版属性不存在，判断旧版本属性
    if ([conferenceId length] == 0) {
        conferenceId = [msg.ext objectForKey:@"conferenceId"];
        password = [msg.ext objectForKey:@"password"];
    }
    
    //如果conferenceId不存在，则不处理
    if ([conferenceId length] == 0) {
        return;
    }
    
    EMConferenceViewController *controller = nil;
    NSString *op = [msg.ext objectForKey:MSG_EXT_CALLOP];
    do {
        //如果“em_conference_op”属性存在，说明是新版
        if ([op length] == 0) {
            controller = [[MeetingViewController alloc] initWithJoinConfId:conferenceId password:password type:EMConferenceTypeLargeCommunication chatId:nil chatType:EMChatTypeChat];
            break;
        }
        
        if (![op isEqualToString:@"invite"]) {
            break;
        }
        
        EMConferenceType type = (EMConferenceType)[[msg.ext objectForKey:@"em_conference_type"] integerValue];
        NSString *chatId = [msg.ext objectForKey:@"em_conference_chatId"];
        EMChatType chatType = (EMChatType)[[msg.ext objectForKey:@"em_conference_chatType"] integerValue];
        if (type == EMConferenceTypeLive) {
            NSString *admin = [msg.ext objectForKey:@"em_conference_admin"];
            if ([admin length] == 0) {
                admin = msg.from;
            }
            controller = [[Live2ViewController alloc] initWithJoinConfId:conferenceId password:password admin:admin chatId:chatId chatType:chatType];
        } else {
            controller = [[MeetingViewController alloc] initWithJoinConfId:conferenceId password:password type:EMConferenceTypeLargeCommunication chatId:chatId chatType:chatType];
        }
        
    } while (0);
    
    if (controller) {
        gIsCalling = YES;
        self.confNavController = [[UINavigationController alloc] initWithRootViewController:controller];
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        UIViewController *rootViewController = window.rootViewController;
        self.confNavController.modalPresentationStyle = 0;
        [rootViewController presentViewController:self.confNavController animated:NO completion:nil];
    }
}

@end
