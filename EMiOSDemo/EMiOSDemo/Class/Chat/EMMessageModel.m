//
//  EMMessageModel.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/18.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EMMessageModel.h"

@implementation EMMessageModel

- (instancetype)initWithEMMessage:(EMMessage *)aMsg
{
    self = [super init];
    if (self) {
        _emModel = aMsg;
        _direction = aMsg.direction;
        _type = (EMMessageType)aMsg.body.type;
        if (aMsg.body.type == EMMessageBodyTypeText) {
            if (aMsg.isNeedGroupAck)
                _readReceiptCount = [NSString stringWithFormat:@"阅读回执，已读用户（%d）",aMsg.groupAckCount];
            if ([aMsg.ext objectForKey:MSG_EXT_GIF]) {
                _type = EMMessageTypeExtGif;
                return self;
            }
            if ([aMsg.ext objectForKey:MSG_EXT_RECALL]) {
                _type = EMMessageTypeExtRecall;
                return self;
            }
            if ([[aMsg.ext objectForKey:MSG_EXT_NEWNOTI] isEqualToString:NOTI_EXT_ADDFRIEND]) {
                _type = EMMessageTypeExtNewFriend;
                return self;
            }
            if ([[aMsg.ext objectForKey:MSG_EXT_NEWNOTI] isEqualToString:NOTI_EXT_ADDGROUP]) {
                _type = EMMessageTypeExtAddGroup;
                return self;
            }
            if ([aMsg.ext objectForKey:EMCOMMUNICATE_TYPE]){
                _type = EMMessageTypePictMixText;
                return self;
            }
            NSString *conferenceId = [aMsg.ext objectForKey:@"conferenceId"];
            if ([conferenceId length] == 0)
                conferenceId = [aMsg.ext objectForKey:MSG_EXT_CALLID];
            if ([conferenceId length] > 0) {
                _type = EMMessageTypeExtCall;
                return self;
            }
            _type = EMMessageTypeText;
        }
    }
    return self;
}

@end
