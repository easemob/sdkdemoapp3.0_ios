//
//  EaseVideoInfoViewController.m
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 16/10/10.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "EaseVideoInfoViewController.h"

@interface EaseVideoInfoViewController ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *resolutionLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLatencyLabel;
@property (weak, nonatomic) IBOutlet UILabel *frameRateLabel;
@property (weak, nonatomic) IBOutlet UILabel *lostRateLabel;
@property (weak, nonatomic) IBOutlet UILabel *localBitrateLabel;
@property (weak, nonatomic) IBOutlet UILabel *remoteBitrateLabel;

@property (strong, nonatomic) NSTimer *propertyTimer;

@property (strong, nonatomic) NSTimer *timeTimer;

@property (strong, nonatomic) UITapGestureRecognizer *tap;

@end

@implementation EaseVideoInfoViewController


- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        

    }
    
    return self;
}

- (void)startShowInfo
{
    if (_callSession.type == EMCallTypeVideo) {
        
        [self _reloadPropertyData];
        _propertyTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(_reloadPropertyData) userInfo:nil repeats:YES];
        
    }
}

- (void)_reloadPropertyData
{
    if (_callSession) {
        
        _resolutionLabel.text = [NSString stringWithFormat:@"%d x %d px", (int)_callSession.remoteVideoResolution.width, (int)_callSession.remoteVideoResolution.height];
        
        _timeLatencyLabel.text = [NSString stringWithFormat:@"%i ms", _callSession.videoLatency];
        
        _frameRateLabel.text = [NSString stringWithFormat:@"%i fps", _callSession.remoteVideoFrameRate];
        
        _lostRateLabel.text = [NSString stringWithFormat:@"%i%%",_callSession.remoteVideoLostRateInPercent];
        
        _localBitrateLabel.text = [NSString stringWithFormat:@"%i KB", _callSession.localVideoBitrate];
        
        _remoteBitrateLabel.text = [NSString stringWithFormat:@"%i KB", _callSession.remoteVideoBitrate];

    }
}

- (UITapGestureRecognizer *)tap
{
    if (!_tap) {
        _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeVideoInfo)];
    }
    return _tap;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self startShowInfo];
    _timeLabel.text = _currentTime;
    _nameLabel.text = _callSession.remoteName;
    [self timeTimerAction:nil];
    [self.view addGestureRecognizer:self.tap];

}

- (void)closeVideoInfo
{
    if (_propertyTimer) {
        [_propertyTimer invalidate];
        _propertyTimer = nil;
    }
    
    if (_timeTimer) {
        [_timeTimer invalidate];
        _timeTimer = nil;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)startTimer:(int)currentTimeLength
{
    _timeLength = currentTimeLength;
    _timeTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timeTimerAction:) userInfo:nil repeats:YES];
}

- (void)timeTimerAction:(id)sender
{
    _timeLength += 1;
    int hour = _timeLength / 3600;
    int m = (_timeLength - hour * 3600) / 60;
    int s = _timeLength - hour * 3600 - m * 60;
    
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

@end
