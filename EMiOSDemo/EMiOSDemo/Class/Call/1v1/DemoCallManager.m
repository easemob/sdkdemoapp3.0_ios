//
//  DemoCallManager.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 22/11/2016.
//  Copyright © 2016 XieYajie. All rights reserved.
//

#import "DemoCallManager.h"

#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>

#import "EMCallOptions+NSCoding.h"

#import "EMGlobalVariables.h"
#import "Call1v1AudioViewController.h"
#import "Call1v1VideoViewController.h"

#ifdef ENABLE_RECORDER_PLUGIN
#import "EMCallRecorderPlugin.h"
#endif

static DemoCallManager *callManager = nil;

@interface DemoCallManager()<EMChatManagerDelegate, EMCallManagerDelegate, EMCallBuilderDelegate>

@property (strong, nonatomic) NSObject *callLock;
@property (strong, nonatomic) EMCallSession *currentCall;
@property (nonatomic, strong) EM1v1CallViewController *currentController;

@property (strong, nonatomic) NSTimer *timeoutTimer;

@property (nonatomic, strong) CTCallCenter *callCenter;

@end


@implementation DemoCallManager

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
        callManager = [[DemoCallManager alloc] init];
    });
    
    return callManager;
}

- (void)dealloc
{
    self.callCenter = nil;
    [[EMClient sharedClient].chatManager removeDelegate:self];
    [[EMClient sharedClient].callManager removeDelegate:self];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CALL_MAKE1V1 object:nil];
}

#pragma mark - private

- (void)_initManager
{
    _callLock = [[NSObject alloc] init];
    _currentCall = nil;
    _currentController = nil;
    
    [[EMClient sharedClient].chatManager addDelegate:self delegateQueue:nil];
    [[EMClient sharedClient].callManager addDelegate:self delegateQueue:nil];
    [[EMClient sharedClient].callManager setBuilderDelegate:self];
    
#ifdef ENABLE_RECORDER_PLUGIN
    //录制相关功能初始化
    [EMCallRecorderPlugin initGlobalConfig];
#endif
    
    NSString *file = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"calloptions.data"];
    EMCallOptions *options = [[EMClient sharedClient].callManager getCallOptions];
    if ([[NSFileManager defaultManager] fileExistsAtPath:file]) {
        options = [NSKeyedUnarchiver unarchiveObjectWithFile:file];
    } else {
        options = [[EMClient sharedClient].callManager getCallOptions];
        options.isSendPushIfOffline = NO;
        options.videoResolution = EMCallVideoResolution640_480;
    }
    [[EMClient sharedClient].callManager setCallOptions:options];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMake1v1Call:) name:CALL_MAKE1V1 object:nil];
    
//    __weak typeof(self) weakSelf = self;
//    self.callCenter = [[CTCallCenter alloc] init];
//    self.callCenter.callEventHandler = ^(CTCall* call) {
////        if(call.callState == CTCallStateConnected) {
////            [weakSelf hangupCallWithReason:EMCallEndReasonBusy];
////        }
//
//        if(call.callState == CTCallStateConnected) {
//            [weakSelf.currentController muteCall];
//        } else if(call.callState == CTCallStateDisconnected) {
//            [weakSelf.currentController resumeCall];
//        }
//    };
}

#pragma mark - Call Timeout Before Answered

- (void)_timeoutBeforeCallAnswered
{
    [self endCallWithId:self.currentCall.callId reason:EMCallEndReasonNoResponse];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"call.autoHangup", @"No response and Hang up") delegate:self cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
    [alertView show];
}

- (void)_startCallTimeoutTimer
{
    self.timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:50 target:self selector:@selector(_timeoutBeforeCallAnswered) userInfo:nil repeats:NO];
}

- (void)_stopCallTimeoutTimer
{
    if (self.timeoutTimer == nil) {
        return;
    }
    
    [self.timeoutTimer invalidate];
    self.timeoutTimer = nil;
}

#pragma mark - EMCallManagerDelegate

- (void)callDidReceive:(EMCallSession *)aSession
{
    if (!aSession || [aSession.callId length] == 0) {
        return ;
    }
    
    if(gIsCalling || (self.currentCall && self.currentCall.status != EMCallSessionStatusDisconnected)){
        [[EMClient sharedClient].callManager endCall:aSession.callId reason:EMCallEndReasonBusy];
        return;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:CALL_PUSH_VIEWCONTROLLER object:nil];
    
    gIsCalling = YES;
    @synchronized (_callLock) {
        [self _startCallTimeoutTimer];
        
        self.currentCall = aSession;
        if (aSession.type == EMCallTypeVoice) {
            self.currentController = [[Call1v1AudioViewController alloc] initWithCallSession:self.currentCall];
        } else {
            self.currentController = [[Call1v1VideoViewController alloc] initWithCallSession:self.currentCall];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.currentController) {
                self.currentController.modalPresentationStyle = UIModalPresentationOverFullScreen;
                UIWindow *window = [[UIApplication sharedApplication] keyWindow];
                UIViewController *rootViewController = window.rootViewController;
                [rootViewController presentViewController:self.currentController animated:NO completion:nil];
            }
        });
    }
}

- (void)callDidConnect:(EMCallSession *)aSession
{
    if ([aSession.callId isEqualToString:self.currentCall.callId]) {
        self.currentController.callStatus = EMCallSessionStatusConnected;
    }
}

- (void)callDidAccept:(EMCallSession *)aSession
{
    if ([aSession.callId isEqualToString:self.currentCall.callId]) {
        [self _stopCallTimeoutTimer];
        self.currentController.callStatus = EMCallSessionStatusAccepted;
    }
}

- (void)callDidEnd:(EMCallSession *)aSession
            reason:(EMCallEndReason)aReason
             error:(EMError *)aError
{
    if (![aSession.callId isEqualToString:self.currentCall.callId]) {
        return;
    }
    
    [self _endCallWithId:aSession.callId isNeedHangup:NO reason:aReason];
    if (aReason != EMCallEndReasonHangup) {
        if (aError) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:aError.errorDescription delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
            [alertView show];
        } else {
            NSString *reasonStr = @"通话结束";
            switch (aReason) {
                case EMCallEndReasonNoResponse:
                    reasonStr = @"没有响应";
                    break;
                case EMCallEndReasonDecline:
                    reasonStr = @"对方拒绝接通通话";
                    break;
                case EMCallEndReasonBusy:
                    reasonStr = @"对方正在通话中";
                    break;
                case EMCallEndReasonFailed:
                    reasonStr = @"通话建立连接失败";
                    break;
                case EMCallEndReasonRemoteOffline:
                    reasonStr = @"对方不在线，无法接听通话";
                    break;
                default:
                    break;
            }
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:reasonStr delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
            [alertView show];
        }
    }
}

- (void)callStateDidChange:(EMCallSession *)aSession
                      type:(EMCallStreamingStatus)aStatus
{
    if ([aSession.callId isEqualToString:self.currentCall.callId]) {
        [self.currentController updateStreamingStatus:aStatus];
    }
}

- (void)callNetworkDidChange:(EMCallSession *)aSession
                      status:(EMCallNetworkStatus)aStatus
{
    if ([aSession.callId isEqualToString:self.currentCall.callId]) {
//        [self.currentController setNetwork:aStatus];
    }
}

#pragma mark - EMCallBuilderDelegate

- (void)callRemoteOffline:(NSString *)aRemoteName
{
    NSString *text = [[EMClient sharedClient].callManager getCallOptions].offlineMessageText;
    EMTextMessageBody *body = [[EMTextMessageBody alloc] initWithText:text];
    NSString *fromStr = [EMClient sharedClient].currentUsername;
    EMMessage *message = [[EMMessage alloc] initWithConversationID:aRemoteName from:fromStr to:aRemoteName body:body ext:@{@"em_apns_ext":@{@"em_push_title":text}}];
    message.chatType = EMChatTypeChat;
    
    [[EMClient sharedClient].chatManager sendMessage:message progress:nil completion:nil];
}

#pragma mark - NSNotification

- (void)handleMake1v1Call:(NSNotification*)notify
{
    if (!notify.object) {
        return;
    }
    
    if (gIsCalling) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"错误" message:@"有通话正在进行" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    
    EMCallType type = (EMCallType)[[notify.object objectForKey:CALL_TYPE] integerValue];
    NSString *chatter = [notify.object valueForKey:CALL_CHATTER] ;
    if (type == EMCallTypeVideo) {
        [self _makeCallWithUsername:chatter type:type isCustomVideoData:NO];
//        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
//
//        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"title.conference.default", @"Default") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//            [self _makeCallWithUsername:[notify.object valueForKey:@"chatter"] type:type isCustomVideoData:NO];
//        }];
//        [alertController addAction:defaultAction];
//
//        UIAlertAction *customAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"title.conference.custom", @"Custom") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//            [self _makeCallWithUsername:[notify.object valueForKey:@"chatter"] type:type isCustomVideoData:YES];
//        }];
//        [alertController addAction:customAction];
//
//        [alertController addAction: [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"Cancel") style: UIAlertActionStyleCancel handler:nil]];
//
//        [self.mainController.navigationController presentViewController:alertController animated:YES completion:nil];
    } else {
        [self _makeCallWithUsername:chatter type:type isCustomVideoData:NO];
    }
}

- (void)_makeCallWithUsername:(NSString *)aUsername
                         type:(EMCallType)aType
            isCustomVideoData:(BOOL)aIsCustomVideo
{
    if ([aUsername length] == 0) {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    void (^completionBlock)(EMCallSession *, EMError *) = ^(EMCallSession *aCallSession, EMError *aError) {
        DemoCallManager *strongSelf = weakSelf;
        if (strongSelf) {
            if (aError || aCallSession == nil) {
                gIsCalling = NO;
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"call.initFailed", @"Establish call failure") message:aError.errorDescription delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
                [alertView show];
                
                return;
            }
            
            @synchronized (self.callLock) {
                strongSelf.currentCall = aCallSession;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:CALL_PUSH_VIEWCONTROLLER object:nil];
                    
                    if (aType == EMCallTypeVideo) {
                        strongSelf.currentController = [[Call1v1VideoViewController alloc] initWithCallSession:strongSelf.currentCall];
                    } else {
                        strongSelf.currentController = [[Call1v1AudioViewController alloc] initWithCallSession:strongSelf.currentCall];
                    }
                    
                    if (strongSelf.currentController) {
                        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
                        UIViewController *rootViewController = window.rootViewController;
                        [rootViewController presentViewController:strongSelf.currentController animated:NO completion:nil];
                    }
                });
            }
            
            [weakSelf _startCallTimeoutTimer];
        }
        else {
            gIsCalling = NO;
            [[EMClient sharedClient].callManager endCall:aCallSession.callId reason:EMCallEndReasonNoResponse];
        }
    };
    
    gIsCalling = YES;
    
    EMCallOptions *options = [[EMClient sharedClient].callManager getCallOptions];
    options.enableCustomizeVideoData = aIsCustomVideo;
    
    [[EMClient sharedClient].callManager startCall:aType remoteName:aUsername ext:@"123" completion:^(EMCallSession *aCallSession, EMError *aError) {
        completionBlock(aCallSession, aError);
    }];
}

#pragma mark - public

- (void)saveCallOptions
{
    NSString *file = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"calloptions.data"];
    EMCallOptions *options = [[EMClient sharedClient].callManager getCallOptions];
    [NSKeyedArchiver archiveRootObject:options toFile:file];
}

- (void)answerCall:(NSString *)aCallId
{
    if (!self.currentCall || ![self.currentCall.callId isEqualToString:aCallId]) {
        return ;
    }
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        EMError *error = [[EMClient sharedClient].callManager answerIncomingCall:weakSelf.currentCall.callId];
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error.code == EMErrorNetworkUnavailable) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"network.disconnection", @"Network disconnection") delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
                    [alertView show];
                }
                else{
                    [weakSelf endCallWithId:aCallId reason:EMCallEndReasonFailed];
                }
            });
        }
    });
}

- (void)_endCallWithId:(NSString *)aCallId
          isNeedHangup:(BOOL)aIsNeedHangup
                reason:(EMCallEndReason)aReason
{
    if (!self.currentCall || ![self.currentCall.callId isEqualToString:aCallId]) {
        if (aIsNeedHangup) {
            [[EMClient sharedClient].callManager endCall:aCallId reason:aReason];
        }
        return ;
    }
    
    gIsCalling = NO;
    [self _stopCallTimeoutTimer];
    
    EMCallOptions *options = [[EMClient sharedClient].callManager getCallOptions];
    options.enableCustomizeVideoData = NO;
    
    if (aIsNeedHangup) {
        [[EMClient sharedClient].callManager endCall:aCallId reason:aReason];
    }
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    @synchronized (_callLock) {
        self.currentCall = nil;
        
        //        self.currentController.isDismissing = YES;
        [self.currentController clearDataAndView];
        [self.currentController dismissViewControllerAnimated:NO completion:nil];
        self.currentController = nil;
        
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:nil];
        [audioSession setActive:YES error:nil];
    }
}

- (void)endCallWithId:(NSString *)aCallId
               reason:(EMCallEndReason)aReason
{
    [self _endCallWithId:aCallId isNeedHangup:YES reason:aReason];
}


@end
