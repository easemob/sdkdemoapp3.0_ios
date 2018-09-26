//
//  MeetingViewController.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2018/9/20.
//  Copyright © 2018 XieYajie. All rights reserved.
//

#import "MeetingViewController.h"

@interface MeetingViewController ()<EMConferenceVideoViewDelegate>

@property (nonatomic, strong) UIButton *gridButton;
@property (nonatomic, strong) EMConferenceVideoView *currentBigView;

@end

@implementation MeetingViewController

- (instancetype)initWithPassword:(NSString *)aPassword
                     inviteUsers:(NSArray *)aInviteUsers
{
    self = [super initWithType:EMConferenceTypeLargeCommunication password:aPassword inviteUsers:aInviteUsers];
    if (self) {
    }
    
    return self;
}

- (instancetype)initWithJoinConfId:(NSString *)aConfId
                          password:(NSString *)aPassword
{
    self = [super initWithJoinConfId:aConfId password:aPassword type:EMConferenceTypeLargeCommunication];
    if (self) {
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.switchCameraButton.enabled = NO;
    
    self.gridButton = [[UIButton alloc] init];
    self.gridButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.gridButton setImage:[UIImage imageNamed:@"grid_white"] forState:UIControlStateNormal];
    [self.gridButton addTarget:self action:@selector(gridAction) forControlEvents:UIControlEventTouchUpInside];
    self.gridButton.hidden = YES;
    [self.view addSubview:self.gridButton];
    [self.gridButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(-30);
        make.left.equalTo(self.view).offset(25);
        make.width.height.equalTo(@40);
    }];
    
    [self _createOrJoinConference];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - EMConferenceVideoViewDelegate

- (void)conferenceVideoViewDidTap:(EMConferenceVideoView *)aVideoView
{
    self.gridButton.hidden = !aVideoView.isBig;
    [aVideoView.displayView removeFromSuperview];
    if (aVideoView.isBig) {
        self.currentBigView = aVideoView;
        [self.view addSubview:aVideoView.displayView];
        [self.view sendSubviewToBack:aVideoView.displayView];
        [self.view sendSubviewToBack:self.scrollView];
        [aVideoView.displayView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    } else {
        self.currentBigView = nil;
        [aVideoView addSubview:aVideoView.displayView];
        [aVideoView.displayView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(aVideoView);
        }];
    }
}

#pragma mark - EMConference

- (void)_createOrJoinConference
{
    __weak typeof(self) weakself = self;
    void (^block)(EMCallConference *aCall, NSString *aPassword, EMError *aError) = ^(EMCallConference *aCall, NSString *aPassword, EMError *aError) {
        if (aError) {
            [self hangupAction];
            
            NSString *msg = weakself.isCreater ? @"创建会议失败" : @"加入会议失败";
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"错误" message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
            
            return ;
        }
        
        weakself.conference = aCall;
        weakself.password = aPassword;
        
        [weakself _pubLocalStreamWithEnableVideo:NO completion:nil];
        
        //如果是创建者，进行邀请人操作
        if (weakself.isCreater) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                for (NSString *username in weakself.inviteUsers) {
                    [weakself inviteUser:username];
                }
            });
        }
    };
    
    if (self.isCreater) {
        [[EMClient sharedClient].conferenceManager createAndJoinConferenceWithType:self.type password:self.password completion:block];
    } else {
        [[EMClient sharedClient].conferenceManager joinConferenceWithConfId:self.joinConfId password:self.password completion:^(EMCallConference *aCall, EMError *aError) {
            block(aCall, weakself.password, aError);
        }];
    }
}

#pragma mark - EMStream

- (EMConferenceVideoItem *)setupNewVideoViewWithName:(NSString *)aName
                                         displayView:(UIView *)aDisplayView
                                              stream:(EMCallStream *)aStream
{
    EMConferenceVideoItem *item = [super setupNewVideoViewWithName:aName displayView:aDisplayView stream:aStream];
    item.videoView.delegate = self;
    return item;
}

- (void)_pubLocalStreamWithEnableVideo:(BOOL)aEnableVideo
                            completion:(void (^)(NSString *aPubStreamId))aCompletionBlock
{
    //上传流的过程中，不允许操作视频按钮
    self.videoButton.enabled = NO;
    self.switchCameraButton.enabled = NO;
    
    EMStreamParam *pubConfig = [[EMStreamParam alloc] init];
    pubConfig.streamName = [EMClient sharedClient].currentUsername;
    pubConfig.enableVideo = aEnableVideo;
    
    EMCallOptions *options = [[EMClient sharedClient].callManager getCallOptions];
    pubConfig.isFixedVideoResolution = options.isFixedVideoResolution;
    pubConfig.maxVideoKbps = (int)options.maxVideoKbps;
    pubConfig.maxAudioKbps = (int)options.maxAudioKbps;
    pubConfig.videoResolution = options.videoResolution;
    
    pubConfig.isBackCamera = self.switchCameraButton.isSelected;
    
    EMCallLocalView *localView = [[EMCallLocalView alloc] init];
    localView.scaleMode = EMCallViewScaleModeAspectFill;
    localView.backgroundColor = [UIColor blueColor];
    pubConfig.localView = localView;
    
    __weak typeof(self) weakself = self;
    [[EMClient sharedClient].conferenceManager publishConference:self.conference streamParam:pubConfig completion:^(NSString *aPubStreamId, EMError *aError) {
        if (aError) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"上传本地视频流失败，请重试" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
            return ;
            
            //TODO: 后续处理是怎么样的
        }
        
        weakself.videoButton.enabled = YES;
        weakself.videoButton.selected = aEnableVideo;
        weakself.switchCameraButton.enabled = aEnableVideo;
        
        weakself.pubStreamId = aPubStreamId;
        
        EMConferenceVideoItem *videoItem = [self setupNewVideoViewWithName:pubConfig.streamName displayView:localView stream:nil];
        videoItem.videoView.enableVideo = aEnableVideo;
        [weakself.streamItemDict setObject:videoItem forKey:aPubStreamId];
        [weakself.streamIds addObject:aPubStreamId];
        
        if (aCompletionBlock) {
            aCompletionBlock(aPubStreamId);
        }
    }];
}

#pragma mark - Action

- (void)microphoneButtonAction
{
    [super microphoneButtonAction];
    
    if ([self.pubStreamId length] > 0) {
        EMConferenceVideoItem *videoItem = [self.streamItemDict objectForKey:self.pubStreamId];
        if (videoItem) {
            videoItem.videoView.enableVoice = !self.microphoneButton.isSelected;
        }
    }
}

- (void)videoButtonAction:(EMButton *)aButton
{
    [super videoButtonAction:aButton];
    
    //TODO: 更新View
    EMConferenceVideoItem *videoItem = [self.streamItemDict objectForKey:self.pubStreamId];
    videoItem.videoView.enableVideo = aButton.isSelected;
    self.switchCameraButton.enabled = aButton.isSelected;
    
    if (aButton.selected) {
        BOOL isUseBackCamera = [[[NSUserDefaults standardUserDefaults] objectForKey:@"em_IsUseBackCamera"] boolValue];
        if (isUseBackCamera != self.isUseBackCamera) {
            self.switchCameraButton.selected = self.isUseBackCamera;
            [[EMClient sharedClient].conferenceManager updateConferenceWithSwitchCamera:self.conference];
        }
    }
}

- (void)inviteButtonAction:(EMButton *)aButton
{
    NSMutableArray *members = [[NSMutableArray alloc] init];
    [members addObject:[EMClient sharedClient].currentUsername];
    for (NSString *key in self.streamItemDict) {
        EMConferenceVideoItem *item = [self.streamItemDict objectForKey:key];
        if (item.stream) {
            [members addObject:item.stream.userName];
        }
    }
    
    NSMutableArray *usernames = [[NSMutableArray alloc] initWithArray:[[EMClient sharedClient].contactManager getContacts]];
    if ([members count] > 0) {
        for (NSInteger i = [members count] - 1; i > -1; i--) {
            NSString *name = [members objectAtIndex:i];
            if ([usernames containsObject:name]) {
                [usernames removeObject:name];
            }
        }
    }
    
    ConfInviteUsersViewController *controller = [[ConfInviteUsersViewController alloc] initWithCreate:NO];
    [controller.dataArray removeAllObjects];
    [controller.dataArray addObjectsFromArray:usernames];
    [controller.tableView reloadData];
    
    __weak typeof(self) weakself = self;
    [controller setDoneCompletion:^(NSArray *inviteUsers) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            for (NSString *username in inviteUsers) {
                [weakself inviteUser:username];
            }
        });
    }];
    
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)gridAction
{
    if (self.currentBigView) {
        self.currentBigView.isBig = NO;
        [self conferenceVideoViewDidTap:self.currentBigView];
    }
}

@end
