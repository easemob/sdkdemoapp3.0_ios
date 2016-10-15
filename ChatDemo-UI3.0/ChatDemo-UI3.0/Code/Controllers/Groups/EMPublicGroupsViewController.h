//
//  EMPublicGroupsViewController.h
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 16/10/13.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EMBaseRefreshTableController.h"
#import "EMGroupModel.h"

@interface EMPublicGroupsViewController : EMBaseRefreshTableController

@property (nonatomic, strong) NSMutableArray<EMGroupModel *> *publicGroups;
@property (nonatomic, strong) NSMutableArray<EMGroupModel *> *searchResults;
- (void)setSearchState:(BOOL)isSearching;

@end
