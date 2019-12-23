//
//  OneLoadingAnimation.m
//  OneLoadingAnimationStep1
//
//  Created by thatsoul on 15/11/15.
//  Copyright © 2015年 chenms.m2. All rights reserved.
//

#import "OneLoadingAnimationView.h"
#import "LoadingCALayer.h"

static CGFloat kRadius = 9;
static CGFloat kLineWidth = 2;
static CGFloat kStep1Duration = 2.5;

@interface OneLoadingAnimationView ()
@property (nonatomic) LoadingCALayer *arcToCircleLayer;
@end

@implementation OneLoadingAnimationView

- (instancetype)initWithRadius:(CGFloat)radius
{
    self = [super init];
    if (self) {
        kRadius = radius;
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

#pragma mark - public
- (void)startAnimation {
    //self.arcToCircleLayer = [LoadingCALayer layer];
    [self reset];
    [self doStep];
}

#pragma mark - animation
- (void)reset {
    [self.arcToCircleLayer removeFromSuperlayer];
}

- (void)doStep {
    self.arcToCircleLayer = [LoadingCALayer layer];
    self.arcToCircleLayer.contentsScale = [UIScreen mainScreen].scale;
    [self.layer addSublayer:self.arcToCircleLayer];

    self.arcToCircleLayer.bounds = CGRectMake(0, 0, kRadius * 2 + kLineWidth, kRadius * 2 + kLineWidth);
    self.arcToCircleLayer.position = CGPointMake(self.frame.origin.x + 10, self.frame.origin.y + 10);

    // animation
    self.arcToCircleLayer.progress = 1; // end status

    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"progress"];
    animation.duration = kStep1Duration;
    animation.fromValue = @0.0;
    animation.toValue = @1.0;
    [self.arcToCircleLayer addAnimation:animation forKey:nil];
}

@end
