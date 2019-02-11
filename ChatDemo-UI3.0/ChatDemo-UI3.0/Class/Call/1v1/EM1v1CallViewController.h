//
//  EM1v1CallViewController.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2018/9/19.
//  Copyright © 2018 XieYajie. All rights reserved.
//

#import "EMCallViewController.h"

#import "DemoCallManager.h"
#import "EMStreamView.h"

@interface EM1v1CallViewController : EMCallViewController<EMStreamViewDelegate>

@property (nonatomic, strong) UILabel *remoteNameLabel;
@property (nonatomic, strong) UILabel *timeLabel;

@property (nonatomic, strong) UIButton *answerButton;

@property (nonatomic, strong) UIImageView *waitImgView;

@property (nonatomic, strong) EMStreamView *floatingView;

@property (nonatomic) EMCallSessionStatus callStatus;
@property (nonatomic, strong) EMCallSession *callSession;

- (instancetype)initWithCallSession:(EMCallSession *)aCallSession;

- (void)updateStreamingStatus:(EMCallStreamingStatus)aStatus;

- (void)clearDataAndView;

@end
