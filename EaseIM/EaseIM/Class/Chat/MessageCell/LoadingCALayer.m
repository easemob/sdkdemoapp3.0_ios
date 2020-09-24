//
//  LoadingCALayer.m
//  EaseIM
//
//  Created by 娜塔莎 on 2019/11/19.
//  Copyright © 2019 娜塔莎. All rights reserved.
//

#import "LoadingCALayer.h"
static CGFloat const kLineWidth = 2;

@implementation LoadingCALayer

@dynamic progress;

+ (BOOL)needsDisplayForKey:(NSString *)key {
    if ([key isEqualToString:@"progress"]) {
        return YES;
    }
    return [super needsDisplayForKey:key];
}

- (void)drawInContext:(CGContextRef)ctx {
   UIBezierPath *path = [UIBezierPath bezierPath];

    CGFloat radius = MIN(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds)) / 2 - kLineWidth / 2;
    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));

    // O
    CGFloat originStart = M_PI * 8 / 2;
    CGFloat originEnd = M_PI * 2;
    CGFloat currentOrigin = originStart - (originStart - originEnd) * self.progress;

    // D
    CGFloat destStart = M_PI * 8 / 2;
    CGFloat destEnd = 0;
    CGFloat currentDest = destStart - (destStart - destEnd) * self.progress;

    [path addArcWithCenter:center radius:radius startAngle: currentOrigin endAngle: currentDest clockwise:NO];
    CGContextAddPath(ctx, path.CGPath);
    CGContextSetLineWidth(ctx, kLineWidth);
    CGContextSetStrokeColorWithColor(ctx, [UIColor lightGrayColor].CGColor);
    CGContextStrokePath(ctx);
    
}


@end
