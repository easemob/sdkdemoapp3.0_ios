//
//  EMMsgTouchIncident.h
//  EaseIM
//
//  Created by 娜塔莎 on 2020/7/7.
//  Copyright © 2020 娜塔莎. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EMChatViewController.h"
#import "EMMessageCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface EMMessageEventStrategy : NSObject

@property (nonatomic, strong) EMChatViewController *chatController;

- (void)messageCellEventOperation:(EMMessageCell *)aCell;

- (void)_showCustomTransferFileAlertView;

@end


/**
    消息事件工厂
 */
@interface EMMessageEventStrategyFactory : NSObject

+ (EMMessageEventStrategy * _Nonnull)getStratrgyImplWithMsgCell:(EMMessageCell *)aCell;

@end

@interface CommunicateMsgEvent : EMMessageEventStrategy
@end

@interface ImageMsgEvent : EMMessageEventStrategy
@end

@interface LocationMsgEvent : EMMessageEventStrategy
@end

@interface VoiceMsgEvent : EMMessageEventStrategy
@end

@interface VideoMsgEvent : EMMessageEventStrategy
@end

@interface FileMsgEvent : EMMessageEventStrategy
@end

@interface ConferenceMsgEvent : EMMessageEventStrategy
@end

NS_ASSUME_NONNULL_END
