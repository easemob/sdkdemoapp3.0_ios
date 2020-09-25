//
//  EMCallViewController.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2018/9/19.
//  Copyright © 2018 XieYajie. All rights reserved.
//

#import "EMCallViewController.h"

@interface EMCallViewController ()

@end

@implementation EMCallViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    [self _setupCallControllerSubviews];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAudioRouteChanged:)   name:AVAudioSessionRouteChangeNotification object:[AVAudioSession sharedInstance]];
    
    //监测耳机状态，如果是插入耳机或者蓝牙状态，不显示扬声器按钮
    if (isHeadphone()) {
        self.speakerButton.hidden = YES;
    } else {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:nil];
        [audioSession setActive:YES error:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Subviews

- (void)_setupCallControllerSubviews
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.statusLabel = [[UILabel alloc] init];
    self.statusLabel.backgroundColor = [UIColor clearColor];
    self.statusLabel.font = [UIFont systemFontOfSize:15];
    self.statusLabel.textColor = [UIColor blackColor];
    self.statusLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.statusLabel];
    [self.statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(35 + EMVIEWTOPMARGIN);
        make.left.equalTo(self.view).offset(15);
    }];
    
    self.microphoneButton = [[EMButton alloc] initWithTitle:@"静音" target:self action:@selector(microphoneButtonAction)];
    [self.microphoneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.microphoneButton setImage:[UIImage imageNamed:@"microphone-initiate"] forState:UIControlStateNormal];
    [self.microphoneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.microphoneButton setEnabled:NO];
    [self.view addSubview:self.microphoneButton];
    
    self.speakerButton = [[EMButton alloc] initWithTitle:@"免提" target:self action:@selector(speakerButtonAction)];
    [self.speakerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.speakerButton setImage:[UIImage imageNamed:@"loudspeaker-initiate"] forState:UIControlStateNormal];
    [self.speakerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.speakerButton setEnabled:NO];
    [self.view addSubview:self.speakerButton];
    
    self.minButton = [[UIButton alloc] init];
    self.minButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.minButton setImage:[UIImage imageNamed:@"cuteFirstView"] forState:UIControlStateNormal];
    [self.minButton addTarget:self action:@selector(minimizeAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.minButton];
    [self.minButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(35);
        make.left.equalTo(self.view).offset(15);
        make.width.height.equalTo(@44);
    }];
    
    self.hangupButton = [[EMButton alloc] initWithTitle:@"取消" target:self action:@selector(hangupAction)];
    [self.hangupButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.hangupButton setImage:[UIImage imageNamed:@"hangup"] forState:UIControlStateNormal];
    [self.hangupButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.view addSubview:self.hangupButton];
}

#pragma mark - NSNotification

- (void)handleAudioRouteChanged:(NSNotification *)aNotif
{
    NSDictionary *interuptionDict = aNotif.userInfo;
    NSInteger routeChangeReason = [[interuptionDict valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    switch (routeChangeReason) {
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
        {
            //插入耳机
            dispatch_async(dispatch_get_main_queue(), ^{
                self.speakerButton.hidden = YES;
            });
        }
            break;
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
        {
            //拔出耳机
            dispatch_async(dispatch_get_main_queue(), ^{
                self.speakerButton.hidden = NO;
                if (self.speakerButton.isSelected) {
                    [self speakerButtonAction];
                }
            });
            
            AVAudioSession *audioSession = [AVAudioSession sharedInstance];
            [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:nil];
            [audioSession setActive:YES error:nil];
        }
            break;
        case AVAudioSessionRouteChangeReasonCategoryChange:
            // called at start - also when other audio wants to play
            break;
    }
}

#pragma mark - Action

- (void)microphoneButtonAction
{
    
}

- (void)speakerButtonAction
{
    self.speakerButton.selected = !self.speakerButton.isSelected;
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    if (self.speakerButton.isSelected) {
        [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
    } else {
        [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:nil];
    }
    [audioSession setActive:YES error:nil];
}

- (void)minimizeAction
{
    
}

- (void)hangupAction
{
    
}

@end
