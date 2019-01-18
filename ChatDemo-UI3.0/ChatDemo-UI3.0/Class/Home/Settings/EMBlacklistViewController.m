//
//  EMBlacklistViewController.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2018/12/27.
//  Copyright © 2018 XieYajie. All rights reserved.
//

#import "EMBlacklistViewController.h"

@interface EMBlacklistViewController ()

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (strong, nonatomic) NSMutableArray *sectionTitles;

@end

@implementation EMBlacklistViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    self.dataArray = [[NSMutableArray alloc] init];
    self.sectionTitles = [[NSMutableArray alloc] init];
    
    [self _setupSubviews];
    [self _headerRefreshAction];
}

#pragma mark - Subviews

- (void)_setupSubviews
{
    [self addPopBackLeftItem];
    self.title = @"黑名单";
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.tableView.rowHeight = 60;
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(_headerRefreshAction) forControlEvents:UIControlEventValueChanged];
    self.tableView.refreshControl = refreshControl;
}

- (id)_setupCellEditActions:(NSIndexPath *)aIndexPath
{
    if ([UIDevice currentDevice].systemVersion.floatValue < 11.0) {
        UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"移除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
            [self deleteCellAction:indexPath];
        }];
        deleteAction.backgroundColor = [UIColor redColor];
        return @[deleteAction];
    } else {
        UIContextualAction *deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"移除" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
            [self deleteCellAction:aIndexPath];
        }];
        deleteAction.backgroundColor = [UIColor redColor];
        
        UISwipeActionsConfiguration *config = [UISwipeActionsConfiguration configurationWithActions:@[deleteAction]];
        config.performsFirstActionWithFullSwipe = NO;
        return config;
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.dataArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataArray[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
    }
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    cell.imageView.image = [UIImage imageNamed:@"user_1"];
    cell.textLabel.text = [self.dataArray[section] objectAtIndex:row];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //在iOS8.0上，必须加上这个方法才能出发左划操作
}

- (nullable UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self _setupCellEditActions:indexPath];
}

- (nullable NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self _setupCellEditActions:indexPath];
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ([self.dataArray[section] count] == 0) {
        return 0;
    } else {
        return 25;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if ([self.dataArray[section] count] == 0) {
        return nil;
    }
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 25)];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:15];
    label.text = [NSString stringWithFormat:@"    %@", self.sectionTitles[section]];
    return label;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    NSMutableArray *existTitles = [NSMutableArray array];
    //section数组为空的title过滤掉，不显示
    for (int i = 0; i < [self.sectionTitles count]; i++) {
        if ([self.dataArray[i] count] > 0) {
            [existTitles addObject:[self.sectionTitles objectAtIndex:i]];
        }
    }
    return existTitles;
}

#pragma mark - Data

- (NSArray *)_sortDataArray:(NSArray *)dataArray
{
    //建立索引的核心
    UILocalizedIndexedCollation *indexCollation = [UILocalizedIndexedCollation currentCollation];
    
    [self.sectionTitles removeAllObjects];
    [self.sectionTitles addObjectsFromArray:[indexCollation sectionTitles]];
    
    //返回27，是a－z和＃
    NSInteger highSection = [self.sectionTitles count];
    //tableView 会被分成27个section
    NSMutableArray *sortedArray = [NSMutableArray arrayWithCapacity:highSection];
    for (int i = 0; i <= highSection; i++) {
        NSMutableArray *sectionArray = [NSMutableArray arrayWithCapacity:1];
        [sortedArray addObject:sectionArray];
    }
    
    //名字分section
    for (NSString *username in dataArray) {
        //getUserName是实现中文拼音检索的核心，见NameIndex类
        NSString *firstLetter = [EaseChineseToPinyin pinyinFromChineseString:username];
        NSInteger section = [indexCollation sectionForObject:[firstLetter substringToIndex:1] collationStringSelector:@selector(uppercaseString)];
        
        NSMutableArray *array = [sortedArray objectAtIndex:section];
        [array addObject:username];
    }
    
    //每个section内的数组排序
    for (int i = 0; i < [sortedArray count]; i++) {
        NSArray *array = [[sortedArray objectAtIndex:i] sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
            NSString *firstLetter1 = [EaseChineseToPinyin pinyinFromChineseString:obj1];
            firstLetter1 = [[firstLetter1 substringToIndex:1] uppercaseString];
            
            NSString *firstLetter2 = [EaseChineseToPinyin pinyinFromChineseString:obj2];
            firstLetter2 = [[firstLetter2 substringToIndex:1] uppercaseString];
            
            return [firstLetter1 caseInsensitiveCompare:firstLetter2];
        }];
        
        
        [sortedArray replaceObjectAtIndex:i withObject:[NSMutableArray arrayWithArray:array]];
    }
    
    return sortedArray;
}

- (void)_headerRefreshAction
{
    __weak typeof(self) weakself = self;
    [[EMClient sharedClient].contactManager getBlackListFromServerWithCompletion:^(NSArray *aList, EMError *aError) {
        [weakself.refreshControl endRefreshing];
        if (!aError) {
            [weakself.dataArray removeAllObjects];
            [weakself.dataArray addObjectsFromArray:[weakself _sortDataArray:aList]];
            [weakself.tableView reloadData];
        }
    }];
}

#pragma mark - Action

- (void)deleteCellAction:(NSIndexPath *)aIndexPath
{
    NSString *username = [[self.dataArray objectAtIndex:aIndexPath.section] objectAtIndex:aIndexPath.row];
    EMError *error = [[EMClient sharedClient].contactManager removeUserFromBlackList:username];
    if (!error) {
//        [[ChatDemoHelper shareHelper].contactViewVC reloadDataSource];
        [self.dataArray[aIndexPath.section] removeObjectAtIndex:aIndexPath.row];
        [self.tableView reloadData];
    } else {
        [self showHint:error.errorDescription];
    }
}

@end
