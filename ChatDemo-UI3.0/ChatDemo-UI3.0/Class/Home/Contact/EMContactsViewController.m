//
//  EMContactsViewController.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/9.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EMContactsViewController.h"

#import "EMRealtimeSearch.h"
#import "DemoConfManager.h"

#import "EMAlertController.h"
#import "EMAvatarNameCell.h"
#import "UIViewController+Search.h"
#import "EMInviteFriendViewController.h"
#import "EMNotificationViewController.h"

#import "GroupListViewController.h"
#import "ChatroomListViewController.h"
#import "ChatViewController.h"

@interface EMContactsViewController ()<XHSearchControllerDelegate>

@property (strong, nonatomic) NSMutableArray *allContacts;
@property (strong, nonatomic) NSMutableArray *sectionTitles;

@end

@implementation EMContactsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.allContacts = [[NSMutableArray alloc] init];
    self.sectionTitles = [[NSMutableArray alloc] init];
    
    [self _setupSubviews];
    
    [self _loadAllContactsFromDB];
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

#pragma mark - Subviews

- (void)_setupSubviews
{
    [[UITableViewHeaderFooterView appearance] setTintColor:kColor_LightGray];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.showRefreshHeader = YES;
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"联系人";
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.font = [UIFont systemFontOfSize:28];
    [self.view addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(15);
        make.top.equalTo(self.view).offset(20);
        make.height.equalTo(@60);
    }];
    
    [self enableSearchController];
    
    self.tableView.rowHeight = 50;
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.searchButton.mas_bottom).offset(15);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    
    __weak typeof(self) weakself = self;
    self.resultController.tableView.rowHeight = 50;
    [self.resultController setCellForRowAtIndexPathCompletion:^UITableViewCell *(UITableView *tableView, NSIndexPath *indexPath) {
        NSString *CellIdentifier = @"EMAvatarNameCell";
        EMAvatarNameCell *cell = (EMAvatarNameCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[EMAvatarNameCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        NSInteger row = indexPath.row;
        NSString *contact = weakself.resultController.dataArray[row];
        cell.avatarView.image = [UIImage imageNamed:@"user_2"];
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
                }
            }];
        }
    }];
    [self.resultController setDidSelectRowAtIndexPathCompletion:^(UITableView *tableView, NSIndexPath *indexPath) {
        NSInteger row = indexPath.row;
        NSString *contact = weakself.resultController.dataArray[row];
        ChatViewController *chatController = [[ChatViewController alloc] initWithConversationChatter:contact conversationType:EMConversationTypeChat];
        [weakself.navigationController pushViewController:chatController animated:YES];
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
        return 5;
    }
    
    return [self.dataArray[section - 1] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"EMAvatarNameCell";
    EMAvatarNameCell *cell = (EMAvatarNameCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[EMAvatarNameCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (section == 0) {
        if (row == 0) {
            cell.avatarView.image = [UIImage imageNamed:@""];
            cell.nameLabel.text = @"添加好友";
        } else if (row == 1) {
            cell.avatarView.image = [UIImage imageNamed:@""];
            cell.nameLabel.text = @"申请与通知";
        } else if (row == 2) {
            cell.avatarView.image = [UIImage imageNamed:@""];
            cell.nameLabel.text = @"群组";
        } else if (row == 3) {
            cell.avatarView.image = [UIImage imageNamed:@""];
            cell.nameLabel.text = @"聊天室";
        } else if (row == 4) {
            cell.avatarView.image = [UIImage imageNamed:@""];
            cell.nameLabel.text = @"多人视频";
        }
    } else {
        NSString *contact = self.dataArray[section - 1][row];
        cell.avatarView.image = [UIImage imageNamed:@"user_2"];
        cell.nameLabel.text = contact;
    }
    
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
    if (section == [self.dataArray count]) {
        return 20;
    }
    
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
            EMInviteFriendViewController *controller = [[EMInviteFriendViewController alloc] initWithStyle:UITableViewStylePlain];
            [self.navigationController pushViewController:controller animated:YES];
        } else if (row == 1) {
            EMNotificationViewController *controller = [[EMNotificationViewController alloc] initWithStyle:UITableViewStylePlain];
            [self.navigationController pushViewController:controller animated:YES];
        } else if (row == 2) {
//            GroupListViewController *groupController = [[GroupListViewController alloc] initWithStyle:UITableViewStylePlain];
//            [self.navigationController pushViewController:groupController animated:YES];
        } else if (row == 3) {
//            ChatroomListViewController *controller = [[ChatroomListViewController alloc] initWithStyle:UITableViewStylePlain];
//            [self.navigationController pushViewController:controller animated:YES];
        } else if (row == 4) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"会议类型" message:nil preferredStyle:UIAlertControllerStyleActionSheet];

            UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"普通会议" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [[DemoConfManager sharedManager] inviteMemberWithConfType:EMConferenceTypeCommunication inviteType:ConfInviteTypeUser conversationId:nil chatType:EMChatTypeChat];
            }];
            [alertController addAction:defaultAction];

            UIAlertAction *mixAction = [UIAlertAction actionWithTitle:@"混音会议" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [[DemoConfManager sharedManager] inviteMemberWithConfType:EMConferenceTypeLargeCommunication inviteType:ConfInviteTypeUser conversationId:nil chatType:EMChatTypeChat];
            }];
            [alertController addAction:mixAction];

            [alertController addAction: [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"Cancel") style: UIAlertActionStyleCancel handler:nil]];

            [self presentViewController:alertController animated:YES completion:nil];
        }
    } else {
        NSString *contact = self.dataArray[section - 1][row];
        ChatViewController *chatController = [[ChatViewController alloc] initWithConversationChatter:contact conversationType:EMConversationTypeChat];
        [self.navigationController pushViewController:chatController animated:YES];
    }
    
//    if (section == 0) {
//        if (row == 0) {
//            [self.navigationController pushViewController:[ApplyViewController shareController] animated:YES];
//        }
//        else if (row == 1)
//        {
//            GroupListViewController *groupController = [[GroupListViewController alloc] initWithStyle:UITableViewStylePlain];
//            [self.navigationController pushViewController:groupController animated:YES];
//        }
//        else if (row == 2)
//        {
//            ChatroomListViewController *controller = [[ChatroomListViewController alloc] initWithStyle:UITableViewStylePlain];
//            [self.navigationController pushViewController:controller animated:YES];
//        }
//
//#if DEMO_CALL == 1
//        else if (row == 3) {
//            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"会议类型" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
//
//            UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"普通会议" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//                [[DemoConfManager sharedManager] inviteMemberWithConfType:EMConferenceTypeCommunication inviteType:ConfInviteTypeUser conversationId:nil chatType:EMChatTypeChat];
//            }];
//            [alertController addAction:defaultAction];
//
//            UIAlertAction *mixAction = [UIAlertAction actionWithTitle:@"混音会议" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//                [[DemoConfManager sharedManager] inviteMemberWithConfType:EMConferenceTypeLargeCommunication inviteType:ConfInviteTypeUser conversationId:nil chatType:EMChatTypeChat];
//            }];
//            [alertController addAction:mixAction];
//
//            [alertController addAction: [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"Cancel") style: UIAlertActionStyleCancel handler:nil]];
//
//            [self presentViewController:alertController animated:YES completion:nil];
//        }
//        else if (row == 4) {
//            //TODO: custom call
//        }
//#endif
//    } else if (section == 1) {
//        ChatViewController *chatController = [[ChatViewController alloc] initWithConversationChatter:[self.otherPlatformIds objectAtIndex:indexPath.row] conversationType:EMConversationTypeChat];
//        [self.navigationController pushViewController:chatController animated:YES];
//    }
//    else{
//        EaseUserModel *model = [[self.dataArray objectAtIndex:(section - 2)] objectAtIndex:row];
//        UIViewController *chatController = [[ChatViewController alloc] initWithConversationChatter:model.buddy conversationType:EMConversationTypeChat];
//        chatController.title = model.nickname.length > 0 ? model.nickname : model.buddy;
//        [self.navigationController pushViewController:chatController animated:YES];
//    }
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
        __weak typeof(self) weakself = self;
        [self showHudInView:self.view hint:@"删除好友..."];
        [self _deleteContact:contact completion:^(EMError *aError) {
            if (!aError) {
                NSMutableArray *array = weakself.dataArray[section];
                [array removeObjectAtIndex:indexPath.row];
                if ([array count] == 0) {
                    [weakself.dataArray removeObjectAtIndex:section];
                    [weakself.sectionTitles removeObjectAtIndex:section];
                }
                [weakself.tableView reloadData];
            }
        }];
    }
}

#pragma mark - XHSearchControllerDelegate

- (void)searchBarWillBeginEditing:(UISearchBar *)searchBar
{
    self.resultController.searchKeyword = nil;
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
        NSString *firstLetter = [EaseChineseToPinyin pinyinFromChineseString:contact];
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
            NSString *firstLetter1 = [EaseChineseToPinyin pinyinFromChineseString:contact1];
            firstLetter1 = [[firstLetter1 substringToIndex:1] uppercaseString];
            
            NSString *firstLetter2 = [EaseChineseToPinyin pinyinFromChineseString:contact2];
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
    [[EMClient sharedClient].contactManager deleteContact:aContact isDeleteConversation:NO completion:^(NSString *aUsername, EMError *aError) {
        [weakself hideHud];
        if (aError) {
            [EMAlertController showErrorAlert:@"删除好友失败"];
        } else {
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

- (void)tableViewDidTriggerHeaderRefresh
{
    __weak typeof(self) weakself = self;
    [[EMClient sharedClient].contactManager getContactsFromServerWithCompletion:^(NSArray *aContactsList, EMError *aContactsError) {
        if (!aContactsError) {
            [weakself.allContacts removeAllObjects];
            [weakself.allContacts addObjectsFromArray:aContactsList];
        }
        
        [[EMClient sharedClient].contactManager getBlackListFromServerWithCompletion:^(NSArray *aBlackList, EMError *aError) {
            if (!aError) {
                [weakself _sortAllContacts:weakself.allContacts];
            }
            [weakself tableViewDidFinishTriggerHeader:YES reload:NO];
            [weakself.tableView reloadData];
        }];
    }];
}

#pragma mark - Action

@end
