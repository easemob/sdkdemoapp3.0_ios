//
//  SingleCallController.h
//  EMiOS_IM
//
//  Created by XieYajie on 22/11/2016.
//  Copyright © 2016 XieYajie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SingleCallController : NSObject

@property (nonatomic, strong) NSString *chatter; //通话的联系人

@property (nonatomic,strong) NSString *callDirection; //通话角色，主/被叫

@property (nonatomic,strong) NSString *callDurationTime; //通话持续时间

@property (nonatomic) EMCallType type;

+ (instancetype)sharedManager;

//实时单聊通话：语音/视频
- (void)communicateWithContact:(NSString *)conversationId callType:(EMCallType)callType;

- (void)answerCall:(NSString *)aCallId;

- (void)endCallWithId:(NSString *)aCallId
               reason:(EMCallEndReason)aReason;

- (void)saveCallOptions;

@end

