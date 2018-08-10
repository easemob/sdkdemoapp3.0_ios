//
//  LiveViewController.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2018/7/24.
//  Copyright © 2018 XieYajie. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LiveVideoItem : NSObject

@property (nonatomic, strong) EMCallStream *stream;

@property (nonatomic, strong) UIView *videoView;

@end

@interface LiveViewController : UIViewController

@property (nonatomic, strong) NSString *conversationId;
@property (nonatomic) EMChatType chatType;

- (instancetype)initWithPassword:(NSString *)aPassword;

- (instancetype)initWithConfrId:(NSString *)aConfId
                       password:(NSString *)aPassword
                          admin:(NSString *)aAdmin;

- (void)handleMessage:(EMMessage *)aMessage;

@end
