//
//  EMChatroomInfoViewController.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/2/11.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EMChatroomInfoViewController.h"

#import "EMTextViewController.h"
#import "EMTextFieldViewController.h"
#import "EMChatroomOwnerViewController.h"
#import "EMChatroomMembersViewController.h"
#import "EMChatroomAdminsViewController.h"
#import "EMChatroomMutesViewController.h"

@interface EMChatroomInfoViewController ()<EMChatroomManagerDelegate>

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
    
    [[EMClient sharedClient].roomManager addDelegate:self delegateQueue:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleChatroomInfoUpdated:) name:CHATROOM_INFO_UPDATED object:nil];
}

- (void)dealloc
{
    [[EMClient sharedClient].roomManager removeDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Subviews

- (void)_setupSubviews
{
    [self addPopBackLeftItem];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@""] style:UIBarButtonItemStylePlain target:self action:@selector(chatroomAnnouncementAction)];
    self.title = @"聊天室信息";
    
    self.showRefreshHeader = YES;
    
    self.tableView.rowHeight = 60;
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
        count = 1;
        if (self.chatroom.permissionType == EMChatroomPermissionTypeOwner || self.chatroom.permissionType == EMChatroomPermissionTypeAdmin) {
            count = 2;
        }
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
            cell.accessoryType = self.chatroom.permissionType == EMChatroomPermissionTypeOwner ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
        } else if (row == 2) {
            cell.textLabel.text = @"描述";
            cell.detailTextLabel.text = self.chatroom.description;
            cell.accessoryType = self.chatroom.permissionType == EMChatroomPermissionTypeOwner ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
        } else if (row == 3) {
            cell.textLabel.text = @"Owner";
            cell.detailTextLabel.text = self.chatroom.owner;
            cell.accessoryType = self.chatroom.permissionType == EMChatroomPermissionTypeOwner ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
        }
    } else if (section == 1) {
        if (row == 0) {
            cell.textLabel.text = @"聊天室成员";
            cell.detailTextLabel.text = nil;
//            cell.detailTextLabel.text = @([self.chatroom.memberList count]).stringValue;
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
            [self _updateChatroomNameAction];
        } else if (row == 2) {
            [self _updateChatroomDetailAction];
        } else if (row == 3) {
            [self _updateChatroomOnwerAction];
        }
    } else if (section == 1) {
        if (row == 0) {
            EMChatroomMembersViewController *controller = [[EMChatroomMembersViewController alloc] initWithChatroom:self.chatroom];
            [self.navigationController pushViewController:controller animated:YES];
        }
    } else if (section == 2) {
        if (row == 0) {
            EMChatroomAdminsViewController *controller = [[EMChatroomAdminsViewController alloc] initWithChatroom:self.chatroom];
            [self.navigationController pushViewController:controller animated:YES];
        } else if (row == 1) {
            EMChatroomMutesViewController *controller = [[EMChatroomMutesViewController alloc] initWithChatroom:self.chatroom];
            [self.navigationController pushViewController:controller animated:YES];
        }
    } else if (section == 3) {
        if (row == 0) {
            [self _leaveChatroomAction];
        }
    }
}

#pragma mark - EMChatroomManagerDelegate

- (void)chatroomMuteListDidUpdate:(EMChatroom *)aChatroom
                addedMutedMembers:(NSArray *)aMutes
                       muteExpire:(NSInteger)aMuteExpire
{
    [self _resetChatroom:aChatroom];
}

- (void)chatroomMuteListDidUpdate:(EMChatroom *)aChatroom
              removedMutedMembers:(NSArray *)aMutes
{
    [self _resetChatroom:aChatroom];
}

- (void)chatroomAdminListDidUpdate:(EMChatroom *)aChatroom
                        addedAdmin:(NSString *)aAdmin
{
    [self _resetChatroom:aChatroom];
}

- (void)chatroomAdminListDidUpdate:(EMChatroom *)aChatroom
                      removedAdmin:(NSString *)aAdmin
{
    [self _resetChatroom:aChatroom];
}

- (void)chatroomOwnerDidUpdate:(EMChatroom *)aChatroom
                      newOwner:(NSString *)aNewOwner
                      oldOwner:(NSString *)aOldOwner
{
    [self _resetChatroom:aChatroom];
}

#pragma mark - Data

- (void)_resetChatroom:(EMChatroom *)aChatroom
{
    self.chatroom = aChatroom;
    if (aChatroom.permissionType == EMChatroomPermissionTypeOwner) {
        self.leaveCell.textLabel.text = @"解散聊天室";
    } else {
        self.leaveCell.textLabel.text = @"退出聊天室";
    }
    [self.tableView reloadData];
}

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
            weakself.chatroomId = aChatroom.chatroomId;
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

#pragma mark - NSNotification

- (void)handleChatroomInfoUpdated:(NSNotification *)aNotif
{
    EMChatroom *chatroom = aNotif.object;
    if (!chatroom || ![chatroom.chatroomId isEqualToString:self.chatroomId]) {
        return;
    }
    
    [self tableViewDidTriggerHeaderRefresh];
}

#pragma mark - Action

- (void)chatroomAnnouncementAction
{
    __weak typeof(self) weakself = self;
    [self showHudInView:self.view hint:@"获取聊天室公告..."];
    [[EMClient sharedClient].roomManager getChatroomAnnouncementWithId:self.chatroomId completion:^(NSString *aAnnouncement, EMError *aError) {
        [weakself hideHud];
        if (!aError) {
            BOOL isEditable = weakself.isOwner;
            if (!isEditable) {
                isEditable = [weakself.chatroom.adminList containsObject:[EMClient sharedClient].currentUsername];
            }
            EMTextViewController *controller = [[EMTextViewController alloc] initWithString:aAnnouncement placeholder:@"请输入聊天室公告" isEditable:isEditable];
            controller.title = @"聊天室公告";
            
            __weak typeof(controller) weakController = controller;
            [controller setDoneCompletion:^BOOL(NSString * _Nonnull aString) {
                [weakController showHudInView:weakController.view hint:@"更新聊天室公告..."];
                [[EMClient sharedClient].roomManager updateChatroomAnnouncementWithId:weakself.chatroomId announcement:aString completion:^(EMChatroom *aChatroom, EMError *aError) {
                    [weakController hideHud];
                    if (aError) {
                        [EMAlertController showErrorAlert:@"更新聊天室公告失败"];
                    } else {
                        [weakController.navigationController popViewControllerAnimated:YES];
                    }
                }];
                
                return NO;
            }];
            
            [weakself.navigationController pushViewController:controller animated:YES];
        } else {
            [EMAlertController showErrorAlert:@"获取聊天室公告失败"];
        }
    }];
}

- (void)_updateChatroomNameAction
{
    BOOL isEditable = self.chatroom.permissionType == EMChatroomPermissionTypeOwner ? YES : NO;
    EMTextFieldViewController *controller = [[EMTextFieldViewController alloc] initWithString:self.chatroom.subject placeholder:@"请输入聊天室名称" isEditable:isEditable];
    controller.title = @"聊天室名称";
    [self.navigationController pushViewController:controller animated:YES];
    
    __weak typeof(self) weakself = self;
    __weak typeof(controller) weakController = controller;
    [controller setDoneCompletion:^BOOL(NSString * _Nonnull aString) {
        if ([aString length] == 0) {
            [EMAlertController showErrorAlert:@"聊天室名称不能为空"];
            return NO;
        }
        
        [weakController showHudInView:weakController.view hint:@"更新聊天室名称..."];
        [[EMClient sharedClient].roomManager updateSubject:aString forChatroom:weakself.chatroom.chatroomId completion:^(EMChatroom *aChatroom, EMError *aError) {
            [weakController hideHud];
            if (!aError) {
                [weakself _resetChatroom:aChatroom];
                [weakController.navigationController popViewControllerAnimated:YES];
            } else {
                [EMAlertController showErrorAlert:@"更新聊天室名称失败"];
            }
        }];
        
        return NO;
    }];
}

- (void)_updateChatroomDetailAction
{
    BOOL isEditable = self.chatroom.permissionType == EMChatroomPermissionTypeOwner ? YES : NO;
    EMTextViewController *controller = [[EMTextViewController alloc] initWithString:self.chatroom.description placeholder:@"请输入聊天室简介" isEditable:isEditable];
    controller.title = @"聊天室简介";
    [self.navigationController pushViewController:controller animated:YES];
    
    __weak typeof(self) weakself = self;
    __weak typeof(controller) weakController = controller;
    [controller setDoneCompletion:^BOOL(NSString * _Nonnull aString) {
        [weakController showHudInView:weakController.view hint:@"更新聊天室简介..."];
        [[EMClient sharedClient].roomManager updateDescription:aString forChatroom:weakself.chatroom.chatroomId completion:^(EMChatroom *aChatroom, EMError *aError) {
            [weakController hideHud];
            if (!aError) {
                [weakself _resetChatroom:aChatroom];
                [weakController.navigationController popViewControllerAnimated:YES];
            } else {
                [EMAlertController showErrorAlert:@"更新聊天室简介失败"];
            }
        }];
        
        return NO;
    }];
}

- (void)_updateChatroomOnwerAction
{
    if (self.chatroom.permissionType != EMChatroomPermissionTypeOwner) {
        return;
    }
    
    EMChatroomOwnerViewController *controller = [[EMChatroomOwnerViewController alloc] initWithChatroom:self.chatroom];
    __weak typeof(self) weakself = self;
    [controller setSuccessCompletion:^(EMChatroom * _Nonnull aChatroom) {
        [weakself _resetChatroom:aChatroom];
    }];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)_leaveChatroomAction
{
    __weak typeof(self) weakself = self;
    void (^block)(EMError *aError) = ^(EMError *aError) {
        [weakself hideHud];
        if (!aError) {
            if (weakself.leaveCompletion) {
                weakself.leaveCompletion();
            }
            [weakself.navigationController popViewControllerAnimated:YES];
        }
    };
    
    if (self.chatroom.permissionType == EMChatroomPermissionTypeOwner) {
        [self showHudInView:self.view hint:@"解散群组..."];
        [[EMClient sharedClient].roomManager destroyChatroom:self.chatroom.chatroomId completion:block];
    } else {
        [self showHudInView:self.view hint:@"离开群组..."];
        [[EMClient sharedClient].roomManager leaveChatroom:self.chatroom.chatroomId completion:block];
    }
}

@end
