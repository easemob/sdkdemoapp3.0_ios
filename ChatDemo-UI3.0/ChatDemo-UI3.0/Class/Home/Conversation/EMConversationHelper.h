//
//  EMConversationHelper.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/14.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EMConversationModel : NSObject

@property (nonatomic, strong) EMConversation *emModel;

@property (nonatomic, strong) NSString *name;

- (instancetype)initWithEMModel:(EMConversation *)aModel;

@end


@protocol EMConversationsDelegate;
@interface EMConversationHelper : NSObject

- (void)addDelegate:(id<EMConversationsDelegate>)aDelegate;

- (void)removeDelegate:(id<EMConversationsDelegate>)aDelegate;

+ (instancetype)shared;

+ (NSArray<EMConversationModel *> *)modelsFromEMConversations:(NSArray<EMConversation *> *)aConversations;

+ (EMConversationModel *)modelFromContact:(NSString *)aContact;

+ (EMConversationModel *)modelFromGroup:(EMGroup *)aGroup;

+ (EMConversationModel *)modelFromChatroom:(EMChatroom *)aChatroom;

+ (void)markAllAsRead:(EMConversationModel *)aConversationModel;

@end


@protocol EMConversationsDelegate <NSObject>

@optional

- (void)didConversationUnreadCountZero:(EMConversationModel *)aConversation;

@end

NS_ASSUME_NONNULL_END
