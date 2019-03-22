//
//  EMChatViewController.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/18.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EMRefreshViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class EMConversationModel;
@interface EMChatViewController : EMRefreshViewController

- (instancetype)initWithConversationId:(NSString *)aId
                                  type:(EMConversationType)aType
                      createIfNotExist:(BOOL)aIsCreate;

- (instancetype)initWithCoversationModel:(EMConversationModel *)aModel;

@end

NS_ASSUME_NONNULL_END
