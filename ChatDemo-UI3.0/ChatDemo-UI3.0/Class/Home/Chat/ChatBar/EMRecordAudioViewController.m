//
//  EMRecordAudioViewController.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/29.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EMRecordAudioViewController.h"

#import "EMAudioHelper.h"

@interface EMRecordAudioViewController()

@property (nonatomic) NSInteger timeLength;
@property (nonatomic) BOOL isRecording;

@property (nonatomic, strong) UIButton *recordButton;

@property (nonatomic, strong) UILabel *titleLabel;

@end


@implementation EMRecordAudioViewController

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
    [self.view addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.bottom.equalTo(self).offset(-20);
    }];
    
    self.recordButton = [[UIButton alloc] init];
    [self.recordButton setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    [self.recordButton addTarget:self action:@selector(recordButtonTouchBegin) forControlEvents:UIControlEventTouchDown];
    [self.recordButton addTarget:self action:@selector(recordButtonTouchEnd) forControlEvents:UIControlEventTouchUpInside];
    [self.recordButton addTarget:self action:@selector(recordButtonTouchCancel) forControlEvents:UIControlEventTouchUpOutside];
    [self.recordButton addTarget:self action:@selector(recordButtonTouchCancel) forControlEvents:UIControlEventTouchCancel];
    [self.view addSubview:self.recordButton];
    [self.recordButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.bottom.equalTo(self.titleLabel.mas_top).offset(-5);
        make.height.equalTo(@50);
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
}

- (void)recordButtonTouchCancel
{
    self.titleLabel.text = @"松手取消";
    
    [self _stopRecord];
}

@end
