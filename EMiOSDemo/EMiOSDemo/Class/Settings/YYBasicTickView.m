//
//  YYBasicTickView.m
//  YYDemo
//
//  Created by yy on 2017/7/27.
//  Copyright © 2017年 yy. All rights reserved.
//

#import "YYBasicTickView.h"

@interface YYBasicTickView()

@property(nonatomic,strong)UIColor *backColor;

@property(nonatomic,strong)UIColor *tickColor;

@end

@implementation YYBasicTickView

- (instancetype)initWithFrame:(CGRect)frame backGroundColor:(UIColor *)backColor tickColor:(UIColor *)tickColor
{
    if (self = [super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor clearColor];
        self.backColor = backColor;
        self.tickColor = tickColor;
        self.isTick = NO;
        self.userInteractionEnabled = YES;
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
        [self addGestureRecognizer:singleTap];
    }
    return self;
}

- (void)setTick:(BOOL)isTick
{
    self.isTick = isTick;
    
    // 重绘
    //[self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    if (self.isTick)
    {
        /** 填充背景 */
        CGPoint center = CGPointMake(rect.size.width*0.5,rect.size.height*0.5);
        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:(rect.size.width*0.5 - rect.size.width*0.03) startAngle:0 endAngle:M_PI*2 clockwise:YES];
        //设置颜色
        [self.backColor set];
        // 填充：必须是一个完整的封闭路径,默认就会自动关闭路径
        [path fill];
        
        /** 绘制勾 */
        UIBezierPath *path1 = [UIBezierPath bezierPath];
        path1.lineWidth = rect.size.width*0.06;
        // 设置起点
        [path1 moveToPoint:CGPointMake(rect.size.width*0.23, rect.size.height*0.43)];
        // 添加一根线到某个点
        [path1 addLineToPoint:CGPointMake(rect.size.width*0.45, rect.size.height*0.7)];
        [path1 addLineToPoint:CGPointMake(rect.size.width*0.79, rect.size.height*0.35)];
        //设置颜色
        [self.tickColor set];
        // 绘制路径
        [path1 stroke];
    }
    else
    {
        CGPoint center = CGPointMake(rect.size.width*0.5,rect.size.height*0.5);
        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:(rect.size.width*0.5 - rect.size.width*0.03) startAngle:0 endAngle:M_PI*2 clockwise:YES];
        [[UIColor lightGrayColor] set];
        [path fill];
        [path stroke];
    }
}

- (void)tapAction
{
    if (!self.isTick) {
        self.isTick = !self.isTick;
        
        if (self.basicTickDelegate != nil && [self.basicTickDelegate respondsToSelector:@selector(basicTickViewValueChanged:)])
        {
            [self.basicTickDelegate basicTickViewValueChanged:self];
        }
    }
}


@end
