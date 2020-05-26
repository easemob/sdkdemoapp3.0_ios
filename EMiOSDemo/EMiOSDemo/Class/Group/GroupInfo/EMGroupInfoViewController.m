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
#import "EMGroupManageViewController.h"
#import "EMGroupAllMembersViewController.h"
#import "EMChatViewController.h"

@interface EMGroupInfoViewController ()<EMMultiDevicesDelegate>

@property (nonatomic, strong) NSString *groupId;
@property (nonatomic, strong) EMGroup *group;

@property (nonatomic, strong) EMAvatarNameCell *addMemberCell;
@property (nonatomic, strong) UITableViewCell *leaveCell;

@end

@implementation EMGroupInfoViewController

- (instancetype)initWithGroupId:(NSString *)aGroupId
{
    self = [super init];
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
    self.showRefreshHeader = YES;
    [self _fetchGroupWithId:self.groupId isShowHUD:YES];
    
    [[EMClient sharedClient] addMultiDevicesDelegate:self delegateQueue:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleGroupInfoUpdated:) name:GROUP_INFO_UPDATED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadInfo) name:GROUP_INFO_REFRESH object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    __weak typeof(self) weakself = self;
    [EMClient.sharedClient.groupManager getGroupSpecificationFromServerWithId:self.groupId completion:^(EMGroup *aGroup, EMError *aError) {
        weakself.group = aGroup;
        [weakself reloadInfo];
        [weakself _resetGroup:aGroup];
    }];
}

- (void)reloadInfo
{
    [self.tableView reloadData];
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
    self.title = @"群组信息";

    self.tableView.rowHeight = 60;
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.backgroundColor = [UIColor whiteColor];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    
    self.addMemberCell = [[EMAvatarNameCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"EMAvatarNameCell"];
    self.addMemberCell.avatarView.image = [UIImage imageNamed:@"group_join"];
    self.addMemberCell.nameLabel.textColor = kColor_Blue;
    self.addMemberCell.nameLabel.text = @"邀请成员";
    self.addMemberCell.separatorInset = UIEdgeInsetsMake(0, [UIScreen mainScreen].bounds.size.width, 0, 0);
    
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
        if ((self.group.setting.style == EMGroupStylePrivateOnlyOwnerInvite || self.group.setting.style == EMGroupStylePublicJoinNeedApproval) && (self.group.permissionType == EMGroupPermissionTypeOwner || self.group.permissionType == EMGroupPermissionTypeAdmin)) {
            count = 3;
        } else if (self.group.setting.style == EMGroupStylePrivateMemberCanInvite) {
            count = 3;
        } else {
            count = 2;
        }
    } else if (section == 1) {
        if (self.group.permissionType == EMGroupPermissionTypeOwner || self.group.permissionType == EMGroupPermissionTypeAdmin) {
            count = 5;
        } else {
            count = 4;
        }
    } else if (section == 2) {
        count = 1;
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
    NSString *cellIdentifier = @"UITableViewCellValue1";
    if (section == 0 && row == 0) {
        cellIdentifier = @"UITableViewCellStyleSubtitle";
    }
    
    UISwitch *switchControl = nil;
    BOOL isSwitchCell = NO;
    if (section == 3) {
        isSwitchCell = YES;
        cellIdentifier = @"UITableViewCellSwitch";
    }

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    // Configure the cell...
    if (cell == nil) {
        if (section == 0 && row == 0) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        } else {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (isSwitchCell) {
            switchControl = [[UISwitch alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width - 65, 20, 50, 40)];
            switchControl.tag = [self _tagWithIndexPath:indexPath];
            [switchControl addTarget:self action:@selector(cellSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
            [cell.contentView addSubview:switchControl];
        }
    } else if (isSwitchCell) {
        switchControl = [cell.contentView viewWithTag:[self _tagWithIndexPath:indexPath]];
    }
    
    if (section == 4 && row == 0) {
        return self.leaveCell;
    } else if (section == 0 && row == 2) {
        return self.addMemberCell;
    }
    
    cell.separatorInset = UIEdgeInsetsMake(0, 16, 0, 16);
    cell.detailTextLabel.textColor = [UIColor grayColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    if (section == 0) {
        if (row == 0) {
            cell.imageView.image = [UIImage imageNamed:@"group_avatar"];
            cell.textLabel.font = [UIFont systemFontOfSize:18.0];
            cell.detailTextLabel.font = [UIFont systemFontOfSize:12.0];
            cell.textLabel.text = self.group.subject;
            if (self.group.description && ![self.group.description isEqualToString:@""]) {
                cell.detailTextLabel.text = self.group.description;
            } else {
                cell.detailTextLabel.text = @"群主很懒，还没有群介绍哦～";
            }
            cell.accessoryType = UITableViewCellAccessoryNone;
        } else if (row == 1) {
            cell.textLabel.text = @"群聊成员";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"共%lu人",self.group.occupantsCount];
            cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, [UIScreen mainScreen].bounds.size.width);
        }
    } else if (section == 1) {
        if (row == 0) {
            cell.textLabel.text = @"群聊名称";
            cell.detailTextLabel.text = self.group.subject;
            cell.accessoryType = self.group.permissionType == EMGroupPermissionTypeOwner ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
        } else if (row == 1) {
            cell.textLabel.text = @"共享文件";
            cell.detailTextLabel.text = @"";
        } else if (row == 2) {
            cell.textLabel.text = @"群公告";
            cell.detailTextLabel.text = @"";
        } else if (row == 3) {
            cell.textLabel.text = @"群介绍";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",self.group.description];
            cell.accessoryType = self.group.permissionType == EMGroupPermissionTypeOwner ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
        } else if (row == 4) {
            cell.textLabel.text = @"群管理";
            cell.detailTextLabel.text = @"";
        }
    }  else if (section == 2) {
        if (row == 0) {
            cell.textLabel.text = @"查找聊天记录";
            cell.detailTextLabel.text = @"";
        }
    } else if (section == 3) {
        if (row == 0) {
            cell.textLabel.text = @"消息免打扰";
            [switchControl setOn:!self.group.isPushNotificationEnabled animated:NO];
        } else if (row == 1) {
            cell.textLabel.text = @"会话置顶";
            EMConversation *conversastion = [[EMClient sharedClient].chatManager getConversation:self.group.groupId type:EMConversationTypeGroupChat createIfNotExist:NO];
            [switchControl setOn:([conversastion.ext objectForKey:CONVERSATION_STICK] && ![(NSNumber *)[conversastion.ext objectForKey:CONVERSATION_STICK] isEqualToNumber:[NSNumber numberWithLong:0]]) animated:NO];
        }
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 2) {
        return 50;
    }
    
    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    
    if (section == 0) {
        return 0.001;
    }
    
    return 20.0;
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
            //群成员
            EMGroupAllMembersViewController *controller = [[EMGroupAllMembersViewController alloc]initWithGroup:self.group];
            [self.navigationController pushViewController:controller animated:YES];
        } else if (row == 2) {
            //邀请成员
            [self addMemberAction];
        }
    } else if (section == 1) {
        if (row == 0) {
            //修改群名称
            [self _updateGroupNameAction];
        } else if (row == 1) {
            //群共享文件
            EMGroupSharedFilesViewController *controller = [[EMGroupSharedFilesViewController alloc] initWithGroup:self.group];
            [self.navigationController pushViewController:controller animated:YES];
        } else if (row == 2) {
            [self groupAnnouncementAction];
        } else if (row == 3) {
            //群介绍
            [self _updateGroupDetailAction];
        } else if (row == 4) {
            //群管理
            EMGroupManageViewController *controller = [[EMGroupManageViewController alloc]initWithGroup:self.groupId];
            [self.navigationController pushViewController:controller animated:YES];
        }
    } else if (section == 2) {
        if (row == 0) {
            //查找聊天记录
            EMChatViewController *controller = [[EMChatViewController alloc]initWithConversationId:self.group.groupId type:EMConversationTypeGroupChat createIfNotExist:NO isChatRecord:YES];
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
//cell开关
- (void)cellSwitchValueChanged:(UISwitch *)aSwitch
{
    NSIndexPath *indexPath = [self _indexPathWithTag:aSwitch.tag];
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (section == 3) {
        if (row == 0) {
            //免打扰
            __weak typeof(self) weakself = self;
            [EMClient.sharedClient.groupManager updatePushServiceForGroup:self.group.groupId isPushEnabled:aSwitch.isOn ? NO : YES completion:^(EMGroup *aGroup, EMError *aError) {
                weakself.group = aGroup;
                [weakself reloadInfo];
            }];
        } else if (row == 1) {
            //置顶
            EMConversation *conversation = [[EMClient sharedClient].chatManager getConversation:self.group.groupId type:EMConversationTypeGroupChat createIfNotExist:NO];
            NSMutableDictionary *ext = [[NSMutableDictionary alloc]initWithDictionary:conversation.ext];
            NSDate *date = [NSDate date];
            NSDateFormatter *format=[[NSDateFormatter alloc]init];
            [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSDate *time = [format dateFromString:[format stringFromDate:date]];
            NSTimeInterval stickTimeInterval = [time timeIntervalSince1970];
            NSNumber *stickTime = [NSNumber numberWithLong:stickTimeInterval];
            if (aSwitch.isOn) {
                [ext setObject:stickTime forKey:CONVERSATION_STICK];
            } else {
                [ext setObject:[NSNumber numberWithLong:0] forKey:CONVERSATION_STICK];
            }
            [conversation setExt:ext];
        }
    }
}

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
            NSString *hint;
            if (isEditable) {
                hint = @"请输入群组公告";
            } else {
                hint = @"暂无群公告哦～";
            }
            EMTextViewController *controller = [[EMTextViewController alloc] initWithString:aAnnouncement placeholder:hint isEditable:isEditable];
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
/*
//获取我的群昵称
- (NSString *)acquireGroupNickNamkeOfMine
{
    NSMutableDictionary *nickNameDict = [self changeStringToDictionary:self.group.setting.ext];
    if (nickNameDict) {
        return [nickNameDict objectForKey:EMClient.sharedClient.currentUsername];
    }
    return EMClient.sharedClient.currentUsername;
}

//修改我的群昵称
- (void)_updateGroupNickNameOfMine
{
    EMTextFieldViewController *controller = [[EMTextFieldViewController alloc] initWithString:[self acquireGroupNickNamkeOfMine] placeholder:@"输入你的群昵称" isEditable:YES];
    controller.title = @"编辑群昵称";
    [self.navigationController pushViewController:controller animated:YES];
    
    __weak typeof(self) weakself = self;
    __weak typeof(controller) weakController = controller;
    [controller setDoneCompletion:^BOOL(NSString * _Nonnull aString) {
        NSMutableDictionary *nickNameDic = [weakself changeStringToDictionary:weakself.group.setting.ext];
        if (!nickNameDic) {
            nickNameDic = [[NSMutableDictionary alloc]init];
        }
        if ([aString length] == 0) {
            [nickNameDic setObject:EMClient.sharedClient.currentUsername forKey:EMClient.sharedClient.currentUsername];
        } else {
            [nickNameDic setObject:aString forKey:EMClient.sharedClient.currentUsername];
        }
        [weakController showHudInView:weakController.view hint:@"更新我的群昵称..."];
        [weakController hideHud];
        //修改我的群昵称
        NSData *data=[NSJSONSerialization dataWithJSONObject:nickNameDic options:NSJSONWritingPrettyPrinted error:nil];
        NSString *str=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        //[weakself.group.setting setExt:str];
        [EMClient.sharedClient.groupManager updateGroupExtWithId:weakself.group.groupId ext:str completion:^(EMGroup *aGroup, EMError *aError) {
            NSLog(@"%@", [NSString stringWithFormat:@"ext :    %@",weakself.group.setting.ext]);
            [weakself.tableView reloadData];
            [weakController.navigationController popViewControllerAnimated:YES];

        }];
        return NO;
    }];
}
*/
- (void)_updateGroupNameAction
{
    BOOL isEditable = self.group.permissionType == EMGroupPermissionTypeOwner ? YES : NO;
    if (!isEditable) {
        return;
    }
    EMTextFieldViewController *controller = [[EMTextFieldViewController alloc] initWithString:self.group.subject placeholder:@"输入群聊名称" isEditable:isEditable];
    controller.title = @"编辑群聊名称";
    [self.navigationController pushViewController:controller animated:YES];
    
    __weak typeof(self) weakself = self;
    __weak typeof(controller) weakController = controller;
    [controller setDoneCompletion:^BOOL(NSString * _Nonnull aString) {
        if ([aString length] == 0) {
            [EMAlertController showErrorAlert:@"群聊名称不能为空"];
            return NO;
        }
        
        [weakController showHudInView:weakController.view hint:@"更新群聊名称..."];
        [[EMClient sharedClient].groupManager updateGroupSubject:aString forGroup:weakself.groupId completion:^(EMGroup *aGroup, EMError *aError) {
            [weakController hideHud];
            if (!aError) {
                [weakself _resetGroup:aGroup];
                [weakController.navigationController popViewControllerAnimated:YES];
            } else {
                [EMAlertController showErrorAlert:@"更新群聊名称失败"];
            }
        }];
        
        return NO;
    }];
}

- (void)_updateGroupDetailAction
{
    BOOL isEditable = self.group.permissionType == EMGroupPermissionTypeOwner ? YES : NO;
    EMTextViewController *controller = [[EMTextViewController alloc] initWithString:self.group.description placeholder:@"请输入群介绍" isEditable:isEditable];
    if (isEditable) {
         controller.title = @"编辑群介绍";
    } else {
        controller.title = @"群介绍";
    }
    [self.navigationController pushViewController:controller animated:YES];
    
    __weak typeof(self) weakself = self;
    __weak typeof(controller) weakController = controller;
    [controller setDoneCompletion:^BOOL(NSString * _Nonnull aString) {
        [weakController showHudInView:weakController.view hint:@"更新群介绍..."];
        [[EMClient sharedClient].groupManager updateDescription:aString forGroup:weakself.groupId completion:^(EMGroup *aGroup, EMError *aError) {
            [weakController hideHud];
            if (!aError) {
                [weakself _resetGroup:aGroup];
                [weakController.navigationController popViewControllerAnimated:YES];
            } else {
                [EMAlertController showErrorAlert:@"更新群介绍失败"];
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
    
#pragma mark - Private

- (NSInteger)_tagWithIndexPath:(NSIndexPath *)aIndexPath
{
    NSInteger tag = aIndexPath.section * 10 + aIndexPath.row;
    return tag;
}

- (NSIndexPath *)_indexPathWithTag:(NSInteger)aTag
{
    NSInteger section = aTag / 10;
    NSInteger row = aTag % 10;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
    return indexPath;
}

//string TO dictonary
- (NSMutableDictionary *)changeStringToDictionary:(NSString *)string{

    if (string) {
        NSMutableDictionary *returnDic = [[NSMutableDictionary  alloc]  init];
        returnDic = [NSJSONSerialization JSONObjectWithData:[string dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
        return returnDic;
    }
    return nil;
}


@end
