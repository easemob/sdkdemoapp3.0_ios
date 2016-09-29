//
//  UIImage+ImageEffect.h
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 16/9/28.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ImageEffect)

//为图片设置透明度
- (UIImage *)imageByApplingAlpha:(CGFloat)alpha;

//带有颜色的图片
+ (UIImage *)imageWIthColor:(UIColor *)color;

@end
