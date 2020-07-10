//
//  EMChatViewController.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/18.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EMRefreshViewController.h"
#import "EMSearchViewController.h"
#import "EMChatBar.h"

NS_ASSUME_NONNULL_BEGIN

@class EMConversationModel;
@interface EMChatViewController : EMSearchViewController <UIDocumentInteractionControllerDelegate>

@property (nonatomic, strong) dispatch_queue_t msgQueue;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *titleDetailLabel;

@property (nonatomic, strong) EMConversationModel *conversationModel;

//消息格式化
@property (nonatomic) NSTimeInterval msgTimelTag;

@property(nonatomic, strong) UIAlertController *alertController;

- (instancetype)initWithConversationId:(NSString *)aId
                                  type:(EMConversationType)aType
                      createIfNotExist:(BOOL)aIsCreate
                        isChatRecord:(BOOL)aIsChatRecord;

- (instancetype)initWithCoversationModel:(EMConversationModel *)aModel;

- (void)sendTextAction:(NSString *)aText
                    ext:(NSDictionary * __nullable)aExt;

//发送消息体
- (void)sendMessageWithBody:(EMMessageBody *)aBody
                         ext:(NSDictionary * __nullable)aExt
                    isUpload:(BOOL)aIsUpload;

- (void)refreshTableView;

//消息已读回执
- (void)returnReceipt:(EMMessage *)msg;

@end

NS_ASSUME_NONNULL_END
