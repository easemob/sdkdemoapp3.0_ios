//
//  EMDingMessageHelper.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 12/01/2018.
//  Copyright © 2018 XieYajie. All rights reserved.
//

#import "EMDingMessageHelper.h"

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
    NSArray *array = [self.dingAcks objectForKey:aMessage.messageId];
    NSInteger retCount = [array count];
    return retCount;
}

- (EMMessage *)createDingAckForMessage:(EMMessage *)aMessage
{
    NSString *msgId = aMessage.messageId;
    NSMutableArray *array = [self.dingAcks objectForKey:msgId];
    if ([array containsObject:aMessage.from]) {
        return nil;
    }
    
    NSString *from = [[EMClient sharedClient] currentUsername];
    EMCmdMessageBody *body = [[EMCmdMessageBody alloc] initWithAction:aMessage.messageId];
    EMMessage *retMessage = [[EMMessage alloc] initWithConversationID:aMessage.conversationId from:from to:aMessage.from body:body ext:@{kDingAckKey:@(1)}];
    return retMessage;
}

- (NSString *)addDingMessageAck:(EMMessage *)aMessage
{
    NSString *retId = @"";
    if (aMessage == nil) {
        return retId;
    }
    
    EMCmdMessageBody *body = (EMCmdMessageBody *)aMessage.body;
    retId = body.action;
    NSMutableArray *array = [self.dingAcks objectForKey:retId];
    if (![array containsObject:aMessage.from]) {
        NSMutableArray *tmpArray = [[NSMutableArray alloc] initWithArray:array];
        [tmpArray addObject:aMessage.from];
        [self.dingAcks setValue:tmpArray forKey:retId];
    }
    
    return retId;
}

- (NSArray *)acksWithMessageId:(NSString *)aMessageId
{
    NSArray *retArray = nil;
    if ([aMessageId length] == 0) {
        return retArray;
    }
    
    retArray = [self.dingAcks objectForKey:aMessageId];
    
    return retArray;
}

- (void)save
{
    [self _archiveDingAcks:self.dingAcks];
}

@end
