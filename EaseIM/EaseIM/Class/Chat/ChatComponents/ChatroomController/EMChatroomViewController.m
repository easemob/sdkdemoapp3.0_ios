//
//  EMChatroomViewController.m
//  EaseIM
//
//  Created by 娜塔莎 on 2020/7/9.
//  Copyright © 2020 娜塔莎. All rights reserved.
//

#import "EMChatroomViewController.h"

@interface EMChatroomViewController () <EMChatroomManagerDelegate>

@end

@implementation EMChatroomViewController

- (instancetype)initWithCoversationModel:(EMConversationModel *)aModel
{
    return [super initWithCoversationModel:aModel];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _setupNavigationBarRightItem];
    [self _joinChatroom];
    [[EMClient sharedClient].roomManager addDelegate:self delegateQueue:nil];
}

- (void)dealloc
{
    [[EMClient sharedClient].roomManager removeDelegate:self];
}

- (void)_setupNavigationBarRightItem
{
    UIImage *image = [[UIImage imageNamed:@"groupInfo"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(_chatroomInfoAction)];
}

#pragma mark - EMChatroomManagerDelegate

//有用户加入聊天室
- (void)userDidJoinChatroom:(EMChatroom *)aChatroom
                       user:(NSString *)aUsername
{
    EMConversation *conversation = self.conversationModel.emModel;
    if (conversation.type == EMChatTypeChatRoom && [aChatroom.chatroomId isEqualToString:conversation.conversationId]) {
        NSString *str = [NSString stringWithFormat:@"%@ 加入聊天室", aUsername];
        [self showHint:str];
    }
}

- (void)userDidLeaveChatroom:(EMChatroom *)aChatroom
                        user:(NSString *)aUsername
{
    EMConversation *conversation = self.conversationModel.emModel;
    if (conversation.type == EMChatTypeChatRoom && [aChatroom.chatroomId isEqualToString:conversation.conversationId]) {
        NSString *str = [NSString stringWithFormat:@"%@ 离开聊天室", aUsername];
        [self showHint:str];
    }
}

- (void)didDismissFromChatroom:(EMChatroom *)aChatroom
                        reason:(EMChatroomBeKickedReason)aReason
{
    if (aReason == 0)
        [self showHint:@"被移出聊天室"];
    if (aReason == 1)
        [self showHint:@"聊天室已销毁"];
    if (aReason == 2)
        [self showHint:@"您的账号已离线"];
    EMConversation *conversation = self.conversationModel.emModel;
    if (conversation.type == EMChatTypeChatRoom && [aChatroom.chatroomId isEqualToString:conversation.conversationId]) {
        //[self.navigationController popToViewController:self animated:YES];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)chatroomMuteListDidUpdate:(EMChatroom *)aChatroom removedMutedMembers:(NSArray *)aMutes
{
    if ([aMutes containsObject:EMClient.sharedClient.currentUsername]) {
        [self showHint:@"您已被解除禁言"];
    }
}

- (void)chatroomMuteListDidUpdate:(EMChatroom *)aChatroom addedMutedMembers:(NSArray *)aMutes muteExpire:(NSInteger)aMuteExpire
{
    if ([aMutes containsObject:EMClient.sharedClient.currentUsername]) {
        [self showHint:@"您已被禁言"];
    }
}

- (void)chatroomWhiteListDidUpdate:(EMChatroom *)aChatroom addedWhiteListMembers:(NSArray *)aMembers
{
    if ([aMembers containsObject:EMClient.sharedClient.currentUsername]) {
        [self showHint:@"您已被加入白名单"];
    }
}

- (void)chatroomWhiteListDidUpdate:(EMChatroom *)aChatroom removedWhiteListMembers:(NSArray *)aMembers
{
    if ([aMembers containsObject:EMClient.sharedClient.currentUsername]) {
        [self showHint:@"您已被移出白名单"];
    }
}

- (void)chatroomAllMemberMuteChanged:(EMChatroom *)aChatroom isAllMemberMuted:(BOOL)aMuted
{
    [self showHint:[NSString stringWithFormat:@"全员禁言已%@", aMuted ? @"开启" : @"关闭"]];
}

- (void)chatroomAdminListDidUpdate:(EMChatroom *)aChatroom addedAdmin:(NSString *)aAdmin
{
    [self showHint:[NSString stringWithFormat:@"%@已成为管理员", aAdmin]];
}

- (void)chatroomAdminListDidUpdate:(EMChatroom *)aChatroom removedAdmin:(NSString *)aAdmin
{
    [self showHint:[NSString stringWithFormat:@"%@被降级为普通成员", aAdmin]];
}

- (void)chatroomOwnerDidUpdate:(EMChatroom *)aChatroom newOwner:(NSString *)aNewOwner oldOwner:(NSString *)aOldOwner
{
    [self showHint:[NSString stringWithFormat:@"%@ 已将聊天室移交给 %@", aOldOwner, aNewOwner]];
}

- (void)chatroomAnnouncementDidUpdate:(EMChatroom *)aChatroom announcement:(NSString *)aAnnouncement
{
    [self showHint:@"聊天室公告内容已更新，请查看"];
}

#pragma mark - Private

- (void)_joinChatroom
{
    __weak typeof(self) weakself = self;
    [self showHudInView:self.view hint:@"加入聊天室..."];
    [[EMClient sharedClient].roomManager joinChatroom:self.conversationModel.emModel.conversationId completion:^(EMChatroom *aChatroom, EMError *aError) {
        [weakself hideHud];
        if (aError) {
            [EMAlertController showErrorAlert:@"加入聊天室失败"];
            [weakself.navigationController popViewControllerAnimated:YES];
        } else {
            [weakself tableViewDidTriggerHeaderRefresh];
        }
    }];
}

//聊天室 详情页
- (void)_chatroomInfoAction
{
    if (self.conversationModel.emModel.type == EMConversationTypeChatRoom)
        [[NSNotificationCenter defaultCenter] postNotificationName:CHATROOM_INFO_PUSHVIEWCONTROLLER object:@{NOTIF_ID:self.conversationModel.emModel.conversationId, NOTIF_NAVICONTROLLER:self.navigationController}];
}

@end
