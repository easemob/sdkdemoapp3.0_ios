//
//  EaseCallManager.m
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 16/9/29.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "EaseCallManager.h"

@interface EaseCallManager()<EMCallManagerDelegate>
{
    NSTimer *_callTimer;
}

@end

static EaseCallManager *callManager = nil;
@implementation EaseCallManager

+ (instancetype)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        callManager = [[EaseCallManager alloc] init];
    });
    
    return callManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[EMClient sharedClient].callManager addDelegate:self delegateQueue:nil];
        EMCallOptions *options = [[EMClient sharedClient].callManager getCallOptions];
        [options setIsSendPushIfOffline:[[[NSUserDefaults standardUserDefaults] objectForKey:@"callPushChanged"] boolValue]];
        [[EMClient sharedClient].callManager setCallOptions:options];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(makeCall:) name:KNOTIFICATION_CALL object:nil];
    }
    return self;
}



- (void)makeCall:(NSNotification *)notify
{
    if (notify.object) {
        
        [self makeCallWithUsername:[notify.object valueForKey:@"chatter"] isVideo:[[notify.object objectForKey:@"type"] boolValue]];
    }
}

- (void)makeCallWithUsername:(NSString *)aUsername
                     isVideo:(BOOL)aIsVideo
{
    if ([aUsername length] == 0) {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    void (^completionBlock)(EMCallSession *, EMError *) = ^(EMCallSession *aCallSession, EMError *aError){
        EaseCallManager *strongSelf = weakSelf;
        if (strongSelf) {
            
            if (!aError && aCallSession) {
                
                strongSelf.callSession = aCallSession;
                [strongSelf _startCallTimer];
                if (strongSelf.callController == nil) {
                    
                    strongSelf.callController = [[EaseCallViewController alloc] initWithCallSession:self.callSession isCaller:YES status:@"Calling"];
                    [strongSelf.mainVC presentViewController:self.callController animated:YES completion:nil];
                } else {
                    strongSelf.callController.callSession = aCallSession;
                    [strongSelf.callController setupSubViews];
                }
            }
            else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"call.initFailed", @"Failed to establish the call") delegate:nil cancelButtonTitle:NSLocalizedString(@"call.ok", @"OK") otherButtonTitles:nil, nil];
                [alertView show];
            }
        }
        else {
            [[EMClient sharedClient].callManager endCall:aCallSession.callId reason:EMCallEndReasonNoResponse];
        }
    };
    EMCallType type = EMCallTypeVideo;
    if (aIsVideo) {
        type = EMCallTypeVideo;
#if TARGET_OS_IPHONE
        [[EMClient sharedClient].callManager startCall:type remoteName:aUsername ext:nil completion:^(EMCallSession *aCallSession, EMError *aError) {
            completionBlock(aCallSession, aError);
        }];
#endif
    } else {
        type = EMCallTypeVoice;
        [[EMClient sharedClient].callManager startCall:type remoteName:aUsername ext:nil completion:^(EMCallSession *aCallSession, EMError *aError) {
            completionBlock(aCallSession, aError);
        }];
    }
}

- (void)_startCallTimer
{
    _callTimer = [NSTimer scheduledTimerWithTimeInterval:50 target:self selector:@selector(_cancelCall) userInfo:nil repeats:NO];
}

- (void)_stopCallTimer
{
    if (_callTimer == nil) {
        return;
    }
    
    [_callTimer invalidate];
    _callTimer = nil;
}

- (void)_cancelCall
{
    [self hangupCallWithReason:EMCallEndReasonNoResponse];
}

#pragma mark -  Hang up

- (void)hangupCallWithReason:(EMCallEndReason)aReason
{
    [self _stopCallTimer];
    
    if (_callSession) {
        [[EMClient sharedClient].callManager endCall:_callSession.callId reason:aReason];
    }
    
    _callSession = nil;
    
    [_callController close];
    _callController = nil;
    
}

- (void)answerCall
{
    if (_callSession)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            EMError *error = [[EMClient sharedClient].callManager answerIncomingCall:self.callSession.callId];
            if (error)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (error.code == EMErrorNetworkUnavailable)
                    {
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"call.network.disconnection", @"Network disconnection") delegate:nil cancelButtonTitle:NSLocalizedString(@"call.ok", @"OK") otherButtonTitles:nil, nil];
                        [alertView show];
                    }
                    else
                    {
                        [self hangupCallWithReason:EMCallEndReasonFailed];
                    }
                });
            }
        });
    }
}


#pragma mark - EMCallManagerDelegate

- (void)callDidAccept:(EMCallSession *)aSession
{
    if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive) {
        
        [[EMClient sharedClient].callManager endCall:aSession.callId reason:EMCallEndReasonFailed];
    }
    if ([aSession.callId isEqualToString:_callSession.callId]) {
        
        [self _stopCallTimer];
        [_callController reloadConnectedUI];
    }
}

- (void)callDidConnect:(EMCallSession *)aSession
{
    if ([aSession.callId isEqualToString:_callSession.callId]) {
        
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        [audioSession setActive:YES error:nil];
    }
}

- (void)callDidEnd:(EMCallSession *)aSession reason:(EMCallEndReason)aReason error:(EMError *)aError
{
    if ([aSession.callId isEqualToString:_callSession.callId]) {
        
        [self _stopCallTimer];
        
        if (aSession.type == EMCallTypeVideo) {
            _callSession.remoteVideoView.hidden = YES;
        }
        
        [_callController stopTimer];
        
        if (aReason != EMCallEndReasonHangup) {
            
            NSString * reasonStr = @"";
            switch (aReason) {
                case EMCallEndReasonNoResponse:
                {
                    reasonStr = NSLocalizedString(@"call.userNotAnswer", @"User didn't answer");
                }
                    break;
                case EMCallEndReasonDecline:
                {
                    reasonStr = NSLocalizedString(@"call.declined", @"Call declined");
                }
                    break;
                case EMCallEndReasonBusy:
                {
                    reasonStr = NSLocalizedString(@"call.userBusy", @"User is busy");
                }
                    break;
                case EMCallEndReasonFailed:
                {
                    reasonStr = NSLocalizedString(@"call.failed", @"Call failed");
                }
                    break;
                default:
                    break;
            }
            
            if (aError) {
                
                if (aError.code == EMErrorCallRemoteOffline) {
                    reasonStr = NSLocalizedString(@"call.userOffline", @"User is offline");
                } else {
                    reasonStr = aError.errorDescription;
                }
                
                _callController.statusLabel.text = reasonStr;
            } else {
                
                _callController.statusLabel.text = reasonStr;
            }
            
            [_callController reloadCallDisconnectedUI];
        } else {
            
            [_callController close];
            _callSession = nil;
            _callController = nil;
        }
    }
}

// Receive Call
- (void)callDidReceive:(EMCallSession *)aSession
{
    if (_callSession && _callSession.status != EMCallSessionStatusDisconnected) {
        [[EMClient sharedClient].callManager endCall:aSession.callId reason:EMCallEndReasonBusy];
    }
    
    if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive) {
        [[EMClient sharedClient].callManager endCall:aSession.callId reason:EMCallEndReasonFailed];
    }
    
    _callSession = aSession;
    if (_callSession) {
        
        [self _startCallTimer];
        _callController = [[EaseCallViewController alloc] initWithCallSession:aSession isCaller:NO status:NSLocalizedString(@"call.finished", "Establish call finished")];
        _callController.modalPresentationStyle = UIModalPresentationOverFullScreen;
        
        [self.mainVC presentViewController:_callController animated:YES completion:nil];
    }
}





- (void)dealloc
{
    [[EMClient sharedClient].callManager removeDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KNOTIFICATION_CALL object:nil];
}
@end
