//
//  EMChatAudioBubbleView.m
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 16/9/28.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "EMChatAudioBubbleView.h"

@interface EMChatAudioBubbleView ()

@property (strong, nonatomic) UIImageView *playView;
@property (strong, nonatomic) UILabel *durationLabel;

@end

@implementation EMChatAudioBubbleView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _playView = [[UIImageView alloc] init];
        _playView.image = [UIImage imageNamed:@"Icon_Play"];
        _playView.contentMode = UIViewContentModeScaleAspectFill;
        _durationLabel = [[UILabel alloc] init];
        _durationLabel.font = [UIFont systemFontOfSize:11.f];
        [self addSubview:_durationLabel];
        [self addSubview:_playView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _durationLabel.frame = CGRectMake(40.f, 12.f, 24.f, 11.f);
    _playView.frame = CGRectMake(5.f, 5.f, 25.f, 25.f);
}

- (CGSize)sizeThatFits:(CGSize)size
{
    return CGSizeMake(79.f, 35.f);
}

- (void)setMessage:(EMMessage *)message
{
    [super setMessage:message];
    
    EMVoiceMessageBody *body = (EMVoiceMessageBody*)message.body;
    _durationLabel.text = [self formatDuration:body.duration];
    _durationLabel.textColor = message.direction == EMMessageDirectionSend ? RGBACOLOR(255, 255, 255, 1) : RGBACOLOR(12, 18, 24, 1);
}

- (NSString*)formatDuration:(int)duration
{
    NSString *formatDuration;
    if (duration < 60) {
        formatDuration = [NSString stringWithFormat:@"0:%d",duration];
    } else if (duration >= 60 && duration < 3600) {
        int minutes = duration / 60;
        int seconds = duration % 60;
        formatDuration = [NSString stringWithFormat:@"%d:%d",minutes,seconds];
    } else {
        int hours = duration / 3600;
        int minutes = (duration % 3600) / 60;
        int seconds = duration % 60;
        formatDuration = [NSString stringWithFormat:@"%d:%d:%d",hours,minutes,seconds];
    }
    return formatDuration;
}

+ (CGFloat)heightForBubbleWithMessage:(EMMessage *)message
{
    return 35.f;
}

@end
