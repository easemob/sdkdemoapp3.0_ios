//
//  EMUserAgreementView.h
//  EMiOSDemo
//
//  Created by 娜塔莎 on 2020/7/2.
//  Copyright © 2020 娜塔莎. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#define ComponentHeight 24.0

//用户协议组件
@interface EMUserAgreementView : UIView

- (instancetype)initUserAgreement;

@property (assign) CGFloat protocolTextHeight;//文本高度

@property (nonatomic, strong) UIButton *userAgreementBtn;//已阅读并同意用户协议按钮

@end

NS_ASSUME_NONNULL_END
