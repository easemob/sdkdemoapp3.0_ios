//
//  EMChatViewController.h
//  EaseIM
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

@property (nonatomic, strong) EMChatBar *chatBar;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UILabel *titleDetailLabel;

@property (nonatomic, strong) EMConversationModel *conversationModel;

//第一条消息的消息id
@property (nonatomic, strong) NSString *moreMsgId;

//消息格式化
@property (nonatomic) NSTimeInterval msgTimelTag;

@property(nonatomic, strong) UIAlertController *alertController;

- (instancetype)initWithConversationId:(NSString *)aId
                                  type:(EMConversationType)aType
                      createIfNotExist:(BOOL)aIsCreate;

- (instancetype)initWithCoversationModel:(EMConversationModel *)aModel;

- (NSString *)getAudioOrVideoPath;

- (void)sendTextAction:(NSString *)aText
                    ext:(NSDictionary * __nullable)aExt;

//发送消息体
- (void)sendMessageWithBody:(EMMessageBody *)aBody
                         ext:(NSDictionary * __nullable)aExt
                    isUpload:(BOOL)aIsUpload;

//刷新页面
- (void)refreshTableView;

//消息已读回执
- (void)returnReadReceipt:(EMMessage *)msg;

- (NSArray *)formatMessages:(NSArray<EMMessage *> *)aMessages;

@end

NS_ASSUME_NONNULL_END
