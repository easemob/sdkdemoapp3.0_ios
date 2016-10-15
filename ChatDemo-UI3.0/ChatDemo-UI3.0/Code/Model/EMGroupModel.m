//
//  EMGroupModel.m
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 16/10/6.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "EMGroupModel.h"

@implementation EMGroupModel

- (instancetype)initWithObject:(NSObject *)obj {
    if ([obj isKindOfClass:[EMGroup class]]) {
        self = [super init];
        if (self) {
            _group = (EMGroup *)obj;
            _hyphenateId = _group.groupId;
            _subject = _group.subject;
            _defaultAvatarImage = [UIImage imageNamed:@"default_avatar.png"];
        }
        return self;
    }
    return nil;
}

- (NSString *)subject {
    if (_subject.length == 0) {
        return _hyphenateId;
    }
    return _subject;
}

- (NSString *)searchKey {
    if (self.subject.length > 0) {
        return self.subject;
    }
    return _hyphenateId;
}

@end
