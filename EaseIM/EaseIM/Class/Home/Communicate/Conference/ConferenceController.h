//
//  ConferenceController.h
//  EMiOS_IM
//
//  Created by XieYajie on 23/11/2016.
//  Copyright © 2016 XieYajie. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ConfInviteUsersViewController.h"

@class EMConferenceViewController;
@interface ConferenceController : NSObject

+ (instancetype)sharedManager;

//开始一场会议（群组/聊天室）
- (void)communicateConference:(EMConversation *)conversation rootController:(UIViewController *)controller;

- (void)endConference:(EMCallConference *)aCall
            isDestroy:(BOOL)aIsDestroy;

@end

