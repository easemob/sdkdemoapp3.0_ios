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
#import "EMChineseToPinyin.h"

@interface EMGroupsViewController ()<EMMultiDevicesDelegate, EMGroupManagerDelegate>

@property (nonatomic, strong) EMInviteGroupMemberViewController *inviteController;

@property(nonatomic, strong) UIAlertController *alertController;

//我参与的群类型
@property (nonatomic) NSInteger type;
//我参与的公开/私有群
@property (nonatomic) BOOL isPublic;

//按群昵称首字母排序
@property (nonatomic, strong) NSMutableArray *sectionTitles;

//参与的群
@property (nonatomic, strong) UIButton *participantBtn;
@property (nonatomic, strong) UIView *participantView;

//管理的群
@property (nonatomic, strong) UIButton *managementBtn;
@property (nonatomic, strong) UIView *managementView;

//切换群类型
@property (nonatomic, strong) UIButton *cutGroupAuthorityBtn;

@property (nonatomic, strong) NSMutableArray *tempArray;
@property (nonatomic, strong) NSMutableArray *tempSearchResults;
@property (nonatomic, strong) NSMutableArray *tempSectionTitles;

@property (nonatomic, strong) NSMutableArray *currentSearchGroupArray;

@end

@implementation EMGroupsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self _setupSubviews];
    [self _setupSwitchviews];
    self.view.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0];
    
    self.type = 1;//我参与的群
    self.isPublic = YES;//公开/私有群
    
    self.sectionTitles = [[NSMutableArray alloc] init];//群昵称首字母
    
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
    [self.navigationController.navigationBar.layer setMasksToBounds:YES];
    /*
    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithTitle:@"公开群" style:UIBarButtonItemStylePlain target:self action:@selector(_cutSpecialGroupType)];
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 44)];

    UIBarButtonItem *backBtnI = [[UIBarButtonItem alloc] initWithCustomView:backButton];

    rightBarItem.width = -30;

    self.navigationItem.rightBarButtonItems = @[rightBarItem,backBtnI];
    
     [self.navigationItem.rightBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:15], NSFontAttributeName, nil] forState:UIControlStateNormal];
    */
    //self.navigationItem.rightBarButtonItem.enabled = NO;
    self.title = @"群组列表";
    //[self.navigationItem.rightBarButtonItem setTintColor:[UIColor blackColor]];
    self.view.backgroundColor = [UIColor whiteColor];
    self.showRefreshHeader = YES;
    self.tableView.rowHeight = 74;
    self.searchResultTableView.rowHeight = 74;
}

#pragma mark - SubviewsSwitch
//我的群类型
- (void)_setupSwitchviews
{
    CGFloat width = (self.view.frame.size.width) / 3;

    self.cutGroupAuthorityBtn = [[UIButton alloc]init];
    [_cutGroupAuthorityBtn setTitle:@"公开群" forState:UIControlStateNormal];
    [_cutGroupAuthorityBtn setTitleColor:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0] forState:UIControlStateNormal];
    _cutGroupAuthorityBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    _cutGroupAuthorityBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    _cutGroupAuthorityBtn.backgroundColor = [UIColor whiteColor];
    _cutGroupAuthorityBtn.tag = 1;
    [_cutGroupAuthorityBtn addTarget:self action:@selector(_cutGroupAuthorityType) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_cutGroupAuthorityBtn];
    [_cutGroupAuthorityBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(50);
        make.left.equalTo(self.view);
        make.width.mas_equalTo(width-1);
        make.height.equalTo(@40);
    }];
    
    self.participantBtn = [[UIButton alloc]init];
    [_participantBtn setTitle:@"我参与的" forState:UIControlStateNormal];
    [_participantBtn setTitleColor:[UIColor colorWithRed:4/255.0 green:174/255.0 blue:240/255.0 alpha:1.0] forState:UIControlStateNormal];
    _participantBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    _participantBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    _participantBtn.backgroundColor = [UIColor whiteColor];
    _participantBtn.tag = 1;
    [_participantBtn addTarget:self action:@selector(cutGroupType:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_participantBtn];
    [_participantBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(50);
        make.left.equalTo(self.cutGroupAuthorityBtn.mas_right).offset(1);
        make.width.mas_equalTo(width-1);
        make.height.equalTo(@40);
    }];
    self.participantView = [[UIView alloc]init];
    _participantView.backgroundColor = [UIColor colorWithRed:4/255.0 green:174/255.0 blue:240/255.0 alpha:1.0];
    [self.view addSubview:_participantView];
    [_participantView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.participantBtn.mas_bottom);
        make.height.equalTo(@2);
        make.width.equalTo(self.participantBtn);
        make.left.equalTo(self.participantBtn);
    }];
    
    self.managementBtn = [[UIButton alloc]init];
    [_managementBtn setTitle:@"我管理的" forState:UIControlStateNormal];
    _managementBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    _managementBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [_managementBtn setTitleColor:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0] forState:UIControlStateNormal];
    _managementBtn.backgroundColor = [UIColor whiteColor];
    _managementBtn.tag = 2;
    [_managementBtn addTarget:self action:@selector(cutGroupType:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.managementBtn];
    [_managementBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(50);
        make.right.equalTo(self.view);
        make.left.equalTo(self.participantBtn.mas_right).offset(1);
        make.width.mas_equalTo(width-1);
        make.height.equalTo(@40);
    }];
    self.managementView = [[UIView alloc]init];
    _managementView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.managementView];
    [_managementView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.managementBtn.mas_bottom);
        make.height.equalTo(@2);
        make.width.equalTo(self.managementBtn);
        make.right.equalTo(self.managementBtn);
    }];
    
    [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.participantView.mas_bottom);
        make.left.right.bottom.equalTo(self.view);
    }];
    
}
//切换我的群类型
#pragma mark - cutGroupType
- (void)cutGroupType:(UIButton *)btn
{
    if (self.isSearching) {
        return;
    }
    self.type = btn.tag;
    if (btn.tag == 1) {
        [self.participantBtn setTitleColor:[UIColor colorWithRed:4/255.0 green:174/255.0 blue:240/255.0 alpha:1.0] forState:UIControlStateNormal];
        self.participantView.backgroundColor = [UIColor colorWithRed:4/255.0 green:174/255.0 blue:240/255.0 alpha:1.0];
        
        [self.managementBtn setTitleColor:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0] forState:UIControlStateNormal];
        self.managementView.backgroundColor = [UIColor clearColor];
    } else if (btn.tag == 2) {
        [self.participantBtn setTitleColor:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0] forState:UIControlStateNormal];
        self.participantView.backgroundColor = [UIColor clearColor];
        
        [self.managementBtn setTitleColor:[UIColor colorWithRed:4/255.0 green:174/255.0 blue:240/255.0 alpha:1.0] forState:UIControlStateNormal];
        self.managementView.backgroundColor = [UIColor colorWithRed:4/255.0 green:174/255.0 blue:240/255.0 alpha:1.0];
    }
    [self.tableView reloadData];
}

//切换公开/私有群
#pragma mark - Action

- (void)_cutGroupAuthorityType
{
    if (self.isSearching) {
        [EMAlertController showErrorAlert:@"切换群类型请重新搜索！"];
        return;
    }
    self.alertController = [[UIAlertController alloc]init];
    __weak typeof(self) weakself = self;
    [self.alertController addAction:[UIAlertAction actionWithTitle:@"公开群" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (weakself.isPublic) {
            [EMAlertController showSuccessAlert:@"当前已是公开群！"];
            return;
        }
        [weakself _cutGroupAuthorityOperate];
    }]];
    [self.alertController addAction:[UIAlertAction actionWithTitle:@"私有群" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (!weakself.isPublic) {
            [EMAlertController showSuccessAlert:@"当前已是私有群！"];
            return;
        }
        [weakself _cutGroupAuthorityOperate];
    }]];
    [self.alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }]];
    for (UIAlertAction *alertAction in self.alertController.actions) {
        [alertAction setValue:[UIColor colorWithRed:49/255.0 green:49/255.0 blue:49/255.0 alpha:1.0] forKey:@"_titleTextColor"];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didAlert" object:@{@"alert":self.alertController}];
    [self presentViewController:self.alertController animated:YES completion:nil];
}

- (void)_cutGroupAuthorityOperate
{
    self.isPublic = !self.isPublic;
    if (self.isPublic) {
        [_cutGroupAuthorityBtn setTitle:@"公开群" forState:UIControlStateNormal];
        //self.navigationItem.rightBarButtonItem.title = @"公开群";
    } else {
        [_cutGroupAuthorityBtn setTitle:@"私有群" forState:UIControlStateNormal];
        //self.navigationItem.rightBarButtonItem.title = @"私有群";
    }
    [self.tableView reloadData];
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
            make.top.equalTo(self.participantView.mas_bottom);
            make.left.equalTo(self.view);
            make.right.equalTo(self.view);
            make.bottom.equalTo(self.view);
        }];
    }
}

#pragma mark - Private

- (void)_sortAllGroups:(NSArray *)aGroupList
{
    
    NSMutableArray *groupList = [[NSMutableArray alloc]init];
    for (EMGroup *group in aGroupList) {
        [groupList addObject:group];
    }
    [self.sectionTitles removeAllObjects];
    
    //建立索引的核心, 返回27，是a－z和＃
    UILocalizedIndexedCollation *indexCollation = [UILocalizedIndexedCollation currentCollation];
    [self.sectionTitles addObjectsFromArray:[indexCollation sectionTitles]];
    
    NSInteger highSection = [self.sectionTitles count];
    NSMutableArray *sortedArray = [NSMutableArray arrayWithCapacity:highSection];
    for (int i = 0; i < highSection; i++) {
        NSMutableArray *sectionArray = [NSMutableArray arrayWithCapacity:1];
        [sortedArray addObject:sectionArray];
    }
    
    //按group-subject首字母分组
    for (EMGroup *group in groupList) {
        NSString *firstLetter = [EMChineseToPinyin pinyinFromChineseString:group.groupName];
        NSInteger section;
        if (firstLetter.length > 0) {
            section = [indexCollation sectionForObject:[firstLetter substringToIndex:1] collationStringSelector:@selector(uppercaseString)];
        } else {
            section = [sortedArray count] - 1;
        }
        
        NSMutableArray *array = [sortedArray objectAtIndex:section];
        [array addObject:group];
        sortedArray[section] = array;
    }
    
    //每个section内的数组排序
    for (int i = 0; i < [sortedArray count]; i++) {
        NSArray *array = [[sortedArray objectAtIndex:i] sortedArrayUsingComparator:^NSComparisonResult(EMGroup *group1, EMGroup *group2) {
            NSString *firstLetter1 = [EMChineseToPinyin pinyinFromChineseString:group1.groupName];
            firstLetter1 = [[firstLetter1 substringToIndex:1] uppercaseString];
            
            NSString *firstLetter2 = [EMChineseToPinyin pinyinFromChineseString:group2.groupName];
            firstLetter2 = [[firstLetter2 substringToIndex:1] uppercaseString];
            
            return [firstLetter1 caseInsensitiveCompare:firstLetter2];
        }];
        
        [sortedArray replaceObjectAtIndex:i withObject:[NSMutableArray arrayWithArray:array]];
    }
    
    //去掉空的section
    for (NSInteger i = [sortedArray count] - 1; i >= 0; i--) {
        NSArray *array = [sortedArray objectAtIndex:i];
        if ([array count] == 0) {
            [sortedArray removeObjectAtIndex:i];
            [self.sectionTitles removeObjectAtIndex:i];
        }
    }
    
    if(!self.isSearching){
        [self.dataArray removeAllObjects];
        [self.dataArray addObjectsFromArray:sortedArray];
    }else{
        [self.searchResults removeAllObjects];
        [self.searchResults addObjectsFromArray:sortedArray];
    }
    
}

#pragma mark - Table view data source

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return self.tempSectionTitles;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    NSInteger count = 0;
    NSArray *data = [[NSArray alloc]init];
    if (tableView == self.tableView) {
        data = [self _getSpecificGroupCount:self.dataArray];
        count = [data count];
    } else {
        data = [self _getSpecificGroupCount:self.searchResults];
        count = [data count];
    }
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tableView) {
        return [(NSArray *)(self.tempArray[section]) count];
    } else {
        return [(NSArray *)(self.tempSearchResults[section]) count];
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
        group = self.tempArray[(indexPath.section)][indexPath.row];
        [self.currentSearchGroupArray addObject:group];
    } else {
        group = self.tempSearchResults[(indexPath.section)][indexPath.row];
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
    return 20;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = kColor_LightGray;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, tableView.frame.size.width - 20, 20)];
    label.backgroundColor = kColor_LightGray;
    label.font = [UIFont systemFontOfSize:15];
    
    NSString *title = self.tempSectionTitles[section];
    label.text = [NSString stringWithFormat:@"  %@", title];
    [view addSubview:label];
    
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.view endEditing:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    EMGroup *group = nil;
    if (tableView == self.tableView) {
        group = self.tempArray[(indexPath.section)][indexPath.row];
    } else {
        group = self.tempSearchResults[(indexPath.section)][indexPath.row];
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
    [[EMRealtimeSearch shared] realtimeSearchWithSource:self.currentSearchGroupArray searchText:aString collationStringSelector:@selector(subject) resultBlock:^(NSArray *results) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself.searchResults removeAllObjects];
            [weakself.searchResults addObjectsFromArray:results];
            [weakself _sortAllGroups:weakself.searchResults];
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
    [self _sortAllGroups:self.dataArray];
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
    for (NSArray *groupArray in self.dataArray) {
        for (EMGroup *group in groupArray) {
            if ([group.groupId isEqualToString:groupId]) {
                [self.tableView reloadData];
            }
        }
    }
}

#pragma mark - data

//返回特定类型的群组
- (NSMutableArray *)_getSpecificGroupCount:(NSMutableArray *)data
{
    [self.tempSectionTitles removeAllObjects];
    if ([data count] <= 0) {
        return nil;
    }
    for (NSArray<NSString *> *str in self.sectionTitles) {
        [self.tempSectionTitles addObject:str];
    }
    if (!self.isSearching) {
        [self.currentSearchGroupArray removeAllObjects];
    }
    [self.tempArray removeAllObjects];
    [self.tempSearchResults removeAllObjects];
    NSMutableArray *arrayTemp = [[NSMutableArray alloc]init];
    NSMutableArray *arraySpecial = [[NSMutableArray alloc]initWithCapacity:[data count]];
    for (int i = 0; i < [data count]; i++) {
        for (EMGroup *group in data[i]) {
            if (group.isPublic == self.isPublic) {
                if (self.type == 2 && [group.owner isEqualToString:EMClient.sharedClient.currentUsername]) {
                    [arrayTemp addObject:group];
                } else if (self.type == 1 && ![group.owner isEqualToString:EMClient.sharedClient.currentUsername]) {
                    [arrayTemp addObject:group];
                }
            }
        }
        arraySpecial[i] = [[NSMutableArray alloc]init];
        for (EMGroup *group in arrayTemp) {
            [arraySpecial[i] addObject:group];
        }
        [arrayTemp removeAllObjects];
    }

    //去掉空的section
    NSInteger count = [arraySpecial count] - 1;
    for (NSInteger i = count; i > -1; --i) {
        NSArray *array = [arraySpecial objectAtIndex:i];
        if ([array count] == 0) {
            [arraySpecial removeObjectAtIndex:i];
            [self.tempSectionTitles removeObjectAtIndex:i];
        }
    }
    if(self.isSearching){
        self.tempSearchResults = arraySpecial;
    }else{
        self.tempArray = arraySpecial;
    }
    return arraySpecial;
}

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
            [weakself _sortAllGroups:weakself.dataArray];
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
    [self _sortAllGroups:self.dataArray];
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
        [weakself.navigationController pushViewController:createController animated:NO];
    }];
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self.inviteController];
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)_joinGroupAction
{
    EMJoinGroupViewController *controller = [[EMJoinGroupViewController alloc] init];
    [self.navigationController pushViewController:controller animated:NO];
}

- (NSMutableArray *)tempArray
{
    if(_tempArray == nil){
        _tempArray = [[NSMutableArray alloc]init];
    }
    return _tempArray;
}

- (NSMutableArray *)tempSearchResults
{
    if(_tempSearchResults == nil){
        _tempSearchResults = [[NSMutableArray alloc]init];
    }
    return _tempSearchResults;
}

- (NSMutableArray *)tempSectionTitles
{
    if(_tempSectionTitles == nil){
        _tempSectionTitles = [[NSMutableArray alloc]init];
    }
    return _tempSectionTitles;
}

- (NSMutableArray *)currentSearchGroupArray
{
    if(_currentSearchGroupArray == nil){
        _currentSearchGroupArray = [[NSMutableArray alloc]init];
    }
    return _currentSearchGroupArray;
}

@end
