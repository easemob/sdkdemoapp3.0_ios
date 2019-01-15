//
//  EMConversationsViewController.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/8.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EMConversationsViewController.h"

#import "EMRealtimeSearch.h"

#import "EMConversationModel.h"
#import "EMAlertController.h"
#import "EMConversationCell.h"
#import "UIViewController+Search.h"
#import "ChatViewController.h"

@interface EMConversationsViewController()<XHSearchControllerDelegate>

@end

@implementation EMConversationsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self _setupSubviews];
    
    [self _loadAllConversationsFromDBWithIsShowHud:YES];
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
    self.view.backgroundColor = [UIColor whiteColor];
    self.showRefreshHeader = YES;
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"聊天";
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.font = [UIFont systemFontOfSize:28];
    [self.view addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(15);
        make.top.equalTo(self.view).offset(20);
        make.height.equalTo(@60);
    }];
    
    [self enableSearchController];
    self.tableView.rowHeight = 60;
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
    self.resultController.tableView.rowHeight = 50;
    [self.resultController setCellForRowAtIndexPathCompletion:^UITableViewCell *(UITableView *tableView, NSIndexPath *indexPath) {
        NSString *cellIdentifier = @"EMConversationCell";
        EMConversationCell *cell = (EMConversationCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[EMConversationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        
        NSInteger row = indexPath.row;
        EMConversationModel *model = [weakself.resultController.dataArray objectAtIndex:row];
        cell.model = model;
        return cell;
    }];
    [self.resultController setCanEditRowAtIndexPath:^BOOL(UITableView *tableView, NSIndexPath *indexPath) {
        return YES;
    }];
    [self.resultController setCommitEditingAtIndexPath:^(UITableView *tableView, UITableViewCellEditingStyle editingStyle, NSIndexPath *indexPath) {
        if (editingStyle != UITableViewCellEditingStyleDelete) {
            return ;
        }
        
        NSInteger row = indexPath.row;
        EMConversationModel *model = [weakself.resultController.dataArray objectAtIndex:row];
        EMConversation *conversation = model.emModel;
        [[EMClient sharedClient].chatManager deleteConversation:conversation.conversationId isDeleteMessages:YES completion:nil];
        [weakself.resultController.dataArray removeObjectAtIndex:row];
        [weakself.resultController.tableView reloadData];
    }];
    [self.resultController setDidSelectRowAtIndexPathCompletion:^(UITableView *tableView, NSIndexPath *indexPath) {
        NSInteger row = indexPath.row;
        EMConversationModel *model = [weakself.resultController.dataArray objectAtIndex:row];
        EMConversation *conversation = model.emModel;
        ChatViewController *chatController = [[ChatViewController alloc] initWithConversationChatter:conversation.conversationId conversationType:conversation.type];
        [weakself.resultController.navigationController pushViewController:chatController animated:YES];
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"EMConversationCell";
    EMConversationCell *cell = (EMConversationCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[EMConversationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    NSInteger row = indexPath.row;
    EMConversationModel *model = [self.dataArray objectAtIndex:row];
    cell.model = model;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSInteger row = indexPath.row;
    EMConversationModel *model = [self.dataArray objectAtIndex:row];
    EMConversation *conversation = model.emModel;
    ChatViewController *chatController = [[ChatViewController alloc] initWithConversationChatter:conversation.conversationId conversationType:conversation.type];
    [self.navigationController pushViewController:chatController animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //在iOS8.0上，必须加上这个方法才能出发左划操作
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSInteger row = indexPath.row;
        EMConversationModel *model = [self.dataArray objectAtIndex:row];
        EMConversation *conversation = model.emModel;
        [[EMClient sharedClient].chatManager deleteConversation:conversation.conversationId isDeleteMessages:YES completion:nil];
        [self.dataArray removeObjectAtIndex:row];
        [self.tableView reloadData];
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
    [[EMRealtimeSearch shared] realtimeSearchWithSource:self.dataArray searchText:aString collationStringSelector:@selector(name) resultBlock:^(NSArray *results) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself.resultController.dataArray removeAllObjects];
            [weakself.resultController.dataArray addObjectsFromArray:results];
            [weakself.resultController.tableView reloadData];
        });
    }];
}

#pragma mark - Data

- (void)_loadAllConversationsFromDBWithIsShowHud:(BOOL)aIsShowHUD
{
    if (aIsShowHUD) {
        [self showHudInView:self.view hint:@"加载会话列表..."];
    }
    
    __weak typeof(self) weakself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *conversations = [[EMClient sharedClient].chatManager getAllConversations];
        NSArray *sorted = [conversations sortedArrayUsingComparator:^(EMConversation *obj1, EMConversation *obj2) {
            EMMessage *message1 = [obj1 latestMessage];
            EMMessage *message2 = [obj2 latestMessage];
            if(message1.timestamp > message2.timestamp) {
                return(NSComparisonResult)NSOrderedAscending;
            } else {
                return(NSComparisonResult)NSOrderedDescending;
            }}];
        
        [weakself.dataArray removeAllObjects];
        
        NSArray *groupArray = [[EMClient sharedClient].groupManager getJoinedGroups];
        for (int i = 0; i < [sorted count]; i++) {
            EMConversation *conversation = sorted[i];
            EMConversationModel *model = [[EMConversationModel alloc] initWithEMModel:conversation];
            if (conversation.type == EMConversationTypeGroupChat) {
                NSString *name = [conversation.ext objectForKey:@"subject"];
                if ([name length] == 0) {
                    for (EMGroup *group in groupArray) {
                        if ([group.groupId isEqualToString:conversation.conversationId]) {
                            NSMutableDictionary *ext = [NSMutableDictionary dictionaryWithDictionary:conversation.ext];
                            [ext setObject:group.subject forKey:@"subject"];
                            [ext setObject:[NSNumber numberWithBool:group.isPublic] forKey:@"isPublic"];
                            conversation.ext = ext;
                            name = group.subject;
                            break;
                        }
                    }
                }
                
                model.name = name;
            }
            
            [weakself.dataArray addObject:model];
        }
        
        if (aIsShowHUD) {
            [weakself hideHud];
        }
        [weakself tableViewDidFinishTriggerHeader:YES reload:NO];
        
        [weakself.tableView reloadData];
    });
}

- (void)tableViewDidTriggerHeaderRefresh
{
    [self _loadAllConversationsFromDBWithIsShowHud:NO];
}

#pragma mark - Action

- (void)deleteConversationAction:(EMConversation *)aConversation
{
    [[EMClient sharedClient].chatManager deleteConversation:aConversation.conversationId isDeleteMessages:YES completion:nil];
}

@end
