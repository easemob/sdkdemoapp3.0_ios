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

@interface EMChatroomsViewController ()

@end

@implementation EMChatroomsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self _setupSubviews];
    
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
            count = 1;
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
            cell.avatarView.image = [UIImage imageNamed:@"chatroom_create"];
            cell.nameLabel.text = @"创建聊天室";
        }
        
        return cell;
    }
    
    EMChatroom *chatroom = nil;
    if (tableView == self.tableView) {
        chatroom = [self.dataArray objectAtIndex:indexPath.row];
    } else {
        chatroom = [self.searchResults objectAtIndex:indexPath.row];
    }
    
    cell.avatarView.image = [UIImage imageNamed:@"chatroom_avatar"];
    if ([chatroom.subject length]) {
        cell.nameLabel.text = chatroom.subject;
    } else {
        cell.nameLabel.text = chatroom.chatroomId;
    }
    cell.detailLabel.text = chatroom.chatroomId;
    
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
    
    EMChatroom *chatroom = nil;
    if (tableView == self.tableView) {
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
                EMCreateChatroomViewController *controller = [[EMCreateChatroomViewController alloc] initWithStyle:UITableViewStyleGrouped];
//                [controller setSuccessCompletion:^(EMChatroom * _Nonnull aChatroom) {
//                    
//                }];
                [self.navigationController pushViewController:controller animated:YES];
            }
            
            return;
        }
        
        chatroom = [self.dataArray objectAtIndex:indexPath.row];
    } else {
        chatroom = [self.searchResults objectAtIndex:indexPath.row];
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
            [weakself.searchResultTableView reloadData];
        } else {
            [EMAlertController showErrorAlert:@"未搜索到聊天室"];
        }
    }];
}

@end
