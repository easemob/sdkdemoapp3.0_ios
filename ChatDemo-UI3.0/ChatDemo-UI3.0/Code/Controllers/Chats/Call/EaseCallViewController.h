//
//  EaseCallViewController.h
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 16/9/26.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EaseCallViewController : UIViewController
{
    NSTimer *_timeTimer;
}

@property (weak, nonatomic) EMCallSession *callSession;

//top
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *avatarView;

//actions
@property (weak, nonatomic) IBOutlet UIButton *speakerOutButton;
@property (weak, nonatomic) IBOutlet UIButton *silenceButton;
@property (weak, nonatomic) IBOutlet UIButton *minimizeButton;
@property (weak, nonatomic) IBOutlet UIButton *rejectCallButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelCallButton;
@property (weak, nonatomic) IBOutlet UIButton *answerCallButton;
@property (weak, nonatomic) IBOutlet UIButton *switchCameraButton;
@property (weak, nonatomic) IBOutlet UIButton *showVideoInfoButton;

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIView *actionView;

- (instancetype)initWithCallSession:(EMCallSession *)session isCaller:(BOOL)isCaller status:(NSString *)status;

- (void)startTimer;

- (void)stopTimer;

- (void)close;

- (void)setupSubViews;

- (void)reloadConnectedUI;

- (void)reloadCallDisconnectedUI;

@end
