//
//  ConfInviteUsersViewController.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2018/9/20.
//  Copyright © 2018 XieYajie. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConfInviteUsersViewController : UIViewController

@property (nonatomic, strong, readonly) UITableView *tableView;

@property (nonatomic, strong, readonly) NSMutableArray *dataArray;
@property (nonatomic, strong) NSMutableArray *inviteUsers;

- (instancetype)initWithType:(EMConferenceType)aType;

@end
