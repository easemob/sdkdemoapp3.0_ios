//
//  Call1v1VideoViewController.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2018/9/19.
//  Copyright © 2018 XieYajie. All rights reserved.
//

#import "Call1v1VideoViewController.h"

#import "EMButton.h"

#ifdef ENABLE_RECORDER_PLUGIN
#import "EMCallRecorderPlugin.h"
#endif

#define TAG_MINVIDEOVIEW_LOCAL 100
#define TAG_MINVIDEOVIEW_REMOTE 200

@interface Call1v1VideoViewController ()

@property (nonatomic, strong) UIView *minVideoView;
@property (nonatomic, strong) EMButton *switchCameraButton;

#ifdef ENABLE_RECORDER_PLUGIN
@property (nonatomic, strong) EMButton *recorderButton;
@property (nonatomic, strong) EMButton *picButton;
#endif

@end

@implementation Call1v1VideoViewController
@synthesize callStatus = _callStatus;

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
    
    self.switchCameraButton = [[EMButton alloc] initWithTitle:@"切换摄像头" target:self action:@selector(switchCameraButtonAction:)];
    [self.switchCameraButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.switchCameraButton setTitleColor:[UIColor grayColor] forState:UIControlStateSelected];
    [self.switchCameraButton setImage:[UIImage imageNamed:@"switchCamera_white"] forState:UIControlStateNormal];
    [self.switchCameraButton setImage:[UIImage imageNamed:@"switchCamera_gray"] forState:UIControlStateSelected];
    [self.view addSubview:self.switchCameraButton];
    [self.switchCameraButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(padding);
        make.bottom.equalTo(self.hangupButton.mas_top).offset(-40);
    }];
    
    [self.microphoneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.microphoneButton setTitleColor:[UIColor grayColor] forState:UIControlStateSelected];
    [self.microphoneButton setImage:[UIImage imageNamed:@"micphone_white"] forState:UIControlStateNormal];
    [self.microphoneButton setImage:[UIImage imageNamed:@"micphone_gray"] forState:UIControlStateSelected];
    [self.microphoneButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.switchCameraButton.mas_right).offset(padding);
        make.bottom.equalTo(self.switchCameraButton);
    }];
    
    EMButton *videoButton = [[EMButton alloc] initWithTitle:@"视频" target:self action:@selector(videoButtonAction:)];
    [videoButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [videoButton setTitleColor:[UIColor grayColor] forState:UIControlStateSelected];
    [videoButton setImage:[UIImage imageNamed:@"video_white"] forState:UIControlStateNormal];
    [videoButton setImage:[UIImage imageNamed:@"video_gray"] forState:UIControlStateSelected];
    [self.view addSubview:videoButton];
    [videoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.microphoneButton.mas_right).offset(padding);
        make.bottom.equalTo(self.switchCameraButton);
    }];
    
    [self.speakerButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [self.speakerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.speakerButton setImage:[UIImage imageNamed:@"speaker_gray"] forState:UIControlStateNormal];
    [self.speakerButton setImage:[UIImage imageNamed:@"speaker_white"] forState:UIControlStateSelected];
    [self.speakerButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(videoButton.mas_right).offset(padding);
        make.bottom.equalTo(self.switchCameraButton);
    }];
    
    [@[self.switchCameraButton, self.microphoneButton, videoButton, self.speakerButton] mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(width);
        make.height.mas_equalTo(height);
    }];
    
    [self.waitImgView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-20);
        make.bottom.equalTo(self.switchCameraButton.mas_top).offset(-30);
    }];
    
#ifdef ENABLE_RECORDER_PLUGIN
    self.recorderButton = [[EMButton alloc] initWithTitle:@"录制" target:self action:@selector(recorderButtonAction)];
    [self.recorderButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [self.recorderButton setImage:[UIImage imageNamed:@"recorder_gray"] forState:UIControlStateNormal];
    [self.recorderButton setTitle:@"停止录屏" forState:UIControlStateSelected];
    [self.recorderButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.recorderButton setImage:[UIImage imageNamed:@"recorder_white"] forState:UIControlStateSelected];
    [self.view addSubview:self.recorderButton];
    [self.recorderButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(padding);
        make.bottom.equalTo(self.switchCameraButton.mas_top).offset(-20);
        make.width.mas_equalTo(width);
        make.height.mas_equalTo(height);
    }];
    
    self.picButton = [[EMButton alloc] initWithTitle:@"截图" target:self action:@selector(takeRemoteVideoPicture)];
    [self.picButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [self.picButton setImage:[UIImage imageNamed:@"grid_white"] forState:UIControlStateNormal];
    [self.view addSubview:self.picButton];
    [self.picButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.recorderButton.mas_right).offset(padding);
        make.bottom.equalTo(self.recorderButton);
        make.width.mas_equalTo(width);
        make.height.mas_equalTo(height);
    }];
#endif
    
    //初始化自己视频显示的页面
    width = 80;
    CGSize size = [UIScreen mainScreen].bounds.size;
    height = size.height / size.width * width;

    self.minVideoView = [[UIView alloc] init];
    self.minVideoView.tag = TAG_MINVIDEOVIEW_LOCAL;
    self.minVideoView.backgroundColor = [UIColor blackColor];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(exchangeVideoViewAction:)];
    [self.minVideoView addGestureRecognizer:tap];
    [self.view addSubview:self.minVideoView];
    [self.minVideoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.remoteNameLabel.mas_bottom);
        make.width.mas_equalTo(80);
        make.height.mas_equalTo(80);
        make.right.equalTo(self.view).offset(-15);
    }];
    
    self.callSession.localVideoView = [[EMCallLocalView alloc] init];
    self.callSession.localVideoView.scaleMode = EMCallViewScaleModeAspectFill;
    [self.minVideoView addSubview:self.callSession.localVideoView];
    [self.view bringSubviewToFront:self.minVideoView];
    [self.callSession.localVideoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.minVideoView);
    }];
}

- (void)_setRemoteVideoViewFrame
{
    if (self.minButton.isSelected) {
        [self.floatingView addSubview:self.callSession.remoteVideoView];
        [self.callSession.remoteVideoView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.floatingView);
        }];
        return;
    }
    
    if (self.minVideoView.tag == TAG_MINVIDEOVIEW_REMOTE) {
        [self.minVideoView addSubview:self.callSession.remoteVideoView];
        [self.view bringSubviewToFront:self.minVideoView];
        [self.callSession.remoteVideoView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.minVideoView);
        }];
    } else {
        [self.view addSubview:self.callSession.remoteVideoView];
        [self.view sendSubviewToBack:self.callSession.remoteVideoView];
        [self.callSession.remoteVideoView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
}

- (void)_setupRemoteVideoView
{
    if (self.callSession.remoteVideoView == nil) {
        self.callSession.remoteVideoView = [[EMCallRemoteView alloc] init];
        self.callSession.remoteVideoView.backgroundColor = [UIColor clearColor];
        self.callSession.remoteVideoView.scaleMode = EMCallViewScaleModeAspectFill;
        self.callSession.remoteVideoView.userInteractionEnabled = YES;
    }
    
    [self _setRemoteVideoViewFrame];
}

#pragma mark - Super Public

- (void)setCallStatus:(EMCallSessionStatus)callStatus
{
    [super setCallStatus:callStatus];
    
    if (callStatus == EMCallSessionStatusAccepted) {
        if (!self.callSession.remoteVideoView) {
            [self _setupRemoteVideoView];
        }
    }
}

#pragma mark - EMStreamViewDelegate

- (void)streamViewDidTap:(EMStreamView *)aVideoView
{
    [super streamViewDidTap:aVideoView];
    
    if (self.callSession.remoteVideoView) {
        [self.callSession.remoteVideoView removeFromSuperview];
        [self _setRemoteVideoViewFrame];
    }
}

#pragma mark - Action

- (void)exchangeVideoViewAction:(UITapGestureRecognizer *)aTap
{
    if (aTap.state != UIGestureRecognizerStateEnded) {
        return;
    }
    
    [self.callSession.localVideoView removeFromSuperview];
    [self.callSession.remoteVideoView removeFromSuperview];
    [self.waitImgView removeFromSuperview];
    if (self.minVideoView.tag == TAG_MINVIDEOVIEW_LOCAL) {
        self.minVideoView.tag = TAG_MINVIDEOVIEW_REMOTE;
        
        [self.view addSubview:self.callSession.localVideoView];
        [self.view sendSubviewToBack:self.callSession.localVideoView];
        [self.callSession.localVideoView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        
        if (self.callSession.remoteVideoView) {
            [self.minVideoView addSubview:self.callSession.remoteVideoView];
            [self.callSession.remoteVideoView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self.minVideoView);
            }];
        } else {
            [self.minVideoView addSubview:self.waitImgView];
            [self.waitImgView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self.minVideoView);\
            }];
        }
    } else if (self.minVideoView.tag == TAG_MINVIDEOVIEW_REMOTE) {
        self.minVideoView.tag = TAG_MINVIDEOVIEW_LOCAL;
        
        [self.minVideoView addSubview:self.callSession.localVideoView];
        [self.callSession.localVideoView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.minVideoView);
        }];
        
        if (self.callSession.remoteVideoView) {
            [self.view addSubview:self.callSession.remoteVideoView];
            [self.view sendSubviewToBack:self.callSession.remoteVideoView];
            [self.callSession.remoteVideoView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self.view);
            }];
        } else {
            [self.view addSubview:self.waitImgView];
            [self.view sendSubviewToBack:self.waitImgView];
            [self.waitImgView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.view).offset(20);
                make.right.equalTo(self.view).offset(-20);
                make.bottom.equalTo(self.switchCameraButton.mas_top).offset(-30);
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

- (void)minimizeAction
{
    self.minButton.selected = YES;
    
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:self.floatingView];
    [keyWindow bringSubviewToFront:self.floatingView];
    [self.floatingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@80);
        make.top.equalTo(keyWindow.mas_top).offset(80);
        make.right.equalTo(keyWindow.mas_right).offset(-40);
    }];
    
    if (self.callSession.remoteVideoView) {
        [self.callSession.remoteVideoView removeFromSuperview];
        self.floatingView.displayView = self.callSession.remoteVideoView;
        [self.floatingView addSubview:self.callSession.remoteVideoView];
        self.floatingView.enableVoice = self.floatingView.enableVoice;
        [self.callSession.remoteVideoView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.floatingView);
        }];
    }
    
    [self dismissViewControllerAnimated:NO completion:nil];
}

#ifdef ENABLE_RECORDER_PLUGIN
- (void)takeRemoteVideoPicture
{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [path stringByAppendingPathComponent:@"HyphenateSDK/image"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = YES;
    if (![fileManager fileExistsAtPath:filePath isDirectory:&isDir]) {
        [fileManager createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970] * 1000;
    NSString *fileName = [NSString stringWithFormat:@"%@/%.0f.jpeg", filePath, time];
    [[EMCallRecorderPlugin sharedInstance] screenCaptureToFilePath:fileName error:nil];
}

- (void)recorderButtonAction
{
    self.recorderButton.selected = !self.recorderButton.isSelected;

    if (!self.recorderButton.isSelected) {
        if (self.recorderButton.tag == 100) {
            [[EMCallRecorderPlugin sharedInstance]   stopAudioRecordWithCompletion:^(NSString *aFilePath, EMError *aError) {
                NSLog(@"录制语音路径：%@", aFilePath);
            }];
        } else if (self.recorderButton.tag == 200) {
            NSString *path = [[EMCallRecorderPlugin sharedInstance] stopVideoRecording:nil];
            NSLog(@"录制音视频路径：%@", path);
        }
    } else {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"录制" message:nil preferredStyle:UIAlertControllerStyleActionSheet];

        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"录制语音" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.recorderButton.tag = 100;
            [[EMCallRecorderPlugin sharedInstance] startAudioRecordWithCompletion:^(EMError *aError) {
                //
            }];
        }];
        [alertController addAction:defaultAction];

        UIAlertAction *mixAction = [UIAlertAction actionWithTitle:@"录制视频" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.recorderButton.tag = 200;
            NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            NSString *filePath = [path stringByAppendingPathComponent:@"HyphenateSDK/video"];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            BOOL isDir = YES;
            if (![fileManager fileExistsAtPath:filePath isDirectory:&isDir]) {
                [fileManager createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
            }
            [[EMCallRecorderPlugin sharedInstance] startVideoRecordingToFilePath:filePath error:nil];
        }];
        [alertController addAction:mixAction];

        [alertController addAction: [UIAlertAction actionWithTitle:@"取消" style: UIAlertActionStyleCancel handler:nil]];

        [self presentViewController:alertController animated:YES completion:nil];
    }
}
#endif

@end
