//
//  EMAvatarNameModel.m
//  EMiOSDemo
//
//  Created by 娜塔莎 on 2020/8/19.
//  Copyright © 2020 娜塔莎. All rights reserved.
//

#import "EMAvatarNameModel.h"

@implementation EMAvatarNameModel

- (instancetype)initWithInfo:(UIImage *)img msg:(EMMessage *)msg time:(NSString *)timestamp
{
    self = [super init];
    if (self) {
        _avatarImg = img;
        _from = msg.from;
        _detail = ((EMTextMessageBody *)msg.body).text;
        _timestamp = timestamp;
    }
    return self;
}

@end
