//
//  EMChatDemoHelper.h
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 16/10/9.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMContactsViewController.h"
#import "EMMainViewController.h"
#import "EMPushNotificationViewController.h"

@interface EMChatDemoHelper : NSObject<EMClientDelegate, EMContactManagerDelegate, EMGroupManagerDelegate, EMChatManagerDelegate>

@property (nonatomic, weak) EMContactsViewController *contactsVC;

@property (nonatomic, weak) EMMainViewController *mainVC;

@property (nonatomic, weak) EMPushNotificationViewController *pushVC;

+ (instancetype)shareHelper;

- (void)setupUntreatedApplyCount;



@end
