//
//  EMRefreshTableViewController.h
//  DXStudio
//
//  Created by XieYajie on 18/08/2017.
//  Copyright © 2017 dxstudio. All rights reserved.
//

#import <UIKit/UIKit.h>

//带加载、刷新的Controller(包含UITableView)
@interface EMRefreshTableViewController : UITableViewController
{
    NSArray *_rightItems;
}

//导航栏右侧BarItem
@property (strong, nonatomic) NSArray *rightItems;

@property (strong, nonatomic) UIView *defaultFooterView;

@property (strong, nonatomic) NSMutableArray *dataArray;

@property (strong, nonatomic) NSMutableDictionary *dataDictionary;

@property (nonatomic) int page;

@property (nonatomic) BOOL showRefreshHeader;

@property (nonatomic) BOOL showRefreshFooter;

//- (void)setRefreshHeaderColor:(UIColor *)aColor;


- (void)tableViewDidTriggerHeaderRefresh;

- (void)tableViewDidTriggerFooterRefresh;

- (void)tableViewDidFinishTriggerHeader:(BOOL)isHeader reload:(BOOL)reload;

@end
