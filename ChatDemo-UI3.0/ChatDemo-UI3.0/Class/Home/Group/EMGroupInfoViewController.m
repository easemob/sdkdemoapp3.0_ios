//
//  EMGroupInfoViewController.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/18.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EMGroupInfoViewController.h"

#import "EMTextFieldViewController.h"
#import "EMTextViewController.h"
#import "EMGroupOwnerViewController.h"
#import "EMGroupSharedFilesViewController.h"
#import "EMGroupSettingsViewController.h"

@interface EMGroupInfoViewController ()

@property (nonatomic, strong) NSString *groupId;
@property (nonatomic, strong) EMGroup *group;
@property (nonatomic) BOOL isOwner;

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
}

- (void)dealloc
{
//    [[EMClient sharedClient].groupManager removeDelegate:self];
}

#pragma mark - Subviews

- (void)_setupSubviews
{
    [self addPopBackLeftItem];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@""] style:UIBarButtonItemStylePlain target:self action:@selector(groupAnnouncementAction)];
    self.title = @"群组信息";
    
    self.showRefreshHeader = YES;

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
        count = 1;
    }  else if (section == 2) {
        count = self.isOwner ? 3 : 1;
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
            cell.accessoryType = self.isOwner ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
        } else if (row == 2) {
            cell.textLabel.text = @"简介";
            cell.detailTextLabel.text = self.group.description;
            cell.accessoryType = self.isOwner ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
        } else if (row == 3) {
            cell.textLabel.text = @"群主";
            cell.detailTextLabel.text = self.group.owner;
            cell.accessoryType = self.isOwner ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
        }
    } else if (section == 1) {
        if (row == 0) {
            cell.textLabel.text = @"群组成员";
            cell.detailTextLabel.text = @([self.group.memberList count]).stringValue;
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
//            cell.detailTextLabel.text = @([self.group.sharedFileList count]).stringValue;
        } else if (row == 1) {
            cell.textLabel.text = @"群组设置";
            cell.detailTextLabel.text = nil;
        }
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && indexPath.row == 1) {
        return 75;
    }
    
    return 55;
}

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
    if (section == 0 && self.isOwner) {
        if (row == 1) {
            [self _updateGroupNameAction];
        } else if (row == 2) {
            [self _updateGroupDetailAction];
        } else if (row == 3) {
            [self _updateGroupOnwerAction];
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

//#pragma mark - EMGroupManagerDelegate
//
//- (void)groupFileListDidUpdate:(EMGroup *)aGroup
//               addedSharedFile:(EMGroupSharedFile *)aSharedFile
//{
//    [self _reloadSharedFilesCell];
//}
//
//- (void)groupFileListDidUpdate:(EMGroup *)aGroup
//             removedSharedFile:(NSString *)aFileId
//{
//    [self _reloadSharedFilesCell];
//}

#pragma mark - Data

//- (void)_reloadSharedFilesCell
//{
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:3];
//    [self.tableView beginUpdates];
//    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
//    [self.tableView endUpdates];
//}

- (void)_resetGroup:(EMGroup *)aGroup
{
    self.group = aGroup;
    self.isOwner = [aGroup.owner isEqualToString:[EMClient sharedClient].currentUsername] ? YES : NO;
    if (self.isOwner) {
        self.leaveCell.textLabel.text = @"销毁群组";
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

#pragma mark - Action

- (void)groupAnnouncementAction
{
    __weak typeof(self) weakself = self;
    [self showHudInView:self.view hint:@"获取群组公告..."];
    [[EMClient sharedClient].groupManager getGroupAnnouncementWithId:self.groupId completion:^(NSString *aAnnouncement, EMError *aError) {
        [weakself hideHud];
        if (!aError) {
            BOOL isEditable = weakself.isOwner;
            if (!isEditable) {
                isEditable = [weakself.group.adminList containsObject:[EMClient sharedClient].currentUsername];
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
    EMTextFieldViewController *controller = [[EMTextFieldViewController alloc] initWithString:self.group.subject placeholder:@"请输入群组名称"];
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
    EMTextViewController *controller = [[EMTextViewController alloc] initWithString:self.group.description placeholder:@"请输入群组简介" isEditable:self.isOwner];
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
        [weakself hideHud];
        if (!aError) {
            if (weakself.leaveOrDestroyCompletion) {
                weakself.leaveOrDestroyCompletion();
            }
            [weakself.navigationController popViewControllerAnimated:YES];
        }
    };
    
    if (self.isOwner) {
        [self showHudInView:self.view hint:@"销毁群组..."];
        [[EMClient sharedClient].groupManager destroyGroup:self.groupId finishCompletion:block];
    } else {
        [self showHudInView:self.view hint:@"离开群组..."];
        [[EMClient sharedClient].groupManager leaveGroup:self.groupId completion:block];
    }
}

@end
