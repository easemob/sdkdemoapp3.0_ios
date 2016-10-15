//
//  IEMApplyModel.h
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 16/10/9.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, EMApplyStyle) {
    EMApplyStyle_contact         =          0,
    EMApplyStyle_joinGroup,
    EMApplyStyle_groupInvitation
};

#define kApply_recordId             @"recordId"
#define kApply_applyHyphenateId     @"applyHyphenateId"
#define kApply_applyNickName        @"applyNickName"
#define kApply_reason               @"reason"
#define kApply_receiverHyphenateId  @"receiverHyphenateId"
#define kApply_receiverNickname     @"receiverNickname"
#define kApply_style                @"style"
#define kApply_groupId              @"groupId"
#define kApply_groupSubject         @"groupSubject"
#define kApply_groupMemberCount     @"groupMemberCount"

@protocol IEMApplyModel <NSObject>

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
