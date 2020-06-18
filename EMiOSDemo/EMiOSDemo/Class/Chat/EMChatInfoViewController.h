//
//  EMChatInfoViewController.h
//  EMiOSDemo
//
//  Created by 娜塔莎 on 2020/2/4.
//  Copyright © 2020 娜塔莎. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EMRefreshViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface EMChatInfoViewController : EMRefreshViewController

- (instancetype)initWithCoversation:(EMConversationModel *)aConversationModel;

@property (nonatomic, copy) void (^clearRecordCompletion)(BOOL isClear);

@end

NS_ASSUME_NONNULL_END
