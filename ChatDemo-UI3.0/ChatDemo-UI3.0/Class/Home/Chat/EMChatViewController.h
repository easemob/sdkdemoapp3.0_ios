//
//  EMChatViewController.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/18.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EMRefreshViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface EMChatViewController : EMRefreshViewController

- (instancetype)initWithCoversation:(EMConversation *)aConversation;

@end

NS_ASSUME_NONNULL_END
