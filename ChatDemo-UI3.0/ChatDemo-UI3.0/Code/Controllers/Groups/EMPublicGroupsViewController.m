//
//  EMPublicGroupsViewController.m
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 16/10/13.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "EMPublicGroupsViewController.h"
#import "EMGroupCell.h"
#import "EMRefreshFootViewCell.h"

#define KPUBLICGROUP_PAGE_COUNT    50

typedef NS_ENUM(NSUInteger, EMFetchPublicGroupState) {
    EMFetchPublicGroupState_Normal            =           0,
    EMFetchPublicGroupState_Loading,
    EMFetchPublicGroupState_Nomore
};


@interface EMPublicGroupsViewController ()<EMGroupUIProtocol>

@property (nonatomic, strong) NSString *cursor;

@property (nonatomic, copy) EMGroupModel *requestGroupModel;

@property (nonatomic, strong) NSMutableArray<NSString *> *applyedDataSource;

@property (nonatomic, assign) EMFetchPublicGroupState loadState;

@end

@implementation EMPublicGroupsViewController
{
    BOOL _isSearching;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self fetchPublicGroups];
}

- (void)setSearchState:(BOOL)isSearching {
    _isSearching = isSearching;
    if (!_isSearching) {
        [_searchResults removeAllObjects];
    }
}

- (NSMutableArray<EMGroupModel *> *)publicGroups {
    if (!_publicGroups) {
        _publicGroups = [NSMutableArray array];
    }
    return _publicGroups;
}

- (NSMutableArray<NSString *> *)applyedDataSource {
    if (!_applyedDataSource) {
        _applyedDataSource = [NSMutableArray array];
    }
    return _applyedDataSource;
}

- (NSMutableArray<EMGroupModel *> *)searchResults {
    if (!_searchResults) {
        _searchResults = [NSMutableArray array];
    }
    return _searchResults;
}

#pragma mark - Load Data
- (void)fetchPublicGroups {
    _loadState = EMFetchPublicGroupState_Loading;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1]
                  withRowAnimation:UITableViewRowAnimationNone];
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
        EMError *error = nil;
        EMCursorResult *result = [[EMClient sharedClient].groupManager getPublicGroupsFromServerWithCursor:_cursor
                                                                                                  pageSize:KPUBLICGROUP_PAGE_COUNT
                                                                                                     error:&error];
        if (!error) {
            weakSelf.cursor = result.cursor;
            for (EMGroup *group in result.list) {
                EMGroupModel *model = [[EMGroupModel alloc] initWithObject:group];
                if (model) {
                    [weakSelf.publicGroups addObject:model];
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.loadState = EMFetchPublicGroupState_Normal;
                if (weakSelf.cursor.length == 0) {
                    weakSelf.loadState = EMFetchPublicGroupState_Nomore;
                }
                [weakSelf.tableView reloadData];
            });
        }
    });
}

- (void)reloadRequestedApplyDataSource {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.applyedDataSource addObject:_requestGroupModel.group.groupId];
        NSUInteger index = [weakSelf.publicGroups indexOfObject:_requestGroupModel];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [weakSelf.tableView beginUpdates];
        [weakSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        [weakSelf.tableView endUpdates];
        _requestGroupModel = nil;
    });
}

#pragma mark - Join Public Group
- (void)joinToPublicGroup:(NSString *)groupId {
    __weak typeof(self) weakSelf = self;
    [[EMClient sharedClient].groupManager joinPublicGroup:groupId
                                               completion:^(EMGroup *aGroup, EMError *aError) {
                                                   if (!aError) {
                                                       [weakSelf reloadRequestedApplyDataSource];
                                                   }
                                               }
     ];
}

- (void)requestToJoinPublicGroup:(NSString *)groupId message:(NSString *)message {
    __weak typeof(self) weakSelf = self;
    [[EMClient sharedClient].groupManager requestToJoinPublicGroup:groupId
                                                           message:message
                                                        completion:^(EMGroup *aGroup, EMError *aError) {
                                                            if (!aError) {
                                                                [weakSelf reloadRequestedApplyDataSource];
                                                            }
                                                        }];
}

- (void)popAlertView {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                        message:@""
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"common.cancel", @"Cancel")
                                              otherButtonTitles:NSLocalizedString(@"common.ok", @"OK"), nil];
    [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [alertView show];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (_loadState != EMFetchPublicGroupState_Nomore && !_isSearching) {
        return 2;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_isSearching) {
        return _searchResults.count;
    }
    if (_loadState != EMFetchPublicGroupState_Nomore && section == 1) {
        return 1;
    }
    return _publicGroups.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        static NSString *cellIdentifier = @"EMRefreshFootViewCell";
        EMRefreshFootViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:self options:nil] lastObject];
        }
        switch (_loadState) {
            case EMFetchPublicGroupState_Normal:
                cell.loadMoreLabel.hidden = NO;
                cell.activity.hidden = YES;
                [cell.activity stopAnimating];
                break;
            case EMFetchPublicGroupState_Loading:
                cell.loadMoreLabel.hidden = YES;
                cell.activity.hidden = NO;
                [cell.activity startAnimating];
                break;
            default:
                break;
        }
        return cell;
    }
    
    static NSString *cellIdentifier = @"EMGroup_Public_Cell";
    EMGroupCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:self options:nil] lastObject];
    }
    EMGroupModel *model = nil;
    if (_isSearching) {
        model = _searchResults[indexPath.row];
    }
    else {
        model = _publicGroups[indexPath.row];
    }
    cell.isRequestedToJoinPublicGroup = [_applyedDataSource containsObject:model.group.groupId];
    cell.model = model;
    cell.delegate = self;
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 90;
}

#pragma mark - EMGroupUIProtocol

- (void)joinPublicGroup:(EMGroupModel *)groupModel {
    _requestGroupModel = groupModel;
    if (groupModel.group.setting.style == EMGroupStylePublicOpenJoin) {
        [self joinToPublicGroup:groupModel.group.groupId];
    }
    else {
        [self popAlertView];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (scrollView.contentOffset.y >= MAX(0, scrollView.contentSize.height - scrollView.frame.size.height) + 50) {
        if (_loadState == EMFetchPublicGroupState_Normal) {
            [self fetchPublicGroups];
        }
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([alertView cancelButtonIndex] != buttonIndex) {
        UITextField *messageTextField = [alertView textFieldAtIndex:0];
        NSString *messageStr = @"";
        if (messageTextField.text.length > 0) {
            messageStr = messageTextField.text;
        }
        [self requestToJoinPublicGroup:_requestGroupModel.group.groupId message:messageStr];
    }
}


@end
