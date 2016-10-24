//
//  EMChatBaseBubbleView.h
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 16/9/27.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EMMessageModel;
@protocol EMChatBaseBubbleViewDelegate <NSObject>

@optional

- (void)didBubbleViewPressed:(EMMessageModel*)models;

- (void)didBubbleViewLongPressed;

@end

@interface EMChatBaseBubbleView : UIView

@property (strong, nonatomic) UIImageView *backImageView;

@property (strong, nonatomic) EMMessageModel *model;

@property (weak, nonatomic) id<EMChatBaseBubbleViewDelegate> delegate;

+ (CGFloat)heightForBubbleWithMessageModel:(EMMessageModel *)model;

@end
