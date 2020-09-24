//
//  EMRightViewTool.m
//  EaseIM
//
//  Created by 娜塔莎 on 2020/7/1.
//  Copyright © 2020 娜塔莎. All rights reserved.
//

#import "EMRightViewToolView.h"

#define RightViewRange 24.0

@interface EMRightViewToolView()

@end

@implementation EMRightViewToolView

- (instancetype)initRightViewWithViewType:(EMRightViewType)rightViewType
{
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, 0, 46, RightViewRange);
        self.rightViewBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, RightViewRange, RightViewRange)];
        if (rightViewType == EMPswdRightView) {
            //密码
            [self.rightViewBtn setImage:[UIImage imageNamed:@"hiddenPwd"] forState:UIControlStateNormal];
            [self.rightViewBtn setImage:[UIImage imageNamed:@"showPwd"] forState:UIControlStateSelected];
        }
        if (rightViewType == EMUsernameRightView)
            //清除用户名
            [self.rightViewBtn setImage:[UIImage imageNamed:@"clearContent"] forState:UIControlStateNormal];
        [self addSubview:self.rightViewBtn];
    }
    return self;
}

@end
