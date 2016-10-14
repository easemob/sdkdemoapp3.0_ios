//
//  EMApplyRequestCell.h
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 16/10/9.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>
@class EMApplyModel;
@interface EMApplyRequestCell : UITableViewCell

@property (nonatomic, strong) EMApplyModel *model;

@property (nonatomic, copy) void(^declineApply)(EMApplyModel *model);

@property (nonatomic, copy) void(^acceptApply)(EMApplyModel *model);

@end
