//
//  DemoConfManager.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 23/11/2016.
//  Copyright © 2016 XieYajie. All rights reserved.
//

#import <Foundation/Foundation.h>

#define KNOTIFICATION_CONFERENCE @"conference"

@class MainViewController;
@interface DemoConfManager : NSObject

#if DEMO_CALL == 1

@property (strong, nonatomic) MainViewController *mainController;

+ (instancetype)sharedManager;

- (void)pushConferenceControllerWithType:(EMConferenceType)aType;

- (void)pushLiveControllerWithPassword:(NSString *)aPassword;

- (void)pushCustomVideoConferenceController;

- (void)handleMessageToJoinConference:(EMMessage *)aMessage;

#endif

@end
