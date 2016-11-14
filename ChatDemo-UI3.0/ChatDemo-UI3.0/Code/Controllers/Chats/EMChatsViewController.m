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
#import "EMConversationModel.h"

@interface EMChatsViewController () <EMChatManagerDelegate,EMGroupManagerDelegate,UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource,UISearchDisplayDelegate>
{
    BOOL _isSearchState;
}

@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) NSMutableArray *dataSource;
@property (strong, nonatomic) NSMutableArray *resultsSource;
@property (strong, nonatomic) UIView *networkStateView;

@end

@implementation EMChatsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    [self setupForDismissKeyboard];
    
    if ([UIDevice currentDevice].systemVersion.floatValue >= 7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin |UIViewAutoresizingFlexibleHeight;
    _isSearchState = NO;
    WEAK_SELF
    self.headerRefresh = ^(BOOL isRefreshing){
        [weakSelf tableViewDidTriggerHeaderRefresh];
    };
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self registerNotifications];
    [self tableViewDidTriggerHeaderRefresh];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_UPDATEUNREADCOUNT object:nil];
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

- (UIView *)networkStateView
{
    if (_networkStateView == nil) {
        _networkStateView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 44)];

        _networkStateView.backgroundColor = RGBACOLOR(0, 186, 110, 1);
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, (_networkStateView.frame.size.height - 20) / 2, 20, 20)];
        imageView.image = [UIImage imageNamed:@"Icon_error"];
        [_networkStateView addSubview:imageView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageView.frame) + 5, 0, _networkStateView.frame.size.width - (CGRectGetMaxX(imageView.frame) + 15), _networkStateView.frame.size.height)];
        label.font = [UIFont systemFontOfSize:15.0];
        label.textColor = [UIColor grayColor];
        label.backgroundColor = [UIColor clearColor];
        label.text = NSLocalizedString(@"network.disconnection", @"Network disconnection");
        [_networkStateView addSubview:label];
    }
    return _networkStateView;
}

- (UISearchBar*)searchBar
{
    if (_searchBar == nil) {
        _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 30)];
        _searchBar.placeholder = NSLocalizedString(@"common.search", @"Search");
        _searchBar.delegate = self;
        _searchBar.showsCancelButton = NO;
        _searchBar.backgroundImage = [UIImage imageWithColor:[UIColor whiteColor] size:_searchBar.bounds.size];
        [_searchBar setSearchFieldBackgroundPositionAdjustment:UIOffsetMake(0, 0)];
        [_searchBar setSearchFieldBackgroundImage:[UIImage imageWithColor:RGBACOLOR(228, 233, 236, 1) size:_searchBar.bounds.size] forState:UIControlStateNormal];
        _searchBar.tintColor = RGBACOLOR(12, 18, 24, 1);
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

- (NSMutableArray*)resultsSource
{
    if (_resultsSource == nil) {
        _resultsSource = [NSMutableArray array];
    }
    return _resultsSource;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_isSearchState) {
        return [self.resultsSource count];
    }
    return [self.dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_isSearchState) {
        NSString *CellIdentifier = @"EMChatsSearchCell";
        EMChatsCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = (EMChatsCell*)[[[NSBundle mainBundle]loadNibNamed:@"EMChatsCell" owner:nil options:nil] firstObject];
        }
        EMConversationModel *model = [self.resultsSource objectAtIndex:indexPath.row];
        [(EMChatsCell*)cell setConversationModel:model];
        
        return cell;
    }
    
    NSString *CellIdentifier = @"EMChatsCell";
    EMChatsCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = (EMChatsCell*)[[[NSBundle mainBundle]loadNibNamed:@"EMChatsCell" owner:nil options:nil] firstObject];
    }
    EMConversationModel *model = [self.dataSource objectAtIndex:indexPath.row];
    [(EMChatsCell*)cell setConversationModel:model];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_isSearchState) {
        return NO;
    }
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        EMConversationModel *model = [self.dataSource objectAtIndex:indexPath.row];
        WEAK_SELF
        [[EMClient sharedClient].chatManager deleteConversation:model.conversation.conversationId isDeleteMessages:YES completion:^(NSString *aConversationId, EMError *aError) {
            [weakSelf.dataSource removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }];
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    EMConversationModel *model = nil;
    if (_isSearchState) {
        model = [self.resultsSource objectAtIndex:indexPath.row];
    } else {
        model = [self.dataSource objectAtIndex:indexPath.row];
    }
    
    EMChatViewController *chatViewController = [[EMChatViewController alloc] initWithConversationId:model.conversation.conversationId conversationType:model.conversation.type];
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_UPDATEUNREADCOUNT object:nil];
    [self.navigationController pushViewController:chatViewController animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.f;
}

#pragma marl - UISearchBarDelegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
//    [self.searchController setActive:YES animated:YES];
    _isSearchState = YES;
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    WEAK_SELF
    [[EMRealtimeSearchUtil currentUtil] realtimeSearchWithSource:self.dataSource searchText:(NSString *)searchText collationStringSelector:@selector(title) resultBlock:^(NSArray *results) {
        if (results) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.resultsSource removeAllObjects];
                [weakSelf.resultsSource addObjectsFromArray:results];
                [weakSelf.tableView reloadData];
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
    _isSearchState = NO;
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
            for (EMConversation *conversation in sorted) {
                EMConversationModel *model = [[EMConversationModel alloc] initWithConversation:conversation];
                [weakSelf.dataSource addObject:model];
            }
            [self endHeaderRefresh];
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
            for (EMConversation *conversation in sorted) {
                EMConversationModel *model = [[EMConversationModel alloc] initWithConversation:conversation];
                [weakSelf.dataSource addObject:model];
            }
            [self endHeaderRefresh];
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

- (void)networkChanged:(EMConnectionState)connectionState
{
    if (connectionState == EMConnectionDisconnected) {
        self.tableView.tableHeaderView = self.networkStateView;
    } else {
        self.tableView.tableHeaderView = nil;
    }
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
