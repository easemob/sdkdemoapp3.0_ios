//
//  EMConversationModel.h
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

+ (NSArray<EMConversationModel *> *)modelsFromEMConversations:(NSArray<EMConversation *> *)aConversations;

@end

NS_ASSUME_NONNULL_END
