//
//  EMConfirmViewController.h
//  EaseIM
//
//  Created by 娜塔莎 on 2019/12/4.
//  Copyright © 2019 娜塔莎. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EMConfirmViewController : UIViewController

@property (nonatomic, copy) BOOL (^doneCompletion)(BOOL aConfirm);

- (instancetype)initWithMembername:(NSString *)name titleText:(NSString *)titleText;

@end

NS_ASSUME_NONNULL_END
