//
//  EMMessageModel.h
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 16/10/22.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EMMessageModel : NSObject

@property (strong, nonatomic) EMMessage *message;

@property (assign, nonatomic) BOOL isPlaying;

- (instancetype)initWithMessage:(EMMessage*)message;

@end
