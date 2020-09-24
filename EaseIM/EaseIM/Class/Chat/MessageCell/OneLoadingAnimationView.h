//
//  OneLoadingAnimation.h
//  OneLoadingAnimationStep1
//
//  Created by thatsoul on 15/11/15.
//  Copyright © 2015年 chenms.m2. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OneLoadingAnimationView : UIView
- (void)startAnimation;

- (void)stopTimer;

- (instancetype)initWithRadius:(CGFloat)radius;
@end
