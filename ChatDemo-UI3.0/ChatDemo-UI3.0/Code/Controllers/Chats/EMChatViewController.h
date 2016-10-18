//
//  EMChatViewController.h
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 16/9/22.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EMChatViewController : UIViewController

- (instancetype)initWithConversationId:(NSString*)conversationId conversationType:(EMConversationType)type;

@end
