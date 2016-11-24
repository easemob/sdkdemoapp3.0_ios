//
//  DemoConfManager.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 23/11/2016.
//  Copyright © 2016 XieYajie. All rights reserved.
//

#import "DemoConfManager.h"

#if DEMO_CALL == 1

#import "EMSDKFull.h"
#import "EMClient+Conference.h"
#import "IEMConferenceManager.h"

#import "MainViewController.h"
#import "EMConfUserSelectionViewController.h"
#import "ConferenceViewController.h"


static DemoConfManager *confManager = nil;

@interface DemoConfManager()<EMConferenceManagerDelegate>

@property (strong, nonatomic) ConferenceViewController *currentController;

@end

#endif

@implementation DemoConfManager

#if DEMO_CALL == 1

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self _initManager];
    }
    
    return self;
}

+ (instancetype)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        confManager = [[DemoConfManager alloc] init];
    });
    
    return confManager;
}

- (void)dealloc
{
    [[EMClient sharedClient].conferenceManager removeDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - private

- (void)_initManager
{
    _currentController = nil;
    
    [[EMClient sharedClient].conferenceManager addDelegate:self delegateQueue:nil];
}

#pragma mark - EMConferenceManagerDelegate

- (void)userDidRecvConferenceInvite:(NSString *)aConfId
                                ext:(NSString *)aExt
{
    
}

#pragma mark - conference

- (void)chooseUsersToConferenceAction
{
    NSArray *contacts = [[EMClient sharedClient].contactManager getContacts];
    EMConfUserSelectionViewController *controller = [[EMConfUserSelectionViewController alloc] initWithDataSource:contacts selectedUsers:@[[EMClient sharedClient].currentUsername]];
    [controller setSelecteUserFinishedCompletion:^(NSArray *selectedUsers) {
        ConferenceViewController *confController = [[ConferenceViewController alloc] initWithUsers:selectedUsers type:EMCallTypeVoice];
        [self.mainController.navigationController pushViewController:confController animated:NO];
    }];
    [self.mainController.navigationController pushViewController:controller animated:YES];
}


#endif

@end
