//
//  EMApplyManager.h
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 16/10/9.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMApplyModel.h"

@interface EMApplyManager : NSObject

+ (instancetype)defaultManager;

- (NSUInteger)unHandleApplysCount;

- (NSArray *)contactApplys;

- (NSArray *)groupApplys;

- (void)addApplyRequest:(EMApplyModel *)model;

- (void)removeApplyRequest:(EMApplyModel *)model;

- (BOOL)isExistingRequest:(NSString *)applyHyphenateId
               applyStyle:(EMApplyStyle)applyStyle;

@end
