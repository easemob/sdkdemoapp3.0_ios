//
//  Call1v1VideoViewController.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2018/9/19.
//  Copyright © 2018 XieYajie. All rights reserved.
//

#import "Call1v1VideoViewController.h"

#import "EMButton.h"

@interface Call1v1VideoViewController ()

@property (nonatomic, strong) UIButton *minVideoView;
@property (nonatomic, strong) EMButton *recorderButton;

@property (nonatomic) BOOL isCustom;
@property (nonatomic) CGSize minVideoViewSize;

@end

@implementation Call1v1VideoViewController

#if DEMO_CALL == 1

@synthesize callStatus = _callStatus;

- (instancetype)initWithCallSession:(EMCallSession *)aCallSession
                       isCustomData:(BOOL)aIsCustom
{
    self = [super initWithCallSession:aCallSession];
    if (self) {
        _isCustom = aIsCustom;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self _setupSubviews];
    
    if (!isHeadphone()) {
        [self speakerButtonAction];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Subviews

- (void)_setupSubviews
{
    CGFloat color = 51 / 255.0;
    self.view.backgroundColor = [UIColor colorWithRed:color green:color blue:color alpha:1.0];
    
    self.statusLabel.textColor = [UIColor whiteColor];
    self.timeLabel.textColor = [UIColor whiteColor];
    self.remoteNameLabel.textColor = [UIColor whiteColor];
    
    CGFloat width = 80;
    CGFloat height = 50;
    CGFloat padding = ([UIScreen mainScreen].bounds.size.width - width * 4) / 5;
    
    self.recorderButton = [[EMButton alloc] initWithTitle:@"屏幕录制" target:self action:@selector(recorderButtonAction)];
    [self.recorderButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [self.recorderButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.recorderButton setImage:[UIImage imageNamed:@"recorder_gray"] forState:UIControlStateNormal];
    [self.recorderButton setImage:[UIImage imageNamed:@"recorder_white"] forState:UIControlStateSelected];
    [self.view addSubview:self.recorderButton];
    [self.recorderButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(padding);
        make.bottom.equalTo(self.hangupButton.mas_top).offset(-40);
    }];
    
    EMButton *switchCameraButton = [[EMButton alloc] initWithTitle:@"切换摄像头" target:self action:@selector(switchCameraButtonAction:)];
    [switchCameraButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [switchCameraButton setTitleColor:[UIColor grayColor] forState:UIControlStateSelected];
    [switchCameraButton setImage:[UIImage imageNamed:@"switchCamera_white"] forState:UIControlStateNormal];
    [switchCameraButton setImage:[UIImage imageNamed:@"switchCamera_gray"] forState:UIControlStateSelected];
    [self.view addSubview:switchCameraButton];
    [switchCameraButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(padding);
        make.bottom.equalTo(self.recorderButton.mas_top).offset(-20);
    }];
    
    [self.microphoneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.microphoneButton setTitleColor:[UIColor grayColor] forState:UIControlStateSelected];
    [self.microphoneButton setImage:[UIImage imageNamed:@"micphone_white"] forState:UIControlStateNormal];
    [self.microphoneButton setImage:[UIImage imageNamed:@"micphone_gray"] forState:UIControlStateSelected];
    [self.microphoneButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(switchCameraButton.mas_right).offset(padding);
        make.bottom.equalTo(switchCameraButton);
    }];
    
    EMButton *videoButton = [[EMButton alloc] initWithTitle:@"视频" target:self action:@selector(videoButtonAction:)];
    [videoButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [videoButton setTitleColor:[UIColor grayColor] forState:UIControlStateSelected];
    [videoButton setImage:[UIImage imageNamed:@"video_white"] forState:UIControlStateNormal];
    [videoButton setImage:[UIImage imageNamed:@"video_gray"] forState:UIControlStateSelected];
    [self.view addSubview:videoButton];
    [videoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.microphoneButton.mas_right).offset(padding);
        make.bottom.equalTo(switchCameraButton);
    }];
    
    [self.speakerButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [self.speakerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.speakerButton setImage:[UIImage imageNamed:@"speaker_gray"] forState:UIControlStateNormal];
    [self.speakerButton setImage:[UIImage imageNamed:@"speaker_white"] forState:UIControlStateSelected];
    [self.speakerButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(videoButton.mas_right).offset(padding);
        make.bottom.equalTo(switchCameraButton);
    }];
    
    [@[self.recorderButton, switchCameraButton, self.microphoneButton, videoButton, self.speakerButton] mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(width);
        make.height.mas_equalTo(height);
    }];
    
    [self.waitImgView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-20);
        make.bottom.equalTo(switchCameraButton.mas_top).offset(-30);
    }];
    
    //初始化自己视频显示的页面
    width = 80;
    CGSize size = [UIScreen mainScreen].bounds.size;
    height = size.height / size.width * width;
    self.minVideoViewSize = CGSizeMake(width, height);
    
    self.callSession.localVideoView = [[EMCallLocalView alloc] initWithFrame:CGRectMake(0, 0, self.minVideoViewSize.width, self.minVideoViewSize.height)];
    [self.view addSubview:self.callSession.localVideoView];
//    [self.view bringSubviewToFront:self.callSession.localVideoView];
    
    self.minVideoView = [[UIButton alloc] init];
    self.minVideoView.backgroundColor = [UIColor clearColor];
    [self.minVideoView addTarget:self action:@selector(changeVideoViewAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.minVideoView];
    [self.minVideoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(width);
        make.height.mas_equalTo(height);
        make.right.equalTo(self.view).offset(-15);
    }];
    
    
}

- (void)_setupRemoteVideoView
{
    if (self.callSession.remoteVideoView == nil) {
        CGRect frame = self.minVideoView.isSelected ? CGRectMake(0, 0, self.minVideoViewSize.width, self.minVideoViewSize.height) : CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        self.callSession.remoteVideoView = [[EMCallRemoteView alloc] initWithFrame:frame];
        self.callSession.remoteVideoView.backgroundColor = [UIColor clearColor];
        self.callSession.remoteVideoView.scaleMode = EMCallViewScaleModeAspectFill;
        
        if (self.minVideoView.isSelected) {
            [self.view addSubview:self.callSession.remoteVideoView];
            [self.view bringSubviewToFront:self.callSession.remoteVideoView];
            [self.view bringSubviewToFront:self.minVideoView];
        } else {
            [self.view addSubview:self.callSession.remoteVideoView];
            [self.view sendSubviewToBack:self.callSession.remoteVideoView];
        }
    }
}

#pragma mark - Super Public

- (void)setCallStatus:(EMCallSessionStatus)callStatus
{
    [super setCallStatus:callStatus];
    
    if (callStatus == EMCallSessionStatusAccepted && !self.callSession.remoteVideoView) {
        [self _setupRemoteVideoView];
    }
}

#pragma mark - Action

- (void)changeVideoViewAction
{
    self.minVideoView.selected = !self.minVideoView.isSelected;
    
    CGRect bigFrame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    CGRect minFrame = CGRectMake(0, 0, self.minVideoViewSize.width, self.minVideoViewSize.height);
    if (self.minVideoView.isSelected) {
        [self.callSession.localVideoView removeFromSuperview];
        self.callSession.localVideoView.frame = bigFrame;
        [self.view addSubview:self.callSession.localVideoView];
        [self.view sendSubviewToBack:self.callSession.remoteVideoView];
        
        if (self.callSession.remoteVideoView) {
            [self.callSession.remoteVideoView removeFromSuperview];
            self.callSession.remoteVideoView.frame = minFrame;
            [self.view addSubview:self.callSession.remoteVideoView];
            [self.view bringSubviewToFront:self.callSession.remoteVideoView];
            [self.view bringSubviewToFront:self.minVideoView];
        } else {
            [self.waitImgView removeFromSuperview];
            [self.view addSubview:self.waitImgView];
            [self.view bringSubviewToFront:self.waitImgView];
            [self.view bringSubviewToFront:self.minVideoView];
            [self.waitImgView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.minVideoView);
                make.left.equalTo(self.minVideoView);
                make.bottom.equalTo(self.minVideoView);
                make.right.equalTo(self.minVideoView);
            }];
        }
    } else {
        [self.callSession.localVideoView removeFromSuperview];
        self.callSession.localVideoView.frame = minFrame;
        [self.view addSubview:self.callSession.localVideoView];
        [self.view bringSubviewToFront:self.callSession.localVideoView];
        [self.view bringSubviewToFront:self.minVideoView];
        
        if (self.callSession.remoteVideoView) {
            [self.callSession.remoteVideoView removeFromSuperview];
            self.callSession.remoteVideoView.frame = bigFrame;
            [self.view addSubview:self.callSession.remoteVideoView];
            [self.view sendSubviewToBack:self.callSession.remoteVideoView];
        } else {
            [self.waitImgView removeFromSuperview];
            [self.view addSubview:self.waitImgView];
            [self.view sendSubviewToBack:self.callSession.remoteVideoView];
            [self.waitImgView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.view);
                make.left.equalTo(self.view);
                make.bottom.equalTo(self.view);
                make.right.equalTo(self.view);
            }];
        }
    }
}

- (void)switchCameraButtonAction:(EMButton *)aButton
{
    aButton.selected = !aButton.selected;
    [self.callSession switchCameraPosition:!aButton.selected];
}

- (void)videoButtonAction:(EMButton *)aButton
{
    aButton.selected = !aButton.isSelected;
    if (aButton.isSelected) {
        [self.callSession pauseVideo];
    } else {
        [self.callSession resumeVideo];
    }
}

- (void)recorderButtonAction
{
    self.recorderButton.selected = !self.recorderButton.isSelected;
    
    //    UIButton *button = (UIButton *)sender;
    //    [button setTitle:@"停止录制" forState:UIControlStateSelected];
    //    button.selected = !button.isSelected;
    //
    //    if (!button.isSelected) {
    //        if (button.tag == 100) {
    //            [[EMCallRecorderPlugin sharedInstance] stopAudioRecordWithCompletion:^(NSString *aFilePath, EMError *aError) {
    //                NSLog(@"录制语音路径：%@", aFilePath);
    //            }];
    //        } else if (button.tag == 200) {
    //            NSString *path = [[EMCallRecorderPlugin sharedInstance] stopVideoRecording:nil];
    //            NSLog(@"录制音视频路径：%@", path);
    //        }
    //    } else {
    //        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"录制" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    //
    //        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"录制语音" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    //            button.tag = 100;
    //            [[EMCallRecorderPlugin sharedInstance] startAudioRecordWithCompletion:^(EMError *aError) {
    //                //
    //            }];
    //        }];
    //        [alertController addAction:defaultAction];
    //
    //        UIAlertAction *mixAction = [UIAlertAction actionWithTitle:@"录制音视频" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    //            button.tag = 200;
    //            NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    //            NSString *filePath = [path stringByAppendingPathComponent:@"HyphenateSDK"];
    //            [[EMCallRecorderPlugin sharedInstance] startVideoRecordingToFilePath:filePath error:nil];
    //        }];
    //        [alertController addAction:mixAction];
    //
    //        [alertController addAction: [UIAlertAction actionWithTitle:@"取消" style: UIAlertActionStyleCancel handler:nil]];
    //
    //        [self presentViewController:alertController animated:YES completion:nil];
    //    }
}

#endif

@end
