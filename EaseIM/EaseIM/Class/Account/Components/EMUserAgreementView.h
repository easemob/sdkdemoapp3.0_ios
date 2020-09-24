//
//  EMUserAgreementView.h
//  EaseIM
//
//  Created by 娜塔莎 on 2020/7/2.
//  Copyright © 2020 娜塔莎. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#define ComponentHeight 24.0

/**
 用户协议组件
*/

@protocol EMUserProtocol <NSObject>

- (void)didTapUserProtocol:(NSString *)protocolUrl sign:(NSString *)sign;

@end

@interface EMUserAgreementView : UIView

@property (nonatomic, weak) id<EMUserProtocol> delegate;

- (instancetype)initUserAgreement;

@property (assign) CGFloat protocolTextHeight;//文本高度

@property (nonatomic, strong) UIButton *userAgreementBtn;//同意用户协议按钮

@end

NS_ASSUME_NONNULL_END
