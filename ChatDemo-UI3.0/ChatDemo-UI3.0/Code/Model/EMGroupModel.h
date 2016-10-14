//
//  EMGroupModel.h
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 16/10/6.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IEMConferenceModel.h"
#import "IEMRealtimeSearch.h"
@interface EMGroupModel : NSObject<IEMConferenceModel, IEMRealtimeSearch>
@property (nonatomic, strong, readonly) NSString *hyphenateId;
@property (nonatomic, strong) NSString *subject;
@property (nonatomic, strong) NSString *avatarURLPath;
@property (nonatomic, strong, readonly) UIImage *defaultAvatarImage;
@property (nonatomic, strong) EMGroup *group;

- (instancetype)initWithObject:(NSObject *)obj;
@end
