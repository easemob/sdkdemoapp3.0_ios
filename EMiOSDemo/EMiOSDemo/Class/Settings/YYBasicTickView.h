//
//  YYBasicTickView.h
//  YYDemo
//
//  Created by yy on 2017/7/27.
//  Copyright © 2017年 yy. All rights reserved.
//

#import <UIKit/UIKit.h>
@class YYBasicTickView;

@protocol YYBasicTickViewDelegate <NSObject>

@optional

- (void)basicTickViewValueChanged:(YYBasicTickView *)tickView;

@end

@interface YYBasicTickView : UIView

@property(nonatomic,assign)BOOL isTick;

@property(nonatomic)NSInteger index;

- (void)setTick:(BOOL)isTick;

@property(nonatomic,weak)id<YYBasicTickViewDelegate> basicTickDelegate;

- (instancetype)initWithFrame:(CGRect)frame backGroundColor:(UIColor *)backColor tickColor:(UIColor *)tickColor;

@end
