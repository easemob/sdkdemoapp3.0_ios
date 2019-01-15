//
//  EMConversationModel.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/14.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EMConversationModel.h"

@implementation EMConversationModel

- (instancetype)initWithEMModel:(EMConversation *)aModel
{
    self = [super init];
    if (self) {
        _emModel = aModel;
        
        _name = aModel.conversationId;
    }
    
    return self;
}

@end
