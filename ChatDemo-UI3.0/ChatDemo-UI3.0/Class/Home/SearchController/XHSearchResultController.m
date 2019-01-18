//
//  XHSearchResultController.h
//  DXStudio
//
//  Created by XieYajie on 22/09/2017.
//  Copyright © 2017 dxstudio. All rights reserved.
//

#import "XHSearchResultController.h"

#import "MJRefresh.h"

@interface XHSearchResultController ()<UITableViewDelegate, UITableViewDataSource>

@end

@implementation XHSearchResultController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    [self _initSubviews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
}

#pragma mark - Getter

- (UISearchBar *)searchBar
{
    if (_searchBar == nil) {
        _searchBar = [[UISearchBar alloc] init];
//        _searchBar.tintColor = kColor_Green;
//        _searchBar.backgroundImage = [[UIImage imageNamed:@"searchBar_bg"] stretchableImageWithLeftCapWidth:5 topCapHeight:5];
    }
    
    return _searchBar;
}

#pragma mark - Subviews

- (void)_initSubviews
{
    self.view.backgroundColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1.0];
    
    [self.view addSubview:self.searchBar];
    
    CGFloat oY = [UIApplication sharedApplication].statusBarFrame.size.height + 5;
    [self.searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(oY);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.height.equalTo(@50);
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.searchBar.mas_bottom);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
    
    self.defaultFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 80)];
    UILabel *label = [[UILabel alloc] init];
    label.text = NSLocalizedString(@"title.searchNoResult", @"Search has no result");
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor grayColor];
    label.font = [UIFont systemFontOfSize:17.0];
    [self.defaultFooterView addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.defaultFooterView).offset(20);
        make.left.equalTo(self.defaultFooterView).offset(20);
        make.right.equalTo(self.defaultFooterView).offset(-20);
        make.bottom.equalTo(self.defaultFooterView).offset(-20);
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_numberOfSectionsInTableViewCompletion) {
        return _numberOfSectionsInTableViewCompletion(tableView);
    }
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_numberOfRowsInSectionCompletion) {
        return _numberOfRowsInSectionCompletion(tableView, section);
    }
    // Return the number of rows in the section.
    return [self.dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_cellForRowAtIndexPathCompletion) {
        return _cellForRowAtIndexPathCompletion(tableView, indexPath);
    }
    else{
        static NSString *CellIdentifier = @"UITableViewCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        // Configure the cell...
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        return cell;
    }
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    if (_canEditRowAtIndexPath) {
        return _canEditRowAtIndexPath(tableView, indexPath);
    }
    else{
        return NO;
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_didSelectRowAtIndexPathCompletion) {
        return _didSelectRowAtIndexPathCompletion(tableView, indexPath);
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_didDeselectRowAtIndexPathCompletion) {
        _didDeselectRowAtIndexPathCompletion(tableView, indexPath);
    }
}

#pragma mark - Data

- (void)tableViewDidTriggerFooterRefresh
{
    if (_footerBeginRefreshCompletion) {
        ++self.page;
        _footerBeginRefreshCompletion(self.tableView);
    }
}

@end
