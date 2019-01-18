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

#pragma mark - Class Methods

+ (NSArray<EMConversationModel *> *)modelsFromEMConversations:(NSArray<EMConversation *> *)aConversations
{
    NSMutableArray *retArray = [[NSMutableArray alloc] init];
    
    NSArray *groupArray = [[EMClient sharedClient].groupManager getJoinedGroups];
    for (int i = 0; i < [aConversations count]; i++) {
        EMConversation *conversation = aConversations[i];
        EMConversationModel *model = [[EMConversationModel alloc] initWithEMModel:conversation];
        if (conversation.type == EMConversationTypeGroupChat || conversation.type == EMConversationTypeChatRoom) {
            NSString *name = [conversation.ext objectForKey:@"subject"];
            if ([name length] == 0 && conversation.type == EMConversationTypeGroupChat) {
                for (EMGroup *group in groupArray) {
                    if ([group.groupId isEqualToString:conversation.conversationId]) {
                        NSMutableDictionary *ext = [NSMutableDictionary dictionaryWithDictionary:conversation.ext];
                        [ext setObject:group.subject forKey:@"subject"];
                        [ext setObject:[NSNumber numberWithBool:group.isPublic] forKey:@"isPublic"];
                        conversation.ext = ext;
                        name = group.subject;
                        break;
                    }
                }
            }
            
            model.name = name;
        }
        [retArray addObject:model];
    }
    
    return retArray;
}

@end
