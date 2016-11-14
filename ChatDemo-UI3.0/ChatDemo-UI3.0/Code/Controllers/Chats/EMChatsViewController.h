//
//  EMChatsViewController.h
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 16/9/19.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EMBaseRefreshTableController.h"

@interface EMChatsViewController : EMBaseRefreshTableController

- (void)setupNavigationItem:(UINavigationItem *)navigationItem;

- (void)networkChanged:(EMConnectionState)connectionState;

- (void)tableViewDidTriggerHeaderRefresh;

@end
