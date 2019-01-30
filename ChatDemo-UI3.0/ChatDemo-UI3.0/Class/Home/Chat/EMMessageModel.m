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
        _type = aMsg.body.type;
        
//        if (aMsg.direction == EMMessageDirectionSend) {
//            EMImageMessageBody *body = (EMImageMessageBody *)aMsg.body;
//            if ([body.thumbnailLocalPath length] > 0) {
//                _image = [UIImage imageWithContentsOfFile:body.thumbnailLocalPath];
//            }
//        }
    }
    
    return self;
}

@end
