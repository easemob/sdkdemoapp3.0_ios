//
//  EMChatsViewController.m
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 16/9/19.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "EMChatsViewController.h"

#import "UIViewController+DismissKeyboard.h"
#import "EMChatsCell.h"
#import "EMRealtimeSearchUtil.h"
#import "EMChatViewController.h"
#import "EMSearchDisplayController.h"

@interface EMChatsViewController () <EMChatManagerDelegate,EMGroupManagerDelegate,UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource,UISearchDisplayDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) NSMutableArray *dataSource;
@property (strong, nonatomic) UIRefreshControl *refresh;
@property (strong, nonatomic) EMSearchDisplayController *searchController;

@end

@implementation EMChatsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self.tableView addSubview:self.refresh];
    
    [self setupForDismissKeyboard];
    
    if ([UIDevice currentDevice].systemVersion.floatValue >= 7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin |UIViewAutoresizingFlexibleHeight;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self registerNotifications];
    [self tableViewDidTriggerHeaderRefresh];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self unregisterNotifications];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)registerNotifications{
    [self unregisterNotifications];
    [[EMClient sharedClient].chatManager addDelegate:self delegateQueue:nil];
    [[EMClient sharedClient].groupManager addDelegate:self delegateQueue:nil];
}

-(void)unregisterNotifications{
    [[EMClient sharedClient].chatManager removeDelegate:self];
    [[EMClient sharedClient].groupManager removeDelegate:self];
}

#pragma mark - getter

- (UISearchBar*)searchBar
{
    if (_searchBar == nil) {
        _searchBar = [[UISearchBar alloc] init];
        _searchBar.placeholder = @"Search";
        _searchBar.delegate = self;
        _searchBar.showsCancelButton = NO;
        _searchBar.tintColor = RGBACOLOR(0, 186, 110, 1);
    }
    return _searchBar;
}

- (NSMutableArray*)dataSource
{
    if (_dataSource == nil) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

- (UIRefreshControl*)refresh
{
    if (_refresh == nil) {
        _refresh = [[UIRefreshControl alloc] init];
        _refresh.tintColor = [UIColor lightGrayColor];
        [_refresh addTarget:self action:@selector(tableViewDidTriggerHeaderRefresh) forControlEvents:UIControlEventValueChanged];
    }
    return _refresh;
}

- (EMSearchDisplayController*)searchController
{
    if (_searchController == nil) {
        _searchController = [[EMSearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
        _searchController.delegate = self;
        _searchController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _searchController.searchResultsTableView.tableFooterView = [[UIView alloc] init];
        _searchController.displaysSearchBarInNavigationBar = YES;
        
        __weak EMChatsViewController *weakSelf = self;
        [_searchController setCellForRowAtIndexPathCompletion:^UITableViewCell *(UITableView *tableView, NSIndexPath *indexPath) {
            NSString *CellIdentifier = @"EMChatsSearchCell";
            EMChatsCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = (EMChatsCell*)[[[NSBundle mainBundle]loadNibNamed:@"EMChatsCell" owner:nil options:nil] firstObject];
            }
            EMConversation *conversation = [weakSelf.searchController.resultsSource objectAtIndex:indexPath.row];
            [(EMChatsCell*)cell setConversation:conversation];
            
            return cell;
        }];
        
        [_searchController setHeightForRowAtIndexPathCompletion:^CGFloat(UITableView *tableView, NSIndexPath *indexPath) {
            return 90;
        }];
        
        [_searchController setDidSelectRowAtIndexPathCompletion:^(UITableView *tableView, NSIndexPath *indexPath) {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            [weakSelf.searchController.searchBar endEditing:YES];
            EMConversation *conversation = [weakSelf.searchController.resultsSource objectAtIndex:indexPath.row];
            EMChatViewController *chatViewController = [[EMChatViewController alloc] initWithConversationId:conversation.conversationId conversationType:conversation.type];
            [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_UPDATEUNREADCOUNT object:nil];
            [weakSelf.navigationController pushViewController:chatViewController animated:YES];
        }];
    }
    return _searchController;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = @"EMChatsCell";
    EMChatsCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = (EMChatsCell*)[[[NSBundle mainBundle]loadNibNamed:@"EMChatsCell" owner:nil options:nil] firstObject];
    }
    EMConversation *conversation = [self.dataSource objectAtIndex:indexPath.row];
    [(EMChatsCell*)cell setConversation:conversation];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        EMConversation *conversation = [self.dataSource objectAtIndex:indexPath.row];
        WEAK_SELF
        [[EMClient sharedClient].chatManager deleteConversation:conversation.conversationId isDeleteMessages:YES completion:^(NSString *aConversationId, EMError *aError) {
            [weakSelf.dataSource removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }];
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    EMConversation *conversation = [self.dataSource objectAtIndex:indexPath.row];
    EMChatViewController *chatViewController = [[EMChatViewController alloc] initWithConversationId:conversation.conversationId conversationType:conversation.type];
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_UPDATEUNREADCOUNT object:nil];
    [self.navigationController pushViewController:chatViewController animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90.f;
}

#pragma marl - UISearchBarDelegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
    [self.searchController setActive:YES animated:NO];
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    WEAK_SELF
    [[EMRealtimeSearchUtil currentUtil] realtimeSearchWithSource:self.dataSource searchText:(NSString *)searchText collationStringSelector:@selector(conversationId) resultBlock:^(NSArray *results) {
        if (results) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.searchController.resultsSource removeAllObjects];
                [weakSelf.searchController.resultsSource addObjectsFromArray:results];
                [weakSelf.searchController.searchResultsTableView reloadData];
            });
        }
    }];
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
    [[EMRealtimeSearchUtil currentUtil] realtimeSearchStop];
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
}


#pragma mark - action

- (void)tableViewDidTriggerHeaderRefresh
{
    WEAK_SELF
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *conversations = [[EMClient sharedClient].chatManager getAllConversations];
        NSArray* sorted = [weakSelf _sortConversationList:conversations];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.dataSource removeAllObjects];
            [weakSelf.dataSource addObjectsFromArray:sorted];
            [weakSelf.refresh endRefreshing];
            [weakSelf.tableView reloadData];
        });
    });
}

#pragma mark - EMChatManagerDelegate

- (void)messagesDidReceive:(NSArray *)aMessages
{
    [self tableViewDidTriggerHeaderRefresh];
}

- (void)conversationListDidUpdate:(NSArray *)aConversationList
{
    WEAK_SELF
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray* sorted = [self _sortConversationList:aConversationList];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.dataSource removeAllObjects];
            [weakSelf.dataSource addObjectsFromArray:sorted];
            [weakSelf.refresh endRefreshing];
            [weakSelf.tableView reloadData];
        });
    });
}

#pragma mark - EMGroupManagerDelegate

- (void)groupListDidUpdate:(NSArray *)aGroupList
{
    [self tableViewDidTriggerHeaderRefresh];
}

#pragma mark - public 

- (void)setupNavigationItem:(UINavigationItem *)navigationItem
{
    navigationItem.titleView = self.searchBar;
}

#pragma mark - private

- (NSArray*)_sortConversationList:(NSArray *)aConversationList
{
    NSArray* sorted = [aConversationList sortedArrayUsingComparator:
                       ^(EMConversation *obj1, EMConversation* obj2){
                           EMMessage *message1 = [obj1 latestMessage];
                           EMMessage *message2 = [obj2 latestMessage];
                           if(message1.timestamp > message2.timestamp) {
                               return(NSComparisonResult)NSOrderedAscending;
                           }else {
                               return(NSComparisonResult)NSOrderedDescending;
                           }
                       }];
    return  sorted;
}

@end
