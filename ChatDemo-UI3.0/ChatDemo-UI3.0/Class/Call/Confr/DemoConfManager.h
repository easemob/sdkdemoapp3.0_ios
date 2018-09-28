//
//  DemoConfManager.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 23/11/2016.
//  Copyright © 2016 XieYajie. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ConfInviteUsersViewController.h"

@class MainViewController;
@class EMConferenceViewController;
@interface DemoConfManager : NSObject

#if DEMO_CALL == 1

@property (nonatomic) BOOL isCalling;

@property (strong, nonatomic) MainViewController *mainController;

+ (instancetype)sharedManager;

- (void)inviteMemberWithConfType:(EMConferenceType)aConfType
                      inviteType:(ConfInviteType)aInviteType
                  conversationId:(NSString *)aConversationId
                        chatType:(EMChatType)aChatType;

- (void)handleMessageToJoinConference:(EMMessage *)aMessage;

- (void)endConference:(EMCallConference *)aCall
            isDestroy:(BOOL)aIsDestroy;

#endif

@end
