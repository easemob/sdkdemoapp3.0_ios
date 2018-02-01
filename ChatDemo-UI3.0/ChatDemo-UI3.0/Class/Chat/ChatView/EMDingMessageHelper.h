//
//  EMDingMessageHelper.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 12/01/2018.
//  Copyright © 2018 XieYajie. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kNotification_DingAction @"DingAction"

@interface EMDingMessageHelper : NSObject

@property (nonatomic, strong, readonly) NSMutableDictionary *dingAcks;

+ (instancetype)sharedHelper;

+ (BOOL)isDingMessage:(EMMessage *)aMessage;

+ (BOOL)isDingMessageAck:(EMMessage *)aMessage;

- (NSInteger)dingAckCount:(EMMessage *)aMessage;

- (EMMessage *)createDingMessageWithText:(NSString *)aText
                          conversationId:(NSString *)aConversationId
                                      to:(NSString *)aTo
                                chatType:(EMChatType)aChatType;

- (EMMessage *)createDingAckForMessage:(EMMessage *)aMessage;

- (NSString *)addDingMessageAck:(EMMessage *)aAckMessage;

- (NSArray *)usersHasReadMessage:(EMMessage *)aMessage;

- (void)deleteConversation:(NSString *)aConversationId;

- (void)deleteConversation:(NSString *)aConversationId
                   message:(NSString *)aMessageId;

- (void)save;

@end
