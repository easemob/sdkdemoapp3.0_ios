//
//  EMChatDemoDelegate.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/23.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol EMChatDemoDelegate <EMChatManagerDelegate>

@property

- (void)demoConversationUnreadCountChanged:(EMConversation *)aConversation;

@end

NS_ASSUME_NONNULL_END
