//
//  DemoCallManager.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 22/11/2016.
//  Copyright © 2016 XieYajie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DemoCallManager : NSObject

@property (nonatomic,strong) NSString *callDirection; //通话方向，主/被叫

@property (nonatomic,strong) NSString *callDurationTime; //通话方向，主/被叫

+ (instancetype)sharedManager;

- (void)answerCall:(NSString *)aCallId;

- (void)endCallWithId:(NSString *)aCallId
               reason:(EMCallEndReason)aReason;

- (void)saveCallOptions;

@end
