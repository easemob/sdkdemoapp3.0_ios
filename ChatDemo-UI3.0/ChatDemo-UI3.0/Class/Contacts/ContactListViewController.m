//
//  ContactListViewController.m
//  ChatDemo-UI3.0
//
//  Created by dhc on 15/6/24.
//  Copyright (c) 2015年 easemob.com. All rights reserved.
//

#import "ContactListViewController.h"

#import <EaseUI/ChineseToPinyin.h>
//#import "ChineseToPinyin.h"
#import "ChatViewController.h"
#import <EaseUI/UIViewController+HUD.h>

@interface ContactListViewController ()

@property(strong, nonatomic) NSMutableArray *sectionTitles;

@end

@implementation ContactListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.showRefreshHeader = YES;
    
    _sectionTitles = [NSMutableArray array];
    
    [self tableViewDidTriggerHeaderRefresh];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - getter

- (NSArray *)rightItems
{
    if (_rightItems == nil) {
        UIButton *addButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        [addButton setImage:[UIImage imageNamed:@"addContact.png"] forState:UIControlStateNormal];
        [addButton addTarget:self action:@selector(addContactAction) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithCustomView:addButton];
        _rightItems = @[addItem];
    }
    
    return _rightItems;
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
    
    return [[self.dataArray objectAtIndex:(section - 1)] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [EMUserCell cellIdentifierWithModel:nil];
    EMUserCell *cell = (EMUserCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[EMUserCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if (indexPath.section == 0) {
        cell.model = nil;
        if (indexPath.row == 0) {
            cell.avatarView.image = [UIImage imageNamed:@"apply"];
            cell.titleLabel.text = NSLocalizedString(@"title.apply", @"Application and notification");
        }
        else if (indexPath.row == 1) {
            cell.avatarView.image = [UIImage imageNamed:@"EaseUIResource.bundle/group"];
            cell.titleLabel.text = NSLocalizedString(@"title.group", @"Group");
        }
        else if (indexPath.row == 2) {
            cell.avatarView.image = [UIImage imageNamed:@"EaseUIResource.bundle/group"];
            cell.titleLabel.text = NSLocalizedString(@"title.chatroomlist",@"chatroom list");
        }
    }
    else{
        NSArray *userSection = [self.dataArray objectAtIndex:(indexPath.section - 1)];
        EMUserModel *model = [userSection objectAtIndex:indexPath.row];
        cell.model = model;
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
    if (section == 0)
    {
        return 0;
    }
    else{
        return 22;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return nil;
    }
    
    UIView *contentView = [[UIView alloc] init];
    [contentView setBackgroundColor:[UIColor colorWithRed:0.88 green:0.88 blue:0.88 alpha:1.0]];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 100, 22)];
    label.backgroundColor = [UIColor clearColor];
    [label setText:[self.sectionTitles objectAtIndex:(section - 1)]];
    [contentView addSubview:label];
    return contentView;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (section == 0) {
        if (row == 0) {
//            [self.navigationController pushViewController:[ApplyViewController shareController] animated:YES];
        }
        else if (row == 1)
        {
//            if (_groupController == nil) {
//                _groupController = [[GroupListViewController alloc] initWithStyle:UITableViewStylePlain];
//            }
//            else{
//                [_groupController reloadDataSource];
//            }
//            [self.navigationController pushViewController:_groupController animated:YES];
        }
        else if (row == 2)
        {
//            ChatroomListViewController *controller = [[ChatroomListViewController alloc] initWithStyle:UITableViewStylePlain];
//            [self.navigationController pushViewController:controller animated:YES];
        }
    }
    else{
        EMUserModel *model = [[self.dataArray objectAtIndex:(section - 1)] objectAtIndex:row];
        ChatViewController *chatController = [[ChatViewController alloc] initWithConversationChatter:model.buddy.username conversationType:eConversationTypeChat];
        chatController.title = model.buddy.username;
        [self.navigationController pushViewController:chatController animated:YES];
    }
}

#pragma mark - action

- (void)addContactAction
{
//    AddFriendViewController *addController = [[AddFriendViewController alloc] initWithStyle:UITableViewStylePlain];
//    [self.navigationController pushViewController:addController animated:YES];
}

#pragma mark - private data

- (void)_reloadWithData:(NSArray *)buddyList
{
    [self.dataArray removeAllObjects];
    [self.sectionTitles removeAllObjects];
    NSMutableArray *contactsSource = [NSMutableArray array];
    
    //从获取的数据中剔除黑名单中的好友
    NSArray *blockList = [[EaseMob sharedInstance].chatManager blockedList];
    for (EMBuddy *buddy in buddyList) {
        if (![blockList containsObject:buddy.username]) {
            [contactsSource addObject:buddy];
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
    for (EMBuddy *buddy in contactsSource) {
        EMUserModel *model = [[EMUserModel alloc] initWithBuddy:buddy];
        if (model) {
            model.avatarImage = [UIImage imageNamed:@"EaseUIResource.bundle/user"];
            model.nickname = buddy.username;
            
            NSString *firstLetter = [ChineseToPinyin pinyinFromChineseString:buddy.username];
            NSInteger section = [indexCollation sectionForObject:[firstLetter substringToIndex:1] collationStringSelector:@selector(uppercaseString)];
            
            NSMutableArray *array = [sortedArray objectAtIndex:section];
            [array addObject:model];
        }
    }
    
    //每个section内的数组排序
    for (int i = 0; i < [sortedArray count]; i++) {
        NSArray *array = [[sortedArray objectAtIndex:i] sortedArrayUsingComparator:^NSComparisonResult(EMUserModel *obj1, EMUserModel *obj2) {
            NSString *firstLetter1 = [ChineseToPinyin pinyinFromChineseString:obj1.buddy.username];
            firstLetter1 = [[firstLetter1 substringToIndex:1] uppercaseString];
            
            NSString *firstLetter2 = [ChineseToPinyin pinyinFromChineseString:obj2.buddy.username];
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
    [self.tableView reloadData];
}

#pragma mark - data

- (void)tableViewDidTriggerHeaderRefresh
{
    [self showHudInView:self.view hint:NSLocalizedString(@"loadData", @"Load data...")];
    __weak ContactListViewController *weakSelf = self;
    [[[EaseMob sharedInstance] chatManager] asyncFetchBuddyListWithCompletion:^(NSArray *buddyList, EMError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf hideHud];
            if (error == nil) {
                [weakSelf _reloadWithData:buddyList];
            }
            else{
                [weakSelf showHint:NSLocalizedString(@"loadDataFailed", @"Load data failed.")];
            }
            
            [weakSelf tableViewDidFinishTriggerHeader:YES reload:YES];
        });
    } onQueue:nil];
}

@end
