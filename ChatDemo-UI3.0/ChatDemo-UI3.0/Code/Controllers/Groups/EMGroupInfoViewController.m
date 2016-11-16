//
//  EMGroupInfoViewController.m
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 16/10/7.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "EMGroupInfoViewController.h"
#import "EMUserModel.h"
#import "EMMemberCollectionCell.h"
#import "EMMemberSelectViewController.h"
#import "EMGroupPermissionCell.h"
#import "EMGroupMemberListViewController.h"
#import "EMNotificationNames.h"

#define KEM_DELETE_GROUP_TITLE    NSLocalizedString(@"group.deleteGroup", @"Delete Group")


@interface EMGroupInfoViewController ()<EMGroupManagerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITableViewDelegate, UITableViewDataSource, EMGroupUIProtocol>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (strong, nonatomic) IBOutlet UIImageView *groupAvatarImageView;
@property (strong, nonatomic) IBOutlet UILabel *groupSubjectLabel;
@property (strong, nonatomic) IBOutlet UILabel *memberCountLabel;
@property (strong, nonatomic) IBOutlet UIButton *showAllMembersBtn;

@property (strong, nonatomic) IBOutlet UICollectionView *membersCollection;
@property (strong, nonatomic) IBOutlet UIButton *footButton;

@property (nonatomic, strong) NSMutableArray<EMUserModel *> *occupants;
@property (nonatomic, strong) EMGroup *currentGroup;
@end

@implementation EMGroupInfoViewController
{
    NSMutableArray *_groupPermissions;
}

- (instancetype)initWithGroup:(EMGroup *)group
{
    self = [super initWithNibName:@"EMGroupInfoViewController" bundle:nil];
    if (self) {
        // Custom initialization
        _currentGroup = group;
        [[EMClient sharedClient].groupManager addDelegate:self delegateQueue:nil];
    }
    return self;
}

- (void)dealloc {
    [[EMClient sharedClient].groupManager removeDelegate:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"title.groupInfo", @"Group Info");
    [self setupNavigationItem];
    self.tableView.tableHeaderView = _headerView;
    self.tableView.tableFooterView = [UIView new];
    [self.membersCollection registerNib:[UINib nibWithNibName:@"EMMemberCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"EMMemberCollectionCell"];
    [self initBasicData];
}

#pragma mark - View Update Method

- (void)setupNavigationItem {
    //设置leftBarItems
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBtn.frame = CGRectMake(0, 0, 20, 20);
    [leftBtn setImage:[UIImage imageNamed:@"Icon_Back"] forState:UIControlStateNormal];
    [leftBtn setImage:[UIImage imageNamed:@"Icon_Back"] forState:UIControlStateHighlighted];
    [leftBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBar = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    [self.navigationItem setLeftBarButtonItem:leftBar];
}

- (void)updateViewData {
    if ([self isGroupOwner]) {
        [_footButton setTitle:KEM_DELETE_GROUP_TITLE forState:UIControlStateNormal];
        [_footButton setTitle:KEM_DELETE_GROUP_TITLE forState:UIControlStateHighlighted];
        
    }
    if (_currentGroup) {
        [self updateMemberCountDescription];
        _groupSubjectLabel.text = _currentGroup.subject;
    }
}

- (void)updateMemberCountDescription {
    _memberCountLabel.text = [NSString stringWithFormat:@"%@: %ld/%d",NSLocalizedString(@"group.participants", @"Participants"),(unsigned long)_occupants.count,2000];
}

#pragma mark - Data Update Method

- (void)initBasicData {
    _occupants = [NSMutableArray array];
    [self reloadPermissionData];
    [self fetchGroupInfo];
}

- (void)updateBasicData {
    NSArray *sectionData1 = @[NSLocalizedString(@"group.isPublic", @"Appear in group search"),NSLocalizedString(@"group.allowedOccupantInvite", @"Allow members to invite")];
    NSArray *sectionData2 = @[];
    _groupPermissions = [NSMutableArray arrayWithObjects:sectionData1, sectionData2, nil];
    [self.tableView reloadData];
}

- (void)fetchGroupInfo {
    WEAK_SELF
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[EMClient sharedClient].groupManager getGroupSpecificationFromServerByID:_currentGroup.groupId includeMembersList:YES completion:^(EMGroup *aGroup, EMError *aError) {
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
        if (!aError) {
            weakSelf.currentGroup = aGroup;
            [weakSelf reloadOccupants];
        }
    }];
}

- (void)reloadOccupants {
    [self.occupants removeAllObjects];
    
    NSMutableArray *occupants = [NSMutableArray arrayWithArray:self.currentGroup.occupants];
    [occupants removeObject:_currentGroup.owner];
    [occupants insertObject:_currentGroup.owner atIndex:0];
    for (NSString *hyphenateId in occupants) {
        EMUserModel *model = [[EMUserModel alloc] initWithHyphenateId:hyphenateId];
        if (model) {
            [self.occupants addObject:model];
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateViewData];
        [self.membersCollection reloadData];
    });
}

- (void)reloadPermissionData {
    _groupPermissions = [NSMutableArray array];
    NSMutableArray *sectionData1 = [NSMutableArray array];
    BOOL isPublic = _currentGroup.setting.style > EMGroupStylePrivateMemberCanInvite;
    BOOL isOwner = [self isGroupOwner];
    
    EMGroupPermissionModel *model = [[EMGroupPermissionModel alloc] init];
    model.title = NSLocalizedString(@"group.id",@"Group ID");
    model.isEdit = NO;
    model.permissionDescription = self.currentGroup.groupId;
    model.type = EMGroupPermissionType_groupId;
    [sectionData1 addObject:model];
    
    model = [[EMGroupPermissionModel alloc] init];
    model.title = isOwner ? NSLocalizedString(@"group.isPublic", @"Appear in group search") : NSLocalizedString(@"group.groupType", @"Group Type");
    model.isEdit = NO;
    model.permissionDescription = isPublic ? NSLocalizedString(@"group.public", @"Public") : NSLocalizedString(@"group.private", @"Private");
    model.type = EMGroupPermissionType_groupType;
    [sectionData1 addObject:model];
    
    model = [[EMGroupPermissionModel alloc] init];
    if (isOwner) {
        model.title = isPublic ? NSLocalizedString(@"group.openJoin", @"Join the group freely") : NSLocalizedString(@"group.allowedOccupantInvite", @"Allow members to invite");
        model.isEdit = NO;
        model.type = isPublic ? EMGroupPermissionType_openJoin : EMGroupPermissionType_canAllInvite;
        model.permissionDescription = _currentGroup.setting.style == EMGroupStylePrivateMemberCanInvite ? NSLocalizedString(@"group.enabled", @"Enabled") : NSLocalizedString(@"group.disabled", @"Disabled");
    }
    else {
        model.title = NSLocalizedString(@"group.block", @"Block");
        model.isEdit = YES;
        model.type = EMGroupPermissionType_mute;
        model.switchState = _currentGroup.isBlocked;
    }
    [sectionData1 addObject:model];
    
    if (!isOwner && !_currentGroup.isBlocked) {
        model = [[EMGroupPermissionModel alloc] init];
        model.title = NSLocalizedString(@"group.pushNotification", @"Push Notification");
        model.isEdit = YES;
        model.type = EMGroupPermissionType_pushSetting;
        model.switchState = _currentGroup.isPushNotificationEnabled;
        [sectionData1 addObject:model];
    }
    [_groupPermissions addObject:sectionData1];
    
    if (isOwner) {
        NSMutableArray *sectionData2 = [NSMutableArray array];
        model = [[EMGroupPermissionModel alloc] init];
        model.title = NSLocalizedString(@"group.pushNotification", @"Push Notification");
        model.isEdit = YES;
        model.type = EMGroupPermissionType_pushSetting;
        model.switchState = _currentGroup.isPushNotificationEnabled;
        [sectionData2 addObject:model];
        [_groupPermissions addObject:sectionData2];
    }
}

- (BOOL)isGroupOwner {
    NSString *currentUser = [EMClient sharedClient].currentUsername;
    if (_currentGroup.owner.length > 0 && [currentUser isEqualToString:_currentGroup.owner]) {
        return YES;
    }
    return NO;
}

- (BOOL)isCanInvite {
    return ([self isGroupOwner] || _currentGroup.setting.style == EMGroupStylePrivateMemberCanInvite);
}

#pragma mark - Action Method
- (void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)deleteOrLeaveGroupAction:(UIButton *)sender {
    WEAK_SELF
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    if ([self isGroupOwner]) {
        [[EMClient sharedClient].groupManager destroyGroup:self.currentGroup.groupId completion:^(EMGroup *aGroup, EMError *aError) {
            [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
            if (aError) {
                [weakSelf showAlertWithMessage:NSLocalizedString(@"group.destroyFailure", @"Destroy group failure")];
            }
            else{
                [[NSNotificationCenter defaultCenter] postNotificationName:KEM_REFRESH_GROUPLIST_NOTIFICATION object:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:KEM_REMOVEGROUP_NOTIFICATION object:nil];
            }
        }];
    }
    else {
        [[EMClient sharedClient].groupManager leaveGroup:self.currentGroup.groupId completion:^(EMGroup *aGroup, EMError *aError) {
            [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
            if (aError) {
                [weakSelf showAlertWithMessage:NSLocalizedString(@"group.leaveFailure", @"Leave group failure")];
            }
            else{
                [[NSNotificationCenter defaultCenter] postNotificationName:KEM_REFRESH_GROUPLIST_NOTIFICATION object:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:KEM_REMOVEGROUP_NOTIFICATION object:nil];
            }
        }];
    }
    
}
- (IBAction)showAllMembersAction:(UIButton *)sender {
    EMGroupMemberListViewController *memberListVc;
    memberListVc = [[EMGroupMemberListViewController alloc] initWithGroup:_currentGroup occupants:_occupants];
    memberListVc.delegate = self;
    [self.navigationController pushViewController:memberListVc animated:YES];
}

- (void)permissionSelectAction:(UISwitch *)permissionSwitch {
    if (permissionSwitch.tag == EMGroupPermissionType_mute) {
        if (permissionSwitch.isOn != _currentGroup.isBlocked) {
            if (permissionSwitch.isOn) {
                [self blockGroupMessages];
            }
            else {
                [self unblockGroupMessages];
            }
        }
    }
    else if (permissionSwitch.tag == EMGroupPermissionType_pushSetting) {
        if (permissionSwitch.isOn != _currentGroup.isPushNotificationEnabled) {
            [self isPushEnabled:permissionSwitch.isOn];
        }
    }
}

- (void)isPushEnabled:(BOOL)isCanPush {
    WEAK_SELF
    [[EMClient sharedClient].groupManager updatePushServiceForGroup:_currentGroup.groupId
                                                      isPushEnabled:isCanPush
                                                         completion:^(EMGroup *aGroup, EMError *aError) {
                                                             NSString *message = @"";
                                                             if (!aError) {
                                                                 message = NSLocalizedString(@"group.setSuccess", @"Set success");
                                                             }
                                                             else {
                                                                 message = NSLocalizedString(@"group.setFailure", @"Set failure");
                                                             }
                                                             [weakSelf showAlertWithMessage:message];
                                                         }];
}


- (void)blockGroupMessages {
    WEAK_SELF
    [[EMClient sharedClient].groupManager blockGroup:_currentGroup.groupId
                                          completion:^(EMGroup *aGroup, EMError *aError) {
                                              NSString *message = @"";
                                              if (aError) {
                                                  message = NSLocalizedString(@"group.blockGroupFailure", @"Block group failure");
                                              }
                                              else {
                                                  message = NSLocalizedString(@"group.blockGroupSuccess", @"Block group success");
                                                  [weakSelf reloadPermissionData];
                                              }
                                              [weakSelf.tableView reloadData];
                                              [weakSelf showAlertWithMessage:message];
                                              
                                          }];
}

- (void)unblockGroupMessages {
    WEAK_SELF
    [[EMClient sharedClient].groupManager unblockGroup:_currentGroup.groupId
                                            completion:^(EMGroup *aGroup, EMError *aError) {
                                                NSString *message = @"";
                                                if (aError) {
                                                    message = NSLocalizedString(@"group.unblockGroupFailure", @"Unblock group failure");
                                                }
                                                else {
                                                    message = NSLocalizedString(@"group.unblockGroupSuccess", @"Unblock group success");
                                                    [weakSelf reloadPermissionData];
                                                }
                                                [weakSelf.tableView reloadData];
                                                [weakSelf showAlertWithMessage:message];
                                            }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _groupPermissions.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *permissions = _groupPermissions[section];
    return permissions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"EMGroupPermissionCell";
    EMGroupPermissionCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"EMGroupPermissionCell" owner:self options:nil] lastObject];
    }
    NSArray *permissions = _groupPermissions[indexPath.section];
    cell.model = permissions[indexPath.row];
    cell.permissionSwitch.tag = cell.model.type;
    [cell.permissionSwitch addTarget:self
                              action:@selector(permissionSelectAction:)
                    forControlEvents:UIControlEventValueChanged];
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = tableView.backgroundColor;
    return view;
    
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    if ([self isCanInvite]) {
        return 2;
    }
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if ([self isCanInvite] && section == 0) {
        return 1;
    }
    return _occupants.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    EMMemberCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"EMMemberCollectionCell" forIndexPath:indexPath];
    if ([self isCanInvite] &&
        indexPath.section == 0) {
        cell.model = nil;
    }
    else {
        cell.model = _occupants[indexPath.row];
    }
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    if ([self isCanInvite] && indexPath.section == 0) {
        EMMemberSelectViewController *selectVc = [[EMMemberSelectViewController alloc] initWithInvitees:_currentGroup.occupants];
        selectVc.style = EMContactSelectStyle_Invite;
        selectVc.delegate = self;
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:selectVc];
        selectVc.title = NSLocalizedString(@"title.inviteContacts", @"Invite Contacts");
        [self presentViewController:nav animated:YES completion:nil];
    }
}


#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(collectionView.frame.size.width / 5, collectionView.frame.size.height);
}

#pragma mark - EMGroupManagerDelegate
- (void)groupInvitationDidApprove:(EMGroup *)aGroup
                          invitee:(NSString *)aInvitee
{
    if ([aGroup.groupId isEqualToString:_currentGroup.groupId]) {
        [self fetchGroupInfo];
    }
}

#pragma mark - EMGroupUIProtocol

- (void)removeSelectOccupants:(NSArray<EMUserModel *> *)modelArray {
    [_occupants removeObjectsInArray:modelArray];
    [_membersCollection reloadData];
    [self updateMemberCountDescription];
}

- (void)addSelectOccupants:(NSArray<EMUserModel *> *)modelArray {
    __block NSMutableArray *invitees = [NSMutableArray array];
    [modelArray enumerateObjectsUsingBlock:^(EMUserModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [invitees addObject:obj.hyphenateId];
    }];
    if (invitees.count > 0) {
        WEAK_SELF
        [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        [[EMClient sharedClient].groupManager addMembers:invitees toGroup:self.currentGroup.groupId message:@"" completion:^(EMGroup *aGroup, EMError *aError) {
            [MBProgressHUD hideAllHUDsForView:weakSelf.navigationController.view animated:YES];
            if (!aError) {
                [weakSelf reloadOccupants];
                [[NSNotificationCenter defaultCenter] postNotificationName:KEM_REFRESH_GROUPLIST_NOTIFICATION object:nil];
            }
            else {
                NSString *msg = NSLocalizedString(@"group.inviteFailure", @"invite contacts to group failure");
                [weakSelf showAlertWithMessage:msg];
            }
        }];
    }
}


@end
