//
//  EMGroupCell.h
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 16/10/6.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EMGroupUIProtocol.h"
@class EMGroupModel;

@interface EMGroupCell : UITableViewCell

@property (nonatomic, strong) EMGroupModel *model;

@property (nonatomic, assign) BOOL isRequestedToJoinPublicGroup;//是否申请加入公有群

@property (nonatomic, assign) id<EMGroupUIProtocol> delegate;

@end
