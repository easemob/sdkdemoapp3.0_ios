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

- (void)chatBarMoreFunctionLocation;//位置

- (void)chatBarMoreFunctionDidCallAction;//视频通话

@end

@protocol SessionToolbarCellDelegate;
@interface SessionToolbarCell : UICollectionViewCell

@property (nonatomic, weak) id<SessionToolbarCellDelegate> delegate;

- (void)personalizeToolbar:(NSString *)imgName funcDesc:(NSString *)funcDesc tag:(NSInteger)tag;//个性化工具栏功能描述

@end

@protocol SessionToolbarCellDelegate <NSObject>

@required
- (void)toolbarCellDidSelected:(NSInteger)tag;

@end

NS_ASSUME_NONNULL_END
