//
//  EMChatroomsViewController.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/16.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EMChatroomsViewController.h"

#import "EMRealtimeSearch.h"
#import "EMConversationHelper.h"

#import "EMAvatarNameCell.h"
#import "EMCreateChatroomViewController.h"
#import "EMChineseToPinyin.h"

@interface EMChatroomsViewController ()
//按群昵称首字母排序
@property (nonatomic, strong) NSMutableArray *sectionTitles;
@end

@implementation EMChatroomsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self _setupSubviews];
    self.sectionTitles = [[NSMutableArray alloc] init];//群昵称首字母
    self.page = 1;
    [self _fetchChatroomsWithPage:self.page isHeader:YES isShowHUD:YES];
}

#pragma mark - Subviews

- (void)_setupSubviews
{
    [self addPopBackLeftItem];
    self.title = @"聊天室";
    self.view.backgroundColor = [UIColor whiteColor];
    self.showRefreshHeader = YES;
}

#pragma mark - Private

- (void)_sortAllChatRooms:(NSArray *)aChatRoomList
{
    
    NSMutableArray *chatRoomList = [[NSMutableArray alloc]init];
    for (EMChatroom *chatRoom in aChatRoomList) {
        [chatRoomList addObject:chatRoom];
    }
    [self.dataArray removeAllObjects];
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
    for (EMChatroom *chatRoom in chatRoomList) {
        NSString *firstLetter = [EMChineseToPinyin pinyinFromChineseString:chatRoom.subject];
        NSInteger section;
        if (firstLetter.length > 0) {
            section = [indexCollation sectionForObject:[firstLetter substringToIndex:1] collationStringSelector:@selector(uppercaseString)];
        } else {
            section = [sortedArray count] - 1;
        }
        
        NSMutableArray *array = [sortedArray objectAtIndex:section];
        [array addObject:chatRoom];
        sortedArray[section] = array;
    }
    
    //每个section内的数组排序
    for (int i = 0; i < [sortedArray count]; i++) {
        NSArray *array = [[sortedArray objectAtIndex:i] sortedArrayUsingComparator:^NSComparisonResult(EMChatroom *chatRoom1, EMChatroom *chatRoom2) {
            NSString *firstLetter1 = [EMChineseToPinyin pinyinFromChineseString:chatRoom1.subject];
            firstLetter1 = [[firstLetter1 substringToIndex:1] uppercaseString];
            
            NSString *firstLetter2 = [EMChineseToPinyin pinyinFromChineseString:chatRoom2.subject];
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
        [self.dataArray addObjectsFromArray:sortedArray];
    }else{
        [self.searchResults addObjectsFromArray:sortedArray];
    }
    
}

#pragma mark - Table view data source

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return self.sectionTitles;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
       NSInteger count = 0;
       if (tableView == self.tableView) {
           count = [self.dataArray count];
       } else {
           count = [self.searchResults count];
       }
       return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
     if (tableView == self.tableView) {
        return [(NSArray *)(self.dataArray[section]) count];
    } else {
        return [(NSArray *)(self.searchResults[section]) count];
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
    /*
    if (tableView == self.tableView && indexPath.section == 0) {
        cell.detailLabel.text = nil;
        if (indexPath.row == 0) {
            cell.avatarView.image = [UIImage imageNamed:@"chatroom_create"];
            cell.nameLabel.text = @"创建聊天室";
        }
        
        return cell;
    }*/
    
    EMChatroom *chatroom = nil;
    if (tableView == self.tableView) {
        chatroom = self.dataArray[(indexPath.section)][indexPath.row];
    } else {
        chatroom = self.searchResults[(indexPath.section)][indexPath.row];
    }
    
    cell.avatarView.image = [UIImage imageNamed:@"chatroom_avatar"];
    if ([chatroom.subject length]) {
        cell.nameLabel.text = chatroom.subject;
    } else {
        cell.nameLabel.text = chatroom.chatroomId;
    }
    cell.detailLabel.text = chatroom.chatroomId;
    
    [cell setSeparatorInset:UIEdgeInsetsMake(0, cell.avatarView.frame.size.height + 23, 0, 1)];
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
    
    NSString *title = self.sectionTitles[section];
    label.text = [NSString stringWithFormat:@"  %@", title];
    [view addSubview:label];
    
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.view endEditing:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    EMChatroom *chatroom = nil;
    if (tableView == self.tableView) {
        chatroom = self.dataArray[(indexPath.section)][indexPath.row];
    } else {
        chatroom = self.searchResults[(indexPath.section)][indexPath.row];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:CHAT_PUSHVIEWCONTROLLER object:chatroom];
}

#pragma mark - EMSearchBarDelegate

- (void)searchBarSearchButtonClicked:(NSString *)aString
{
    if (!self.isSearching) {
        return;
    }

    [self _searchChatroomWithId:aString];
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
            [weakself _sortAllChatRooms:weakself.searchResults];
            [weakself.searchResultTableView reloadData];
        });
    }];
}

#pragma mark - data

- (void)_fetchChatroomsWithPage:(NSInteger)aPage
                      isHeader:(BOOL)aIsHeader
                      isShowHUD:(BOOL)aIsShowHUD
{
    [self hideHud];
    if (aIsShowHUD) {
        [self showHudInView:self.view hint:@"获取聊天室..."];
    }
    
    __weak typeof(self) weakself = self;
    [[EMClient sharedClient].roomManager getChatroomsFromServerWithPage:aPage pageSize:50 completion:^(EMPageResult *aResult, EMError *aError) {
        if (aIsShowHUD) {
            [weakself hideHud];
        }
        if (!aError) {
            if (aIsHeader) {
                [weakself.dataArray removeAllObjects];
            }
            [weakself.dataArray addObjectsFromArray:aResult.list];
            [weakself _sortAllChatRooms:weakself.dataArray];
            weakself.showRefreshFooter = aResult.count > 0 ? YES : NO;
            [weakself tableViewDidFinishTriggerHeader:aIsHeader reload:YES];
        }
    }];
}

- (void)tableViewDidTriggerHeaderRefresh
{
    self.page = 1;
    [self _fetchChatroomsWithPage:self.page isHeader:YES isShowHUD:NO];
}

- (void)tableViewDidTriggerFooterRefresh
{
    self.page += 1;
    [self _fetchChatroomsWithPage:self.page isHeader:NO isShowHUD:NO];
}

- (void)_searchChatroomWithId:(NSString *)aId
{
    __weak typeof(self) weakself = self;
    [self showHudInView:self.view hint:@"搜索聊天室..."];
    [[EMClient sharedClient].roomManager getChatroomSpecificationFromServerWithId:aId completion:^(EMChatroom *aChatroom, EMError *aError) {
        [weakself hideHud];
        if (!aError) {
            [weakself.searchResults removeAllObjects];
            [weakself.searchResults addObject:aChatroom];
            //[weakself _sortAllChatRooms:weakself.searchResults];
            [weakself.searchResultTableView reloadData];
        } else {
            [EMAlertController showErrorAlert:@"未搜索到聊天室"];
        }
    }];
}

@end
