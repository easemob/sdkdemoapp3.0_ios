//
//  EMChatDemoUIDefine.h
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 16/9/20.
//  Copyright © 2016年 easemob. All rights reserved.
//

#ifndef EMChatDemoUIDefine_h
#define EMChatDemoUIDefine_h

#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]

#define WEAK_SELF typeof(self) __weak weakSelf = self;

#define KScreenHeight [[UIScreen mainScreen] bounds].size.height
#define KScreenWidth  [[UIScreen mainScreen] bounds].size.width

#define KNOTIFICATION_LOGINCHANGE @"loginStateChange"

#define KNOTIFICATION_CALL @"callOutWithChatter"

#endif /* EMChatDemoUIDefine_h */
