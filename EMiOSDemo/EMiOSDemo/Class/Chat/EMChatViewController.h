//
//  EMChatViewController.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/18.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EMRefreshViewController.h"
#import "EMSearchViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class EMConversationModel;
@interface EMChatViewController : EMSearchViewController

@property(nonatomic, strong) UIAlertController *alertController;

- (instancetype)initWithConversationId:(NSString *)aId
                                  type:(EMConversationType)aType
                      createIfNotExist:(BOOL)aIsCreate
                        isChatRecord:(BOOL)aIsChatRecord;

- (instancetype)initWithCoversationModel:(EMConversationModel *)aModel;

- (void)sendCallEndMsg:(NSNotification*)noti;

@end

NS_ASSUME_NONNULL_END
