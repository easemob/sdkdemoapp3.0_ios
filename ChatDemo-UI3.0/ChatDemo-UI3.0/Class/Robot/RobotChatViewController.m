//
//  RobotChatViewController.m
//  ChatDemo-UI2.0
//
//  Created by dujiepeng on 15/7/27.
//  Copyright (c) 2015年 dujiepeng. All rights reserved.
//

#import "RobotChatViewController.h"
#import "RobotManager.h"
#import "EMRotbotChatViewCell.h"
//#import "EMChatTimeCell.h"
@implementation RobotChatViewController

- (void)sendTextMessage:(NSString *)text
{
    NSDictionary *ext = nil;
    ext = @{kRobot_Message_Ext:[NSNumber numberWithBool:YES]};
    EMMessage *message = [EaseSDKHelper sendTextMessage:text
                                                   to:self.conversation.chatter
                                          messageType:[self _messageTypeFromConversationType]
                                    requireEncryption:NO
                                           messageExt:ext];
    [self addMessageToDataSource:message
                        progress:nil];
}

- (void)sendImageMessage:(UIImage *)image
{
    NSDictionary *ext = nil;
    ext = @{kRobot_Message_Ext:[NSNumber numberWithBool:YES]};
    id<IEMChatProgressDelegate> progress = nil;
    EMMessage *message = [EaseSDKHelper sendImageMessageWithImage:image
                                                               to:self.conversation.chatter
                                                      messageType:[self _messageTypeFromConversationType]
                                                requireEncryption:NO
                                                       messageExt:ext
                                                         progress:progress];
    [self addMessageToDataSource:message
                        progress:progress];
}

- (void)sendVoiceMessageWithLocalPath:(NSString *)localPath duration:(NSInteger)duration
{
    NSDictionary *ext = nil;
    ext = @{kRobot_Message_Ext:[NSNumber numberWithBool:YES]};
    id<IEMChatProgressDelegate> progress = nil;
    EMMessage *message = [EaseSDKHelper sendVoiceMessageWithLocalPath:localPath
                                                             duration:duration
                                                                   to:self.conversation.chatter
                                                          messageType:[self _messageTypeFromConversationType]
                                                    requireEncryption:NO
                                                           messageExt:ext
                                                             progress:progress];
    [self addMessageToDataSource:message
                        progress:progress];
}

- (void)sendVideoMessageWithURL:(NSURL *)url
{
    NSDictionary *ext = nil;
    ext = @{kRobot_Message_Ext:[NSNumber numberWithBool:YES]};
    id<IEMChatProgressDelegate> progress = nil;
    EMMessage *message = [EaseSDKHelper sendVideoMessageWithURL:url
                                                             to:self.conversation.chatter
                                                    messageType:[self _messageTypeFromConversationType]
                                              requireEncryption:NO
                                                     messageExt:ext
                                                       progress:progress];
    [self addMessageToDataSource:message
                        progress:progress];
}

- (void)sendLocationMessageLatitude:(double)latitude
                          longitude:(double)longitude
                         andAddress:(NSString *)address
{
    NSDictionary *ext = nil;
    ext = @{kRobot_Message_Ext:[NSNumber numberWithBool:YES]};
    EMMessage *message = [EaseSDKHelper sendLocationMessageWithLatitude:latitude
                                                              longitude:longitude
                                                                address:address
                                                                     to:self.conversation.chatter
                                                            messageType:[self _messageTypeFromConversationType]
                                                      requireEncryption:NO
                                                             messageExt:ext];
    [self addMessageToDataSource:message
                        progress:nil];
}

- (EMMessageType)_messageTypeFromConversationType
{
    EMMessageType type = eMessageTypeChat;
    switch (self.conversation.conversationType) {
        case eConversationTypeChat:
            type = eMessageTypeChat;
            break;
        case eConversationTypeGroupChat:
            type = eMessageTypeGroupChat;
            break;
        case eConversationTypeChatRoom:
            type = eMessageTypeChatRoom;
            break;
        default:
            break;
    }
    return type;
}

@end
