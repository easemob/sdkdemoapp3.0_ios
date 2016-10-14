//
//  EMApplyModel.h
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 16/10/9.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IEMApplyModel.h"

@interface EMApplyModel : NSObject<IEMApplyModel>

@property (nonatomic, strong, readonly) NSString *recordId;
@property (nonatomic, strong) NSString * applyHyphenateId;
@property (nonatomic, strong) NSString * applyNickName;
@property (nonatomic, strong) NSString * reason;
@property (nonatomic, strong) NSString * receiverHyphenateId;
@property (nonatomic, strong) NSString * receiverNickname;
@property (nonatomic, assign) EMApplyStyle style;
@property (nonatomic, strong) NSString * groupId;
@property (nonatomic, strong) NSString * groupSubject;
@property (nonatomic, assign) NSInteger groupMemberCount;

@end
