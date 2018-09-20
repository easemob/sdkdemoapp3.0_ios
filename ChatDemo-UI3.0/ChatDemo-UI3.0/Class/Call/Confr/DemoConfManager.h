//
//  DemoConfManager.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 23/11/2016.
//  Copyright © 2016 XieYajie. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ConferenceViewController.h"
#import "LiveViewController.h"

#define KNOTIFICATION_CONFERENCE @"conference"

@class MainViewController;
@class EMConferenceViewController;
@interface DemoConfManager : NSObject

#if DEMO_CALL == 1

@property (strong, nonatomic) MainViewController *mainController;

+ (instancetype)sharedManager;

- (ConferenceViewController *)pushConferenceControllerWithType:(EMConferenceType)aType;

- (LiveViewController *)pushLiveControllerWithPassword:(NSString *)aPassword;

- (void)pushCustomVideoConferenceController;

- (void)handleMessageToJoinConference:(EMMessage *)aMessage;

#pragma mark - New

- (void)selectConfMemberWithType:(EMConferenceType)aType;

- (EMConferenceViewController *)startConferenceWithType:(EMConferenceType)aType
                                               password:(NSString *)aPassword
                                            inviteUsers:(NSArray *)aInviteUsers;

- (void)endConference:(EMCallConference *)aCall
            isDestroy:(BOOL)aIsDestroy;

#endif

@end
