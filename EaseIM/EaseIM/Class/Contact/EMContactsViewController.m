//
//  EMContactsViewController.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/9.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EMContactsViewController.h"

#import "EMRealtimeSearch.h"
#import "EMChineseToPinyin.h"

#import "EMAvatarNameCell.h"
#import "UIViewController+Search.h"
#import "EMInviteFriendViewController.h"
#import "PellTableViewSelect.h"
#import "EMJoinGroupViewController.h"

@interface EMContactsViewController ()<EMMultiDevicesDelegate, EMContactManagerDelegate, EMSearchControllerDelegate>

@property (nonatomic, strong) NSMutableArray *allContacts;
@property (nonatomic, strong) NSMutableArray *sectionTitles;

@property (nonatomic, strong) EMAvatarNameCell *notifCell;
@property (nonatomic, strong) UILabel *notifBadgeLabel;

@property (nonatomic, strong) UIButton *addImageBtn;

@end

@implementation EMContactsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.allContacts = [[NSMutableArray alloc] init];
    self.sectionTitles = [[NSMutableArray alloc] init];
    
    [self _setupSubviews];
    
    [self _fetchContactsFromServerWithIsShowHUD:YES];
    
    [[EMClient sharedClient] addMultiDevicesDelegate:self delegateQueue:nil];
    [[EMClient sharedClient].contactManager addDelegate:self delegateQueue:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_loadAllContactsFromDB) name:CONTACT_BLACKLIST_UPDATE object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.navigationController.navigationBarHidden = NO;
}

- (void)dealloc
{
    [[EMClient sharedClient] removeMultiDevicesDelegate:self];
    [[EMClient sharedClient].contactManager removeDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Subviews

- (void)_setupSubviews
{
    self.view.backgroundColor = [UIColor whiteColor];
    self.showRefreshHeader = YES;
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"通讯录";
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.font = [UIFont systemFontOfSize:18];
    [self.view addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view).offset(EMVIEWTOPMARGIN + 35);
        make.height.equalTo(@25);
    }];
    
    self.addImageBtn = [[UIButton alloc]init];
    [self.addImageBtn setImage:[UIImage imageNamed:@"icon-add"] forState:UIControlStateNormal];
    [self.addImageBtn addTarget:self action:@selector(addAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.addImageBtn];
    [self.addImageBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@35);
        make.centerY.equalTo(titleLabel);
        make.right.equalTo(self.view).offset(-24);
    }];
    
    [self enableSearchController];
    [self.searchButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.mas_bottom).offset(15);
        make.left.equalTo(self.view).offset(15);
        make.right.equalTo(self.view).offset(-15);
        make.height.equalTo(@35);
    }];
    
    self.tableView.rowHeight = 74;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 20)];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.searchButton.mas_bottom).offset(15);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    
    [self _setupSearchResultController];
}

- (void)_setupSearchResultController
{
    __weak typeof(self) weakself = self;
    self.resultController.tableView.rowHeight = 60;
    [self.resultController setCellForRowAtIndexPathCompletion:^UITableViewCell *(UITableView *tableView, NSIndexPath *indexPath) {
        NSString *CellIdentifier = @"EMAvatarNameCell";
        EMAvatarNameCell *cell = (EMAvatarNameCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[EMAvatarNameCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        NSInteger row = indexPath.row;
        NSString *contact = weakself.resultController.dataArray[row];
        cell.avatarView.image = [UIImage imageNamed:@"defaultAvatar"];
        cell.nameLabel.text = contact;
        return cell;
    }];
    [self.resultController setCanEditRowAtIndexPath:^BOOL(UITableView *tableView, NSIndexPath *indexPath) {
        return YES;
    }];
    [self.resultController setCommitEditingAtIndexPath:^(UITableView *tableView, UITableViewCellEditingStyle editingStyle, NSIndexPath *indexPath) {
        if (editingStyle == UITableViewCellEditingStyleDelete) {
            NSInteger row = indexPath.row;
            NSString *contact = weakself.resultController.dataArray[row];
            [weakself.resultController showHudInView:weakself.resultController.view hint:@"删除好友..."];
            [weakself _deleteContact:contact completion:^(EMError *aError) {
                [weakself.resultController hideHud];
                /*
                if (!aError) {
                    [weakself.resultController.dataArray removeObjectAtIndex:row];
                    [weakself.resultController.tableView reloadData];
                    
                    //更新联系人页面
                    for (NSMutableArray *array in weakself.dataArray) {
                        if ([array containsObject:contact]) {
                            [array removeObject:contact];
                            if ([array count] == 0) {
                                [weakself.dataArray removeObject:array];
                            }
                            [weakself.tableView reloadData];
                            break;
                        }
                    }
                }*/
            }];
        }
    }];
    [self.resultController setDidSelectRowAtIndexPathCompletion:^(UITableView *tableView, NSIndexPath *indexPath) {
        NSInteger row = indexPath.row;
        NSString *contact = weakself.resultController.dataArray[row];
        
        weakself.resultController.searchBar.text = @"";
        [weakself.resultController.searchBar resignFirstResponder];
        weakself.resultController.searchBar.showsCancelButton = NO;
        [weakself searchBarCancelButtonAction:nil];
        [weakself.resultNavigationController dismissViewControllerAnimated:NO completion:nil];
        
        //[weakself personalData:contact];
        [[NSNotificationCenter defaultCenter] postNotificationName:CHAT_PUSHVIEWCONTROLLER object:contact];
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [self.dataArray count] + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0) {
        return 3;
    }
    
    return [(NSArray *)(self.dataArray[section - 1]) count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    NSString *cellIdentifier = @"EMAvatarNameCell";
    EMAvatarNameCell *cell = (EMAvatarNameCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[EMAvatarNameCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }

    if (section == 0) {
        if (row == 0) {
            cell.avatarView.image = [UIImage imageNamed:@"newFriend"];
            cell.nameLabel.text = @"新的好友";
        } else if (row == 1) {
            cell.avatarView.image = [UIImage imageNamed:@"groupchat"];
            cell.nameLabel.text = @"群聊";
        } else if (row == 2) {
            cell.avatarView.image = [UIImage imageNamed:@"chatroom"];
            cell.nameLabel.text = @"聊天室";
        }
    } else {
        NSString *contact = self.dataArray[section - 1][row];
        cell.avatarView.image = [UIImage imageNamed:@"defaultAvatar"];
        cell.nameLabel.text = contact;
    }
    [cell setSeparatorInset:UIEdgeInsetsMake(0, cell.avatarView.frame.size.height + 23, 0, 1)];
    return cell;
}

#pragma mark - Table view delegate

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return self.sectionTitles;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0;
    } else {
        return 20;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return nil;
    }
    
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = kColor_LightGray;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, tableView.frame.size.width - 20, 20)];
    label.backgroundColor = kColor_LightGray;
    label.font = [UIFont systemFontOfSize:15];
    
    NSString *title = self.sectionTitles[section - 1];
    label.text = [NSString stringWithFormat:@"  %@", title];
    [view addSubview:label];
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (section == 0) {
        if (row == 0) {
            EMInviteFriendViewController *controller = [[EMInviteFriendViewController alloc] init];
            [self.navigationController pushViewController:controller animated:NO];
        } else if (row == 1) {
            [[NSNotificationCenter defaultCenter] postNotificationName:GROUP_LIST_PUSHVIEWCONTROLLER object:@{NOTIF_NAVICONTROLLER:self.navigationController}];
        } else if (row == 2) {
            [[NSNotificationCenter defaultCenter] postNotificationName:CHATROOM_LIST_PUSHVIEWCONTROLLER object:@{NOTIF_NAVICONTROLLER:self.navigationController}];
        }
    } else {
        NSString *contact = self.dataArray[section - 1][row];
        //[self personalData:contact];
        [[NSNotificationCenter defaultCenter] postNotificationName:CHAT_PUSHVIEWCONTROLLER object:contact];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    if (indexPath.section == 0) {
        return NO;
    }
    
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //在iOS8.0上，必须加上这个方法才能出发左划操作
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSInteger section = indexPath.section - 1;
        NSString *contact = self.dataArray[section][indexPath.row];
        [self showHudInView:self.view hint:@"删除好友..."];
        [self _deleteContact:contact completion:^(EMError *aError) {
            if (!aError) {
                
            }
        }];
    }
}

#pragma mark - EMMultiDevicesDelegate

- (void)multiDevicesContactEventDidReceive:(EMMultiDevicesEvent)aEvent
                                  username:(NSString *)aTarget
                                       ext:(NSString *)aExt
{
    switch (aEvent) {
        case EMMultiDevicesEventContactRemove:
        case EMMultiDevicesEventContactAccept:
        case EMMultiDevicesEventContactBan:
        case EMMultiDevicesEventContactAllow:
            [self _loadAllContactsFromDB];
            break;
            
        default:
            break;
    }
}

#pragma mark - EMContactManagerDelegate

- (void)friendshipDidAddByUser:(NSString *)aUsername
{
    [self _loadAllContactsFromDB];
}

- (void)friendshipDidRemoveByUser:(NSString *)aUsername
{
    [self _loadAllContactsFromDB];
}

#pragma mark - EMSearchControllerDelegate

- (void)searchBarWillBeginEditing:(UISearchBar *)searchBar
{
    self.resultController.searchKeyword = nil;
    [self.tableView reloadData];
}

- (void)searchBarCancelButtonAction:(UISearchBar *)searchBar
{
    [[EMRealtimeSearch shared] realtimeSearchStop];
    
    [self.resultController.dataArray removeAllObjects];
    [self.resultController.tableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.view endEditing:YES];
}

- (void)searchTextDidChangeWithString:(NSString *)aString
{
    self.resultController.searchKeyword = aString;
    
    __weak typeof(self) weakself = self;
    [[EMRealtimeSearch shared] realtimeSearchWithSource:self.allContacts searchText:aString collationStringSelector:nil resultBlock:^(NSArray *results) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself.resultController.dataArray removeAllObjects];
            [weakself.resultController.dataArray addObjectsFromArray:results];
            [weakself.resultController.tableView reloadData];
        });
    }];
}

#pragma mark - Private

- (void)_sortAllContacts:(NSArray *)aContactList
{
    [self.dataArray removeAllObjects];
    [self.sectionTitles removeAllObjects];
    
    NSMutableArray *contactArray = [NSMutableArray array];
    //从获取的数据中剔除黑名单中的好友
    NSArray *blackList = [[EMClient sharedClient].contactManager getBlackList];
    for (NSString *contact in aContactList) {
        if (![blackList containsObject:contact]) {
            [contactArray addObject:contact];
        }
    }
    
    //建立索引的核心, 返回27，是a－z和＃
    UILocalizedIndexedCollation *indexCollation = [UILocalizedIndexedCollation currentCollation];
    [self.sectionTitles addObjectsFromArray:[indexCollation sectionTitles]];
    
    NSInteger highSection = [self.sectionTitles count];
    NSMutableArray *sortedArray = [NSMutableArray arrayWithCapacity:highSection];
    for (int i = 0; i < highSection; i++) {
        NSMutableArray *sectionArray = [NSMutableArray arrayWithCapacity:1];
        [sortedArray addObject:sectionArray];
    }
    
    //按首字母分组
    for (NSString *contact in contactArray) {
        NSString *firstLetter = [EMChineseToPinyin pinyinFromChineseString:contact];
        NSInteger section;
        if (firstLetter.length > 0) {
            section = [indexCollation sectionForObject:[firstLetter substringToIndex:1] collationStringSelector:@selector(uppercaseString)];
        } else {
            section = [sortedArray count] - 1;
        }
        
        NSMutableArray *array = [sortedArray objectAtIndex:section];
        [array addObject:contact];
    }
    
    //每个section内的数组排序
    for (int i = 0; i < [sortedArray count]; i++) {
        NSArray *array = [[sortedArray objectAtIndex:i] sortedArrayUsingComparator:^NSComparisonResult(NSString *contact1, NSString *contact2) {
            NSString *firstLetter1 = [EMChineseToPinyin pinyinFromChineseString:contact1];
            firstLetter1 = [[firstLetter1 substringToIndex:1] uppercaseString];
            
            NSString *firstLetter2 = [EMChineseToPinyin pinyinFromChineseString:contact2];
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
    
    [self.dataArray addObjectsFromArray:sortedArray];
}

- (void)_deleteContact:(NSString *)aContact
            completion:(void (^)(EMError *aError))aCompletion
{
    __weak typeof(self) weakself = self;
    [[EMClient sharedClient].contactManager deleteContact:aContact
                                     isDeleteConversation:YES
                                               completion:^(NSString *aUsername, EMError *aError) {
        [weakself hideHud];
        if (aError) {
            [EMAlertController showErrorAlert:@"删除好友失败"];
        } else {
            [EMAlertController showSuccessAlert:[NSString stringWithFormat:@"您已删除好友%@", aContact]];
            [weakself.allContacts removeObject:aContact];
        }
        
        if (aCompletion) {
            aCompletion(aError);
        }
    }];
}

#pragma mark - Data

- (void)_loadAllContactsFromDB
{
    [self.allContacts removeAllObjects];
    [self.dataArray removeAllObjects];
    
    NSArray *contactList = [[EMClient sharedClient].contactManager getContacts];
    [self.allContacts addObjectsFromArray:contactList];
    [self _sortAllContacts:self.allContacts];
    
    [self.tableView reloadData];
}

- (void)_fetchContactsFromServerWithIsShowHUD:(BOOL)aIsShowHUD
{
    if (aIsShowHUD) {
        [self showHudInView:self.view hint:@"获取好友..."];
    }
    __weak typeof(self) weakself = self;
    [[EMClient sharedClient].contactManager getContactsFromServerWithCompletion:^(NSArray *aContactsList, EMError *aContactsError) {
        if (!aContactsError) {
            [weakself.allContacts removeAllObjects];
            [weakself.allContacts addObjectsFromArray:aContactsList];
        }
        
        [[EMClient sharedClient].contactManager getBlackListFromServerWithCompletion:^(NSArray *aBlackList, EMError *aError) {
            if (aIsShowHUD) {
                [weakself hideHud];
            }
            
            if (!aError) {
                [weakself _sortAllContacts:weakself.allContacts];
            }
            [weakself tableViewDidFinishTriggerHeader:YES reload:NO];
            [weakself.tableView reloadData];
        }];
    }];
}

#pragma mark - moreAction
- (void)addAction
{
    [PellTableViewSelect addPellTableViewSelectWithWindowFrame:CGRectMake(self.view.bounds.size.width-100, self.addImageBtn.frame.origin.y, 110, 104) selectData:@[@"找人",@"找群"] images:@[@"icon-添加好友",@"icon-加群"] locationY:30 - (22 - EMVIEWTOPMARGIN) action:^(NSInteger index) {
        if(index == 0) {
            [self lookForSomeOne];
        } else if (index == 1) {
            [self findGroup];
        }
    } animated:YES];
}

//找人
- (void)lookForSomeOne
{
    EMInviteFriendViewController *controller = [[EMInviteFriendViewController alloc] init];
    [self.navigationController pushViewController:controller animated:NO];
}

//找群
- (void)findGroup
{
    EMJoinGroupViewController *controller = [[EMJoinGroupViewController alloc] init];
    [self.navigationController pushViewController:controller animated:NO];
}

- (void)tableViewDidTriggerHeaderRefresh
{
    [self _fetchContactsFromServerWithIsShowHUD:NO];
}

@end
