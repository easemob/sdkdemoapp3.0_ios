//
//  EMAuthorizationView.h
//  EaseIM
//
//  Created by 娜塔莎 on 2020/7/2.
//  Copyright © 2020 娜塔莎. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, EMAuthorizationType) {
    EMAuthLogin = 1,
    EMAuthRegiste,
};

/**
 用户授权登录注册组件
 */
@interface EMAuthorizationView : UIView

- (instancetype)initWithAuthType:(EMAuthorizationType)authorizationType;

- (void)setupAuthBtnBgcolor:(BOOL)isOperation;//设置授权按钮背景UI

@property (nonatomic, strong) UIButton *authorizationBtn;//授权按钮

//原始视图
- (void)originalView;

//加载视图
- (void)beingLoadedView;

@end

NS_ASSUME_NONNULL_END
