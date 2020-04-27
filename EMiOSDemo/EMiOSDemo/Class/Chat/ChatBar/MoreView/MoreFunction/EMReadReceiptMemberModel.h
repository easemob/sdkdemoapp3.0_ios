//
//  EMReadReceiptMemberModel.h
//  EMiOSDemo
//
//  Created by 娜塔莎 on 2019/10/30.
//  Copyright © 2019 娜塔莎. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EMReadReceiptMemberModel : NSObject
@property (nonatomic, strong) UIImage *avatarImg;
@property (nonatomic, strong) NSString *nickName;
@property (nonatomic, strong) NSString *readTime;

- (instancetype)initWithInfo:(UIImage *)img nick:(NSString *)nick time:(NSString *)time;

@end

NS_ASSUME_NONNULL_END
