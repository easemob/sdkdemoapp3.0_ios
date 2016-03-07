//
//  OccupantListViewController.m
//  ChatDemo-UI3.0
//
//  Created by WYZ on 16/2/16.
//  Copyright © 2016年 WYZ. All rights reserved.
//

#import "OccupantListViewController.h"
#import "OccupantCell.h"
#import "UIImageView+HeadImage.h"
#import "EMSearchBar.h"
#import "EMSearchDisplayController.h"

@interface OccupantListViewController()<UISearchBarDelegate, UISearchDisplayDelegate>

@property (nonatomic, strong) NSMutableArray *dataArray;

@property (nonatomic, strong) EMGroup *chatGroup;

@property (nonatomic, strong) EMSearchBar *searchBar;

@property (nonatomic, strong) EMSearchDisplayController *searchController;

@end

@implementation OccupantListViewController

- (instancetype)initWithGroup:(EMGroup *)chatGroup
{
    self = [super init];
    if (self) {
        // Custom initialization
        _chatGroup = chatGroup;
        _dataArray = [NSMutableArray array];
    }
    return self;
}

- (instancetype)initWithGroupId:(NSString *)chatGroupId
{
    EMGroup *chatGroup = nil;
    NSArray *groupArray = [[EMClient sharedClient].groupManager getAllGroups];
    for (EMGroup *group in groupArray) {
        if ([group.groupId isEqualToString:chatGroupId]) {
            chatGroup = group;
            break;
        }
    }
    
    if (chatGroup == nil) {
        chatGroup = [EMGroup groupWithId:chatGroupId];
    }
    
    self = [self initWithGroup:chatGroup];
    if (self) {
        //
    }
    
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    if ([_tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [_tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([_tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [_tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_tableView];
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [backButton setTitle:NSLocalizedString(@"cancel", @"cancel") forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    backButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [backButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    [self.navigationItem setLeftBarButtonItem:backItem];
    
    [self reloadDataSource];
    
    [self.view addSubview:self.searchBar];
    _tableView.frame = CGRectMake(0, self.searchBar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - self.searchBar.frame.size.height);
    [self searchController];
    
}

#pragma mark - getter

- (UISearchBar *)searchBar
{
    if (!_searchBar) {
        _searchBar = [[EMSearchBar alloc] initWithFrame: CGRectMake(0, 0, self.view.frame.size.width, 44)];
        _searchBar.delegate = self;
        _searchBar.placeholder = NSLocalizedString(@"search", @"Search");
        _searchBar.backgroundColor = [UIColor colorWithRed:0.747 green:0.756 blue:0.751 alpha:1.000];
    }
    
    return _searchBar;
}

- (EMSearchDisplayController *)searchController
{
    if (_searchController == nil) {
        _searchController = [[EMSearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
        _searchController.delegate = self;
        _searchController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _searchController.searchResultsTableView.tableFooterView = [[UIView alloc] init];
        
        __weak typeof(self) weakSelf = self;
        [_searchController setCellForRowAtIndexPathCompletion:^UITableViewCell *(UITableView *tableView, NSIndexPath *indexPath) {
            NSString *CellIdentifier = @"GroupsCell";
            OccupantCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            // Configure the cell...
            if (cell == nil) {
                cell = [[OccupantCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            
            if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
                [cell setSeparatorInset:UIEdgeInsetsZero];
            }
            if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
                [cell setLayoutMargins:UIEdgeInsetsZero];
            }
            NSString *username = weakSelf.searchController.resultsSource[indexPath.row];
            [cell.occupantLabel setTextWithUsername:username];
            [cell.avatarView imageWithUsername:username placeholderImage:[UIImage imageNamed:@"EaseUIResource.bundle/user"]];
            return cell;
        }];
        
        [_searchController setHeightForRowAtIndexPathCompletion:^CGFloat(UITableView *tableView, NSIndexPath *indexPath) {
            return 60;
        }];
        
        [_searchController setDidSelectRowAtIndexPathCompletion:^(UITableView *tableView, NSIndexPath *indexPath) {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            [weakSelf.searchController.searchBar endEditing:YES];
            NSString *selectOccupant = weakSelf.searchController.resultsSource[indexPath.row];
            if ([selectOccupant isEqualToString:[EMClient sharedClient].currentUsername])
            {
                //如果选中的为用户本人
                [weakSelf showHint:@"请选择其他成员！"];
                selectOccupant = nil;
                return;
            }
            if (weakSelf.SelectedOccupant)
            {
                weakSelf.SelectedOccupant(weakSelf.searchController.resultsSource[indexPath.row]);
            }
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
        }];
    }
    
    return _searchController;
}


- (void)reloadDataSource
{
    [self.dataArray removeAllObjects];
    __block typeof(self) weakSelf = self;
    [self showHudInView:self.view hint:NSLocalizedString(@"loadData", @"Load data...")];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
        EMError *error = nil;
        EMGroup *group = [[EMClient sharedClient].groupManager fetchGroupInfo:weakSelf.chatGroup.groupId includeMembersList:YES error:&error];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf hideHud];
        });
        if (!error) {
            weakSelf.chatGroup = group;
            [weakSelf.dataArray addObjectsFromArray:group.occupants];
            NSString *account = [EMClient sharedClient].currentUsername;
            [weakSelf.dataArray removeObject:account];
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.tableView reloadData];
            });
        }
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf showHint:NSLocalizedString(@"group.fetchInfoFail", @"failed to get the group details, please try again later")];
            });
        }
    });
}

- (void)backAction
{
    //取消选择@对象，则调用block重置helpType类型
    if (self.SelectedOccupant)
    {
        self.SelectedOccupant(nil);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentify = @"OccupantCell";
    OccupantCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentify];
    if (!cell)
    {
        cell = [[OccupantCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentify];
    }
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    NSString *username = self.dataArray[indexPath.row];
    [cell.occupantLabel setTextWithUsername:username];
    [cell.avatarView imageWithUsername:username placeholderImage:[UIImage imageNamed:@"EaseUIResource.bundle/user"]];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //被选择的成员id
    NSString *selectOccupant = self.dataArray[indexPath.row];
    if ([selectOccupant isEqualToString:[EMClient sharedClient].currentUsername])
    {
        //如果选中的为用户本人
        [self showHint:@"请选择其他成员！"];
        selectOccupant = nil;
        return;
    }
    if (self.SelectedOccupant)
    {
        self.SelectedOccupant(selectOccupant);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UISearchBarDelegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
    
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *results = [NSMutableArray array];
        for (NSString *occupant in weakSelf.dataArray)
        {
            if ([occupant rangeOfString:searchText].length > 0)
            {
                [results addObject:occupant];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.searchController.resultsSource removeAllObjects];
            [weakSelf.searchController.resultsSource addObjectsFromArray:results];
            [weakSelf.searchController.searchResultsTableView reloadData];
        });
    });
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    searchBar.text = @"";
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
}

@end
