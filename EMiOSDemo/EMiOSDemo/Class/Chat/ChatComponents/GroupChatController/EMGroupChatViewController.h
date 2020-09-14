//
//  EMGroupChatViewController.h
//  EMiOSDemo
//
//  Created by 娜塔莎 on 2020/7/9.
//  Copyright © 2020 娜塔莎. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EMChatViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface EMGroupChatViewController : EMChatViewController

- (instancetype)initWithCoversationModel:(EMConversationModel *)aModel;

@end

NS_ASSUME_NONNULL_END
