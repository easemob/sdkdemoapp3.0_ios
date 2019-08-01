//
//  EMGroupInfoViewController.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/18.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EMGroupInfoViewController.h"

#import "EMAvatarNameCell.h"

#import "EMTextFieldViewController.h"
#import "EMTextViewController.h"
#import "EMGroupOwnerViewController.h"
#import "EMGroupMembersViewController.h"
#import "EMGroupAdminsViewController.h"
#import "EMGroupMutesViewController.h"
#import "EMGroupBlacklistViewController.h"
#import "EMGroupSharedFilesViewController.h"
#import "EMGroupSettingsViewController.h"
#import "EMInviteGroupMemberViewController.h"

@interface EMGroupInfoViewController ()<EMMultiDevicesDelegate>

@property (nonatomic, strong) NSString *groupId;
@property (nonatomic, strong) EMGroup *group;

@property (nonatomic, strong) EMAvatarNameCell *addMemberCell;
@property (nonatomic, strong) UITableViewCell *leaveCell;

@end

@implementation EMGroupInfoViewController

- (instancetype)initWithGroupId:(NSString *)aGroupId
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        _groupId = aGroupId;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    [self _setupSubviews];
    
//    [[EMClient sharedClient].groupManager addDelegate:self delegateQueue:nil];
    
    [self _fetchGroupWithId:self.groupId isShowHUD:YES];
    
    [[EMClient sharedClient] addMultiDevicesDelegate:self delegateQueue:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleGroupInfoUpdated:) name:GROUP_INFO_UPDATED object:nil];
}

- (void)dealloc
{
//    [[EMClient sharedClient].groupManager removeDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Subviews

- (void)_setupSubviews
{
    [self addPopBackLeftItem];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"公告" style:UIBarButtonItemStylePlain target:self action:@selector(groupAnnouncementAction)];
    self.title = @"群组信息";
    
    self.showRefreshHeader = YES;

    self.tableView.rowHeight = 60;
    
    self.addMemberCell = [[EMAvatarNameCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"EMAvatarNameCell"];
    self.addMemberCell.avatarView.image = [UIImage imageNamed:@"group_join"];
    self.addMemberCell.nameLabel.textColor = kColor_Blue;
    self.addMemberCell.nameLabel.text = @"添加成员";
    
    self.leaveCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCellStyleDefaultRedFont"];
    self.leaveCell.textLabel.textColor = [UIColor redColor];
    self.leaveCell.textLabel.text = @"退出群组";
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = 0;
    if (section == 0) {
        count = 4;
    } else if (section == 1) {
        if ((self.group.setting.style == EMGroupStylePrivateOnlyOwnerInvite || self.group.setting.style == EMGroupStylePublicJoinNeedApproval) && self.group.permissionType == EMGroupPermissionTypeOwner) {
            count = 2;
        } else if (self.group.setting.style == EMGroupStylePrivateMemberCanInvite) {
            count = 2;
        } else {
            count = 1;
        }
    } else if (section == 2) {
        count = self.group.permissionType == EMGroupPermissionTypeOwner ? 3 : 1;
    } else if (section == 3) {
        count = 2;
    } else if (section == 4) {
        count = 1;
    }
    
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (section == 4 && row == 0) {
        return self.leaveCell;
    } else if (section == 1 && row == 1) {
        return self.addMemberCell;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCellStyleValue1"];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"UITableViewCellStyleValue1"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.detailTextLabel.textColor = [UIColor grayColor];
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    if (section == 0) {
        if (row == 0) {
            cell.textLabel.text = @"群组ID";
            cell.detailTextLabel.text = self.group.groupId;
            cell.accessoryType = UITableViewCellAccessoryNone;
        } else if (row == 1) {
            cell.textLabel.text = @"名称";
            cell.detailTextLabel.text = self.group.subject;
            cell.accessoryType = self.group.permissionType == EMGroupPermissionTypeOwner ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
        } else if (row == 2) {
            cell.textLabel.text = @"简介";
            cell.detailTextLabel.text = self.group.description;
            cell.accessoryType = self.group.permissionType == EMGroupPermissionTypeOwner ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
        } else if (row == 3) {
            cell.textLabel.text = @"群主";
            cell.detailTextLabel.text = self.group.owner;
            cell.accessoryType = self.group.permissionType == EMGroupPermissionTypeOwner ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
        }
    } else if (section == 1) {
        if (row == 0) {
            cell.textLabel.text = @"群组成员";
            cell.detailTextLabel.text = @(self.group.occupantsCount - self.group.adminList.count - 1).stringValue;
        }
    }  else if (section == 2) {
        if (row == 0) {
            cell.textLabel.text = @"管理员";
            cell.detailTextLabel.text = @([self.group.adminList count]).stringValue;
        } else if (row == 1) {
            cell.textLabel.text = @"黑名单";
            cell.detailTextLabel.text = @([self.group.blacklist count]).stringValue;
        } else if (row == 2) {
            cell.textLabel.text = @"禁言列表";
            cell.detailTextLabel.text = @([self.group.muteList count]).stringValue;
        }
    } else if (section == 3) {
        if (row == 0) {
            cell.textLabel.text = @"共享文件";
            cell.detailTextLabel.text = @"";
        } else if (row == 1) {
            cell.textLabel.text = @"群组设置";
            cell.detailTextLabel.text = nil;
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
    if (section == 4) {
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
            [self _updateGroupNameAction];
        } else if (row == 2) {
            [self _updateGroupDetailAction];
        } else if (row == 3) {
            [self _updateGroupOnwerAction];
        }
    } else if (section == 1) {
        if (row == 0) {
            EMGroupMembersViewController *controller = [[EMGroupMembersViewController alloc] initWithGroup:self.group];
            [self.navigationController pushViewController:controller animated:YES];
        } else if (row == 1) {
            [self addMemberAction];
        }
    } else if (section == 2) {
        if (row == 0) {
            EMGroupAdminsViewController *controller = [[EMGroupAdminsViewController alloc] initWithGroup:self.group];
            [self.navigationController pushViewController:controller animated:YES];
        } else if (row == 1) {
            EMGroupBlacklistViewController *controller = [[EMGroupBlacklistViewController alloc] initWithGroup:self.group];
            [self.navigationController pushViewController:controller animated:YES];
        } else if (row == 2) {
            EMGroupMutesViewController *controller = [[EMGroupMutesViewController alloc] initWithGroup:self.group];
            [self.navigationController pushViewController:controller animated:YES];
        }
    } else if (section == 3) {
        if (row == 0) {
            EMGroupSharedFilesViewController *controller = [[EMGroupSharedFilesViewController alloc] initWithGroup:self.group];
            [self.navigationController pushViewController:controller animated:YES];
        } else if (row == 1) {
            EMGroupSettingsViewController *controller = [[EMGroupSettingsViewController alloc] initWithGroup:self.group];
            [self.navigationController pushViewController:controller animated:YES];
        }
    } else if (section == 4) {
        if (row == 0) {
            [self _leaveOrDestroyGroupAction];
        }
    }
}

#pragma mark - EMMultiDevicesDelegate

- (void)multiDevicesGroupEventDidReceive:(EMMultiDevicesEvent)aEvent
                                 groupId:(NSString *)aGroupId
                                     ext:(id)aExt
{
    switch (aEvent) {
        case EMMultiDevicesEventGroupKick:
        case EMMultiDevicesEventGroupBan:
        case EMMultiDevicesEventGroupAllow:
        case EMMultiDevicesEventGroupAssignOwner:
        case EMMultiDevicesEventGroupAddAdmin:
        case EMMultiDevicesEventGroupRemoveAdmin:
        case EMMultiDevicesEventGroupAddMute:
        case EMMultiDevicesEventGroupRemoveMute:
        {
            if ([aGroupId isEqualToString:self.group.groupId]) {
                [self.tableView reloadData];
            }
        }
            
        default:
            break;
    }
}

#pragma mark - Data

- (void)_resetGroup:(EMGroup *)aGroup
{
    if (![self.group.subject isEqualToString:aGroup.subject]) {
        EMConversation *conversation = [[EMClient sharedClient].chatManager getConversation:aGroup.groupId type:EMConversationTypeGroupChat createIfNotExist:NO];
        if (conversation) {
            NSMutableDictionary *ext = [NSMutableDictionary dictionaryWithDictionary:conversation.ext];
            [ext setObject:aGroup.subject forKey:@"subject"];
            [ext setObject:[NSNumber numberWithBool:aGroup.isPublic] forKey:@"isPublic"];
            conversation.ext = ext;
            
            [[NSNotificationCenter defaultCenter] postNotificationName:GROUP_SUBJECT_UPDATED object:aGroup];
        }
    }
    
    self.group = aGroup;
    if (aGroup.permissionType == EMGroupPermissionTypeOwner) {
        self.leaveCell.textLabel.text = @"解散群组";
    } else {
        self.leaveCell.textLabel.text = @"退出群组";
    }
    [self.tableView reloadData];
}

- (void)_fetchGroupWithId:(NSString *)aGroupId
                isShowHUD:(BOOL)aIsShowHUD
{
    __weak typeof(self) weakself = self;
    
    if (aIsShowHUD) {
        [self showHudInView:self.view hint:@"获取群组详情..."];
    }
    [[EMClient sharedClient].groupManager getGroupSpecificationFromServerWithId:aGroupId completion:^(EMGroup *aGroup, EMError *aError) {
        [weakself hideHud];
        if (!aError) {
            [weakself _resetGroup:aGroup];
        } else {
            [EMAlertController showErrorAlert:@"获取群组详情失败"];
        }
        [weakself tableViewDidFinishTriggerHeader:YES reload:NO];
    }];
}

- (void)tableViewDidTriggerHeaderRefresh
{
    self.page = 1;
    [self _fetchGroupWithId:self.groupId isShowHUD:NO];
}

#pragma mark - NSNotification

- (void)handleGroupInfoUpdated:(NSNotification *)aNotif
{
    EMGroup *group = aNotif.object;
    if (!group || ![group.groupId isEqualToString:self.groupId]) {
        return;
    }
    
    [self _fetchGroupWithId:self.groupId isShowHUD:NO];
}

#pragma mark - Action

- (void)groupAnnouncementAction
{
    __weak typeof(self) weakself = self;
    [self showHudInView:self.view hint:@"获取群组公告..."];
    [[EMClient sharedClient].groupManager getGroupAnnouncementWithId:self.groupId completion:^(NSString *aAnnouncement, EMError *aError) {
        [weakself hideHud];
        if (!aError) {
            BOOL isEditable = NO;
            if (weakself.group.permissionType == EMGroupPermissionTypeOwner || weakself.group.permissionType == EMGroupPermissionTypeAdmin) {
                isEditable = YES;
            }
            EMTextViewController *controller = [[EMTextViewController alloc] initWithString:aAnnouncement placeholder:@"请输入群组公告" isEditable:isEditable];
            controller.title = @"群组公告";
            
            __weak typeof(controller) weakController = controller;
            [controller setDoneCompletion:^BOOL(NSString * _Nonnull aString) {
                [weakController showHudInView:weakController.view hint:@"更新群组公告..."];
                [[EMClient sharedClient].groupManager updateGroupAnnouncementWithId:weakself.groupId announcement:aString completion:^(EMGroup *aGroup, EMError *aError) {
                    [weakController hideHud];
                    if (aError) {
                        [EMAlertController showErrorAlert:@"更新群组公告失败"];
                    } else {
                        [weakController.navigationController popViewControllerAnimated:YES];
                    }
                }];
                
                return NO;
            }];
            
            [weakself.navigationController pushViewController:controller animated:YES];
        } else {
            [EMAlertController showErrorAlert:@"获取群组公告失败"];
        }
    }];
}

- (void)_updateGroupNameAction
{
    BOOL isEditable = self.group.permissionType == EMGroupPermissionTypeOwner ? YES : NO;
    EMTextFieldViewController *controller = [[EMTextFieldViewController alloc] initWithString:self.group.subject placeholder:@"请输入群组名称" isEditable:isEditable];
    controller.title = @"群组名称";
    [self.navigationController pushViewController:controller animated:YES];
    
    __weak typeof(self) weakself = self;
    __weak typeof(controller) weakController = controller;
    [controller setDoneCompletion:^BOOL(NSString * _Nonnull aString) {
        if ([aString length] == 0) {
            [EMAlertController showErrorAlert:@"群组名称不能为空"];
            return NO;
        }
        
        [weakController showHudInView:weakController.view hint:@"更新群组名称..."];
        [[EMClient sharedClient].groupManager updateGroupSubject:aString forGroup:weakself.groupId completion:^(EMGroup *aGroup, EMError *aError) {
            [weakController hideHud];
            if (!aError) {
                [weakself _resetGroup:aGroup];
                [weakController.navigationController popViewControllerAnimated:YES];
            } else {
                [EMAlertController showErrorAlert:@"更新群组名称失败"];
            }
        }];
        
        return NO;
    }];
}

- (void)_updateGroupDetailAction
{
    BOOL isEditable = self.group.permissionType == EMGroupPermissionTypeOwner ? YES : NO;
    EMTextViewController *controller = [[EMTextViewController alloc] initWithString:self.group.description placeholder:@"请输入群组简介" isEditable:isEditable];
    controller.title = @"群组简介";
    [self.navigationController pushViewController:controller animated:YES];
    
    __weak typeof(self) weakself = self;
    __weak typeof(controller) weakController = controller;
    [controller setDoneCompletion:^BOOL(NSString * _Nonnull aString) {
        [weakController showHudInView:weakController.view hint:@"更新群组简介..."];
        [[EMClient sharedClient].groupManager updateDescription:aString forGroup:weakself.groupId completion:^(EMGroup *aGroup, EMError *aError) {
            [weakController hideHud];
            if (!aError) {
                [weakself _resetGroup:aGroup];
                [weakController.navigationController popViewControllerAnimated:YES];
            } else {
                [EMAlertController showErrorAlert:@"更新群组简介失败"];
            }
        }];
        
        return NO;
    }];
}

- (void)_updateGroupOnwerAction
{
    if (self.group.permissionType != EMGroupPermissionTypeOwner) {
        return;
    }
    
    EMGroupOwnerViewController *controller = [[EMGroupOwnerViewController alloc] initWithGroup:self.group];
    __weak typeof(self) weakself = self;
    [controller setSuccessCompletion:^(EMGroup * _Nonnull aGroup) {
        [weakself _resetGroup:aGroup];
    }];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)_leaveOrDestroyGroupAction
{
    __weak typeof(self) weakself = self;
    void (^block)(EMError *aError) = ^(EMError *aError) {
        if (!aError) {
            [[EMClient sharedClient].chatManager deleteConversation:weakself.groupId isDeleteMessages:YES completion:^(NSString *aConversationId, EMError *aError) {
                [weakself hideHud];
                if (weakself.leaveOrDestroyCompletion) {
                    weakself.leaveOrDestroyCompletion();
                }
                [weakself.navigationController popViewControllerAnimated:YES];
            }];
        } else {
            
        }[weakself hideHud];
    };
    
    if (self.group.permissionType == EMGroupPermissionTypeOwner) {
        [self showHudInView:self.view hint:@"解散群组..."];
        [[EMClient sharedClient].groupManager destroyGroup:self.groupId finishCompletion:block];
    } else {
        [self showHudInView:self.view hint:@"离开群组..."];
        [[EMClient sharedClient].groupManager leaveGroup:self.groupId completion:block];
    }
}

- (void)addMemberAction
{
    NSMutableArray *occupants = [[NSMutableArray alloc] init];
    [occupants addObject:self.group.owner];
    [occupants addObjectsFromArray:self.group.adminList];
    [occupants addObjectsFromArray:self.group.memberList];
    EMInviteGroupMemberViewController *controller = [[EMInviteGroupMemberViewController alloc] initWithBlocks:occupants];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
    [self presentViewController:navController animated:YES completion:nil];
    
    __weak typeof(self) weakself = self;
    [controller setDoneCompletion:^(NSArray * _Nonnull aSelectedArray) {
        [weakself showHudInView:weakself.view hint:@"添加成员..."];
        [[EMClient sharedClient].groupManager addMembers:aSelectedArray toGroup:weakself.groupId message:@"" completion:^(EMGroup *aGroup, EMError *aError) {
            [weakself hideHud];
            if (aError) {
                [EMAlertController showErrorAlert:aError.errorDescription];
            } else {
                [weakself _fetchGroupWithId:weakself.groupId isShowHUD:NO];
            }
        }];
    }];
}

@end
