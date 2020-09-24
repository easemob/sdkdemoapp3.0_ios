//
//  EMChatControllerFactory.m
//  EaseIM
//
//  Created by 娜塔莎 on 2020/8/6.
//  Copyright © 2020 娜塔莎. All rights reserved.
//

#import "EMChatControllerFactory.h"
#import "EMSingleChatViewController.h"
#import "EMGroupChatViewController.h"
#import "EMChatroomViewController.h"

@implementation EMChatControllerFactory

+ (EMChatViewController *)getChatControllerInstance:(NSString *)conversationId conversationType:(EMConversationType)conType
{
    EMConversation *conversation = [[EMClient sharedClient].chatManager getConversation:conversationId type:conType createIfNotExist:YES];
    if (!conversation)
        [EMAlertController showErrorAlert:@"当前会话不存在!"];
    EMConversationModel *conModel = [[EMConversationModel alloc]initWithEMModel:conversation];
    
    if (conType == EMConversationTypeChat)
        return [[EMSingleChatViewController alloc]initWithCoversationModel:conModel];
    if (conType == EMConversationTypeGroupChat)
        return [[EMGroupChatViewController alloc]initWithCoversationModel:conModel];
    if (conType == EMConversationTypeChatRoom)
        return [[EMChatroomViewController alloc]initWithCoversationModel:conModel];
    
    return [[EMChatViewController alloc]initWithCoversationModel:conModel];
}

@end
