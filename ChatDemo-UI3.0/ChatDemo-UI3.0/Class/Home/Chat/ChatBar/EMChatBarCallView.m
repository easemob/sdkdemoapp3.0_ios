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

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self _setupSubviews];
    }
    
    return self;
}

#pragma mark - Subviews

- (void)_setupSubviews
{
    self.backgroundColor = [UIColor clearColor];
    CGFloat margin = 15;
    CGFloat width = ([UIScreen mainScreen].bounds.size.width - margin * 5) / 4;
    
    EMChatBarItem *audioButton = [[EMChatBarItem alloc] initWithImage:[UIImage imageNamed:@"msg_video"] title:@"语音通话"];
    [audioButton addTarget:self action:@selector(audioButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:audioButton];
    [audioButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(margin);
        make.left.equalTo(self).offset(margin);
        make.width.height.mas_equalTo(width);
        make.bottom.equalTo(self).offset(-margin);
    }];
    
    EMChatBarItem *videoButton = [[EMChatBarItem alloc] initWithImage:[UIImage imageNamed:@"msg_video"] title:@"视频通话"];
    [videoButton addTarget:self action:@selector(videoButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:videoButton];
    [videoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(audioButton);
        make.left.equalTo(audioButton.mas_right).offset(margin);
        make.width.height.mas_equalTo(width);
    }];
}

#pragma mark - Action

- (void)audioButtonAction
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatBarCallViewAudioDidSelected)]) {
        [self.delegate chatBarCallViewAudioDidSelected];
    }
}

- (void)videoButtonAction
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatBarCallViewVideoDidSelected)]) {
        [self.delegate chatBarCallViewVideoDidSelected];
    }
}

@end
