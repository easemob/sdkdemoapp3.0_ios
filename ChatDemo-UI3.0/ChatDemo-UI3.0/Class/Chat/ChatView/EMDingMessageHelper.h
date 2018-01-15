//
//  EMDingMessageHelper.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 12/01/2018.
//  Copyright © 2018 XieYajie. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kNotification_DingAction @"DingAction"

static const NSString *kDingKey = @"EMDingMessage";
static const NSString *kDingAckKey = @"EMDingMessageAck";
static const NSString *kDingAcksKey = @"EMDingMessageAcks";

@interface EMDingMessageHelper : NSObject

@property (nonatomic, strong, readonly) NSMutableDictionary *dingAcks;

+ (instancetype)sharedHelper;

+ (BOOL)isDingMessage:(EMMessage *)aMessage;

+ (BOOL)isDingMessageAck:(EMMessage *)aMessage;

- (NSInteger)dingAckCount:(EMMessage *)aMessage;

- (EMMessage *)createDingAckForMessage:(EMMessage *)aMessage;

- (NSString *)addDingMessageAck:(EMMessage *)aMessage;

- (NSArray *)acksWithMessageId:(NSString *)aMessageId;

- (void)save;

@end
