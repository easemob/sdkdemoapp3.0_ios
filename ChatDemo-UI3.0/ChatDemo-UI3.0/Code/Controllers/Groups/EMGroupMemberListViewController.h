//
//  EMGroupMemberListViewController.h
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 16/10/8.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>
@class EMUserModel;
#import "EMGroupUIProtocol.h"

@interface EMGroupMemberListViewController : UITableViewController

@property (nonatomic, assign) id<EMGroupUIProtocol> delegate;

- (instancetype)initWithGroup:(EMGroup *)group occupants:(NSArray<EMUserModel *> *)occupants;

@end
