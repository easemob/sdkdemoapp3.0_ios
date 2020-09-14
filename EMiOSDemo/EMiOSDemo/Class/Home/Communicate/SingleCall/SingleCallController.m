//
//  SingleCallController.m
//  EMiOS_IM
//
//  Created by XieYajie on 22/11/2016.
//  Copyright © 2016 XieYajie. All rights reserved.
//

#import "SingleCallController.h"
#import "EMCallOptions+NSCoding.h"

#import "EMGlobalVariables.h"
#import "Call1v1AudioViewController.h"
#import "Call1v1VideoViewController.h"
#import "AudioRecord.h"
#import "EMRemindManager.h"

static SingleCallController *callManager = nil;

@interface SingleCallController()<EMChatManagerDelegate, EMCallManagerDelegate, EMCallBuilderDelegate>

@property (strong, nonatomic) NSObject *callLock;
@property (strong, nonatomic) EMCallSession *currentCall;
@property (nonatomic, strong) EM1v1CallViewController *currentController;

@property (strong, nonatomic) NSTimer *timeoutTimer;

@property (strong, nonatomic) NSTimer *offlineTimer;

@property (nonatomic, strong) UIAlertController *alertView;

@property (nonatomic, strong) AudioRecord* audioRecorder;

@end


@implementation SingleCallController

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
        callManager = [[SingleCallController alloc] init];
    });
    
    return callManager;
}

- (void)dealloc
{
    [self _stopCallTimeoutTimer];
    [[EMClient sharedClient].chatManager removeDelegate:self];
    [[EMClient sharedClient].callManager removeDelegate:self];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CALL_MAKE1V1 object:nil];
}

#pragma mark - public

- (void)communicateWithContact:(NSString *)conversationId callType:(EMCallType)callType
{
    [self _makeCallWithUsername:conversationId type:callType isCustomVideoData:NO];
}

#pragma mark - private

- (void)_initManager
{
    _callLock = [[NSObject alloc] init];
    _currentCall = nil;
    _currentController = nil;
    _audioRecorder = [[AudioRecord alloc] init];
    _audioRecorder.inputAudioData = ^(NSData*data) {
        [[[EMClient sharedClient] callManager] inputCustomAudioData:data];
    };
    
    [[EMClient sharedClient].chatManager addDelegate:self delegateQueue:nil];
    [[EMClient sharedClient].callManager addDelegate:self delegateQueue:nil];
    [[EMClient sharedClient].callManager setBuilderDelegate:self];
 
    
    NSString *file = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"calloptions.data"];
    EMCallOptions *options = [[EMClient sharedClient].callManager getCallOptions];
    if ([[NSFileManager defaultManager] fileExistsAtPath:file]) {
        options = [NSKeyedUnarchiver unarchiveObjectWithFile:file];
    } else {
        options = [[EMClient sharedClient].callManager getCallOptions];
        options.isSendPushIfOffline = NO;
        options.videoResolution = EMCallVideoResolution640_480;
    }
    
    // dujiepeng
    options.maxVideoKbps = 200;
    options.maxAudioKbps = 100;
    [[EMClient sharedClient].callManager setCallOptions:options];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMakeSingleCall:) name:CALL_MAKE1V1 object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeAlertView:) name:@"didAlert" object:nil];
}

#pragma mark - Call Timeout Before Answered

- (void)_timeoutBeforeCallAnswered:(NSTimer *)timer
{
    NSString *reason = (NSString *)[timer userInfo]; //必须放在本timer关闭之前使用，不然会出现野指针错误
    [self endCallWithId:self.currentCall.callId reason:EMCallEndReasonNoResponse];
    UIAlertView *alertView = nil;
    if (reason) {
        alertView = [[UIAlertView alloc] initWithTitle:nil message:reason delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
    } else {
        alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"call.autoHangup", @"No response and Hang up") delegate:self cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
    }
    [alertView show];
}

- (void)_startCallTimeoutTimer
{
    self.timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(_timeoutBeforeCallAnswered:) userInfo:nil repeats:NO];
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
//用户A拨打用户B，用户B会收到这个回调。  被叫方
- (void)callDidReceive:(EMCallSession *)aSession
{
    [EMRemindManager playRing:YES];
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
        //[self _startCallTimeoutTimer];
        
        self.currentCall = aSession;
        if (aSession.type == EMCallTypeVoice) {
            self.currentController = [[Call1v1AudioViewController alloc] initWithCallSession:self.currentCall];
        } else {
            self.currentController = [[Call1v1VideoViewController alloc] initWithCallSession:self.currentCall];
        }
        self.currentController.callType = aSession.type;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.currentController) {
                self.currentController.modalPresentationStyle = UIModalPresentationOverFullScreen;
                
                if(self.alertView) {
                    [self.alertView dismissViewControllerAnimated:NO completion:nil];
                    self.alertView = nil;
                }
                
                UIViewController *rootViewController = [[UIApplication sharedApplication].delegate window].rootViewController;
                //id nextResponder = nil;
                
                UIViewController *parent = [[UIViewController alloc]init];
                parent = rootViewController;
                /*
                while ((parent = rootViewController.presentedViewController) != nil ) {
                    rootViewController = parent;
                }
                
                while ([rootViewController isKindOfClass:[UINavigationController class]]) {
                    rootViewController = [(UINavigationController *)rootViewController topViewController];
                }
                
                /*if(rootViewController.presentedViewController){
                    nextResponder = rootViewController.presentedViewController;
                }else{
                    UIView *frontView = [[window subviews] objectAtIndex:0];
                    nextResponder = [frontView nextResponder];
                }
                if([nextResponder isKindOfClass:[UINavigationController class]]){
                    UIViewController *nav = (UIViewController *)nextResponder;
                    nextResponder = nav.childViewControllers.lastObject;
                }*/

                [rootViewController presentViewController:self.currentController animated:NO completion:nil];
                self->_callDirection = EMCOMMUNICATE_DICT_CALLEDPARTY;
            }
        });
    }
}

- (void)closeAlertView:(NSNotification*)notify {
    self.alertView =  (UIAlertController *)[notify.object valueForKey:@"alert"];
}

- (void)callDidConnect:(EMCallSession *)aSession
{
    if ([aSession.callId isEqualToString:self.currentCall.callId]) {
        self.currentController.callStatus = EMCallSessionStatusConnected;
    }
}

- (void)callDidAccept:(EMCallSession *)aSession
{
    [EMRemindManager stopSound];
    [EMRemindManager playVibration];
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord
                  withOptions:AVAudioSessionCategoryOptionAllowBluetooth
                        error:nil];
    
    [audioSession setActive:YES error:nil];
    
    if ([aSession.callId isEqualToString:self.currentCall.callId]) {
        [self _stopCallTimeoutTimer];
        self.currentController.callStatus = EMCallSessionStatusAccepted;
    }
    EMCallOptions *options = [[EMClient sharedClient].callManager getCallOptions];
    if(options.enableCustomAudioData){
        [self audioRecorder].channels = options.audioCustomChannels;
        [self audioRecorder].samples = options.audioCustomSamples;
        [[self audioRecorder] startAudioDataRecord];
    }
}

- (void)callDidEnd:(EMCallSession *)aSession
            reason:(EMCallEndReason)aReason
             error:(EMError *)aError
{
    [EMRemindManager stopSound];
    if (self.currentCall) {
        [self _endCallWithId:aSession.callId isNeedHangup:NO reason:aReason];
    }
    
    if (aReason != EMCallEndReasonNoResponse) {
        if (aError) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:aError.errorDescription delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
            [alertView show];
        } else {
            NSString *reasonStr = @"通话结束";
            switch (aReason) {
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
                case EMCallEndReasonNotEnable:
                    reasonStr = @"服务未开通";
                    break;
                case EMCallEndReasonServiceArrearages:
                    reasonStr = @"余额不足";
                    break;
                case EMCallEndReasonServiceForbidden:
                    reasonStr = @"服务被拒绝";
                    break;
                default:
                    break;
            }
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:reasonStr delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
            [alertView show];
        }
        [self sendCallRecord:EMCOMMUNICATE_CALLED_MISSEDCALL callType:aSession.type];//被叫方取消通话
    } else {
        [self sendCallRecord:EMCOMMUNICATE_CALLER_MISSEDCALL callType:aSession.type];//主叫方取消通话
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
        [self.currentController setNetwork:aStatus];
    }
}

#pragma mark - EMCallBuilderDelegate

- (void)callRemoteOffline:(NSString *)aRemoteName
{
    [self _stopCallTimeoutTimer];
    self.timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(_timeoutBeforeCallAnswered:) userInfo:@"对方不在线，无法接听通话" repeats:NO];
}

#pragma mark - NSNotification

//主叫方
- (void)handleMakeSingleCall:(NSNotification*)notify
{
    if (!notify.object) {
        return;
    }
    
    if (gIsCalling) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"错误" message:@"有通话正在进行" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    
    _type = (EMCallType)[[notify.object objectForKey:CALL_TYPE] integerValue];
    _chatter = [notify.object valueForKey:CALL_CHATTER] ;
    if (_type == EMCallTypeVideo) {
        [self _makeCallWithUsername:_chatter type:_type isCustomVideoData:NO];
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
        [self _makeCallWithUsername:_chatter type:_type isCustomVideoData:NO];
    }
}

//主叫方
- (void)_makeCallWithUsername:(NSString *)aUsername
                         type:(EMCallType)aType
            isCustomVideoData:(BOOL)aIsCustomVideo
{
    if ([aUsername length] == 0) {
        return;
    }
    
    [EMRemindManager playWattingSound];
    
    __weak typeof(self) weakSelf = self;
    void (^completionBlock)(EMCallSession *, EMError *) = ^(EMCallSession *aCallSession, EMError *aError) {
        SingleCallController *strongSelf = weakSelf;
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
                    NSString *callType;
                    if (aType == EMCallTypeVoice) {
                        callType = EMCOMMUNICATE_TYPE_VOICE;
                    } else if (aType == EMCallTypeVideo) {
                        callType = EMCOMMUNICATE_TYPE_VIDEO;
                    }
                    [[NSNotificationCenter defaultCenter] postNotificationName:CALL_PUSH_VIEWCONTROLLER object:@{EMCOMMUNICATE_TYPE:callType}];
                    
                    if (aType == EMCallTypeVideo) {
                        strongSelf.currentController = [[Call1v1VideoViewController alloc] initWithCallSession:strongSelf.currentCall];
                    } else {
                        strongSelf.currentController = [[Call1v1AudioViewController alloc] initWithCallSession:strongSelf.currentCall];
                    }
                    
                    if (strongSelf.currentController) {
                        strongSelf.currentController.callType = -1;
                        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
                        UIViewController *rootViewController = window.rootViewController;
                        strongSelf.currentController.modalPresentationStyle = 0;
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
    options.isSendPushIfOffline = YES;
    [[EMClient sharedClient].callManager startCall:aType remoteName:aUsername
                                            record:[EMDemoOptions sharedOptions].willRecord
                                       mergeStream:[EMDemoOptions sharedOptions].willMergeStrem
                                               ext:@"123" completion:^(EMCallSession *aCallSession, EMError *aError) {
                                                   completionBlock(aCallSession, aError);
                                               }];
    _callDirection = EMCOMMUNICATE_DICT_CALLINGPARTY;
}

#pragma mark - public

//通话记录
- (void)sendCallRecord:(NSString *)missedCallDirection callType:(EMCallType)callType
{
    //通话类型
    NSString *callTypeStr;
    if (callType == EMCallTypeVoice) {
        callTypeStr = EMCOMMUNICATE_TYPE_VOICE;
    } else if (callType == EMCallTypeVideo) {
        callTypeStr = EMCOMMUNICATE_TYPE_VIDEO;
    }
    //主叫方发送通话信息
    if ([self.callDirection isEqualToString:EMCOMMUNICATE_DICT_CALLINGPARTY]) {
        if (self.callDurationTime) {
            [[NSNotificationCenter defaultCenter] postNotificationName:EMCOMMMUNICATE object:@{EMCOMMUNICATE_TYPE:callTypeStr,EMCOMMUNICATE_DURATION_TIME:self.callDurationTime,EMCOMMUNICATE_MISSED_CALL:@""}];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:EMCOMMMUNICATE object:@{EMCOMMUNICATE_TYPE:callTypeStr,EMCOMMUNICATE_DURATION_TIME:@"",EMCOMMUNICATE_MISSED_CALL:missedCallDirection}];
        }
    }
    self.callDurationTime = nil;
}

- (void)saveCallOptions
{
    NSString *file = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"calloptions.data"];
    EMCallOptions *options = [[EMClient sharedClient].callManager getCallOptions];
    [NSKeyedArchiver archiveRootObject:options toFile:file];
}

- (void)answerCall:(NSString *)aCallId
{
    [EMRemindManager stopSound];
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
    if(options.enableCustomAudioData) {
        [[self audioRecorder] stopAudioDataRecord];
    }
    options.enableCustomizeVideoData = NO;
    
    if (aIsNeedHangup) {
        [[EMClient sharedClient].callManager endCall:aCallId reason:aReason];
    }
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    @synchronized (_callLock) {
        self.currentCall = nil;
        
        //        self.currentController.isDismissing = YES;
        [self.currentController clearDataAndView];
        [self.currentController dismissViewControllerAnimated:NO completion:^{
            self.currentController = nil;
        }];
        
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:nil];
        [audioSession setActive:YES error:nil];
    }
}

- (void)endCallWithId:(NSString *)aCallId
               reason:(EMCallEndReason)aReason
{
    [EMRemindManager stopSound];
    [self _endCallWithId:aCallId isNeedHangup:YES reason:aReason];
}

@end
