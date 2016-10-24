//
//  EMChatAudioBubbleView.m
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 16/9/28.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "EMChatAudioBubbleView.h"

#import "DACircularProgressView.h"
#import "EMMessageModel.h"

#define TIMER_TI 0.04f

@interface EMChatAudioBubbleView ()

@property (strong, nonatomic) UIImageView *playView;
@property (strong, nonatomic) UILabel *durationLabel;

@property (strong, nonatomic) DACircularProgressView *progressView;
@property (assign, nonatomic) CGFloat progress;
@property (strong, nonatomic) NSTimer *playTimer;

@end

@implementation EMChatAudioBubbleView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.durationLabel];
        [self addSubview:self.playView];
        [self addSubview:self.progressView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _durationLabel.frame = CGRectMake(40.f, 12.f, 24.f, 11.f);
    _playView.frame = CGRectMake(5.f, 5.f, 25.f, 25.f);
}

#pragma mark - getter

- (UIImageView*)playView
{
    if (_playView == nil) {
        _playView = [[UIImageView alloc] init];
        _playView.image = [UIImage imageNamed:@"Icon_Play"];
        _playView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _playView;
}

- (UILabel*)durationLabel
{
    if (_durationLabel == nil) {
        _durationLabel = [[UILabel alloc] init];
        _durationLabel.font = [UIFont systemFontOfSize:11.f];
    }
    return _durationLabel;
}

- (DACircularProgressView*)progressView
{
    if (_progressView == nil) {
        _progressView = [[DACircularProgressView alloc] initWithFrame:CGRectMake(5, 5, 25.f, 25.f)];
        _progressView.userInteractionEnabled = NO;
        _progressView.thicknessRatio = 0.2;
        _progressView.roundedCorners = NO;
    }
    return _progressView;
}

- (CGSize)sizeThatFits:(CGSize)size
{
    return CGSizeMake(79.f, 35.f);
}

- (void)setModel:(EMMessageModel *)model
{
    [super setModel:model];
    
    EMVoiceMessageBody *body = (EMVoiceMessageBody*)model.message.body;
    _durationLabel.text = [self formatDuration:body.duration];
    _durationLabel.textColor = model.message.direction == EMMessageDirectionSend ? RGBACOLOR(255, 255, 255, 1) : RGBACOLOR(12, 18, 24, 1);
    
    if (model.isPlaying) {
        [self startPlayAudio];
    } else {
        [self stopPlayAudio];
    }
}

#pragma mark - private

- (void)playAudio
{
    EMVoiceMessageBody *body = (EMVoiceMessageBody*)self.model.message.body;
    [_progressView setProgress:_progress animated:YES];
    _progress = _progress + 1/(body.duration/TIMER_TI);
    if (_progress >= 1) {
        [self stopPlayAudio];
    }
}

- (void)startPlayAudio
{
    _playTimer = [NSTimer scheduledTimerWithTimeInterval:TIMER_TI target:self selector:@selector(playAudio) userInfo:nil repeats:YES];
    _progressView.hidden = NO;
    _progress = 0;
    _playView.hidden = YES;
}

- (void)stopPlayAudio
{
    [_playTimer invalidate];
    _progressView.hidden = YES;
    _playView.hidden = NO;
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

+ (CGFloat)heightForBubbleWithMessageModel:(EMMessageModel *)model
{
    return 35.f;
}

@end
