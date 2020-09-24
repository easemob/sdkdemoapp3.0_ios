//
//  EMJoinGroupViewController.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/17.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EMJoinGroupViewController.h"

#import "EMSearchBar.h"
#import "EMAvatarNameCell.h"

@interface EMJoinGroupViewController ()<EMAvatarNameCellDelegate>

@property (nonatomic, strong) NSMutableArray *joinedIdArray;
@property (nonatomic, strong) NSMutableArray *applyedIdArray;

@property (nonatomic, strong) NSString *cursor;

@end

@implementation EMJoinGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.joinedIdArray = [[NSMutableArray alloc] init];
    self.applyedIdArray = [[NSMutableArray alloc] init];
    
    [self _setupSubviews];
    [self _fetchPublicGroupsWithIsHeader:YES isShowHUD:YES];
}

#pragma mark - Subviews

- (void)_setupSubviews
{
    [self addPopBackLeftItem];
    self.title = @"加群";
    
    self.showRefreshHeader = YES;
    self.searchBar.textField.placeholder = @"搜索群组ID";
    self.tableView.rowHeight = 60;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (tableView == self.tableView) {
        return [self.dataArray count];
    } else {
        return [self.searchResults count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"EMAvatarNameCell";
    EMAvatarNameCell *cell = (EMAvatarNameCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[EMAvatarNameCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.delegate = self;
        
        UIButton *rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80, 35)];
        rightButton.clipsToBounds = YES;
        rightButton.backgroundColor = kColor_Blue;
        rightButton.titleLabel.font = [UIFont systemFontOfSize:16];
        rightButton.layer.cornerRadius = 5;
        [rightButton setTitle:@"加入" forState:UIControlStateNormal];
        [rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [rightButton setTitle:@"已申请" forState:UIControlStateDisabled];
        [rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
        cell.accessoryButton = rightButton;
    }
    
    EMGroup *group = nil;
    if (tableView == self.tableView) {
        group = [self.dataArray objectAtIndex:indexPath.row];
    } else {
        group = [self.searchResults objectAtIndex:indexPath.row];
    }
    
    cell.avatarView.image = [UIImage imageNamed:@"groupConversation"];
    if ([group.groupName length]) {
        cell.nameLabel.text = group.groupName;
    } else {
        cell.nameLabel.text = group.groupId;
    }
    cell.detailLabel.text = group.groupId;
    cell.indexPath = indexPath;
    
    if ([self.applyedIdArray containsObject:group.groupId]) {
        cell.accessoryButton.enabled = NO;
        [cell.accessoryButton setTitle:@"已申请" forState:UIControlStateDisabled];
        cell.accessoryButton.backgroundColor = kColor_Gray;
    } else if ([self.joinedIdArray containsObject:group.groupId]) {
        cell.accessoryButton.enabled = NO;
        [cell.accessoryButton setTitle:@"已加入" forState:UIControlStateDisabled];
        cell.accessoryButton.backgroundColor = kColor_Gray;
    } else {
        cell.accessoryButton.enabled = YES;
        cell.accessoryButton.backgroundColor = kColor_Blue;
    }
    
    return cell;
}

#pragma mark - EMAvatarNameCellDelegate

- (void)_joinGroup:(EMGroup *)aGroup
   accessoryButton:(UIButton *)aButton
{
    __weak typeof(self) weakself = self;
    if (aGroup.setting.style == EMGroupStylePublicOpenJoin) {
        [self showHudInView:self.view hint:@"加入群组..."];
        [[EMClient sharedClient].groupManager joinPublicGroup:aGroup.groupId completion:^(EMGroup *aGroup1, EMError *aError) {
            [weakself hideHud];
            if (aError) {
                [EMAlertController showErrorAlert:@"加入群组失败"];
            } else {
                [weakself.joinedIdArray addObject:aGroup1.groupId];
                aButton.enabled = NO;
                [aButton setTitle:@"已加入" forState:UIControlStateDisabled];
                aButton.backgroundColor = kColor_Gray;
            }
        }];
    } else if (aGroup.setting.style == EMGroupStylePublicJoinNeedApproval) {
        [self showHudInView:self.view hint:@"发送入群申请..."];
        [[EMClient sharedClient].groupManager requestToJoinPublicGroup:aGroup.groupId message:nil completion:^(EMGroup *aGroup1, EMError *aError) {
            [weakself hideHud];
            if (aError) {
                [EMAlertController showErrorAlert:@"发送申请失败"];
            } else {
                [weakself.applyedIdArray addObject:aGroup1.groupId];
                aButton.enabled = NO;
                [aButton setTitle:@"已申请" forState:UIControlStateDisabled];
                aButton.backgroundColor = kColor_Gray;
            }
        }];
    }
}

- (void)cellAccessoryButtonAction:(EMAvatarNameCell *)aCell
{
    __weak typeof(self) weakself = self;
    EMGroup *group = nil;
    if (!self.isSearching) {
        group = [self.dataArray objectAtIndex:aCell.indexPath.row];
    } else {
        group = [self.searchResults objectAtIndex:aCell.indexPath.row];
    }
    
    [self showHudInView:self.view hint:@"获取群组信息..."];
    [[EMClient sharedClient].groupManager getGroupSpecificationFromServerWithId:group.groupId completion:^(EMGroup *aGroup, EMError *aError) {
        [weakself hideHud];
        if (aError) {
            [EMAlertController showErrorAlert:aError.errorDescription];
        } else {
            [weakself _joinGroup:aGroup accessoryButton:aCell.accessoryButton];
        }
    }];
}

#pragma mark - EMSearchBarDelegate

- (void)searchBarSearchButtonClicked:(NSString *)aString
{
    [self.view endEditing:YES];
    [self _searchGroupWithId:aString];
}

- (void)searchTextDidChangeWithString:(NSString *)aString
{
    __weak typeof(self) weakself = self;
    [[EMRealtimeSearch shared] realtimeSearchWithSource:self.dataArray searchText:aString collationStringSelector:@selector(groupId) resultBlock:^(NSArray *results) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself.searchResults removeAllObjects];
            [weakself.searchResults addObjectsFromArray:results];
            [weakself.searchResultTableView reloadData];
        });
    }];
}

#pragma mark - data

- (void)_fetchPublicGroupsWithIsHeader:(BOOL)aIsHeader
                         isShowHUD:(BOOL)aIsShowHUD
{
    if (aIsShowHUD) {
        [self showHudInView:self.view hint:@"获取公开群组..."];
    }
    
    __weak typeof(self) weakself = self;
    [[EMClient sharedClient].groupManager getPublicGroupsFromServerWithCursor:self.cursor pageSize:50 completion:^(EMCursorResult *aResult, EMError *aError) {
        [weakself hideHud];
        
        if (aError) {
            [EMAlertController showErrorAlert:aError.errorDescription];
        } else {
            if (aIsHeader) {
                [weakself.dataArray removeAllObjects];
            }
            
            weakself.cursor = aResult.cursor;
            [weakself.dataArray addObjectsFromArray:aResult.list];
            
            if ([aResult.list count] == 0 || [aResult.cursor length] == 0) {
                weakself.showRefreshFooter = NO;
            } else {
                weakself.showRefreshFooter = YES;
            }
            
            [weakself.tableView reloadData];
        }
        
        [weakself tableViewDidFinishTriggerHeader:aIsHeader reload:NO];
    }];
}

- (void)tableViewDidTriggerHeaderRefresh
{
    self.cursor = nil;
    [self _fetchPublicGroupsWithIsHeader:YES isShowHUD:NO];
}

- (void)tableViewDidTriggerFooterRefresh
{
    [self _fetchPublicGroupsWithIsHeader:NO isShowHUD:NO];
}

#pragma mark - Action

- (BOOL)_isJoined:(EMGroup *)aGroup
{
    if (aGroup) {
        NSArray *groupList = [[EMClient sharedClient].groupManager getJoinedGroups];
        for (EMGroup *tmpGroup in groupList) {
            if (tmpGroup.isPublic == aGroup.isPublic && [aGroup.groupId isEqualToString:tmpGroup.groupId]) {
                return YES;
            }
        }
    }
    
    return NO;
}

- (void)_searchGroupWithId:(NSString *)aId
{
    __weak typeof(self) weakself = self;
    [self showHudInView:self.view hint:@"搜索群组..."];
    [[EMClient sharedClient].groupManager searchPublicGroupWithId:aId completion:^(EMGroup *aGroup, EMError *aError) {
        [weakself hideHud];
        if (!aError) {
            [weakself.searchResults removeAllObjects];
            [weakself.searchResults addObject:aGroup];
            [weakself.searchResultTableView reloadData];
        } else {
            [EMAlertController showErrorAlert:@"未搜索到群组"];
        }
    }];
}

@end
