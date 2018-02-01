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
            if ([DemoCallManager sharedManager].isCalling) {
                return;
            }
            
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
    if ([DemoCallManager sharedManager].isCalling) {
        return;
    }
    
    NSData *jsonData = [aExt dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
    EMCallType type = (EMCallType)[[dic objectForKey:@"type"] integerValue];
    NSString *creater = [dic objectForKey:@"creater"];
    ConferenceViewController *confController = [[ConferenceViewController alloc] initWithConferenceId:aConfId creater:creater type:type];
    [self.mainController.navigationController pushViewController:confController animated:NO];
}

#pragma mark - conference

- (void)pushConferenceControllerWithType:(EMCallType)aType
{
    [[DemoCallManager sharedManager] setIsCalling:YES];
    
    if (aType == EMCallTypeVoice) {
        ConferenceViewController *confController = [[ConferenceViewController alloc] initWithType:aType];
        [self.mainController.navigationController pushViewController:confController animated:NO];
        return;
    }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"title.conference.default", @"Default") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        ConferenceViewController *confController = [[ConferenceViewController alloc] initVideoCallWithIsCustomData:NO];
        [self.mainController.navigationController pushViewController:confController animated:NO];
    }];
    [alertController addAction:defaultAction];
    
    UIAlertAction *customAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"title.conference.custom", @"Custom") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        ConferenceViewController *confController = [[ConferenceViewController alloc] initVideoCallWithIsCustomData:YES];
        [self.mainController.navigationController pushViewController:confController animated:NO];
    }];
    [alertController addAction:customAction];
    
    [alertController addAction: [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"Cancel") style: UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [[DemoCallManager sharedManager] setIsCalling:NO];
    }]];
    
    [self.mainController.navigationController presentViewController:alertController animated:YES completion:nil];
}

#endif

@end
