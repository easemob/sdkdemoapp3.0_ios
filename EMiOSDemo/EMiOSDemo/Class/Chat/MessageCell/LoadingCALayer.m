//
//  LoadingCALayer.m
//  EMiOSDemo
//
//  Created by 娜塔莎 on 2019/11/19.
//  Copyright © 2019 娜塔莎. All rights reserved.
//

#import "LoadingCALayer.h"

@implementation LoadingCALayer

- (void)custom_setValue:(CGFloat)value {
    self.marketValue = value;
    [self setNeedsDisplay];
}

- (void)drawInContext:(CGContextRef)ctx {
    
    CGContextSetLineWidth(ctx, 6);//画线粗细
    
    CGContextSetLineCap(ctx, kCGLineCapRound);//设置画线末端圆角
    CGContextSetFillColorWithColor(ctx, [UIColor blackColor].CGColor);
    
    CGFloat originX = self.bounds.size.width / 2;
    CGFloat originY = self.bounds.size.height / 2;
    CGFloat radius = MIN(originX, originY) - 10.0;
    
    CGContextAddArc(ctx, self.bounds.size.width / 2, self.bounds.size.height / 2, radius,  M_PI_2,  M_PI * 2.5 * (6 * self.marketValue), 0);//绘制圆弧

    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();

    //渐变色数组
    NSArray *colorArray = @[(id)[UIColor colorWithRed:147.0/255.0 green:182.0/255.0 blue:46.0/255.0 alpha:1].CGColor,
                           (id)[UIColor colorWithRed:173.0/255.0 green:152.0/255.0 blue:50.0/255.0 alpha:1].CGColor,
                           (id)[UIColor colorWithRed:226.0/255.0 green:91.0/255.0 blue:52.0/255.0 alpha:1].CGColor,
                           (id)[UIColor colorWithRed:255.0/255.0 green:51.0/255.0 blue:1.0/255.0 alpha:1].CGColor,
                           (id)[UIColor colorWithRed:226.0/255.0 green:38.0/255.0 blue:8.0/255.0 alpha:1].CGColor,
                           ];
    
     //各个渐变色所占比例
    CGFloat locations[5] = {0.0,0.25,0.55,0.7,1.0};
    NSArray *colorArr = colorArray;
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)colorArr, locations);
    CGColorSpaceRelease(colorSpace);
    colorSpace = NULL;
    
    CGContextReplacePathWithStrokedPath(ctx);
    CGContextClip(ctx);
    
    CGContextDrawLinearGradient(ctx, gradient, CGPointMake(0, self.bounds.size.height / 2), CGPointMake(self.bounds.size.width, self.bounds.size.height / 2), 0);//绘制渐变色
    CGGradientRelease(gradient);
}

@end
