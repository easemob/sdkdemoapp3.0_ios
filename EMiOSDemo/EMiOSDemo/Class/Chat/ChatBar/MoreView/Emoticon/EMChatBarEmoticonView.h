//
//  EMChatBarEmoticonView.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/30.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EMEmoticonGroup.h"

NS_ASSUME_NONNULL_BEGIN

@protocol EMChatBarEmoticonViewDelegate;
@interface EMChatBarEmoticonView : UIView

@property (nonatomic, weak) id<EMChatBarEmoticonViewDelegate> delegate;

@property (nonatomic, readonly) CGFloat viewHeight;

@end


@protocol EMChatBarEmoticonViewDelegate <NSObject>

@optional

- (void)didSelectedEmoticonModel:(EMEmoticonModel *)aModel;

- (void)didChatBarEmoticonViewSendAction;

@end

NS_ASSUME_NONNULL_END
