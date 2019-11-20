//
//  LoadingCALayer.h
//  EMiOSDemo
//
//  Created by 娜塔莎 on 2019/11/19.
//  Copyright © 2019 娜塔莎. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface LoadingCALayer : CALayer

@property (nonatomic,assign)CGFloat marketValue;

- (void)custom_setValue:(CGFloat)value;

@end

NS_ASSUME_NONNULL_END
