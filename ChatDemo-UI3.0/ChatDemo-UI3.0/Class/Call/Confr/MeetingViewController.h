//
//  MeetingViewController.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2018/9/20.
//  Copyright © 2018 XieYajie. All rights reserved.
//

#import "EMConferenceViewController.h"

@interface MeetingViewController : EMConferenceViewController

- (instancetype)initWithPassword:(NSString *)aPassword
                     inviteUsers:(NSArray *)aInviteUsers
                          chatId:(NSString *)aChatId
                        chatType:(EMChatType)aChatType;

- (instancetype)initWithJoinConfId:(NSString *)aConfId
                          password:(NSString *)aPassword
                            chatId:(NSString *)aChatId
                          chatType:(EMChatType)aChatType;

@end
