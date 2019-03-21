//
//  EMRegisterViewController.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2018/12/12.
//  Copyright © 2018 XieYajie. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EMRegisterViewController : UIViewController

@property (nonatomic, copy) void (^successCompletion)(NSString *aName, NSString *aPswd);

@end

NS_ASSUME_NONNULL_END
