//
//  EMChatroomViewController.m
//  EMiOSDemo
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
        NSString *str = [NSString stringWithFormat:@"%@ 进入聊天室", aUsername];
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
    EMConversation *conversation = self.conversationModel.emModel;
    if (conversation.type == EMChatTypeChatRoom && [aChatroom.chatroomId isEqualToString:conversation.conversationId]) {
        [self.navigationController popToViewController:self animated:YES];
        [self.navigationController popViewControllerAnimated:YES];
    }
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
