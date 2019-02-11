//
//  EMChatBarCallView.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/30.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EMChatBarCallView.h"

#import "EMChatBarItem.h"

@interface EMChatBarCallView()

//@property (nonatomic, strong)

@end


@implementation EMChatBarCallView

- (instancetype)initWithChatType:(EMConversationType)aChatType
{
    self = [super init];
    if (self) {
        [self _setupSubviewsWithChatType:aChatType];
    }
    
    return self;
}

#pragma mark - Subviews

- (void)_setupSubviewsWithChatType:(EMConversationType)aChatType
{
    self.backgroundColor = [UIColor clearColor];
    CGFloat margin = 15;
    CGFloat width = ([UIScreen mainScreen].bounds.size.width - margin * 5) / 4;
    
    EMChatBarItem *button1 = nil;
    if (aChatType == EMConversationTypeChat) {
        button1 = [[EMChatBarItem alloc] initWithImage:[UIImage imageNamed:@"msg_video"] title:@"语音通话"];
        [button1 addTarget:self action:@selector(audioCallAction) forControlEvents:UIControlEventTouchUpInside];
    } else {
        button1 = [[EMChatBarItem alloc] initWithImage:[UIImage imageNamed:@"msg_video"] title:@"会议"];
        [button1 addTarget:self action:@selector(conferenceAction) forControlEvents:UIControlEventTouchUpInside];
    }
    [self addSubview:button1];
    [button1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(margin);
        make.left.equalTo(self).offset(margin);
        make.width.height.mas_equalTo(width);
        make.bottom.equalTo(self).offset(-margin);
    }];
    
    EMChatBarItem *button2 = nil;
    if (aChatType == EMConversationTypeChat) {
        button2 = [[EMChatBarItem alloc] initWithImage:[UIImage imageNamed:@"msg_video"] title:@"视频通话"];
        [button2 addTarget:self action:@selector(videoCallAction) forControlEvents:UIControlEventTouchUpInside];
    } else {
        button2 = [[EMChatBarItem alloc] initWithImage:[UIImage imageNamed:@"msg_video"] title:@"直播"];
        [button2 addTarget:self action:@selector(liveAction) forControlEvents:UIControlEventTouchUpInside];
    }
    [self addSubview:button2];
    [button2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(button1);
        make.left.equalTo(button1.mas_right).offset(margin);
        make.width.height.mas_equalTo(width);
    }];
}

#pragma mark - Action

- (void)audioCallAction
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatBarCallViewAudioDidSelected)]) {
        [self.delegate chatBarCallViewAudioDidSelected];
    }
}

- (void)videoCallAction
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatBarCallViewVideoDidSelected)]) {
        [self.delegate chatBarCallViewVideoDidSelected];
    }
}

- (void)conferenceAction
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatBarCallViewConferenceDidSelected)]) {
        [self.delegate chatBarCallViewConferenceDidSelected];
    }
}

- (void)liveAction
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatBarCallViewLiveDidSelected)]) {
        [self.delegate chatBarCallViewLiveDidSelected];
    }
}

@end
