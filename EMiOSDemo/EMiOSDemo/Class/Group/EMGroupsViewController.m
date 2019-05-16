//
//  EMGroupsViewController.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/16.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EMGroupsViewController.h"

#import "EMAvatarNameCell.h"
#import "EMInviteGroupMemberViewController.h"
#import "EMCreateGroupViewController.h"
#import "EMJoinGroupViewController.h"

@interface EMGroupsViewController ()<EMMultiDevicesDelegate, EMGroupManagerDelegate>

@property (nonatomic, strong) EMInviteGroupMemberViewController *inviteController;

@end

@implementation EMGroupsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self _setupSubviews];
    
    self.page = 1;
    [self _fetchJoinedGroupsWithPage:self.page isHeader:YES isShowHUD:YES];
    
    [[EMClient sharedClient] addMultiDevicesDelegate:self delegateQueue:nil];
    [[EMClient sharedClient].groupManager addDelegate:self delegateQueue:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleGroupSubjectUpdated:) name:GROUP_SUBJECT_UPDATED object:nil];
}

- (void)dealloc
{
    [[EMClient sharedClient] removeMultiDevicesDelegate:self];
    [[EMClient sharedClient].groupManager removeDelegate:self];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Subviews

- (void)_setupSubviews
{
    [self addPopBackLeftItem];
    self.title = @"我的群组";
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.showRefreshHeader = YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if (tableView == self.tableView) {
        return 2;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSInteger count = 0;
    if (tableView == self.tableView) {
        if (section == 0) {
            count = 2;
        } else {
            count = [self.dataArray count];
        }
    } else {
        count = [self.searchResults count];
    }
    
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"EMAvatarNameCell";
    EMAvatarNameCell *cell = (EMAvatarNameCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[EMAvatarNameCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if (tableView == self.tableView && indexPath.section == 0) {
        cell.detailLabel.text = nil;
        if (indexPath.row == 0) {
            cell.avatarView.image = [UIImage imageNamed:@"group_create"];
            cell.nameLabel.text = @"创建群组";
        } else if (indexPath.row == 1) {
            cell.avatarView.image = [UIImage imageNamed:@"group_join"];
            cell.nameLabel.text = @"加入群组";
        }
        
        return cell;
    }
    
    EMGroup *group = nil;
    if (tableView == self.tableView) {
        group = [self.dataArray objectAtIndex:indexPath.row];
    } else {
        group = [self.searchResults objectAtIndex:indexPath.row];
    }
    
    cell.avatarView.image = [UIImage imageNamed:@"group_avatar"];
    if ([group.subject length]) {
        cell.nameLabel.text = group.subject;
    } else {
        cell.nameLabel.text = group.groupId;
    }
    cell.detailLabel.text = group.groupId;
    
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView == self.tableView && section != 0) {
        return 20;
    }
    
    return 0;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.view endEditing:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (tableView == self.tableView && indexPath.section == 0) {
        if (indexPath.row == 0) {
            [self _createGroupAction];
        } else if (indexPath.row == 1) {
            [self _joinGroupAction];
        }
        return;
    }
    
    EMGroup *group = nil;
    if (tableView == self.tableView) {
        group = [self.dataArray objectAtIndex:indexPath.row];
    } else {
        group = [self.searchResults objectAtIndex:indexPath.row];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:CHAT_PUSHVIEWCONTROLLER object:group];
}

#pragma mark - EMSearchBarDelegate

- (void)searchBarSearchButtonClicked:(NSString *)aString
{
    [self.view endEditing:YES];
}

- (void)searchTextDidChangeWithString:(NSString *)aString
{
    if (!self.isSearching) {
        return;
    }
    
    __weak typeof(self) weakself = self;
    [[EMRealtimeSearch shared] realtimeSearchWithSource:self.dataArray searchText:aString collationStringSelector:@selector(subject) resultBlock:^(NSArray *results) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself.searchResults removeAllObjects];
            [weakself.searchResults addObjectsFromArray:results];
            [weakself.searchResultTableView reloadData];
        });
    }];
}

#pragma mark - EMMultiDevicesDelegate

- (void)multiDevicesGroupEventDidReceive:(EMMultiDevicesEvent)aEvent
                                 groupId:(NSString *)aGroupId
                                     ext:(id)aExt
{
    if ([aGroupId length] == 0) {
        return;
    }
    
    switch (aEvent) {
        case EMMultiDevicesEventGroupCreate:
        case EMMultiDevicesEventGroupJoin:
        case EMMultiDevicesEventGroupDestroy:
        case EMMultiDevicesEventGroupLeave:
        case EMMultiDevicesEventGroupApplyAccept:
        case EMMultiDevicesEventGroupInviteAccept:
        {
            [self getJoinedGroupsAndReloadView];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - EMGroupManagerDelegate

- (void)groupListDidUpdate:(NSArray *)aGroupList
{
    [self.dataArray removeAllObjects];
    [self.dataArray addObjectsFromArray:aGroupList];
    [self.tableView reloadData];
}

#pragma mark - NSNotification

- (void)handleGroupSubjectUpdated:(NSNotification *)aNotif
{
    EMGroup *group = aNotif.object;
    if (!group) {
        return;
    }
    
    NSString *groupId = group.groupId;
    for (EMGroup *obj in self.dataArray) {
        if ([obj.groupId isEqualToString:groupId]) {
            [self.tableView reloadData];
        }
    }
}

#pragma mark - data

- (void)_fetchJoinedGroupsWithPage:(NSInteger)aPage
                          isHeader:(BOOL)aIsHeader
                         isShowHUD:(BOOL)aIsShowHUD
{
    [self hideHud];
    if (aIsShowHUD) {
        [self showHudInView:self.view hint:@"获取群组..."];
    }
    
    __weak typeof(self) weakself = self;
    [[EMClient sharedClient].groupManager getJoinedGroupsFromServerWithPage:aPage pageSize:50 completion:^(NSArray *aList, EMError *aError) {
        if (aIsShowHUD) {
            [weakself hideHud];
        }
        if (!aError) {
            if (aIsHeader) {
                [weakself.dataArray removeAllObjects];
            }
            [weakself.dataArray addObjectsFromArray:aList];
            
            weakself.showRefreshFooter = aList.count < 50 ? NO : YES;
            [weakself tableViewDidFinishTriggerHeader:aIsHeader reload:YES];
        }
    }];
}

- (void)tableViewDidTriggerHeaderRefresh
{
    self.page = 1;
    [self _fetchJoinedGroupsWithPage:self.page isHeader:YES isShowHUD:NO];
}

- (void)tableViewDidTriggerFooterRefresh
{
    self.page += 1;
    [self _fetchJoinedGroupsWithPage:self.page isHeader:NO isShowHUD:NO];
}

- (void)getJoinedGroupsAndReloadView
{
    NSArray *groups = [[EMClient sharedClient].groupManager getJoinedGroups];
    [self.dataArray removeAllObjects];
    [self.dataArray addObjectsFromArray:groups];
    
    [self.tableView reloadData];
}

#pragma mark - Action

- (void)_createGroupAction
{
    self.inviteController = nil;
    self.inviteController = [[EMInviteGroupMemberViewController alloc] init];
    
    __weak typeof(self) weakself = self;
    [self.inviteController setDoneCompletion:^(NSArray * _Nonnull aSelectedArray) {
        EMCreateGroupViewController *createController = [[EMCreateGroupViewController alloc] initWithSelectedMembers:aSelectedArray];
        createController.inviteController = weakself.inviteController;
        [weakself.navigationController pushViewController:createController animated:YES];
    }];
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self.inviteController];
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)_joinGroupAction
{
    EMJoinGroupViewController *controller = [[EMJoinGroupViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

@end
