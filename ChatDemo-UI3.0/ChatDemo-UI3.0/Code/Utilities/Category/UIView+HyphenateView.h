//
//  UIView+EasyView.h
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 16/9/27.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIView (HyphenateView)

@property (nonatomic) CGFloat left;

@property (nonatomic) CGFloat top;

@property (nonatomic) CGFloat width;

@property (nonatomic) CGFloat height;

@end

@interface UIImage (HyphenateImage)

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;

@end
