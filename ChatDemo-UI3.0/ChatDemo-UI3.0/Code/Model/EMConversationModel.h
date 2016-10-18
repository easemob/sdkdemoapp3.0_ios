//
//  EMConversationModel.h
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 16/10/17.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EMConversationModel : NSObject

@property (nonatomic, copy) NSString* title;
@property (nonatomic, strong) EMConversation *conversation;

- (instancetype)initWithConversation:(EMConversation*)conversation;

@end
