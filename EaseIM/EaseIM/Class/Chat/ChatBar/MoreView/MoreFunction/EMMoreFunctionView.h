//
//  EMMoreFunctionView.h
//  EaseIM
//
//  Created by 娜塔莎 on 2019/10/23.
//  Copyright © 2019 娜塔莎. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol EMMoreFunctionViewDelegate;
@interface EMMoreFunctionView : UIView

@property (nonatomic, weak) id<EMMoreFunctionViewDelegate> delegate;

- (instancetype)initWithConversation:(EMConversation *)conversation;

@end

@protocol EMMoreFunctionViewDelegate <NSObject>

@optional

- (void)chatBarMoreFunctionReadReceipt;//群组阅读回执

- (void)chatBarMoreFunctionAction:(NSInteger)componentType;

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
