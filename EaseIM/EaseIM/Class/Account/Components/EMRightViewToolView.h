//
//  EMRightViewTool.h
//  EaseIM
//
//  Created by 娜塔莎 on 2020/7/1.
//  Copyright © 2020 娜塔莎. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, EMRightViewType) {
    EMPswdRightView = 0,
    EMUsernameRightView,
};


/**
 登录注册输入框textfiled的rightView组件
*/
@interface EMRightViewToolView : UIView

@property (nonatomic, strong) UIButton *rightViewBtn;

- (instancetype)initRightViewWithViewType:(EMRightViewType)rightViewType;

@end

NS_ASSUME_NONNULL_END
