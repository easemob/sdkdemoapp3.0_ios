//
//  EMUserModel.m
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 16/9/29.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "EMUserModel.h"

@implementation EMUserModel

- (instancetype)initWithHyphenateId:(NSString *)hyphenateId {
    self = [super init];
    if (self) {
        _hyphenateId = hyphenateId;
        _nickname = @"";
        _defaultAvatarImage = [UIImage imageNamed:@"default_avatar.png"];
    }
    return self;
}

- (NSString *)nickname {
    if (_nickname.length == 0) {
        return _hyphenateId;
    }
    return _nickname;
}

- (NSString *)searchKey {
    if (_nickname.length > 0) {
        return _nickname;
    }
    return _hyphenateId;
}

@end
