//
//  EMContactsViewController.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/9.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EMContactsViewController.h"

#import "Masonry.h"

#import "EMImageTextCell.h"

@interface EMContactsViewController ()

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
    [[UITableViewHeaderFooterView appearance] setTintColor:[UIColor colorWithRed:245 / 255.0 green:245 / 255.0 blue:245 / 255.0 alpha:1.0]];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
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
    
    UIButton *searchButton = [[UIButton alloc] init];
    searchButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    searchButton.backgroundColor = [UIColor colorWithRed:245 / 255.0 green:245 / 255.0 blue:245 / 255.0 alpha:1.0];
    searchButton.titleLabel.font = [UIFont systemFontOfSize:15];
    searchButton.layer.cornerRadius = 8;
    searchButton.imageEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 0);
    searchButton.titleEdgeInsets = UIEdgeInsetsMake(0, 18, 0, 0);
    [searchButton setTitle:@"搜索" forState:UIControlStateNormal];
    [searchButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [searchButton setImage:[UIImage imageNamed:@"search_gray"] forState:UIControlStateNormal];
    [searchButton addTarget:self action:@selector(searchButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:searchButton];
    [searchButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.mas_bottom).offset(10);
        make.left.equalTo(self.view).offset(15);
        make.right.equalTo(self.view).offset(-15);
        make.height.equalTo(@35);
    }];
    
    self.tableView.rowHeight = 50;
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(searchButton.mas_bottom).offset(15);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
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
    NSString *CellIdentifier = @"EMImageTextCell";
    EMImageTextCell *cell = (EMImageTextCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[EMImageTextCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (section == 0) {
        if (row == 0) {
            cell.avatarView.image = [UIImage imageNamed:@""];
            cell.nameLabel.text = @"添加好友";
        } else if (row == 1) {
            cell.avatarView.image = [UIImage imageNamed:@""];
            cell.nameLabel.text = @"申请通知";
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
    view.backgroundColor = [UIColor colorWithRed:245 / 255.0 green:245 / 255.0 blue:245 / 255.0 alpha:1.0];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, tableView.frame.size.width - 20, 20)];
    label.backgroundColor = [UIColor colorWithRed:245 / 255.0 green:245 / 255.0 blue:245 / 255.0 alpha:1.0];
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
    
//    NSInteger section = indexPath.section;
//    NSInteger row = indexPath.row;
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
}

//- (nullable UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return [self setupCellEditActions:indexPath];
//}
//
//- (nullable NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return [self setupCellEditActions:indexPath];
//}

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

#pragma mark - Action

- (void)searchButtonAction
{
    
}

@end
