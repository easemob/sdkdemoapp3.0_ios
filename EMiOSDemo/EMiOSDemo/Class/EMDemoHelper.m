//
//  EMDemoHelper.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/18.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EMDemoHelper.h"

#import "EMGlobalVariables.h"

#import "EMConversationHelper.h"
#import "EMNotificationViewController.h"
#import "EMChatViewController.h"
#import "EMGroupsViewController.h"
#import "EMGroupInfoViewController.h"
#import "EMChatroomsViewController.h"
#import "EMChatroomInfoViewController.h"
#import "EMRemindManager.h"

static EMDemoHelper *helper = nil;
@implementation EMDemoHelper

+ (instancetype)shareHelper
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        helper = [[EMDemoHelper alloc] init];
    });
    return helper;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self _initHelper];
    }
    return self;
}

- (void)dealloc
{
    [[EMClient sharedClient] removeDelegate:self];
    [[EMClient sharedClient] removeMultiDevicesDelegate:self];
    [[EMClient sharedClient].groupManager removeDelegate:self];
    [[EMClient sharedClient].contactManager removeDelegate:self];
    [[EMClient sharedClient].chatManager removeDelegate:self];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - init

- (void)_initHelper
{
    [[EMClient sharedClient] addDelegate:self delegateQueue:nil];
    [[EMClient sharedClient] addMultiDevicesDelegate:self delegateQueue:nil];
    [[EMClient sharedClient].groupManager addDelegate:self delegateQueue:nil];
    [[EMClient sharedClient].contactManager addDelegate:self delegateQueue:nil];
    [[EMClient sharedClient].chatManager addDelegate:self delegateQueue:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePushNotificationController:) name:NOTIF_PUSHVIEWCONTROLLER object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePushChatController:) name:CHAT_PUSHVIEWCONTROLLER object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePushGroupsController:) name:GROUP_LIST_PUSHVIEWCONTROLLER object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePushGroupInfoController:) name:GROUP_INFO_PUSHVIEWCONTROLLER object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePushChatroomsController:) name:CHATROOM_LIST_PUSHVIEWCONTROLLER object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePushChatroomInfoController:) name:CHATROOM_INFO_PUSHVIEWCONTROLLER object:nil];
}

#pragma mark - EMClientDelegate

// 网络状态变化回调
- (void)didConnectionStateChanged:(EMConnectionState)connectionState
{
//    [gMainController networkChanged:connectionState];
}

- (void)autoLoginDidCompleteWithError:(EMError *)error
{
    if (error) {
        [self showAlertWithMessage:@"自动登录失败，请重新登录"];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:ACCOUNT_LOGIN_CHANGED object:@NO];
    }
}

- (void)userAccountDidLoginFromOtherDevice
{
    [[EMClient sharedClient] logout:NO];
    [self showAlertWithMessage:@"你的账号已在其他地方登录"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ACCOUNT_LOGIN_CHANGED object:@NO];
}

- (void)userAccountDidRemoveFromServer
{
    EMDemoOptions *options = [EMDemoOptions sharedOptions];
    options.isAutoLogin = NO;
    [options archive];
    [[EMClient sharedClient] logout:NO];
    [self showAlertWithMessage:@"你的账号已被从服务器端移除"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ACCOUNT_LOGIN_CHANGED object:@NO];
}

- (void)userDidForbidByServer
{
    EMDemoOptions *options = [EMDemoOptions sharedOptions];
    options.isAutoLogin = NO;
    [options archive];
    [[EMClient sharedClient] logout:NO];
    [self showAlertWithMessage:@"账号被禁用"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ACCOUNT_LOGIN_CHANGED object:@NO];
}

- (void)userAccountDidForcedToLogout:(EMError *)aError
{
    [[EMClient sharedClient] logout:NO];
    [self showAlertWithMessage:aError.errorDescription];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ACCOUNT_LOGIN_CHANGED object:@NO];
}

#pragma mark - EMMultiDevicesDelegate

- (void)multiDevicesContactEventDidReceive:(EMMultiDevicesEvent)aEvent
                                  username:(NSString *)aTarget
                                       ext:(NSString *)aExt
{
    NSString *message = [NSString stringWithFormat:@"%li-%@-%@", (long)aEvent, aTarget, aExt];
    [self showAlertWithTitle:@"多设备[好友]" message:message];
}

- (void)multiDevicesGroupEventDidReceive:(EMMultiDevicesEvent)aEvent
                                 groupId:(NSString *)aGroupId
                                     ext:(id)aExt
{
    NSString *message = [NSString stringWithFormat:@"%li-%@-%@", (long)aEvent, aGroupId, aExt];
    [self showAlertWithTitle:@"多设备[群组]" message:message];
}

#pragma mark - EMChatManagerDelegate

- (void)messagesDidReceive:(NSArray *)aMessages
{
    for (EMMessage *msg in aMessages) {
        [EMRemindManager remindMessage:msg];
    }
}

#pragma mark - EMGroupManagerDelegate

- (void)didLeaveGroup:(EMGroup *)aGroup
               reason:(EMGroupLeaveReason)aReason
{
    NSString *str = nil;
    if (aReason == EMGroupLeaveReasonBeRemoved) {
        str = [NSString stringWithFormat:@"你被踢出群组: %@ [%@]", aGroup.groupName, aGroup.groupId];
    } else if (aReason == EMGroupLeaveReasonDestroyed) {
        str = [NSString stringWithFormat:@"群组被解散: %@ [%@]", aGroup.groupName, aGroup.groupId];
    }
    
    if (str.length > 0) {
        [EMAlertController showInfoAlert:str];
    }
}

- (void)didReceiveJoinGroupApplication:(EMGroup *)aGroup
                             applicant:(NSString *)aApplicant
                                reason:(NSString *)aReason
{
//    if (!aGroup || !aApplicant) {
//        return;
//    }
//
//    if (!aReason || aReason.length == 0) {
//        aReason = [NSString stringWithFormat:NSLocalizedString(@"group.applyJoin", @"%@ apply to join groups\'%@\'"), aApplicant, aGroup.groupName];
//    }
//    else{
//        aReason = [NSString stringWithFormat:NSLocalizedString(@"group.applyJoinWithName", @"%@ apply to join groups\'%@\'：%@"), aApplicant, aGroup.groupName, aReason];
//    }
//
//    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:@{@"title":aGroup.groupName, @"groupId":aGroup.groupId, @"username":aApplicant, @"groupname":aGroup.groupName, @"applyMessage":aReason, @"applyStyle":[NSNumber numberWithInteger:ApplyStyleJoinGroup]}];
//    [[ApplyViewController shareController] addNewApply:dic];
//    if (gMainController) {
//        [gMainController setupUntreatedApplyCount];
//#if !TARGET_IPHONE_SIMULATOR
//        [gMainController playSoundAndVibration];
//#endif
//    }
    
//    if (self.contactViewVC) {
//        [self.contactViewVC reloadApplyView];
//    }
}

- (void)didJoinedGroup:(EMGroup *)aGroup
               inviter:(NSString *)aInviter
               message:(NSString *)aMessage
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", @"Prompt") message:[NSString stringWithFormat:NSLocalizedString(@"group.inviteSomeone", nil), aInviter, aGroup.groupName, aGroup.groupId] delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
    [alertView show];
}

- (void)groupInvitationDidDecline:(EMGroup *)aGroup
                          invitee:(NSString *)aInvitee
                           reason:(NSString *)aReason
{
    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"group.declinedInvite", nil), aInvitee, aGroup.groupName];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", @"Prompt") message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
    [alertView show];
}

- (void)groupInvitationDidAccept:(EMGroup *)aGroup
                         invitee:(NSString *)aInvitee
{
    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"group.acceptedInvite", nil), aInvitee, aGroup.groupName, aGroup.groupId];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", @"Prompt") message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
    [alertView show];
}

- (void)didReceiveDeclinedJoinGroup:(NSString *)aGroupId
                             reason:(NSString *)aReason
{
    if (!aReason || aReason.length == 0) {
        aReason = [NSString stringWithFormat:NSLocalizedString(@"group.beRefusedToJoin", @"be refused to join the group\'%@\'"), aGroupId];
    }
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", @"Prompt") message:aReason delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
    [alertView show];
}

- (void)joinGroupRequestDidApprove:(EMGroup *)aGroup
{
    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"group.agreedAndJoined", @"agreed to join the group of \'%@\'"), aGroup.groupName];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", @"Prompt") message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
    [alertView show];
}

- (void)didReceiveGroupInvitation:(NSString *)aGroupId
                          inviter:(NSString *)aInviter
                          message:(NSString *)aMessage
{
//    if (!aGroupId || !aInviter) {
//        return;
//    }
//
//    EMNotificationModel *model = [[EMNotificationModel alloc] init];
//    model.sender = aInviter;
//    model.groupId = aGroupId;
//    model.type = EMNotificationModelTypeGroupInvite;
//    model.message = aMessage;
//    [[EMNotificationHelper shared] insertModel:model];
//
//    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:@{@"title":@"", @"groupId":aGroupId, @"username":aInviter, @"groupname":@"", @"applyMessage":aMessage, @"applyStyle":[NSNumber numberWithInteger:ApplyStyleGroupInvitation]}];
//    [[ApplyViewController shareController] addNewApply:dic];
//    if (gMainController) {
//        [gMainController setupUntreatedApplyCount];
//#if !TARGET_IPHONE_SIMULATOR
//        [gMainController playSoundAndVibration];
//#endif
//    }
//
//    if (self.contactViewVC) {
//        [self.contactViewVC reloadApplyView];
//    }
}

- (void)groupMuteListDidUpdate:(EMGroup *)aGroup
             addedMutedMembers:(NSArray *)aMutedMembers
                    muteExpire:(NSInteger)aMuteExpire
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateGroupDetail" object:aGroup];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"group.update", @"Group update") message:NSLocalizedString(@"group.toMute", @"Mute") delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"Ok") otherButtonTitles:nil, nil];
    [alertView show];
}

- (void)groupMuteListDidUpdate:(EMGroup *)aGroup
           removedMutedMembers:(NSArray *)aMutedMembers
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateGroupDetail" object:aGroup];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"group.update", @"Group update")  message:NSLocalizedString(@"group.unmute", @"Unmute") delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"Ok") otherButtonTitles:nil, nil];
    [alertView show];
}

- (void)groupAdminListDidUpdate:(EMGroup *)aGroup
                     addedAdmin:(NSString *)aAdmin
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateGroupDetail" object:aGroup];
    
    NSString *msg = [NSString stringWithFormat:@"%@ %@", aAdmin, NSLocalizedString(@"group.becomeAdmin", @"Become Admin")];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"group.adminUpdate", @"Group Admin Update") message:msg delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"Ok") otherButtonTitles:nil, nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:GROUP_INFO_REFRESH object:nil];
    [alertView show];
}

- (void)groupAdminListDidUpdate:(EMGroup *)aGroup
                   removedAdmin:(NSString *)aAdmin
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateGroupDetail" object:aGroup];
    
    NSString *msg = [NSString stringWithFormat:@"%@ %@", aAdmin, NSLocalizedString(@"group.beRemovedAdmin", @"is removed from admin list")];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"group.adminUpdate", @"Group Admin Update") message:msg delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"Ok") otherButtonTitles:nil, nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:GROUP_INFO_REFRESH object:nil];
    [alertView show];
}

- (void)groupOwnerDidUpdate:(EMGroup *)aGroup
                   newOwner:(NSString *)aNewOwner
                   oldOwner:(NSString *)aOldOwner
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateGroupDetail" object:aGroup];
    
    NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"group.changeOwnerTo", @"Change owner %@ to %@"), aOldOwner, aNewOwner];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"group.ownerUpdate", @"Group Owner Update") message:msg delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"Ok") otherButtonTitles:nil, nil];
    [alertView show];
    [[NSNotificationCenter defaultCenter] postNotificationName:GROUP_INFO_REFRESH object:aGroup];
}

- (void)userDidJoinGroup:(EMGroup *)aGroup
                    user:(NSString *)aUsername
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateGroupDetail" object:aGroup];
    
    NSString *msg = [NSString stringWithFormat:@"%@ %@ %@", aUsername, NSLocalizedString(@"group.join", @"Join the group"), aGroup.groupName];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"group.membersUpdate", @"Group Members Update") message:msg delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"Ok") otherButtonTitles:nil, nil];
    [alertView show];
}

- (void)userDidLeaveGroup:(EMGroup *)aGroup
                     user:(NSString *)aUsername
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateGroupDetail" object:aGroup];
    
    NSString *msg = [NSString stringWithFormat:@"%@ %@ %@", aUsername, NSLocalizedString(@"group.leave", @"Leave group"), aGroup.groupName];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"group.membersUpdate", @"Group Members Update") message:msg delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"Ok") otherButtonTitles:nil, nil];
    [alertView show];
}

- (void)groupAnnouncementDidUpdate:(EMGroup *)aGroup
                      announcement:(NSString *)aAnnouncement
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateGroupDetail" object:aGroup];
    
    NSString *msg = aAnnouncement == nil ? [NSString stringWithFormat:NSLocalizedString(@"group.clearAnnouncement", @"Group:%@ Announcement is clear"), aGroup.groupName] : [NSString stringWithFormat:NSLocalizedString(@"group.updateAnnouncement", @"Group:%@ Announcement: %@"), aGroup.groupName, aAnnouncement];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"group.announcementUpdate", @"Group Announcement Update") message:msg delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"Ok") otherButtonTitles:nil, nil];
    [alertView show];
}

- (void)groupFileListDidUpdate:(EMGroup *)aGroup
               addedSharedFile:(EMGroupSharedFile *)aSharedFile
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateGroupSharedFile" object:aGroup];
    
    NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"group.uploadSharedFile", @"Group:%@ Upload file ID: %@"), aGroup.groupName, aSharedFile.fileId];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"group.sharedFileUpdate", @"Group SharedFile Update") message:msg delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"Ok") otherButtonTitles:nil, nil];
    [alertView show];
}

- (void)groupFileListDidUpdate:(EMGroup *)aGroup
             removedSharedFile:(NSString *)aFileId
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateGroupSharedFile" object:aGroup];
    
    NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"group.removeSharedFile", @"Group:%@ Remove file ID: %@"), aGroup.groupName, aFileId];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"group.sharedFileUpdate", @"Group SharedFile Update") message:msg delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"Ok") otherButtonTitles:nil, nil];
    [alertView show];
}

#pragma mark - EMContactManagerDelegate

- (void)friendRequestDidApproveByUser:(NSString *)aUsername
{
    NSString *msg = [NSString stringWithFormat:@"'%@'同意了你的好友请求", aUsername];
    [self showAlertWithTitle:@"O(∩_∩)O" message:msg];
}

- (void)friendRequestDidDeclineByUser:(NSString *)aUsername
{
    NSString *msg = [NSString stringWithFormat:@"'%@'拒绝了你的好友请求", aUsername];
    [self showAlertWithTitle:@"O(∩_∩)O" message:msg];
}

#pragma mark - private

- (BOOL)_needShowNotification:(NSString *)fromChatter
{
    BOOL ret = YES;
    NSArray *igGroupIds = [[EMClient sharedClient].groupManager getGroupsWithoutPushNotification:nil];
    for (NSString *str in igGroupIds) {
        if ([str isEqualToString:fromChatter]) {
            ret = NO;
            break;
        }
    }
    return ret;
}

#pragma mark - NSNotification

- (void)handlePushNotificationController:(NSNotification *)aNotif
{
    NSDictionary *dic = aNotif.object;
    UINavigationController *navController = [dic objectForKey:NOTIF_NAVICONTROLLER];
    if (navController == nil) {
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        navController = (UINavigationController *)window.rootViewController;
    }
    
    EMNotificationViewController *controller = [[EMNotificationViewController alloc] initWithStyle:UITableViewStylePlain];
    [navController pushViewController:controller animated:NO];
}

- (void)handlePushChatController:(NSNotification *)aNotif
{
    id object = aNotif.object;
    EMConversationModel *model = nil;
    if ([object isKindOfClass:[NSString class]]) {
        NSString *contact = (NSString *)object;
        model = [EMConversationHelper modelFromContact:contact];
    } else if ([object isKindOfClass:[EMGroup class]]) {
        EMGroup *group = (EMGroup *)object;
        model = [EMConversationHelper modelFromGroup:group];
    } else if ([object isKindOfClass:[EMChatroom class]]) {
        EMChatroom *chatroom = (EMChatroom *)object;
        model = [EMConversationHelper modelFromChatroom:chatroom];
    } else if ([object isKindOfClass:[EMConversationModel class]]) {
        model = (EMConversationModel *)object;
    }
    
    if (model) {
        EMChatViewController *controller = [[EMChatViewController alloc] initWithCoversationModel:model];
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        UIViewController *rootViewController = window.rootViewController;
        if ([rootViewController isKindOfClass:[UINavigationController class]]) {
            UINavigationController *nav = (UINavigationController *)rootViewController;
            [nav pushViewController:controller animated:NO];
        }
    }
}

- (void)handlePushGroupsController:(NSNotification *)aNotif
{
    NSDictionary *dic = aNotif.object;
    UINavigationController *navController = [dic objectForKey:NOTIF_NAVICONTROLLER];
    if (navController == nil) {
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        navController = (UINavigationController *)window.rootViewController;
    }
    
    EMGroupsViewController *controller = [[EMGroupsViewController alloc] init];
    [navController pushViewController:controller animated:NO];
}

- (void)handlePushGroupInfoController:(NSNotification *)aNotif
{
    NSDictionary *dic = aNotif.object;
    if ([dic count] == 0) {
        return;
    }
    
    NSString *groupId = [dic objectForKey:NOTIF_ID];
    UINavigationController *navController = [dic objectForKey:NOTIF_NAVICONTROLLER];

    EMGroupInfoViewController *controller = [[EMGroupInfoViewController alloc] initWithGroupId:groupId];
    [controller setLeaveOrDestroyCompletion:^{
        [navController popViewControllerAnimated:YES];
    }];
    [navController pushViewController:controller animated:NO];
}

- (void)handlePushChatroomsController:(NSNotification *)aNotif
{
    NSDictionary *dic = aNotif.object;
    UINavigationController *navController = [dic objectForKey:NOTIF_NAVICONTROLLER];
    if (navController == nil) {
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        navController = (UINavigationController *)window.rootViewController;
    }
    
    EMChatroomsViewController *controller = [[EMChatroomsViewController alloc] init];
    [navController pushViewController:controller animated:NO];
}

- (void)handlePushChatroomInfoController:(NSNotification *)aNotif
{
    NSDictionary *dic = aNotif.object;
    if ([dic count] == 0) {
        return;
    }
    
    NSString *chatroomId = [dic objectForKey:NOTIF_ID];
    UINavigationController *navController = [dic objectForKey:NOTIF_NAVICONTROLLER];
    
    EMChatroomInfoViewController *controller = [[EMChatroomInfoViewController alloc] initWithChatroomId:chatroomId];
    [controller setLeaveCompletion:^{
        [navController popViewControllerAnimated:YES];
    }];
    [navController pushViewController:controller animated:NO];
}


@end
