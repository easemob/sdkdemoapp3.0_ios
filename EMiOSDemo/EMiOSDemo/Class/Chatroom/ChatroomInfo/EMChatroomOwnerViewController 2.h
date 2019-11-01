//
//  EMChatroomOwnerViewController.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/2/19.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EMSearchViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class EMGroup;
@interface EMChatroomOwnerViewController : EMSearchViewController

@property (nonatomic, copy) void (^successCompletion)(EMChatroom *aChatroom);

- (instancetype)initWithChatroom:(EMChatroom *)aChatroom;

@end

NS_ASSUME_NONNULL_END
