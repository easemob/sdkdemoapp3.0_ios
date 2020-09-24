//
//  EMConferenceInviteViewController.m
//  EaseIM
//
//  Created by 娜塔莎 on 2020/6/8.
//  Copyright © 2020 娜塔莎. All rights reserved.
//

#import "EMConferenceInviteViewController.h"

@interface EMConferenceInviteViewController ()
@property (nonatomic, strong) EMMessage *msg;
@end

extern BOOL gIsConferenceCalling;
@implementation EMConferenceInviteViewController

- (instancetype)initWithMessage:(EMMessage *)msg
{
    if (self = [super init]) {
        _msg = msg;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBar.hidden = YES;
    [self _setupSubviews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Subviews

- (void)_setupSubviews
{
    self.microphoneButton.hidden = YES;
    self.speakerButton.hidden = YES;
    self.minButton.hidden = YES;
    self.answerButton.enabled = YES;
    self.statusLabel.font = [UIFont systemFontOfSize:20];
    self.statusLabel.text = [NSString stringWithFormat:@"%@ 邀请你加入会议",_msg.from];
    
    [self.statusLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(30);
    }];
    /*
    [self.waitImgView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-20);
        make.bottom.equalTo(self.answerButton.mas_top).offset(-40);
    }];*/
    
    self.floatingView.bgView.image = [UIImage imageNamed:@"floating_voice"];
    self.floatingView.bgView.layer.borderWidth = 0;
    self.floatingView.isLockedBgView = YES;
}

#pragma mark - Action
- (void)answerAction
{
    [self dismissViewControllerAnimated:NO completion:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:CALL_SELECTCONFERENCECELL object:_msg];
}

- (void)hangupAction
{
    gIsConferenceCalling = NO;
    [self dismissViewControllerAnimated:NO completion:nil];
}

@end
