//
//  EMChatControllerFactory.h
//  EMiOSDemo
//
//  Created by 娜塔莎 on 2020/8/6.
//  Copyright © 2020 娜塔莎. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMChatViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface EMChatControllerFactory : NSObject

+ (EMChatViewController *)getChatControllerInstance:(NSString *)conversationId conversationType:(EMConversationType)conType;

@end

NS_ASSUME_NONNULL_END
