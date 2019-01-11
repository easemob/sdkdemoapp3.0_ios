//
//  EMNotificationViewController.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/10.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EMNotificationViewController.h"

#import "EMNotifications.h"
#import "EMNotificationCell.h"

@interface EMNotificationViewController ()<EMNotificationsDelegate, EMNotificationCellDelegate>

@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation EMNotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    self.dataArray = [[NSMutableArray alloc] init];
    [EMNotifications shared].delegate = self;
    
    [self _setupViews];
}

- (void)dealloc
{
    [EMNotifications shared].delegate = nil;
}

#pragma mark - Subviews

- (void)_setupViews
{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"back_gary"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(backAction)];
    self.title = @"申请与通知";
    
    self.tableView.backgroundColor = kColor_LightGray;
    self.tableView.estimatedRowHeight = 150;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[EMNotifications shared].notificationList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EMNotificationModel *model = [[EMNotifications shared].notificationList objectAtIndex:indexPath.row];
    NSString *cellIdentifier = [NSString stringWithFormat:@"EMNotificationCell_%@", @(model.status)];
    EMNotificationCell *cell = (EMNotificationCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[EMNotificationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.delegate = self;
    }
    
    cell.model = model;
    
    return cell;
}

#pragma mark - EMNotificationsDelegate

- (void)didNotificationListUpdate
{
    [self.tableView reloadData];
}

#pragma mark - EMNotificationCellDelegate

- (void)agreeNotification:(EMNotificationModel *)aModel
{
    [self showHudInView:self.view hint:@"处理请求..."];
    
    __weak typeof(self) weakself = self;
    void (^block) (EMError *aError) = ^(EMError *aError) {
        [weakself hideHud];
        if (!aError) {
            aModel.status = EMNotificationModelStatusAgreed;
            [[EMNotifications shared] archive];
            
            [weakself.tableView reloadData];
        }
    };
    
    if (aModel.type == EMNotificationModelTypeContact) {
        [[EMClient sharedClient].contactManager approveFriendRequestFromUser:aModel.sender completion:^(NSString *aUsername, EMError *aError) {
            block(aError);
        }];
    } else if (aModel.type == EMNotificationModelTypeGroupInvite) {
        [[EMClient sharedClient].groupManager acceptInvitationFromGroup:aModel.groupId inviter:aModel.sender completion:^(EMGroup *aGroup, EMError *aError) {
            block(aError);
        }];
    }
}

- (void)declineNotification:(EMNotificationModel *)aModel
{
    [self showHudInView:self.view hint:@"处理请求..."];
    
    __weak typeof(self) weakself = self;
    void (^block) (EMError *aError) = ^(EMError *aError) {
        [weakself hideHud];
        if (!aError) {
            aModel.status = EMNotificationModelStatusDeclined;
        } else {
            if (aError.code == EMErrorGroupInvalidId) {
                aModel.status = EMNotificationModelStatusExpired;
            }
        }
        
        [[EMNotifications shared] archive];
        [weakself.tableView reloadData];
    };
    
    if (aModel.type == EMNotificationModelTypeContact) {
        [[EMClient sharedClient].contactManager declineFriendRequestFromUser:aModel.sender completion:^(NSString *aUsername, EMError *aError) {
            block(aError);
        }];
    } else if (aModel.type == EMNotificationModelTypeGroupInvite) {
        [[EMClient sharedClient].groupManager declineGroupInvitation:aModel.groupId inviter:aModel.sender reason:nil completion:^(EMError *aError) {
            block(aError);
        }];
    }
}

#pragma mark - Action

- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
