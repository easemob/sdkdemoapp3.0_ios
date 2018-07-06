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
    
    [[EMClient sharedClient].chatManager addDelegate:self delegateQueue:nil];
    [[EMClient sharedClient].conferenceManager addDelegate:self delegateQueue:nil];
    
    EMConferenceMode model = EMConferenceModeLarge;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    id obj = [userDefaults objectForKey:@"audioMix"];
    if (obj) {
        model = (EMConferenceMode)[obj integerValue];
    } else {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:[NSNumber numberWithInteger:model] forKey:@"audioMix"];
        [userDefaults synchronize];
    }
    [[EMClient sharedClient].conferenceManager setMode:model];
}

#pragma mark - EMChatManagerDelegate

- (void)cmdMessagesDidReceive:(NSArray *)aCmdMessages
{
    for (EMMessage *message in aCmdMessages) {
        EMCmdMessageBody *cmdBody = (EMCmdMessageBody *)message.body;
        NSString *action = cmdBody.action;
        if ([action isEqualToString:@"inviteToJoinConference"]) {
            if ([DemoCallManager sharedManager].isCalling) {
                return;
            }
            
            NSString *confId = [message.ext objectForKey:@"confId"];
            EMCallType type = (EMCallType)[[message.ext objectForKey:@"type"] integerValue];
            NSString *creater = [message.ext objectForKey:@"creater"];
            ConferenceViewController *confController = [[ConferenceViewController alloc] initWithConferenceId:confId creater:creater password:@""];
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
    if ([DemoCallManager sharedManager].isCalling) {
        return;
    }
    
    NSData *jsonData = [aExt dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
    EMCallType type = (EMCallType)[[dic objectForKey:@"type"] integerValue];
    NSString *creater = [dic objectForKey:@"creater"];
    ConferenceViewController *confController = [[ConferenceViewController alloc] initWithConferenceId:aConfId creater:creater password:@""];
    [self.mainController.navigationController pushViewController:confController animated:NO];
}

#pragma mark - conference

- (void)pushConferenceController
{
    [[DemoCallManager sharedManager] setIsCalling:YES];
    
    ConferenceViewController *confController = [[ConferenceViewController alloc] init];
    [self.mainController.navigationController pushViewController:confController animated:NO];
}

- (void)pushCustomVideoConferenceController
{
    [[DemoCallManager sharedManager] setIsCalling:YES];
    
    ConferenceViewController *confController = [[ConferenceViewController alloc] initVideoCallWithIsCustomData:YES];
    [self.mainController.navigationController pushViewController:confController animated:NO];
}

- (void)handleMessageToJoinConference:(EMMessage *)aMessage
{
    EMTextMessageBody *textBody = (EMTextMessageBody *)aMessage.body;
    NSString *conferenceId = [aMessage.ext objectForKey:@"conferenceId"];
    NSString *password = [aMessage.ext objectForKey:@"password"];
    if ([conferenceId length] > 0) {
        if ([DemoCallManager sharedManager].isCalling) {
            return;
        }
        
        ConferenceViewController *confController = [[ConferenceViewController alloc] initWithConferenceId:conferenceId creater:@"" password:password];
        [self.mainController.navigationController pushViewController:confController animated:NO];
    }
}

#endif

@end
