//
//  Call1v1AudioViewController.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2018/9/19.
//  Copyright © 2018 XieYajie. All rights reserved.
//

#import "Call1v1AudioViewController.h"

#import "EMButton.h"

#import "DemoCallManager.h"

@interface Call1v1AudioViewController ()

@end

@implementation Call1v1AudioViewController

#if DEMO_CALL == 1

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self _setupSubviews];
    
    //默认不开启扬声器
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:nil];
    [audioSession setActive:YES error:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Subviews

- (void)_setupSubviews
{
    CGFloat size = 50;
    CGFloat padding = ([UIScreen mainScreen].bounds.size.width - size * 2) / 3;
    [self.microphoneButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(padding);
        make.bottom.equalTo(self.hangupButton.mas_top).offset(-40);
        make.width.height.mas_equalTo(size);
    }];
    
    [self.speakerButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view).offset(-padding);
        make.bottom.equalTo(self.microphoneButton);
        make.width.height.mas_equalTo(size);
    }];
    
    [self.waitImgView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-20);
        make.bottom.equalTo(self.microphoneButton.mas_top).offset(-40);
    }];
}

#endif

@end
