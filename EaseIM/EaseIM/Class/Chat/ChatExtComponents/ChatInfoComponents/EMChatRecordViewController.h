//
//  EMChatRecordViewController.h
//  EaseIM
//
//  Created by 娜塔莎 on 2020/7/15.
//  Copyright © 2020 娜塔莎. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EMSearchViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface EMChatRecordViewController : EMSearchViewController

- (instancetype)initWithCoversationModel:(EMConversationModel *)aConversationModel;

@end

NS_ASSUME_NONNULL_END
