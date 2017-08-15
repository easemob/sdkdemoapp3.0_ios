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

#import "MainViewController.h"
#import "EMConfUserSelectionViewController.h"
#import "ConferenceViewController.h"


static DemoConfManager *confManager = nil;

@interface DemoConfManager()<EMConferenceManagerDelegate, EMChatManagerDelegate>

@property (strong, nonatomic) ConferenceViewController *currentController;

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
    _currentController = nil;
    
    [[EMClient sharedClient].conferenceManager addDelegate:self delegateQueue:nil];
    [[EMClient sharedClient].chatManager addDelegate:self delegateQueue:nil];
}

#pragma mark - EMChatManagerDelegate

- (void)cmdMessagesDidReceive:(NSArray *)aCmdMessages
{
    for (EMMessage *message in aCmdMessages) {
        EMCmdMessageBody *cmdBody = (EMCmdMessageBody *)message.body;
        NSString *action = cmdBody.action;
        if ([action isEqualToString:@"inviteToJoinConference"]) {
            NSString *confId = [message.ext objectForKey:@"confId"];
            EMCallType type = (EMCallType)[[message.ext objectForKey:@"type"] integerValue];
            NSString *creater = [message.ext objectForKey:@"creater"];
            ConferenceViewController *confController = [[ConferenceViewController alloc] initWithConferenceId:confId creater:creater type:type];
            [self.mainController.navigationController pushViewController:confController animated:NO];
            
        } else if ([action isEqualToString:@"__Call_ReqP2P_ConferencePattern"]) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"已转为会议模式" delegate:self cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
            [alertView show];
        }
    }
}

#pragma mark - EMConferenceManagerDelegate

- (void)userDidRecvInvite:(NSString *)aConfId
                 password:(NSString *)aPassword
                      ext:(NSString *)aExt
{
    NSData *jsonData = [aExt dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
    EMCallType type = (EMCallType)[[dic objectForKey:@"type"] integerValue];
    NSString *creater = [dic objectForKey:@"creater"];
    ConferenceViewController *confController = [[ConferenceViewController alloc] initWithConferenceId:aConfId creater:creater type:type];
    [self.mainController.navigationController pushViewController:confController animated:NO];
}

#pragma mark - conference

- (void)createConferenceWithType:(EMCallType)aType
{
    ConferenceViewController *confController = [[ConferenceViewController alloc] initWithType:aType];
    [self.mainController.navigationController pushViewController:confController animated:NO];
    
//    NSArray *contacts = [[EMClient sharedClient].contactManager getContacts];
//    EMConfUserSelectionViewController *controller = [[EMConfUserSelectionViewController alloc] initWithDataSource:contacts selectedUsers:@[[EMClient sharedClient].currentUsername]];
//    [controller setSelecteUserFinishedCompletion:^(NSArray *selectedUsers) {
//        EMGroupOptions *options = [[EMGroupOptions alloc] init];
//        options.style = EMGroupStylePublicOpenJoin;
//        options.maxUsersCount = 6;
//        EMError *error = nil;
//        EMGroup *group = [[EMClient sharedClient].groupManager createGroupWithSubject:@"多人会议" description:nil invitees:selectedUsers message:nil setting:options error:&error];
//        if (error) {
//            NSLog(@"创建多人会议群组失败");
//        } else {
//            NSString *localName = [EMClient sharedClient].currentUsername;
//            EMTextMessageBody *body = [[EMTextMessageBody alloc] initWithText:[NSString stringWithFormat:@"%@ 发起了多人会议", localName]];
//            EMMessage *message = [[EMMessage alloc] initWithConversationID:group.groupId from:localName to:group.groupId body:body ext:nil];
//            message.chatType = EMChatTypeGroupChat;
//            [[EMClient sharedClient].chatManager sendMessage:message progress:nil completion:nil];
//        }
//        
//        ConferenceViewController *confController = [[ConferenceViewController alloc] initWithUsers:selectedUsers type:aType conversationId:group.groupId];
//        [self.mainController.navigationController pushViewController:confController animated:NO];
//    }];
//    [self.mainController.navigationController pushViewController:controller animated:YES];
}


#endif

@end
