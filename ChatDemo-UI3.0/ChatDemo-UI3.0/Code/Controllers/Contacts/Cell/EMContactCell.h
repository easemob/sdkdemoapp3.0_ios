//
//  EMContactCell.h
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 16/9/29.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>
@class EMUserModel;

@interface EMContactCell : UITableViewCell

@property (nonatomic, strong) EMUserModel *model;

@property (nonatomic, assign) BOOL isSelected; //联系人选择、编辑时使用

@end
