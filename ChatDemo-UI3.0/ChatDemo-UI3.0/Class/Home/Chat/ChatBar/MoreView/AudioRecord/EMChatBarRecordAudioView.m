//
//  EMChatBarRecordAudioView.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/29.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EMChatBarRecordAudioView.h"

#import "EMAudioRecordHelper.h"

@interface EMChatBarRecordAudioView()

@property (nonatomic, strong) NSString *path;
@property (nonatomic) NSInteger maxTimeSecond;

@property (nonatomic) NSInteger timeLength;
@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong) UIButton *recordButton;
@property (nonatomic, strong) UILabel *titleLabel;

@end


@implementation EMChatBarRecordAudioView

- (instancetype)initWithRecordPath:(NSString *)aPath
{
    self = [super init];
    if (self) {
        _path = aPath;
        _maxTimeSecond = 60;
        
        [self _setupSubviews];
    }
    
    return self;
}

#pragma mark - Subviews

- (void)_setupSubviews
{
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.font = [UIFont systemFontOfSize:18];
    self.titleLabel.textColor = [UIColor grayColor];
    self.titleLabel.text = @"按住录音";
    [self addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.bottom.equalTo(self).offset(-30);
        make.height.equalTo(@20);
    }];
    
    self.recordButton = [[UIButton alloc] init];
    [self.recordButton setBackgroundImage:[UIImage imageNamed:@"chat_audio_blue"] forState:UIControlStateNormal];
    [self.recordButton addTarget:self action:@selector(recordButtonTouchBegin) forControlEvents:UIControlEventTouchDown];
    [self.recordButton addTarget:self action:@selector(recordButtonTouchEnd) forControlEvents:UIControlEventTouchUpInside];
    [self.recordButton addTarget:self action:@selector(recordButtonTouchCancelBegin) forControlEvents:UIControlEventTouchDragOutside];
    [self.recordButton addTarget:self action:@selector(recordButtonTouchCancelCancel) forControlEvents:UIControlEventTouchDragInside];
    [self addSubview:self.recordButton];
    [self.recordButton addTarget:self action:@selector(recordButtonTouchCancelEnd) forControlEvents:UIControlEventTouchUpOutside];
    [self.recordButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.bottom.equalTo(self.titleLabel.mas_top).offset(-15);
        make.width.height.equalTo(@80);
        make.top.equalTo(self).offset(100);
    }];
}

#pragma mark - Private Timer

- (void)_startTimer
{
    
}

- (void)_stopTimer
{
    
}

#pragma mark - Private Record

- (void)_startRecord
{
    self.timeLength = 0;
    
    NSString *recordPath = [self.path stringByAppendingFormat:@"/%.0f", [[NSDate date] timeIntervalSince1970] * 1000];
    __weak typeof(self) weakself = self;
    [[EMAudioRecordHelper sharedHelper] startRecordWithPath:recordPath completion:^(NSError * _Nonnull error) {
        if (error) {
            [weakself recordButtonTouchCancelEnd];
            [EMAlertController showErrorAlert:error.domain];
        } else {
            [weakself _startTimer];
            if (weakself.delegate && [weakself.delegate respondsToSelector:@selector(chatBarRecordAudioViewStartRecord)]) {
                [weakself.delegate chatBarRecordAudioViewStartRecord];
            }
        }
    }];
}

- (void)_stopRecord
{
    [self _stopTimer];
    
    __weak typeof(self) weakself = self;
    [[EMAudioRecordHelper sharedHelper] stopRecordWithCompletion:^(NSString * _Nonnull aPath, NSInteger aTimeLength) {
        if (weakself.delegate && [weakself.delegate respondsToSelector:@selector(chatBarRecordAudioViewStopRecord:timeLength:)]) {
            [weakself.delegate chatBarRecordAudioViewStopRecord:aPath timeLength:aTimeLength];
        }
    }];
}

- (void)_cancelRecord
{
    [self _stopTimer];
    
    [[EMAudioRecordHelper sharedHelper] cancelRecord];
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatBarRecordAudioViewCancelRecord)]) {
        [self.delegate chatBarRecordAudioViewCancelRecord];
    }
}

#pragma mark - Action

- (void)recordButtonTouchBegin
{
    self.titleLabel.text = @"松手发送";
    
    [self _startRecord];
}

- (void)recordButtonTouchEnd
{
    [self _stopRecord];
    
    self.titleLabel.text = @"按住录音";
    [self.recordButton setBackgroundImage:[UIImage imageNamed:@"chat_audio_blue"] forState:UIControlStateNormal];
}

- (void)recordButtonTouchCancelBegin
{
    self.titleLabel.text = @"松手取消";
    [self.recordButton setBackgroundImage:[UIImage imageNamed:@"chat_audio_red"] forState:UIControlStateNormal];
}

- (void)recordButtonTouchCancelCancel
{
    self.titleLabel.text = @"松手发送";
    [self.recordButton setBackgroundImage:[UIImage imageNamed:@"chat_audio_blue"] forState:UIControlStateNormal];
}

- (void)recordButtonTouchCancelEnd
{
    self.titleLabel.text = @"按住录音";
    [self.recordButton setBackgroundImage:[UIImage imageNamed:@"chat_audio_blue"] forState:UIControlStateNormal];
    
    [self _cancelRecord];
}

@end
