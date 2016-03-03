//
//  OccupantListViewController.h
//  ChatDemo-UI3.0
//
//  Created by WYZ on 16/2/16.
//  Copyright © 2016年 WYZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OccupantListViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, copy) void(^SelectedOccupant)(NSString *occupantName);

- (instancetype)initWithGroupId:(NSString *)chatGroupId;

@end
