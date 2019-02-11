//
//  XHRefreshTableViewController.m
//  DXStudio
//
//  Created by XieYajie on 18/08/2017.
//  Copyright © 2017 dxstudio. All rights reserved.
//

#import "EMRefreshTableViewController.h"

#import "MJRefresh.h"

@interface EMRefreshTableViewController ()

@end

@implementation EMRefreshTableViewController

@synthesize rightItems = _rightItems;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }

    self.tableView.tableFooterView = self.defaultFooterView;
    
    _page = 0;
    _showRefreshHeader = NO;
    _showRefreshFooter = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - setter

//- (void)setRefreshHeaderColor:(UIColor *)aColor
//{
//    if (self.showRefreshHeader && self.tableView.mj_header) {
//        [(MJRefreshNormalHeader *)self.tableView.mj_header setRefreshHeaderColor:aColor];
//    }
//}

- (void)setShowRefreshHeader:(BOOL)showRefreshHeader
{
    if (_showRefreshHeader != showRefreshHeader) {
        _showRefreshHeader = showRefreshHeader;
        if (_showRefreshHeader) {
            __weak typeof(self) weakSelf = self;
            self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
                [weakSelf tableViewDidTriggerHeaderRefresh];
            }];
            self.tableView.mj_header.accessibilityIdentifier = @"refresh_header";
        }
        else{
            [self.tableView setMj_header:nil];
        }
    }
}

- (void)setShowRefreshFooter:(BOOL)showRefreshFooter
{
    if (_showRefreshFooter != showRefreshFooter) {
        _showRefreshFooter = showRefreshFooter;
        if (_showRefreshFooter) {
            __weak typeof(self) weakSelf = self;
            self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
                [weakSelf tableViewDidTriggerFooterRefresh];
            }];
            self.tableView.mj_footer.accessibilityIdentifier = @"refresh_footer";
        }
        else{
            [self.tableView setMj_footer:nil];
        }
    }
}

#pragma mark - getter

- (NSMutableArray *)dataArray
{
    if (_dataArray == nil) {
        _dataArray = [NSMutableArray array];
    }
    
    return _dataArray;
}

- (NSMutableDictionary *)dataDictionary
{
    if (_dataDictionary == nil) {
        _dataDictionary = [NSMutableDictionary dictionary];
    }
    
    return _dataDictionary;
}

- (UIView *)defaultFooterView
{
    if (_defaultFooterView == nil) {
        _defaultFooterView = [[UIView alloc] init];
    }
    
    return _defaultFooterView;
}

#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    // Return the number of sections.
//    return 1;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    // Return the number of rows in the section.
//    return 0;
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    static NSString *CellIdentifier = @"UITableViewCell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//
//    // Configure the cell...
//
//    return cell;
//}

#pragma mark - public refresh

- (void)autoTriggerHeaderRefresh
{
    if (self.showRefreshHeader) {
        [self tableViewDidTriggerHeaderRefresh];
    }
}

- (void)tableViewDidTriggerHeaderRefresh
{
    
}

- (void)tableViewDidTriggerFooterRefresh
{
    
}

- (void)tableViewDidFinishTriggerHeader:(BOOL)isHeader reload:(BOOL)reload
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (reload) {
            [weakSelf.tableView reloadData];
        }
        
        if (isHeader) {
            [weakSelf.tableView.mj_header endRefreshing];
        }
        else{
            [weakSelf.tableView.mj_footer endRefreshing];
        }
    });
}

@end
