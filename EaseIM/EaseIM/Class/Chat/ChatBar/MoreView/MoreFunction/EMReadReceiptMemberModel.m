//
//  EMReadReceiptMemberModel.m
//  EaseIM
//
//  Created by 娜塔莎 on 2019/10/30.
//  Copyright © 2019 娜塔莎. All rights reserved.
//

#import "EMReadReceiptMemberModel.h"

@implementation EMReadReceiptMemberModel

- (instancetype)initWithInfo:(UIImage *)img nick:(NSString *)nick time:(NSString *)time
{
    self = [super init];
    if (self) {
        _avatarImg = img;
        _nickName = nick;
        _readTime = time;
    }
    return self;
}

@end
