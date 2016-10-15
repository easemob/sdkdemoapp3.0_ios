//
//  EMChatBaseBubbleView.h
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 16/9/27.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EMChatBaseBubbleViewDelegate <NSObject>

@optional

- (void)didBubbleViewPressed:(EMMessage*)message;

- (void)didBubbleViewLongPressed;

@end

@interface EMChatBaseBubbleView : UIView

@property (strong, nonatomic) UIImageView *backImageView;

@property (strong, nonatomic) EMMessage *message;

@property (weak, nonatomic) id<EMChatBaseBubbleViewDelegate> delegate;

+ (CGFloat)heightForBubbleWithMessage:(EMMessage *)message;

@end
