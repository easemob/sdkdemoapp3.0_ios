//
//  EMNotificationCell.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/10.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol EMNotificationCellDelegate;

@class EMNotificationModel;
@interface EMNotificationCell : UITableViewCell

@property (nonatomic, weak) id<EMNotificationCellDelegate> delegate;

@property (nonatomic, strong) EMNotificationModel *model;

@end


@protocol EMNotificationCellDelegate <NSObject>

@optional

- (void)agreeNotification:(EMNotificationModel *)aModel;

- (void)declineNotification:(EMNotificationModel *)aModel;

@end

NS_ASSUME_NONNULL_END
