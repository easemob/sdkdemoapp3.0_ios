//
//  EMUserModel.m
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 16/9/29.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "EMUserModel.h"
#import "EMUserProfileManager.h"

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
        UserProfileEntity *profileEntity = [[EMUserProfileManager sharedInstance] getUserProfileByUsername:self.hyphenateId];
        if (profileEntity) {
            _nickname = profileEntity.nickname;
            _avatarURLPath = profileEntity.imageUrl;
        }
        return _nickname.length > 0 ? _nickname : _hyphenateId;
    }
    return _nickname;
}

- (NSString *)searchKey {
    if (_nickname.length > 0) {
        return _nickname;
    }
    return _hyphenateId;
}

- (NSString *)avatarURLPath {
    if (_avatarURLPath.length > 0) {
        return _avatarURLPath;
    }
    UserProfileEntity *profileEntity = [[EMUserProfileManager sharedInstance] getUserProfileByUsername:self.hyphenateId];
    if (profileEntity) {
        _nickname = profileEntity.nickname;
        _avatarURLPath = profileEntity.imageUrl;
    }
    if (_avatarURLPath.length > 0) {
        return _avatarURLPath;
    }
    return nil;
}

@end
