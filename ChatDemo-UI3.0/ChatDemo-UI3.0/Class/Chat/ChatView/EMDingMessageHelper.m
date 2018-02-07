//
//  EMDingMessageHelper.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 12/01/2018.
//  Copyright © 2018 XieYajie. All rights reserved.
//

#import "EMDingMessageHelper.h"

static const NSString *kDingKey = @"EMDingMessage";
static const NSString *kDingAckKey = @"EMDingMessageAck";
static const NSString *kDingConversationIdKey = @"EMConversationID";

static EMDingMessageHelper *sharedInstance = nil;

@implementation EMDingMessageHelper

+ (instancetype)sharedHelper
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[EMDingMessageHelper alloc] init];
    });
    
    return sharedInstance;
}

+ (BOOL)isDingMessage:(EMMessage *)aMessage
{
    BOOL ret = NO;
    id ext = aMessage.ext;
    if (ext == nil || ext == NULL) {
        return ret;
    }
    
    if ([ext isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dic = (NSDictionary *)ext;
        if ([dic objectForKey:kDingKey]) {
            ret = YES;
        }
    }
    
    return ret;
}

+ (BOOL)isDingMessageAck:(EMMessage *)aMessage
{
    BOOL ret = NO;
    do {
        EMMessageBody *body = aMessage.body;
        if (body.type != EMMessageBodyTypeCmd) {
            break;
        }
        id ext = aMessage.ext;
        if (ext == nil || ext == NULL) {
            break;
        }
        
        if ([ext isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dic = (NSDictionary *)ext;
            if ([dic objectForKey:kDingAckKey]) {
                ret = YES;
            }
        }
    } while (0);
    
    return ret;
}

#pragma mark - Init

- (instancetype)init
{
    self = [super init];
    if (self) {
        _dingAcks = [[NSMutableDictionary alloc] initWithDictionary:[self _unarchiveDingAcks]];
        if (_dingAcks == nil) {
            _dingAcks = [[NSMutableDictionary alloc] init];
        }
    }
    
    return self;
}

- (void)dealloc
{
    [self save];
}

#pragma mark - Private

// 将数据存到本地，建议使用数据库
- (void)_archiveDingAcks:(NSDictionary *)aDic
{
    NSString *file = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"emding_acks.data"];
    [NSKeyedArchiver archiveRootObject:aDic toFile:file];
}

- (NSDictionary *)_unarchiveDingAcks
{
    NSString *file = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"emding_acks.data"];
    NSDictionary *dic = [NSKeyedUnarchiver unarchiveObjectWithFile:file];
    return dic;
}

#pragma mark - Public

- (NSInteger)dingAckCount:(EMMessage *)aMessage
{
    NSInteger retCount = 0;
    NSDictionary *dic = [self.dingAcks objectForKey:aMessage.conversationId];
    if ([dic count] > 0) {
        NSArray *array = [dic objectForKey:aMessage.messageId];
        retCount = [array count];
    }

    return retCount;
}

- (EMMessage *)createDingMessageWithText:(NSString *)aText
                          conversationId:(NSString *)aConversationId
                                      to:(NSString *)aTo
                                chatType:(EMChatType)aChatType
{
    NSString *from = [[EMClient sharedClient] currentUsername];
    EMTextMessageBody *body = [[EMTextMessageBody alloc] initWithText:aText];
    EMMessage *retMsg = [[EMMessage alloc] initWithConversationID:aConversationId from:from to:aTo body:body ext:@{kDingKey:@(1)}];
    retMsg.chatType = aChatType;
    
    return retMsg;
}

- (EMMessage *)createDingAckForMessage:(EMMessage *)aMessage
{
    NSString *from = [[EMClient sharedClient] currentUsername];
    if ([aMessage.from isEqualToString:from]) {
        return nil;
    }
    NSString *to = aMessage.from;
    EMCmdMessageBody *body = [[EMCmdMessageBody alloc] initWithAction:aMessage.messageId];
    EMMessage *retMessage = [[EMMessage alloc] initWithConversationID:to from:from to:to body:body ext:@{kDingAckKey:@(1), kDingConversationIdKey:aMessage.conversationId}];
    return retMessage;
}

- (NSString *)addDingMessageAck:(EMMessage *)aAckMessage
{
    if (aAckMessage == nil) {
        return nil;
    }
    
    EMCmdMessageBody *body = (EMCmdMessageBody *)aAckMessage.body;
    NSString *retMessageId = body.action;
    
    NSString *conversationId = [aAckMessage.ext objectForKey:kDingConversationIdKey];
    
    NSMutableDictionary *dic = [self.dingAcks objectForKey:conversationId];
    NSMutableArray *array = nil;
    if (dic == nil) {
        dic = [[NSMutableDictionary alloc] init];
        [self.dingAcks setObject:dic forKey:conversationId];
        
        array = [[NSMutableArray alloc] init];
    } else {
        array = [dic objectForKey:retMessageId];
        if ([array containsObject:aAckMessage.from]) {
            return nil;
        }
        
        array = [[NSMutableArray alloc] initWithArray:array];
    }
    
    [array addObject:aAckMessage.from];
    [dic setObject:array forKey:retMessageId];
    [self save];
    
    return retMessageId;
}

- (NSArray *)usersHasReadMessage:(EMMessage *)aMessage
{
    if (aMessage == nil) {
        return nil;
    }
    
    NSDictionary *dic = [self.dingAcks objectForKey:aMessage.conversationId];
    NSArray *retArray = [dic objectForKey:aMessage.messageId];
    
    return retArray;
}

- (void)deleteConversation:(NSString *)aConversationId
{
    if ([aConversationId length] == 0) {
        return;
    }
    
    [self.dingAcks removeObjectForKey:aConversationId];
    [self save];
}

- (void)deleteConversation:(NSString *)aConversationId
                   message:(NSString *)aMessageId
{
    if ([aConversationId length] == 0 || [aMessageId length] == 0) {
        return;
    }
    
    NSMutableDictionary *dic = [self.dingAcks objectForKey:aConversationId];
    if ([dic count] > 0) {
        [dic removeObjectForKey:aMessageId];
        [self save];
    }
}

- (void)save
{
    [self _archiveDingAcks:self.dingAcks];
}

@end
