//
//  EMPushNotificationViewController.h
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 16/9/22.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "EMBaseSettingController.h"
typedef void (^PushStatus)(EMPushNoDisturbStatus disturbStatus);

@interface EMPushNotificationViewController : EMBaseSettingController

@property (nonatomic, copy) PushStatus callBack;

- (void)getPushStatus:(PushStatus)callBack;

@end
