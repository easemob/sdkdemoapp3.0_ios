//
//  EMChatroomInfoViewController.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/2/11.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EMChatroomInfoViewController.h"

@interface EMChatroomInfoViewController ()

@property (nonatomic, strong) NSString *chatroomId;
@property (nonatomic, strong) EMChatroom *chatroom;
@property (nonatomic) BOOL isOwner;

@property (nonatomic, strong) UITableViewCell *leaveCell;

@end

@implementation EMChatroomInfoViewController

- (instancetype)initWithChatroomId:(NSString *)aChatroomId
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        _chatroomId = aChatroomId;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    [self _setupSubviews];
    
    [self _fetchChatroomWithId:self.chatroomId isShowHUD:YES];
}

- (void)dealloc
{
    //    [[EMClient sharedClient].roomManager removeDelegate:self];
}

#pragma mark - Subviews

- (void)_setupSubviews
{
    [self addPopBackLeftItem];
    self.title = @"聊天室信息";
    
    self.showRefreshHeader = YES;
    
    self.leaveCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCellStyleDefaultRedFont"];
    self.leaveCell.textLabel.textColor = [UIColor redColor];
    self.leaveCell.textLabel.text = @"退出聊天室";
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = 0;
    if (section == 0) {
        count = 4;
    } else if (section == 1) {
        count = 1;
    }  else if (section == 2) {
        count = 2;
    } else if (section == 3) {
        count = 1;
    }
    
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (section == 3 && row == 0) {
        return self.leaveCell;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCellStyleValue1"];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"UITableViewCellStyleValue1"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.detailTextLabel.textColor = [UIColor grayColor];
    }
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    if (section == 0) {
        if (row == 0) {
            cell.textLabel.text = @"聊天室ID";
            cell.detailTextLabel.text = self.chatroom.chatroomId;
            cell.accessoryType = UITableViewCellAccessoryNone;
        } else if (row == 1) {
            cell.textLabel.text = @"名称";
            cell.detailTextLabel.text = self.chatroom.subject;
//            cell.accessoryType = self.isOwner ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
        } else if (row == 2) {
            cell.textLabel.text = @"描述";
            cell.detailTextLabel.text = self.chatroom.description;
//            cell.accessoryType = self.isOwner ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
        } else if (row == 3) {
            cell.textLabel.text = @"Owner";
            cell.detailTextLabel.text = self.chatroom.owner;
//            cell.accessoryType = self.isOwner ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
        }
    } else if (section == 1) {
        if (row == 0) {
            cell.textLabel.text = @"聊天室成员";
            cell.detailTextLabel.text = @([self.chatroom.memberList count]).stringValue;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }  else if (section == 2) {
        if (row == 0) {
            cell.textLabel.text = @"管理员";
            cell.detailTextLabel.text = @([self.chatroom.adminList count]).stringValue;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else if (row == 1) {
            cell.textLabel.text = @"禁言列表";
            cell.detailTextLabel.text = @([self.chatroom.muteList count]).stringValue;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 3) {
        return 40;
    }
    
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (section == 0) {
        if (row == 1) {
            
        } else if (row == 2) {
            
        } else if (row == 3) {
            
        }
    } else if (section == 2) {
        
    }
}

#pragma mark - Data

- (void)_fetchChatroomWithId:(NSString *)aChatroomId
                   isShowHUD:(BOOL)aIsShowHUD
{
    __weak typeof(self) weakself = self;
    
    if (aIsShowHUD) {
        [self showHudInView:self.view hint:@"获取聊天室详情..."];
    }
    [[EMClient sharedClient].roomManager getChatroomSpecificationFromServerWithId:aChatroomId completion:^(EMChatroom *aChatroom, EMError *aError) {
        [weakself hideHud];
        if (aChatroom) {
            weakself.chatroom = aChatroom;
            weakself.isOwner = [aChatroom.owner isEqualToString:[EMClient sharedClient].currentUsername] ? YES : NO;
            [weakself.tableView reloadData];
        } else if (aError) {
            [EMAlertController showErrorAlert:@"获取聊天室详情失败"];
        }
        [weakself tableViewDidFinishTriggerHeader:YES reload:NO];
    }];
}

- (void)tableViewDidTriggerHeaderRefresh
{
    self.page = 1;
    [self _fetchChatroomWithId:self.chatroomId isShowHUD:NO];
}

@end
