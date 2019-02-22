//
//  EMBlacklistViewController.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2018/12/27.
//  Copyright © 2018 XieYajie. All rights reserved.
//

#import "EMBlacklistViewController.h"

#import "EMChineseToPinyin.h"
#import "EMRealtimeSearch.h"

#import "EMAvatarNameCell.h"
#import "EMAddBlacklistViewController.h"

@interface EMBlacklistViewController ()<EMMultiDevicesDelegate, EMAvatarNameCellDelegate>

@property (nonatomic, strong) NSMutableArray *sectionTitles;
@property (nonatomic, strong) NSArray *blacklist;

@end

@implementation EMBlacklistViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    self.sectionTitles = [[NSMutableArray alloc] init];
    
    [self _setupSubviews];
    [self tableViewDidTriggerHeaderRefresh];
    
    [[EMClient sharedClient] addMultiDevicesDelegate:self delegateQueue:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleReloadBlacklist:) name:CONTACT_BLACKLIST_RELOAD object:nil];
}

- (void)dealloc
{
    [[EMClient sharedClient] removeMultiDevicesDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Subviews

- (void)_setupSubviews
{
    [self addPopBackLeftItem];
    self.title = @"黑名单";
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.showRefreshHeader = YES;
    self.tableView.rowHeight = 60;
    self.tableView.tableFooterView = [[UIView alloc] init];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == self.tableView) {
        return [self.dataArray count] + 1;
    } else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = 0;
    if (tableView == self.tableView) {
        if (section == 0) {
            count = 1;
        } else {
            count = [self.dataArray[section - 1] count];
        }
    } else {
        count = [self.searchResults count];
    }
    
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EMAvatarNameCell *cell = (EMAvatarNameCell *)[tableView dequeueReusableCellWithIdentifier:@"EMAvatarNameCell"];
    // Configure the cell...
    if (cell == nil) {
        cell = [[EMAvatarNameCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"EMAvatarNameCell"];
    }
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    cell.indexPath = indexPath;
    if (tableView == self.tableView) {
        if (section == 0) {
            cell.avatarView.image = [UIImage imageNamed:@"contact"];
            cell.nameLabel.text = @"添加至黑名单";
        } else {
            cell.avatarView.image = [UIImage imageNamed:@"user_avatar_gray"];
            cell.nameLabel.text = [self.dataArray[section - 1] objectAtIndex:row];
        }
    } else {
        cell.avatarView.image = [UIImage imageNamed:@"user_avatar_gray"];
        cell.nameLabel.text = [self.searchResults objectAtIndex:row];
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    if (tableView == self.tableView && indexPath.section == 0) {
        return NO;
    }
    
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //在iOS8.0上，必须加上这个方法才能出发左划操作
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSString *username = nil;
        NSInteger section = indexPath.section;
        NSInteger row = indexPath.row;
        if (tableView == self.tableView) {
            if (section != 0) {
                username = [self.dataArray[section - 1] objectAtIndex:row];
            }
        } else {
            username = [self.searchResults objectAtIndex:row];
        }
        
        if ([username length] == 0) {
            return;
        }
        
        [self showHudInView:self.view hint:@"移除黑名单..."];
        __weak typeof(self) weakself = self;
        [[EMClient sharedClient].contactManager removeUserFromBlackList:username completion:^(NSString *aUsername, EMError *aError) {
            [weakself hideHud];
            if (aError) {
                [EMAlertController showErrorAlert:aError.errorDescription];
            } else {
                [[NSNotificationCenter defaultCenter] postNotificationName:CONTACT_BLACKLIST_UPDATE object:nil];
                if (tableView != weakself.tableView) {
                    [self.searchResults removeObject:username];
                    [tableView reloadData];
                }
                [weakself loadBlacklistFromDB];
            }
        }];
    }
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView != self.tableView) {
        return 0;
    }
    
    if (section == 0) {
        return 0;
    } else {
        return 25;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (tableView != self.tableView || section == 0) {
        return nil;
    }
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 25)];
    label.backgroundColor = kColor_LightGray;
    label.font = [UIFont systemFontOfSize:15];
    label.text = [NSString stringWithFormat:@"    %@", self.sectionTitles[section - 1]];
    return label;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if (tableView != self.tableView) {
        return nil;
    }
    
    NSMutableArray *existTitles = [NSMutableArray array];
    //section数组为空的title过滤掉，不显示
    for (int i = 0; i < [self.sectionTitles count]; i++) {
        if ([self.dataArray[i] count] > 0) {
            [existTitles addObject:[self.sectionTitles objectAtIndex:i]];
        }
    }
    return existTitles;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableView && indexPath.section == 0 && indexPath.row == 0) {
        EMAddBlacklistViewController *controller = [[EMAddBlacklistViewController alloc] init];
        [self.navigationController pushViewController:controller animated:YES];
    }
}

#pragma mark - EMSearchBarDelegate

- (void)searchTextDidChangeWithString:(NSString *)aString
{
    __weak typeof(self) weakself = self;
    [[EMRealtimeSearch shared] realtimeSearchWithSource:self.blacklist searchText:aString collationStringSelector:nil resultBlock:^(NSArray *results) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself.searchResults removeAllObjects];
            [weakself.searchResults addObjectsFromArray:results];
            [weakself.searchResultTableView reloadData];
        });
    }];
}

#pragma mark - EMAvatarNameCellDelegate

- (void)cellAccessoryButtonAction:(EMAvatarNameCell *)aCell
{
    NSString *name = [self.searchResults objectAtIndex:aCell.indexPath.row];
    
    [self showHudInView:self.view hint:@"拉黑用户..."];
    __weak typeof(self) weakself = self;
    [[EMClient sharedClient].contactManager addUserToBlackList:name completion:^(NSString *aUsername, EMError *aError) {
        [weakself hideHud];
        if (aError) {
            [EMAlertController showErrorAlert:@"拉黑用户失败"];
        } else {
            [weakself loadBlacklistFromDB];
            
            aCell.accessoryButton.enabled = NO;
            aCell.accessoryButton.backgroundColor = kColor_Gray;
            
            [EMAlertController showSuccessAlert:@"拉黑用户成功"];
        }
    }];
}

#pragma mark - EMMultiDevicesDelegate

- (void)multiDevicesContactEventDidReceive:(EMMultiDevicesEvent)aEvent
                                  username:(NSString *)aTarget
                                       ext:(NSString *)aExt
{
    if (aEvent == EMMultiDevicesEventContactBan || aEvent == EMMultiDevicesEventContactAllow) {
        [self loadBlacklistFromDB];
    }
}

#pragma mark - NSNotification

- (void)handleReloadBlacklist:(NSNotification *)aNotif
{
    [[NSNotificationCenter defaultCenter] postNotificationName:CONTACT_BLACKLIST_UPDATE object:nil];
    [self loadBlacklistFromDB];
}

#pragma mark - Data

- (NSArray *)_sortDataArray:(NSArray *)aDataArray
{
    //建立索引的核心
    UILocalizedIndexedCollation *indexCollation = [UILocalizedIndexedCollation currentCollation];
    [self.sectionTitles removeAllObjects];
    [self.sectionTitles addObjectsFromArray:[indexCollation sectionTitles]];
    
    NSInteger highSection = [self.sectionTitles count];
    NSMutableArray *sortedArray = [NSMutableArray arrayWithCapacity:highSection];
    for (int i = 0; i < highSection; i++) {
        NSMutableArray *sectionArray = [NSMutableArray arrayWithCapacity:1];
        [sortedArray addObject:sectionArray];
    }
    
    //名字分section
    //按首字母分组
    for (NSString *username in aDataArray) {
        NSString *firstLetter = [EMChineseToPinyin pinyinFromChineseString:username];
        NSInteger section;
        if (firstLetter.length > 0) {
            section = [indexCollation sectionForObject:[firstLetter substringToIndex:1] collationStringSelector:@selector(uppercaseString)];
        } else {
            section = [sortedArray count] - 1;
        }
        
        NSMutableArray *array = [sortedArray objectAtIndex:section];
        [array addObject:username];
    }
    
    //每个section内的数组排序
    for (int i = 0; i < [sortedArray count]; i++) {
        NSArray *array = [[sortedArray objectAtIndex:i] sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
            NSString *firstLetter1 = [EMChineseToPinyin pinyinFromChineseString:obj1];
            firstLetter1 = [[firstLetter1 substringToIndex:1] uppercaseString];
            
            NSString *firstLetter2 = [EMChineseToPinyin pinyinFromChineseString:obj2];
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
    
    return sortedArray;
}

- (void)tableViewDidTriggerHeaderRefresh
{
    __weak typeof(self) weakself = self;
    [[EMClient sharedClient].contactManager getBlackListFromServerWithCompletion:^(NSArray *aList, EMError *aError) {
        if (!aError) {
            weakself.blacklist = aList;
            [weakself.dataArray removeAllObjects];
            if ([aList count] > 0) {
                [weakself.dataArray addObjectsFromArray:[weakself _sortDataArray:aList]];
            }
            [weakself.tableView reloadData];
        }
        
        [weakself tableViewDidFinishTriggerHeader:YES reload:NO];
    }];
}

- (void)loadBlacklistFromDB
{
    self.blacklist = [[EMClient sharedClient].contactManager getBlackList];
    [self.dataArray removeAllObjects];
    [self.dataArray addObjectsFromArray:[self _sortDataArray:self.blacklist]];
    [self.tableView reloadData];
}

@end
