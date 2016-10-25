//
//  EMChatRecordView.m
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 16/9/24.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "EMChatRecordView.h"

#import <AVFoundation/AVFoundation.h>
#import "EMCDDeviceManager.h"

#define kTextNormalColor RGBACOLOR(112, 126, 137, 1)
#define kTextSendColor RGBACOLOR(255, 59, 48, 1)
#define kTextCancelColor RGBACOLOR(255, 255, 255, 1)

#define kViewSendBackGroundColor RGBACOLOR(228, 233, 236, 1)
#define kViewCancelBackGroundColor RGBACOLOR(135, 152, 164, 1)

@interface EMChatRecordView ()
{
    NSTimer *_recordTimer;
    int _recordLength;
}

@property (weak, nonatomic) IBOutlet UILabel *recordLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIButton *recordButton;

- (IBAction)recordButtonTouchDown:(id)sender;
- (IBAction)recordButtonTouchUpOutside:(id)sender;
- (IBAction)recordButtonTouchUpInside:(id)sender;
- (IBAction)recordDragOutside:(id)sender;
- (IBAction)recordDragInside:(id)sender;

@end

@implementation EMChatRecordView

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _recordButton.left = (KScreenWidth - _recordButton.width)/2;
    _timeLabel.width = KScreenWidth;
    _recordLabel.width = KScreenWidth;
}

- (void)startTimer
{
    _timeLabel.hidden = NO;
    _recordLength = 0;
    _recordTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(recordTimerAction) userInfo:nil repeats:YES];
}

- (void)endTimer
{
    _timeLabel.hidden = YES;
    _timeLabel.text = @"00:0";
    [_recordTimer invalidate];
}

- (void)resetView
{
    _recordLabel.text = NSLocalizedString(@"chat.hold.record", "Hold to record");
    _recordLabel.textColor = kTextNormalColor;
    [_recordButton setImage:[UIImage imageNamed:@"Button_Record"] forState:UIControlStateNormal];
    self.backgroundColor = kViewSendBackGroundColor;
    [self endTimer];
}

#pragma mark - action

- (IBAction)recordButtonTouchDown:(id)sender
{
    _recordLabel.text = NSLocalizedString(@"chat.release.send", @"Release to send");
    _recordLabel.textColor = kTextSendColor;
    [_recordButton setImage:[UIImage imageNamed:@"Button_Record active"] forState:UIControlStateNormal];
    [self startTimer];
    
    int x = arc4random() % 100000;
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    NSString *fileName = [NSString stringWithFormat:@"%d%d",(int)time,x];
    
    [[EMCDDeviceManager sharedInstance] asyncStartRecordingWithFileName:fileName completion:^(NSError *error) {
         if (error) {
             
         }
     }];
}

- (IBAction)recordButtonTouchUpOutside:(id)sender
{
    [[EMCDDeviceManager sharedInstance] cancelCurrentRecording];
    [self resetView];
}

- (IBAction)recordButtonTouchUpInside:(id)sender
{
    [self resetView];
    WEAK_SELF
    [[EMCDDeviceManager sharedInstance] asyncStopRecordingWithCompletion:^(NSString *recordPath, NSInteger aDuration, NSError *error) {
        if (!error) {
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(didFinishRecord:duration:)]) {
                [weakSelf.delegate didFinishRecord:recordPath duration:aDuration];
            }
        }
    }];
}

- (IBAction)recordDragOutside:(id)sender
{
    _recordLabel.text = NSLocalizedString(@"chat.release.cancel", @"Release to cancel");
    _recordLabel.textColor = kTextCancelColor;
    [_recordButton setImage:[UIImage imageNamed:@"Button_Record cancel"] forState:UIControlStateNormal];
    self.backgroundColor = kViewCancelBackGroundColor;
}

- (IBAction)recordDragInside:(id)sender
{
    _recordLabel.text = NSLocalizedString(@"chat.release.send", @"Release to send");
    _recordLabel.textColor = kTextSendColor;
    [_recordButton setImage:[UIImage imageNamed:@"Button_Record active"] forState:UIControlStateNormal];
    self.backgroundColor = kViewSendBackGroundColor;
}

- (void)recordTimerAction
{
    _recordLength += 1;
    int hour = _recordLength / 3600;
    int m = (_recordLength - hour * 3600) / 60;
    int s = _recordLength - hour * 3600 - m * 60;
    
    if (hour > 0) {
        _timeLabel.text = [NSString stringWithFormat:@"%i:%i:%i", hour, m, s];
    }
    else if(m > 0){
        _timeLabel.text = [NSString stringWithFormat:@"%i:%i", m, s];
    }
    else{
        _timeLabel.text = [NSString stringWithFormat:@"00:%i", s];
    }
}

#pragma mark - private

- (BOOL)_canRecord
{
    __block BOOL bCanRecord = YES;
    if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending) {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        if ([audioSession respondsToSelector:@selector(requestRecordPermission:)]) {
            [audioSession performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
                bCanRecord = granted;
            }];
        }
    }
    
    return bCanRecord;
}

@end
