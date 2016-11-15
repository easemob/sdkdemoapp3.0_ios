//
//  EMConversationModel.m
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 16/10/17.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "EMConversationModel.h"

#import "EMUserProfileManager.h"

@implementation EMConversationModel

- (instancetype)initWithConversation:(EMConversation*)conversation
{
    self = [super init];
    if (self) {
        _conversation = conversation;
        if (_conversation.type == EMConversationTypeGroupChat) {
            NSArray *groups = [[EMClient sharedClient].groupManager getJoinedGroups];
            for (EMGroup *group in groups) {
                if ([_conversation.conversationId isEqualToString:group.groupId]) {
                    _title = group.subject;
                    break;
                }
            }
        }
    }
    return self;
}

- (NSString*)title
{
    if (_conversation.type == EMConversationTypeChat) {
        return [[EMUserProfileManager sharedInstance] getNickNameWithUsername:_conversation.conversationId];
    } else {
        return _title;
    }
}

@end
