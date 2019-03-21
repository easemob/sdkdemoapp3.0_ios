//
//  EMDemoHelper.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/18.
//  Copyright © 2019 XieYajie. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface EMDemoHelper : NSObject <EMClientDelegate, EMMultiDevicesDelegate,EMChatManagerDelegate,EMContactManagerDelegate,EMGroupManagerDelegate>

+ (instancetype)shareHelper;

@end
