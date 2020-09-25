//
//  EMChatroomOwnerViewController.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/2/19.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EMChatroomOwnerViewController.h"

#import "EMRealtimeSearch.h"

#import "EMSearchBar.h"
#import "EMAvatarNameCell.h"

@interface EMChatroomOwnerViewController ()<EMSearchBarDelegate, EMAvatarNameCellDelegate>

@property (nonatomic, strong) EMChatroom *chatroom;
@property (nonatomic, strong) NSString *cursor;

@end

@implementation EMChatroomOwnerViewController

- (instancetype)initWithChatroom:(EMChatroom *)aChatroom
{
    self = [super init];
    if (self) {
        self.chatroom = aChatroom;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self _setupSubviews];
    [self _fetchChatroomMembersWithIsHeader:YES isShowHUD:YES];
}

#pragma mark - Subviews

- (void)_setupSubviews
{
    [self addPopBackLeftItemWithTarget:self action:@selector(backAction)];
    self.title = @"移交聊天室Owner";
    self.showRefreshHeader = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.tableView.rowHeight = 60;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.tableView) {
        return [self.dataArray count];
    } else {
        return [self.searchResults count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EMAvatarNameCell *cell = (EMAvatarNameCell *)[tableView dequeueReusableCellWithIdentifier:@"UITableViewCellOwner"];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[EMAvatarNameCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCellOwner"];
        cell.delegate = self;
        
        UIButton *rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 90, 35)];
        rightButton.clipsToBounds = YES;
        rightButton.backgroundColor = kColor_Blue;
        rightButton.titleLabel.font = [UIFont systemFontOfSize:16];
        rightButton.layer.cornerRadius = 5;
        [rightButton setTitle:@"移交Owner" forState:UIControlStateNormal];
        [rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        cell.accessoryButton = rightButton;
    }
    
    NSString *name = nil;
    if (tableView == self.tableView) {
        name = [self.dataArray objectAtIndex:indexPath.row];
    } else {
        name = [self.searchResults objectAtIndex:indexPath.row];
    }
    cell.nameLabel.text = name;
    cell.avatarView.image = [UIImage imageNamed:@"defaultAvatar"];
    cell.indexPath = indexPath;
    
    return cell;
}

#pragma mark - EMAvatarNameCellDelegate

- (void)cellAccessoryButtonAction:(EMAvatarNameCell *)aCell
{
    NSString *name = aCell.nameLabel.text;

    [self showHudInView:self.view hint:@"移交Owner..."];
    __weak typeof(self) weakself = self;
    [[EMClient sharedClient].roomManager updateChatroomOwner:self.chatroom.chatroomId newOwner:name completion:^(EMChatroom *aChatroom, EMError *aError) {
        [weakself hideHud];
        if (aError) {
            [EMAlertController showErrorAlert:@"移交聊天室Owner失败"];
        } else {
            [EMAlertController showSuccessAlert:@"移交聊天室Owner成功"];
            
            if (weakself.successCompletion) {
                weakself.chatroom = aChatroom;
                weakself.successCompletion(weakself.chatroom);
                [weakself backAction];
            }
        }
    }];
}

#pragma mark - EMSearchBarDelegate

- (void)searchTextDidChangeWithString:(NSString *)aString
{
    __weak typeof(self) weakself = self;
    [[EMRealtimeSearch shared] realtimeSearchWithSource:self.dataArray searchText:aString collationStringSelector:nil resultBlock:^(NSArray *results) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself.searchResults removeAllObjects];
            [weakself.searchResults addObjectsFromArray:results];
            [weakself.searchResultTableView reloadData];
        });
    }];
}

#pragma mark - Data

- (void)_fetchChatroomMembersWithIsHeader:(BOOL)aIsHeader
                                isShowHUD:(BOOL)aIsShowHUD
{
    if (aIsShowHUD) {
        [self showHudInView:self.view hint:@"获取聊天室成员..."];
    }
    
    __weak typeof(self) weakself = self;
    void (^errorBlock)(EMError *aError) = ^(EMError *aError) {
        if (aIsShowHUD) {
            [weakself hideHud];
        }
        [weakself tableViewDidFinishTriggerHeader:aIsHeader reload:NO];
        [EMAlertController showErrorAlert:aError.errorDescription];
    };
    
    void (^fetchMembersBlock) (void) = ^(void) {
        [[EMClient sharedClient].roomManager getChatroomMemberListFromServerWithId:self.chatroom.chatroomId cursor:self.cursor pageSize:50 completion:^(EMCursorResult *aResult, EMError *aError) {
            if (aError) {
                errorBlock(aError);
                return ;
            }
            
            if (aIsShowHUD) {
                [weakself hideHud];
            }
            weakself.cursor = aResult.cursor;
            [weakself.dataArray addObjectsFromArray:aResult.list];
            
            if ([aResult.list count] == 0 || [aResult.cursor length] == 0) {
                weakself.showRefreshFooter = NO;
            } else {
                weakself.showRefreshFooter = YES;
            }
            
            [weakself.tableView reloadData];
            [weakself tableViewDidFinishTriggerHeader:aIsHeader reload:NO];
        }];
    };
    
    if (aIsHeader) {
        [[EMClient sharedClient].roomManager getChatroomSpecificationFromServerWithId:self.chatroom.chatroomId completion:^(EMChatroom *aChatroom, EMError *aError) {
            if (aError) {
                errorBlock(aError);
                return ;
            }
            
            weakself.chatroom = aChatroom;
            [weakself.dataArray removeAllObjects];
            [weakself.dataArray addObjectsFromArray:aChatroom.adminList];
            fetchMembersBlock();
        }];
    } else {
        fetchMembersBlock();
    }
}

- (void)tableViewDidTriggerHeaderRefresh
{
    self.cursor = nil;
    [self _fetchChatroomMembersWithIsHeader:YES isShowHUD:NO];
}

- (void)tableViewDidTriggerFooterRefresh
{
    [self _fetchChatroomMembersWithIsHeader:NO isShowHUD:NO];
}

#pragma mark - Action

- (void)backAction
{
    [[EMRealtimeSearch shared] realtimeSearchStop];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
