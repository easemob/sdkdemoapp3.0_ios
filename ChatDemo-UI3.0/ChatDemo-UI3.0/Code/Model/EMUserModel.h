//
//  EMUserModel.h
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 16/9/29.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IEMUserModel.h"
#import "IEMRealtimeSearch.h"
@interface EMUserModel : NSObject<IEMUserModel, IEMRealtimeSearch>

@property (nonatomic, strong, readonly) NSString *hyphenateId;
@property (nonatomic, strong) NSString *nickname;
@property (nonatomic, strong) NSString *avatarURLPath;
@property (nonatomic, strong, readonly) UIImage *defaultAvatarImage;

- (instancetype)initWithHyphenateId:(NSString *)hyphenateId;

@end
