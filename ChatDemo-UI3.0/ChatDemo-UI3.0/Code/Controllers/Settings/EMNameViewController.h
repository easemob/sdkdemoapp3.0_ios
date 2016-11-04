//
//  EMNameViewController.h
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 2016/11/4.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "EMBaseSettingController.h"

typedef void(^UpdatedMyName)(NSString *newName);
@interface EMNameViewController : EMBaseSettingController

@property (nonatomic, copy) NSString *myName;

@property (nonatomic, copy)UpdatedMyName callBack;

- (void)getUpdatedMyName:(UpdatedMyName)callBack;
@end
