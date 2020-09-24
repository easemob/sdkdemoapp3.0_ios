//
//  EMGroupsViewController.m
//  EaseIM
//
//  Update by zhangchong on 2020/9/14.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EMGroupsViewController.h"

#import "EMAvatarNameCell.h"
#import "EMInviteGroupMemberViewController.h"

@interface EMGroupsViewController ()<EMMultiDevicesDelegate, EMGroupManagerDelegate>

@property (nonatomic, strong) EMInviteGroupMemberViewController *inviteController;

@end

@implementation EMGroupsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0];
    // Do any additional setup after loading the view.
    [self _setupSubviews];
    self.searchBar.delegate = self;
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
    self.title = @"群组列表";
    self.view.backgroundColor = [UIColor whiteColor];
    self.showRefreshHeader = YES;
    self.tableView.rowHeight = 74;
    self.searchResultTableView.rowHeight = 74;
}

#pragma mark - EMSearchBarDelegate
//重写父类方法
- (void)searchBarShouldBeginEditing:(EMSearchBar *)searchBar
{
    if (!self.isSearching) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        
        self.isSearching = YES;
        [self.view addSubview:self.searchResultTableView];
        [self.searchResultTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.searchBar.mas_bottom);
            make.left.equalTo(self.view);
            make.right.equalTo(self.view);
            make.bottom.equalTo(self.view);
        }];
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
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
    }
    
    EMGroup *group = nil;
    if (tableView == self.tableView) {
        group = self.dataArray[indexPath.row];
    } else {
        group = self.searchResults[indexPath.row];
    }
    
    cell.avatarView.image = [UIImage imageNamed:@"groupConversation"];
    if ([group.groupName length]) {
        cell.nameLabel.text = group.groupName;
    } else {
        cell.nameLabel.text = group.groupId;
    }
    cell.detailLabel.text = group.groupId;
    
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.0001;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.view endEditing:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    EMGroup *group = nil;
    if (tableView == self.tableView) {
        group = self.dataArray[indexPath.row];
    } else {
        group = self.searchResults[indexPath.row];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:CHAT_PUSHVIEWCONTROLLER object:group];
}

#pragma mark - EMSearchBarDelegate

- (void)searchBarCancelButtonAction:(EMSearchBar *)searchBar
{
    [super searchBarCancelButtonAction:searchBar];
    [self getJoinedGroupsAndReloadView];
}

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
    EMGroup *group = (EMGroup *)aNotif.object;
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
    //按数目从服务器获取自己加入的群组
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
    // 获取用户所有群组
    NSArray *groups = [[EMClient sharedClient].groupManager getJoinedGroups];
    [self.dataArray removeAllObjects];
    [self.dataArray addObjectsFromArray:groups];
    [self.tableView reloadData];
}

@end
