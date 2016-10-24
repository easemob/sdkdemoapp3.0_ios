//
//  EMMessageModel.m
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 16/10/22.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "EMMessageModel.h"

@implementation EMMessageModel

- (instancetype)initWithMessage:(EMMessage*)message
{
    self = [super init];
    if (self) {
        _message = message;
    }
    return self;
}

@end
