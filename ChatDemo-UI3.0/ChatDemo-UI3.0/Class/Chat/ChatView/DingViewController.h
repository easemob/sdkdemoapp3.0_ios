//
//  DingViewController.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 12/01/2018.
//  Copyright © 2018 XieYajie. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DingViewController : UIViewController

- (instancetype)initWithConversationId:(NSString *)aConversationId
                                    to:(NSString *)aTo
                              chatType:(EMChatType)aChatType
                      finishCompletion:(void (^)(EMMessage *aMessage))aCompletion;

@end
