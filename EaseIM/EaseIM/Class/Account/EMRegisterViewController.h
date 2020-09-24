//
//  EMRegisterViewController.h
//  EaseIM
//
//  Update by zhangchong on 2020/8/1.
//  Copyright © 2018 XieYajie. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EMRegisterViewController : UIViewController

@property (nonatomic, copy) void (^successCompletion)(NSString *aName);

@end

NS_ASSUME_NONNULL_END
