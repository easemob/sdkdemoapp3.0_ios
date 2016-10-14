//
//  PushDisplaynameViewController.h
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 16/9/22.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "EMBaseSettingController.h"

typedef void(^UpdatedDisplayName)(NSString *newDisplayName);

@interface EMPushDisplaynameViewController : EMBaseSettingController

@property (nonatomic, copy) NSString *currentDisplayName;

@property (nonatomic, copy)UpdatedDisplayName callBack;

- (void)getUpdatedDisplayName:(UpdatedDisplayName)callBack;
@end
