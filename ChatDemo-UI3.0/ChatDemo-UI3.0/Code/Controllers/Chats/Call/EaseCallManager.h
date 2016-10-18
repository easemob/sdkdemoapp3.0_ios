//
//  EaseCallManager.h
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 16/9/29.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EaseCallViewController.h"
#import "EMSettingsViewController.h"
#import "EMMainViewController.h"

@interface EaseCallManager : NSObject

+ (instancetype) sharedManager;

@property (strong, nonatomic) EMCallSession *callSession;

@property (strong, nonatomic) EaseCallViewController *callController;

@property (strong, nonatomic) EMMainViewController *mainVC;

- (void)makeCallWithUsername:(NSString *)aUsername
                     isVideo:(BOOL)aIsVideo;

- (void)hangupCallWithReason:(EMCallEndReason)aReason;

- (void)answerCall;



@end
