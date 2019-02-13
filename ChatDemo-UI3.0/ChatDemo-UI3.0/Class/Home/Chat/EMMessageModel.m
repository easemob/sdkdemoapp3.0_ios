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
        
        if (aMsg.body.type == EMMessageBodyTypeText) {
            if ([aMsg.ext objectForKey:MSG_EXT_GIF]) {
                _type = EMMessageTypeExtGif;
            } else {
                _type = EMMessageTypeText;
            }
        } else {
            _type = (EMMessageType)aMsg.body.type;
        }
    }
    
    return self;
}

@end
