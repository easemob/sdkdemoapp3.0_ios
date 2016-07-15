/************************************************************
 *  * Hyphenate CONFIDENTIAL
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Hyphenate Inc.
 */

#import "ChatDemoHelper.h"

#import "AppDelegate.h"
#import "ApplyViewController.h"
#import "MBProgressHUD.h"

#ifdef REDPACKET_AVALABLE
#import "RedpacketOpenConst.h"
#import "RedPacketUserConfig.h"
#endif


#if DEMO_CALL == 1

#import "CallViewController.h"
#import "ConferenceViewController.h"

@interface ChatDemoHelper()<EMCallManagerDelegate>
{
    NSTimer *_callTimer;
    NSConditionLock *_callConteollerLock;
    NSInteger _callCount;
}

@end

#endif

static ChatDemoHelper *helper = nil;

@implementation ChatDemoHelper

+ (instancetype)shareHelper
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        helper = [[ChatDemoHelper alloc] init];
    });
    return helper;
}

- (void)dealloc
{
    [[EMClient sharedClient] removeDelegate:self];
    [[EMClient sharedClient].groupManager removeDelegate:self];
    [[EMClient sharedClient].contactManager removeDelegate:self];
    [[EMClient sharedClient].roomManager removeDelegate:self];
    [[EMClient sharedClient].chatManager removeDelegate:self];
    
#if DEMO_CALL == 1
    [[EMClient sharedClient].callManager removeDelegate:self];
#endif
}

- (id)init
{
    self = [super init];
    if (self) {
        [self initHelper];
    }
    return self;
}

- (void)initHelper
{
#ifdef REDPACKET_AVALABLE
    [[RedPacketUserConfig sharedConfig] beginObserveMessage];
#endif
    
    [[EMClient sharedClient] addDelegate:self delegateQueue:nil];
    [[EMClient sharedClient].groupManager addDelegate:self delegateQueue:nil];
    [[EMClient sharedClient].contactManager addDelegate:self delegateQueue:nil];
    [[EMClient sharedClient].roomManager addDelegate:self delegateQueue:nil];
    [[EMClient sharedClient].chatManager addDelegate:self delegateQueue:nil];
    
#if DEMO_CALL == 1
    [[EMClient sharedClient].callManager addDelegate:self delegateQueue:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(makeCall:) name:KNOTIFICATION_CALL object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(makeConference:) name:KNOTIFICATION_CONF object:nil];
    _callConteollerLock = [[NSConditionLock alloc] init];
    
    _callCount = 0;
#endif
}

- (void)asyncPushOptions
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        EMError *error = nil;
        [[EMClient sharedClient] getPushOptionsFromServerWithError:&error];
    });
}

- (void)asyncGroupFromServer
{
    __weak typeof(self) weakself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[EMClient sharedClient].groupManager loadAllMyGroupsFromDB];
        EMError *error = nil;
        [[EMClient sharedClient].groupManager getMyGroupsFromServerWithError:&error];
        if (!error) {
            if (weakself.contactViewVC) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakself.contactViewVC reloadGroupView];
                });
            }
        }
    });
}

- (void)asyncConversationFromDB
{
    __weak typeof(self) weakself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *array = [[EMClient sharedClient].chatManager loadAllConversationsFromDB];
        [array enumerateObjectsUsingBlock:^(EMConversation *conversation, NSUInteger idx, BOOL *stop){
            if(conversation.latestMessage == nil){
                [[EMClient sharedClient].chatManager deleteConversation:conversation.conversationId deleteMessages:NO];
            }
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (weakself.conversationListVC) {
                [weakself.conversationListVC refreshDataSource];
            }
            
            if (weakself.mainVC) {
                [weakself.mainVC setupUnreadMessageCount];
            }
        });
    });
}

#pragma mark - EMClientDelegate

// 网络状态变化回调
- (void)didConnectionStateChanged:(EMConnectionState)connectionState
{
    [self.mainVC networkChanged:connectionState];
}

- (void)didAutoLoginWithError:(EMError *)error
{
    if (error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"自动登录失败，请重新登录" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        alertView.tag = 100;
        [alertView show];
    } else if([[EMClient sharedClient] isConnected]){
        UIView *view = self.mainVC.view;
        [MBProgressHUD showHUDAddedTo:view animated:YES];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            BOOL flag = [[EMClient sharedClient] dataMigrationTo3];
            if (flag) {
                [self asyncGroupFromServer];
                [self asyncConversationFromDB];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideAllHUDsForView:view animated:YES];
            });
        });
    }
}

- (void)didLoginFromOtherDevice
{
    [self _clearHelper];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", @"Prompt") message:NSLocalizedString(@"loginAtOtherDevice", @"your login account has been in other places") delegate:self cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
    [alertView show];
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@NO];
}

- (void)didRemovedFromServer
{
    [self _clearHelper];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", @"Prompt") message:NSLocalizedString(@"loginUserRemoveFromServer", @"your account has been removed from the server side") delegate:self cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
    [alertView show];
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@NO];
}

//- (void)didServersChanged
//{
//    [self _clearHelper];
//    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@NO];
//}
//
//- (void)didAppkeyChanged
//{
//    [self _clearHelper];
//    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@NO];
//}

#pragma mark - EMChatManagerDelegate

- (void)didUpdateConversationList:(NSArray *)aConversationList
{
    if (self.mainVC) {
        [_mainVC setupUnreadMessageCount];
    }
    
    if (self.conversationListVC) {
        [_conversationListVC refreshDataSource];
    }
}

- (void)didReceiveCmdMessages:(NSArray *)aCmdMessages
{
    for(EMMessage *message in aCmdMessages){
        EMCmdMessageBody *body = (EMCmdMessageBody *)message.body;
        if ([body.action containsString:@"inviteJoinConf"]) {
            NSString *confId = [body.action pathExtension];
            NSString *from = message.from;
            [self recvToJoinConference:confId from:from];
        }
    }
}

- (void)didReceiveMessages:(NSArray *)aMessages
{
    BOOL isRefreshCons = YES;
    for(EMMessage *message in aMessages){
        BOOL needShowNotification = (message.chatType != EMChatTypeChat) ? [self _needShowNotification:message.conversationId] : YES;
        
#ifdef REDPACKET_AVALABLE
        /**
         *  屏蔽红包被抢消息的提示
         */
        NSDictionary *dict = message.ext;
        needShowNotification = (dict && [dict valueForKey:RedpacketKeyRedpacketTakenMessageSign]) ? NO : needShowNotification;
#endif
        
        if (needShowNotification) {
#if !TARGET_IPHONE_SIMULATOR
            UIApplicationState state = [[UIApplication sharedApplication] applicationState];
            switch (state) {
                case UIApplicationStateActive:
                    [self.mainVC playSoundAndVibration];
                    break;
                case UIApplicationStateInactive:
                    [self.mainVC playSoundAndVibration];
                    break;
                case UIApplicationStateBackground:
                    [self.mainVC showNotificationWithMessage:message];
                    break;
                default:
                    break;
            }
#endif
        }
        
        if (_chatVC == nil) {
            _chatVC = [self _getCurrentChatView];
        }
        BOOL isChatting = NO;
        if (_chatVC) {
            isChatting = [message.conversationId isEqualToString:_chatVC.conversation.conversationId];
        }
        if (_chatVC == nil || !isChatting) {
            if (self.conversationListVC) {
                [_conversationListVC refresh];
            }
            
            if (self.mainVC) {
                [_mainVC setupUnreadMessageCount];
            }
            return;
        }
        
        if (isChatting) {
            isRefreshCons = NO;
        }
    }
    
    if (isRefreshCons) {
        if (self.conversationListVC) {
            [_conversationListVC refresh];
        }
        
        if (self.mainVC) {
            [_mainVC setupUnreadMessageCount];
        }
    }
}

#pragma mark - EMGroupManagerDelegate

- (void)didReceiveLeavedGroup:(EMGroup *)aGroup
                       reason:(EMGroupLeaveReason)aReason
{
    NSString *str = nil;
    if (aReason == EMGroupLeaveReasonBeRemoved) {
        str = [NSString stringWithFormat:@"Your are kicked out from group: %@ [%@]", aGroup.subject, aGroup.groupId];
    } else if (aReason == EMGroupLeaveReasonDestroyed) {
        str = [NSString stringWithFormat:@"Group: %@ [%@] is destroyed", aGroup.subject, aGroup.groupId];
    }
    
    if (str.length > 0) {
        TTAlertNoTitle(str);
    }
    
    NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:_mainVC.navigationController.viewControllers];
    ChatViewController *chatViewContrller = nil;
    for (id viewController in viewControllers)
    {
        if ([viewController isKindOfClass:[ChatViewController class]] && [aGroup.groupId isEqualToString:[(ChatViewController *)viewController conversation].conversationId])
        {
            chatViewContrller = viewController;
            break;
        }
    }
    if (chatViewContrller)
    {
        [viewControllers removeObject:chatViewContrller];
        if ([viewControllers count] > 0) {
            [_mainVC.navigationController setViewControllers:@[viewControllers[0]] animated:YES];
        } else {
            [_mainVC.navigationController setViewControllers:viewControllers animated:YES];
        }
    }
}

- (void)didReceiveJoinGroupApplication:(EMGroup *)aGroup
                             applicant:(NSString *)aApplicant
                                reason:(NSString *)aReason
{
    if (!aGroup || !aApplicant) {
        return;
    }
    
    if (!aReason || aReason.length == 0) {
        aReason = [NSString stringWithFormat:NSLocalizedString(@"group.applyJoin", @"%@ apply to join groups\'%@\'"), aApplicant, aGroup.subject];
    }
    else{
        aReason = [NSString stringWithFormat:NSLocalizedString(@"group.applyJoinWithName", @"%@ apply to join groups\'%@\'：%@"), aApplicant, aGroup.subject, aReason];
    }
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:@{@"title":aGroup.subject, @"groupId":aGroup.groupId, @"username":aApplicant, @"groupname":aGroup.subject, @"applyMessage":aReason, @"applyStyle":[NSNumber numberWithInteger:ApplyStyleJoinGroup]}];
    [[ApplyViewController shareController] addNewApply:dic];
    if (self.mainVC) {
        [self.mainVC setupUntreatedApplyCount];
#if !TARGET_IPHONE_SIMULATOR
        [self.mainVC playSoundAndVibration];
#endif
    }
    
    if (self.contactViewVC) {
        [self.contactViewVC reloadApplyView];
    }
}

- (void)didJoinedGroup:(EMGroup *)aGroup
               inviter:(NSString *)aInviter
               message:(NSString *)aMessage
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", @"Prompt") message:[NSString stringWithFormat:@"%@ invite you to group: %@ [%@]", aInviter, aGroup.subject, aGroup.groupId] delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
    [alertView show];
}

- (void)didReceiveDeclinedJoinGroup:(NSString *)aGroupId
                             reason:(NSString *)aReason
{
    if (!aReason || aReason.length == 0) {
        aReason = [NSString stringWithFormat:NSLocalizedString(@"group.beRefusedToJoin", @"be refused to join the group\'%@\'"), aGroupId];
    }
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", @"Prompt") message:aReason delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
    [alertView show];
}

- (void)didReceiveAcceptedJoinGroup:(EMGroup *)aGroup
{
    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"group.agreedAndJoined", @"agreed to join the group of \'%@\'"), aGroup.subject];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", @"Prompt") message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
    [alertView show];
}

- (void)didReceiveGroupInvitation:(NSString *)aGroupId
                          inviter:(NSString *)aInviter
                          message:(NSString *)aMessage
{
    if (!aGroupId || !aInviter) {
        return;
    }
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:@{@"title":@"", @"groupId":aGroupId, @"username":aInviter, @"groupname":@"", @"applyMessage":aMessage, @"applyStyle":[NSNumber numberWithInteger:ApplyStyleGroupInvitation]}];
    [[ApplyViewController shareController] addNewApply:dic];
    if (self.mainVC) {
        [self.mainVC setupUntreatedApplyCount];
#if !TARGET_IPHONE_SIMULATOR
        [self.mainVC playSoundAndVibration];
#endif
    }
    
    if (self.contactViewVC) {
        [self.contactViewVC reloadApplyView];
    }
}

#pragma mark - EMContactManagerDelegate
- (void)didReceiveAgreedFromUsername:(NSString *)aUsername
{
    NSString *msgstr = [NSString stringWithFormat:@"%@同意了加好友申请", aUsername];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:msgstr delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertView show];
}

- (void)didReceiveDeclinedFromUsername:(NSString *)aUsername
{
    NSString *msgstr = [NSString stringWithFormat:@"%@拒绝了加好友申请", aUsername];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:msgstr delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertView show];
}

- (void)didReceiveDeletedFromUsername:(NSString *)aUsername
{
    NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:_mainVC.navigationController.viewControllers];
    ChatViewController *chatViewContrller = nil;
    for (id viewController in viewControllers)
    {
        if ([viewController isKindOfClass:[ChatViewController class]] && [aUsername isEqualToString:[(ChatViewController *)viewController conversation].conversationId])
        {
            chatViewContrller = viewController;
            break;
        }
    }
    if (chatViewContrller)
    {
        [viewControllers removeObject:chatViewContrller];
        if ([viewControllers count] > 0) {
            [_mainVC.navigationController setViewControllers:@[viewControllers[0]] animated:YES];
        } else {
            [_mainVC.navigationController setViewControllers:viewControllers animated:YES];
        }
    }
    [_mainVC showHint:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"delete", @"delete"), aUsername]];
    [_contactViewVC reloadDataSource];
}

- (void)didReceiveAddedFromUsername:(NSString *)aUsername
{
    [_contactViewVC reloadDataSource];
}

- (void)didReceiveFriendInvitationFromUsername:(NSString *)aUsername
                                       message:(NSString *)aMessage
{
    if (!aUsername) {
        return;
    }
    
    if (!aMessage) {
        aMessage = [NSString stringWithFormat:NSLocalizedString(@"friend.somebodyAddWithName", @"%@ add you as a friend"), aUsername];
    }
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:@{@"title":aUsername, @"username":aUsername, @"applyMessage":aMessage, @"applyStyle":[NSNumber numberWithInteger:ApplyStyleFriend]}];
    [[ApplyViewController shareController] addNewApply:dic];
    if (self.mainVC) {
        [self.mainVC setupUntreatedApplyCount];
#if !TARGET_IPHONE_SIMULATOR
        [self.mainVC playSoundAndVibration];
        
        BOOL isAppActivity = [[UIApplication sharedApplication] applicationState] == UIApplicationStateActive;
        if (!isAppActivity) {
            //发送本地推送
            UILocalNotification *notification = [[UILocalNotification alloc] init];
            notification.fireDate = [NSDate date]; //触发通知的时间
            notification.alertBody = [NSString stringWithFormat:NSLocalizedString(@"friend.somebodyAddWithName", @"%@ add you as a friend"), aUsername];
            notification.alertAction = NSLocalizedString(@"open", @"Open");
            notification.timeZone = [NSTimeZone defaultTimeZone];
        }
#endif
    }
    [_contactViewVC reloadApplyView];
}

#pragma mark - EMChatroomManagerDelegate

- (void)didReceiveUserJoinedChatroom:(EMChatroom *)aChatroom
                            username:(NSString *)aUsername
{
    
}

- (void)didReceiveUserLeavedChatroom:(EMChatroom *)aChatroom
                            username:(NSString *)aUsername
{

}

- (void)didReceiveKickedFromChatroom:(EMChatroom *)aChatroom
                              reason:(EMChatroomBeKickedReason)aReason
{
    
}

#pragma mark - EMCallManagerDelegate

#if DEMO_CALL == 1

- (void)didReceiveCallIncoming:(EMCallSession *)aSession
{
    if (!aSession) {
        return;
    }
    
//    [self hangupCallWithId:aSession.callId reason:EMCallEndReasonHangup];
////    [self makeCallWithUsername:aSession.remoteName isVideo:NO];
//    
//    return;
    
    if(_callController && _callController.callSession.status != EMCallSessionStatusDisconnected){
        [[EMClient sharedClient].callManager asyncEndCallWithId:aSession.callId reason:EMCallEndReasonBusy];
        return;
    }
    
    if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive) {
        [[EMClient sharedClient].callManager asyncEndCallWithId:aSession.callId reason:EMCallEndReasonFailed];
        
        return;
    }
    
    [self _startCallTimer];
    
    NSLog(@"push call controller---- recv %@", aSession.callId);
    [_callConteollerLock lock];
    self.callController = [[CallViewController alloc] initWithSession:aSession isCaller:NO status:NSLocalizedString(@"call.connecting", "Connecting...")];
    _callController.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [_mainVC presentViewController:_callController animated:NO completion:nil];
    [_callConteollerLock unlock];
}

- (void)didReceiveCallConnected:(EMCallSession *)aSession
{
    if (_callController && [aSession.callId isEqualToString:_callController.callSession.callId]) {
        [_callConteollerLock lock];
        _callController.statusLabel.text = NSLocalizedString(@"call.finished", "Establish call finished");
        _callController.answerButton.enabled = YES;
        [_callConteollerLock unlock];
        
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        [audioSession setActive:YES error:nil];
    }
}

- (void)didReceiveCallAccepted:(EMCallSession *)aSession
{
    if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[EMClient sharedClient].callManager asyncEndCallWithId:aSession.callId reason:EMCallEndReasonFailed];
        });
        
        if ([aSession.callId isEqualToString:_callController.callSession.callId]) {
            [self _stopCallTimer];
            
            [_callConteollerLock lock];
            CallViewController *tmpController = self.callController;
            _callController = nil;
            [tmpController close];
            [_callConteollerLock unlock];
        }
        
        return;
    }
    
    if (_callController && [aSession.callId isEqualToString:_callController.callSession.callId]) {
        [self _stopCallTimer];
        
        [_callConteollerLock lock];
        NSString *connectStr = aSession.connectType == EMCallConnectTypeRelay ? @"Relay" : @"Direct";
        _callController.statusLabel.text = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"call.speak", @"Can speak..."), connectStr];
        _callController.timeLabel.hidden = NO;
        [_callController startTimer];
        [_callController startShowInfo];
        _callController.cancelButton.hidden = NO;
        _callController.rejectButton.hidden = YES;
        _callController.answerButton.hidden = YES;
        [_callConteollerLock unlock];
    }
}

- (void)didReceiveCallTerminated:(EMCallSession *)aSession
                          reason:(EMCallEndReason)aReason
                           error:(EMError *)aError
{
    if (_callController && [aSession.callId isEqualToString:_callController.callSession.callId]) {
        [self _stopCallTimer];
        
        [_callConteollerLock lock];
        CallViewController *tmpController = self.callController;
        _callController = nil;
        [tmpController close];
        [_callConteollerLock unlock];
        
        if (aReason != EMCallEndReasonHangup) {
            NSString *reasonStr = @"";
            switch (aReason) {
                case EMCallEndReasonNoResponse:
                {
                    reasonStr = NSLocalizedString(@"call.noResponse", @"NO response");
                }
                    break;
                case EMCallEndReasonDecline:
                {
                    reasonStr = NSLocalizedString(@"call.rejected", @"Reject the call");
                }
                    break;
                case EMCallEndReasonBusy:
                {
                    reasonStr = NSLocalizedString(@"call.in", @"In the call...");
                }
                    break;
                case EMCallEndReasonFailed:
                {
                    reasonStr = NSLocalizedString(@"call.connectFailed", @"Connect failed");
                }
                    break;
                case EMCallEndReasonRemoteOffline:
                {
                    reasonStr = NSLocalizedString(@"call.remoteOffline", @"Remote offline");
                }
                    break;
                default:
                    break;
            }
            
            if (aError) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:aError.errorDescription delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
                [alertView show];
            }
            else{
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:reasonStr delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
                [alertView show];
            }
        }
    }
}

- (void)didReceiveCallNetworkChanged:(EMCallSession *)aSession status:(EMCallNetworkStatus)aStatus
{
    if (_callController && [aSession.callId isEqualToString:_callController.callSession.callId]) {
        [_callController setNetwork:aStatus];
    }
}

#endif

#pragma mark - public 

#if DEMO_CALL == 1

- (void)makeCall:(NSNotification*)notify
{
    if (notify.object) {
        [self makeCallWithUsername:[notify.object valueForKey:@"chatter"] isVideo:[[notify.object objectForKey:@"type"] boolValue]];
        
//        //TODO: test case
//        int index = 0;
//        NSString *chatter = [notify.object valueForKey:@"chatter"];
//        BOOL isVideo = [[notify.object objectForKey:@"type"] boolValue];
//        while (index < 10) {
//            NSString *callId = [self makeCallWithUsername:chatter isVideo:isVideo];
//            
//            [self hangupCallWithId:callId reason:EMCallEndReasonHangup];
//            ++index;
//        }
    }
}

- (void)_startCallTimer
{
//    _callTimer = [NSTimer scheduledTimerWithTimeInterval:50 target:self selector:@selector(_cancelCall) userInfo:nil repeats:NO];
}

- (void)_stopCallTimer
{
//    if (_callTimer == nil) {
//        return;
//    }
//    
//    [_callTimer invalidate];
//    _callTimer = nil;
}

- (void)_cancelCall
{
    [self hangupCallWithId:_callController.callSession.callId reason:EMCallEndReasonNoResponse];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"call.autoHangup", @"No response and Hang up") delegate:self cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
    [alertView show];
}

- (void)makeCallWithUsername:(NSString *)aUsername
                     isVideo:(BOOL)aIsVideo
{
    if (_callController) {
        [_callConteollerLock lock];
        CallViewController *tmpController = self.callController;
        _callController = nil;
        [tmpController close];
        [_callConteollerLock unlock];
    }
    
    if ([aUsername length] == 0) {
        return ;
    }
    
    EMCallType type = aIsVideo ? EMCallTypeVideo : EMCallTypeVoice;
    [[EMClient sharedClient].callManager asyncMakeCallWithType:type remoteName:aUsername success:^(EMCallSession *aCallSession) {
        
        NSLog(@"push call controller---- make %@", aCallSession.callId);
        [_callConteollerLock lock];
        self.callController = [[CallViewController alloc] initWithSession:aCallSession isCaller:YES status:NSLocalizedString(@"call.connecting", @"Connecting...")];
        [_mainVC presentViewController:_callController animated:NO completion:nil];
        [_callConteollerLock unlock];
        
        [self _startCallTimer];
    } failure:^(EMError *aError) {
        [_callConteollerLock lock];
        CallViewController *tmpController = self.callController;
        _callController = nil;
        [tmpController close];
        [_callConteollerLock unlock];
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:aError.errorDescription delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
        [alertView show];
    }];
}

- (void)hangupCallWithId:(NSString *)aCallId
                  reason:(EMCallEndReason)aReason
{
    if ([aCallId length] == 0) {
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[EMClient sharedClient].callManager asyncEndCallWithId:aCallId reason:aReason];
    });
    
    [self _stopCallTimer];
    
    [_callConteollerLock lock];
    CallViewController *tmpController = self.callController;
    _callController = nil;
    [tmpController close];
    [_callConteollerLock unlock];
}

- (void)answerCallWithId:(NSString *)aCallId
{
    if ([aCallId length] == 0) {
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        EMError *error = [[EMClient sharedClient].callManager asyncAnswerCallWithId:aCallId];
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error.code == EMErrorNetworkUnavailable || error.code == EMErrorServerNotReachable) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"network.disconnection", @"Network disconnection") delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
                    [alertView show];
                }
                else{
                    [self hangupCallWithId:aCallId reason:EMCallEndReasonFailed];
                }
            });
        }
    });
}

#pragma mark - Conference

- (void)makeConference:(NSNotification*)notify
{
    ConferenceViewController *confController = [[ConferenceViewController alloc] init];
    [_mainVC.navigationController pushViewController:confController animated:NO];
}

- (void)recvToJoinConference:(NSString *)aConfId
                        from:(NSString *)aFrom
{
    NSString *str = [NSString stringWithFormat:@"%@ 邀请你加入会议", aFrom];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:str delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertView show];
    
    ConferenceViewController *confController = [[ConferenceViewController alloc] initWithConferenceId:aConfId from:aFrom];
    [_mainVC.navigationController pushViewController:confController animated:NO];
}

#endif

#pragma mark - private
- (BOOL)_needShowNotification:(NSString *)fromChatter
{
    BOOL ret = YES;
    NSArray *igGroupIds = [[EMClient sharedClient].groupManager getAllIgnoredGroupIds];
    for (NSString *str in igGroupIds) {
        if ([str isEqualToString:fromChatter]) {
            ret = NO;
            break;
        }
    }
    return ret;
}

- (ChatViewController*)_getCurrentChatView
{
    NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:_mainVC.navigationController.viewControllers];
    ChatViewController *chatViewContrller = nil;
    for (id viewController in viewControllers)
    {
        if ([viewController isKindOfClass:[ChatViewController class]])
        {
            chatViewContrller = viewController;
            break;
        }
    }
    return chatViewContrller;
}

- (void)_clearHelper
{
    self.mainVC = nil;
    self.conversationListVC = nil;
    self.chatVC = nil;
    self.contactViewVC = nil;
    
    [[EMClient sharedClient] logout:NO];
    
#if DEMO_CALL == 1
    [self hangupCallWithId:_callController.callSession.callId reason:EMCallEndReasonFailed];
#endif
}
@end
