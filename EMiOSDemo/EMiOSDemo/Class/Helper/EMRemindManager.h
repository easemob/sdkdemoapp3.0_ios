//
//  EMRemindManager.h
//  EMiOSDemo
//
//  Created by 杜洁鹏 on 2019/8/21.
//  Copyright © 2019 杜洁鹏. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EMRemindManager : NSObject
// 消息提醒
+ (void)remindMessage:(EMMessage *)aMessage;

// app角标更新
+ (void)updateApplicationIconBadgeNumber:(NSInteger)aBadgeNumber;
@end

NS_ASSUME_NONNULL_END
