//
//  EMChatBaseBubbleView.m
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 16/9/27.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "EMChatBaseBubbleView.h"

@interface EMChatBaseBubbleView ()

@end

@implementation EMChatBaseBubbleView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        _backImageView = [[UIImageView alloc] init];
        _backImageView.userInteractionEnabled = YES;
        _backImageView.multipleTouchEnabled = YES;
        _backImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self addSubview:_backImageView];
        _backImageView.backgroundColor = RGBACOLOR(236, 239, 241, 1);
        _backImageView.layer.cornerRadius = 10.f;
        self.backgroundColor = [UIColor clearColor];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bubbleViewPressed:)];
        [self addGestureRecognizer:tap];
        
        UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(bubbleViewLongPress:)];
        lpgr.minimumPressDuration = .5;
        [self addGestureRecognizer:lpgr];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

#pragma mark - setter

- (void)setMessage:(EMMessage *)message
{
    _message = message;
    _backImageView.backgroundColor = _message.direction == EMMessageDirectionSend ? RGBACOLOR(0, 186, 110, 1) : RGBACOLOR(236, 239, 241, 1);
}

+ (CGFloat)heightForBubbleWithMessage:(EMMessage *)message
{
    return 100.f;
}

#pragma mark - action

- (void)bubbleViewPressed:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didBubbleViewPressed:)]) {
        [self.delegate didBubbleViewPressed:self.message];
    }
}

- (void)bubbleViewLongPress:(UILongPressGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didBubbleViewLongPressed)]) {
            [self.delegate didBubbleViewLongPressed];
        }
    }
}

@end
