//
//  EM1v1CallViewController.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2018/9/19.
//  Copyright © 2018 XieYajie. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Masonry.h"

#import "EMButton.h"
#import "DemoCallManager.h"

static bool isHeadphone()
{
    AVAudioSessionRouteDescription* route = [[AVAudioSession sharedInstance] currentRoute];
    for (AVAudioSessionPortDescription* desc in [route outputs]) {
        if ([[desc portType] isEqualToString:AVAudioSessionPortHeadphones])
            return YES;
    }
    
    return NO;
}

@interface EM1v1CallViewController : UIViewController

#if DEMO_CALL == 1

@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UILabel *remoteNameLabel;
@property (nonatomic, strong) UILabel *timeLabel;

@property (nonatomic, strong) EMButton *microphoneButton;
@property (nonatomic, strong) EMButton *speakerButton;

@property (nonatomic, strong) UIButton *hangupButton;
@property (nonatomic, strong) UIButton *answerButton;
@property (nonatomic, strong) UIButton *minButton;

@property (nonatomic, strong) UIImageView *waitImgView;

@property (nonatomic) EMCallSessionStatus callStatus;
@property (nonatomic, strong) EMCallSession *callSession;

- (instancetype)initWithCallSession:(EMCallSession *)aCallSession;

- (void)updateStreamingStatus:(EMCallStreamingStatus)aStatus;

- (void)speakerButtonAction;

#endif

@end
