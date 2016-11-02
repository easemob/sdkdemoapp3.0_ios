//
//  EMBaseRefreshTableController.h
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 16/10/3.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EMBaseRefreshTableController : UITableViewController

@property (nonatomic, copy) void(^headerRefresh)(BOOL isRefreshing);

- (void)endHeaderRefresh;

- (UIView *)tableViewFoot;

@end
