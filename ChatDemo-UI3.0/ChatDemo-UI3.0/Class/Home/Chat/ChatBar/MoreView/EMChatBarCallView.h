//
//  EMChatBarCallView.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/30.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol EMChatBarCallViewDelegate;
@interface EMChatBarCallView : UIView

@property (nonatomic, weak) id<EMChatBarCallViewDelegate> delegate;

- (instancetype)initWithChatType:(EMConversationType)aChatType;

@end

@protocol EMChatBarCallViewDelegate <NSObject>

@optional

- (void)chatBarCallViewAudioDidSelected;

- (void)chatBarCallViewVideoDidSelected;

- (void)chatBarCallViewConferenceDidSelected;

- (void)chatBarCallViewLiveDidSelected;

@end

NS_ASSUME_NONNULL_END
