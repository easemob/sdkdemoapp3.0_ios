//
//  EMMoreFunctionView.h
//  EMiOSDemo
//
//  Created by 娜塔莎 on 2019/10/23.
//  Copyright © 2019 娜塔莎. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EMReadReceiptMsgViewController.h"

NS_ASSUME_NONNULL_BEGIN
@protocol EMMoreFunctionViewDelegate;
@interface EMMoreFunctionView : UIView

@property (nonatomic, weak) id<EMMoreFunctionViewDelegate> delegate;

@end

@protocol EMMoreFunctionViewDelegate <NSObject>

- (void)chatBarMoreFunctionReadReceipt;//阅读回执

@end

NS_ASSUME_NONNULL_END
