//
//  EMChatBarRecordAudioView.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/29.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EMChatBarRecordAudioView.h"

#import "EMAudioHelper.h"

@interface EMChatBarRecordAudioView()

@property (nonatomic) NSInteger timeLength;
@property (nonatomic) BOOL isRecording;

@property (nonatomic, strong) UIButton *recordButton;

@property (nonatomic, strong) UILabel *titleLabel;

@end


@implementation EMChatBarRecordAudioView

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
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.font = [UIFont systemFontOfSize:16];
    self.titleLabel.textColor = [UIColor grayColor];
    self.titleLabel.text = @"按住录音";
    [self addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.bottom.equalTo(self).offset(-20);
        make.height.equalTo(@20);
    }];
    
    self.recordButton = [[UIButton alloc] init];
    self.recordButton.backgroundColor = [UIColor redColor];
    self.recordButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.recordButton setImage:[UIImage imageNamed:@"msg_video"] forState:UIControlStateNormal];
    [self.recordButton addTarget:self action:@selector(recordButtonTouchBegin) forControlEvents:UIControlEventTouchDown];
    [self.recordButton addTarget:self action:@selector(recordButtonTouchEnd) forControlEvents:UIControlEventTouchUpInside];
    [self.recordButton addTarget:self action:@selector(recordButtonTouchCancelBegin) forControlEvents:UIControlEventTouchDragOutside];
    [self.recordButton addTarget:self action:@selector(recordButtonTouchCancelBegin) forControlEvents:UIControlEventTouchDragExit];
    [self.recordButton addTarget:self action:@selector(recordButtonTouchCancelCancel) forControlEvents:UIControlEventTouchDragInside];
    [self addSubview:self.recordButton];
    [self.recordButton addTarget:self action:@selector(recordButtonTouchCancelEnd) forControlEvents:UIControlEventTouchUpOutside];
    [self.recordButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.bottom.equalTo(self.titleLabel.mas_top).offset(-15);
        make.width.height.equalTo(@50);
        make.top.equalTo(self).offset(80);
    }];
}

#pragma mark - Private

- (void)_startRecord
{
    self.timeLength = 0;
    self.isRecording = YES;
}

- (void)_stopRecord
{
    if (self.isRecording) {
        self.isRecording = NO;
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
}

- (void)recordButtonTouchCancelBegin
{
    self.titleLabel.text = @"松手取消";
    
    [self _stopRecord];
}

- (void)recordButtonTouchCancelCancel
{
    self.titleLabel.text = @"松手发送";
}

- (void)recordButtonTouchCancelEnd
{
    self.titleLabel.text = @"按住录音";
    [self _stopRecord];
}

@end
