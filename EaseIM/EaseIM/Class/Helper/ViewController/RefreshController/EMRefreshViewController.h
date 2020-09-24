//
//  EMRefreshViewController.h
//  DXStudio
//
//  Created by XieYajie on 12/10/2017.
//  Copyright © 2017 dxstudio. All rights reserved.
//

#import <UIKit/UIKit.h>

//带加载、刷新的Controller(包含UITableView)
@interface EMRefreshViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) UIView *defaultFooterView;

@property (strong, nonatomic) NSMutableArray *dataArray;

@property (nonatomic) int page;

@property (nonatomic) BOOL showRefreshHeader;

@property (nonatomic) BOOL showRefreshFooter;

@property (nonatomic, readonly) BOOL isHeaderRefreshing;

@property (nonatomic, readonly) BOOL isFooterRefreshing;

//- (void)setRefreshHeaderColor:(UIColor *)aColor;


- (void)tableViewDidTriggerHeaderRefresh;

- (void)tableViewDidTriggerFooterRefresh;

- (void)tableViewDidFinishTriggerHeader:(BOOL)isHeader reload:(BOOL)reload;

@end
