//
//  EMContactsViewController.m
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 16/9/19.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "EMContactsViewController.h"
#import "EMContactListSectionHeader.h"
#import "EMSearchBar.h"
#import "EMAddContactViewController.h"
#import "EMContactInfoViewController.h"
#import "EMGroupTitleCell.h"
#import "EMContactCell.h"
#import "EMUserModel.h"
#import "EMApplyManager.h"
#import "EMGroupsViewController.h"
#import "EMApplyRequestCell.h"
#import "EMChatDemoHelper.h"
#import "EMRealtimeSearchUtils.h"

#define KEM_CONTACT_BASICSECTION_NUM  3

@interface EMContactsViewController ()<UISearchBarDelegate>

@property (nonatomic, strong) NSMutableArray *contacts;
@property (nonatomic, strong) NSMutableArray *contactRequests;
@property (nonatomic, strong) NSMutableArray *groupNotifications;

@property (nonatomic, strong) EMSearchBar *searchBar;

@end

@implementation EMContactsViewController
{
    NSMutableArray *_sectionTitls;
    NSMutableArray *_searchSource;
    NSMutableArray *_searchResults;
    BOOL _isSearchState;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.tableView.sectionIndexColor = BrightBlue;
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    [self reloadGroupNotifications];
    [self reloadContactRequests];
    [self loadContactsFromServer];
    
    __weak typeof(self) weakSelf = self;
    self.headerRefresh = ^(BOOL isRefreshing){
        [weakSelf loadContactsFromServer];
    };
    
}

- (void)setupNavigationItem:(UINavigationItem *)navigationItem {
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 20, 20);
    [btn setImage:[UIImage imageNamed:@"Icon_Add"] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"Icon_Add"] forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(addContactAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBar = [[UIBarButtonItem alloc] initWithCustomView:btn];
    [navigationItem setRightBarButtonItems:@[rightBar]];
    
    navigationItem.titleView = self.searchBar;
}

- (void)loadContactsFromServer {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
        EMError *error = nil;
        NSArray *bubbyList = [[EMClient sharedClient].contactManager getContactsFromServerWithError:&error];
        if (!error && bubbyList.count > 0) {
            [weakSelf updateContacts:bubbyList];
            dispatch_async(dispatch_get_main_queue(), ^(){
                [weakSelf endHeaderRefresh];
                [weakSelf.tableView reloadData];
            });
        }
    });
}

- (void)reloadContacts {
    NSArray *bubbyList = [[EMClient sharedClient].contactManager getContacts];
    [self updateContacts:bubbyList];
}

- (void)reloadContactRequests {
    NSArray *contactApplys = [[EMApplyManager defaultManager] contactApplys];
    self.contactRequests = [NSMutableArray arrayWithArray:contactApplys];
    NSIndexSet *set = [NSIndexSet indexSetWithIndex:1];
    [self.tableView beginUpdates];
    [self.tableView reloadSections:set withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
}

- (void)reloadGroupNotifications {
    NSArray *groupApplys = [[EMApplyManager defaultManager] groupApplys];
    self.groupNotifications = [NSMutableArray arrayWithArray:groupApplys];
    NSIndexSet *set = [NSIndexSet indexSetWithIndex:0];
    [self.tableView beginUpdates];
    [self.tableView reloadSections:set withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
}

- (void)updateContacts:(NSArray *)bubbyList {
    NSArray *blockList = [[EMClient sharedClient].contactManager getBlackList];
    NSMutableArray *contacts = [NSMutableArray arrayWithArray:bubbyList];
    for (NSString *blockId in blockList) {
        [contacts removeObject:blockId];
    }
    [self.contacts removeAllObjects];
    [self sortContacts:contacts];
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^(){
        [weakSelf.tableView reloadData];
        [weakSelf.refreshControl endRefreshing];
    });
}

- (void)sortContacts:(NSArray *)contacts {
    UILocalizedIndexedCollation *indexCollation = [UILocalizedIndexedCollation currentCollation];
    if (!_sectionTitls) {
        _sectionTitls = [NSMutableArray arrayWithArray:indexCollation.sectionTitles];
    }
    else {
        [_sectionTitls removeAllObjects];
        [_sectionTitls addObjectsFromArray:indexCollation.sectionTitles];
    }
    _contacts = [NSMutableArray arrayWithCapacity:_sectionTitls.count];
    for (int i = 0; i < _sectionTitls.count; i++) {
        NSMutableArray *array = [NSMutableArray array];
        [_contacts addObject:array];
    }
    _searchSource = [NSMutableArray array];
    for (NSString *hyphenateId in contacts) {
        EMUserModel *model = [[EMUserModel alloc] initWithHyphenateId:hyphenateId];
        if (model) {
            NSString *firstLetter = [model.nickname substringToIndex:1];
            NSUInteger sectionIndex = [indexCollation sectionForObject:firstLetter collationStringSelector:@selector(uppercaseString)];
            NSMutableArray *array = _contacts[sectionIndex];
            [array addObject:model];
            [_searchSource addObject:model];
        }
    }
    __block NSMutableIndexSet *indexSet = nil;
    [_contacts enumerateObjectsUsingBlock:^(NSMutableArray * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.count == 0) {
            if (!indexSet) {
                indexSet = [NSMutableIndexSet indexSet];
            }
            [indexSet addIndex:idx];
        }
    }];
    if (indexSet) {
        [_contacts removeObjectsAtIndexes:indexSet];
        [_sectionTitls removeObjectsAtIndexes:indexSet];
    }
}

#pragma mark - Lazy Method 
- (NSMutableArray *)contacts {
    if (!_contacts) {
        _contacts = [NSMutableArray array];
    }
    return _contacts;
}

- (NSMutableArray *)contactRequests {
    if (!_contactRequests) {
        _contactRequests = [NSMutableArray array];
    }
    return _contactRequests;
}

- (NSMutableArray *)groupNotifications {
    if (!_groupNotifications) {
        _groupNotifications = [NSMutableArray array];
    }
    return _groupNotifications;
}

- (EMSearchBar *)searchBar {
    if (!_searchBar) {
        _searchBar = [[EMSearchBar alloc] initWithFrame:CGRectMake(0, 0, 313, 30)];
        _searchBar.searchFieldWidth = 313.0f;
        _searchBar.searchFieldHeight = 30.0f;
        _searchBar.delegate = self;
    }
    return _searchBar;
}


#pragma mark - Action Method

- (void)addContactAction {
    EMAddContactViewController *addContactVc = [[EMAddContactViewController alloc] initWithNibName:@"EMAddContactViewController" bundle:nil];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:addContactVc];
    [self presentViewController:nav animated:YES completion:nil];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (_isSearchState) {
        return 1;
    }
    return KEM_CONTACT_BASICSECTION_NUM + _sectionTitls.count;
}

- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return _sectionTitls;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_isSearchState) {
        return _searchResults.count;
    }
    switch (section) {
        case 0:
            return _groupNotifications.count;
        case 1:
            return _contactRequests.count;
        case 2:
            return 1;
    }
    NSArray *array = _contacts[section - KEM_CONTACT_BASICSECTION_NUM];
    return array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_isSearchState) {
        NSString *cellIdentify = @"EMContactCell";
        EMContactCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentify];
        if (!cell) {
            cell = (EMContactCell *)[[[NSBundle mainBundle] loadNibNamed:@"EMContactCell" owner:self options:nil] lastObject];
        }
        cell.model = _searchResults[indexPath.row];
        return cell;
    }
    
    if (indexPath.section > 2) {
        NSString *cellIdentify = @"EMContactCell";
        EMContactCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentify];
        if (!cell) {
            cell = (EMContactCell *)[[[NSBundle mainBundle] loadNibNamed:@"EMContactCell" owner:self options:nil] lastObject];
        }
        NSArray *sectionList = _contacts[indexPath.section-KEM_CONTACT_BASICSECTION_NUM];
        cell.model = sectionList[indexPath.row];
        return cell;
    }
    if (indexPath.section == 2) {
        NSString *cellIdentify = @"EMGroupTitle_Cell";
        cellIdentify = @"EMGroupTitle_Cell";
        EMGroupTitleCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentify];
        if (!cell) {
            cell = (EMGroupTitleCell *)[[[NSBundle mainBundle] loadNibNamed:@"EMGroupTitleCell" owner:self options:nil] lastObject];
        }
        cell.titleLabel.text = NSLocalizedString(@"common.groups", @"Groups");
        return cell;
    }
    
    NSString *cellIdentifier = @"EMApplyRequestCell";
    EMApplyRequestCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:self options:nil] lastObject];
    }
    EMApplyModel *model = nil;
    if (indexPath.section == 0) {
        model = _groupNotifications[indexPath.row];
    }
    else {
        model = _contactRequests[indexPath.row];
    }
    __weak typeof(self) weakSelf = self;
    cell.declineApply = ^(EMApplyModel *model) {
        if (model.style == EMApplyStyle_contact) {
            [weakSelf reloadContactRequests];
        }
        else {
            [weakSelf reloadGroupNotifications];
        }
        [[EMChatDemoHelper shareHelper] setupUntreatedApplyCount];
    };
    cell.acceptApply = ^(EMApplyModel *model) {
        if (model.style == EMApplyStyle_contact) {
            [weakSelf reloadContactRequests];
        }
        else {
            [weakSelf reloadGroupNotifications];
        }
        [[EMChatDemoHelper shareHelper] setupUntreatedApplyCount];
        [weakSelf reloadContacts];
    };
    cell.model = model;
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 2 && !_isSearchState) {
        EMGroupsViewController *groupsVc = [[EMGroupsViewController alloc] initWithNibName:@"EMGroupsViewController" bundle:nil];
        [self.navigationController pushViewController:groupsVc animated:YES];
        return;
    }
    
    EMUserModel * model = nil;
    if (_isSearchState) {
        model = _searchResults[indexPath.row];
    }
    else if (indexPath.section >= KEM_CONTACT_BASICSECTION_NUM) {
        NSArray *sectionContacts = _contacts[indexPath.section-KEM_CONTACT_BASICSECTION_NUM];
        model = sectionContacts[indexPath.row];
    }
    if (model) {
        EMContactInfoViewController *contactInfoVc = [[EMContactInfoViewController alloc] initWithUserModel:model];
        [self.navigationController pushViewController:contactInfoVc animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_isSearchState) {
        return 50.0f;
    }
    if (indexPath.section < KEM_CONTACT_BASICSECTION_NUM - 1) {
        return 60.0f;
    }
    return 50.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (_isSearchState) {
        return 0;
    }
    
    switch (section) {
        case 0:
            if (self.groupNotifications.count > 0) {
                return 40.0f;
            }
            break;
        case 1:
            if (self.contactRequests.count > 0) {
                return 40.0f;
            }
            break;
        case 2:
            if (self.contactRequests.count > 0 || self.groupNotifications > 0) {
                return 20.0;
            }
            break;
    }
    return 0.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    EMContactListSectionHeader *sectionHeader = [[[NSBundle mainBundle] loadNibNamed:@"EMContactListSectionHeader"
                                                                             owner:self
                                                                           options:nil] firstObject];
    NSUInteger unhandelCount = 0;
    switch (section) {
        case 0:
            unhandelCount = _groupNotifications.count;
            break;
        case 1:
            unhandelCount = _contactRequests.count;
            break;
        default:
            break;
    }
    [sectionHeader updateInfo:unhandelCount section:section];
    return sectionHeader;
}

#pragma mark - UISearchBarDelegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
    _isSearchState = YES;
    return YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    _isSearchState = NO;
    [self.tableView reloadData];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    __weak typeof(self) weakSelf = self;
    [[EMRealtimeSearchUtils defaultUtil] realtimeSearchWithSource:_searchSource searchString:searchText resultBlock:^(NSArray *results) {
        if (results) {
            dispatch_async(dispatch_get_main_queue(), ^{
                _searchResults = [NSMutableArray arrayWithArray:results];
                [weakSelf.tableView reloadData];
            });
        }
    }];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO animated:NO];
    [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.text = @"";
    [searchBar setShowsCancelButton:NO animated:NO];
    [searchBar resignFirstResponder];
    [[EMRealtimeSearchUtils defaultUtil] realtimeSearchDidFinish];
    _isSearchState = NO;
    [self.tableView reloadData];
}



@end
