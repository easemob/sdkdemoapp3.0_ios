//
//  EMGroupMemberCell.h
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 16/10/11.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EMGroupUIProtocol.h"
@class EMUserModel;

@interface EMGroupMemberCell : UITableViewCell

@property (nonatomic, assign) BOOL isGroupOwner;

@property (nonatomic, assign) BOOL isEditing;

@property (nonatomic, assign) BOOL isSelected;

@property (nonatomic, strong) EMUserModel *model;

@property (nonatomic, assign) id<EMGroupUIProtocol> delegate;

@end
