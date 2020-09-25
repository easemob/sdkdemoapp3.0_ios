//
//  EMGroupChatViewController.m
//  EaseIM
//
//  Created by 娜塔莎 on 2020/7/9.
//  Copyright © 2020 娜塔莎. All rights reserved.
//

#import "EMGroupChatViewController.h"
#import "EMReadReceiptMsgViewController.h"
#import "EMGroupInfoViewController.h"
#import "EMAtGroupMembersViewController.h"
#import "EMMessageModel.h"

@interface EMGroupChatViewController () <EMReadReceiptMsgDelegate,EMGroupManagerDelegate>

@property (nonatomic, strong) EMGroup *group;
//阅读回执
@property (nonatomic, strong) EMReadReceiptMsgViewController *readReceiptControl;
//@
@property (nonatomic) BOOL isWillInputAt;

@end

@implementation EMGroupChatViewController

- (instancetype)initWithCoversationModel:(EMConversationModel *)aModel
{
    return [super initWithCoversationModel:aModel];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _setupNavigationBarRightItem];
    
    [[EMClient sharedClient].groupManager addDelegate:self delegateQueue:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleGroupSubjectUpdated:) name:GROUP_SUBJECT_UPDATED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleGroupInfoClearRecord) name:GROUP_INFO_CLEARRECORD object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSMutableDictionary *ext = [[NSMutableDictionary alloc]initWithDictionary:self.conversationModel.emModel.ext];
    //群聊@功能
    if ([self.conversationModel.emModel.ext objectForKey:kConversation_IsRead]) {
        [ext setObject:@"" forKey:kConversation_IsRead];
        [self.conversationModel.emModel setExt:ext];
    }
}

- (void)_setupNavigationBarRightItem {
    if ((NSClassFromString(@"EMGroupInfoViewController")) == nil)
        return;
    UIImage *image = [[UIImage imageNamed:@"groupInfo"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(groupInfoAction)];
}

- (void)dealloc
{
    [[EMClient sharedClient].groupManager removeDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - ACtion

- (void)returnReadReceipt:(EMMessage *)msg
{
    if (msg.isNeedGroupAck && !msg.isReadAcked) {
        [[EMClient sharedClient].chatManager sendGroupMessageReadAck:msg.messageId toGroup:msg.conversationId content:@"123" completion:^(EMError *error) {
            if (error) {
                NSLog(@"\n ------ error   %@",error.errorDescription);
            }
        }];
    }
}

- (void)groupInfoAction {
    if (self.conversationModel.emModel.type == EMConversationTypeGroupChat)
        [[NSNotificationCenter defaultCenter] postNotificationName:GROUP_INFO_PUSHVIEWCONTROLLER object:@{NOTIF_ID:self.conversationModel.emModel.conversationId, NOTIF_NAVICONTROLLER:self.navigationController}];
}

- (void)handleGroupInfoClearRecord {
    [self.dataArray removeAllObjects];
    [self.tableView reloadData];
}

#pragma mark - EMMoreFunctionViewDelegate

//群组阅读回执跳转
- (void)chatBarMoreFunctionReadReceipt
{
    self.readReceiptControl = [[EMReadReceiptMsgViewController alloc]init];
    self.readReceiptControl.delegate = self;
    self.readReceiptControl.modalPresentationStyle = 0;
    [self presentViewController:self.readReceiptControl animated:NO completion:nil];
}

#pragma mark - EMReadReceiptMsgDelegate

//群组阅读回执发送信息
- (void)sendReadReceiptMsg:(NSString *)msg
{
    NSString *str = msg;
    NSLog(@"\n%@",str);
    if (self.conversationModel.emModel.type != EMConversationTypeGroupChat) {
        [self sendTextAction:str ext:nil];
        return;
    }
    [[EMClient sharedClient].groupManager getGroupSpecificationFromServerWithId:self.conversationModel.emModel.conversationId completion:^(EMGroup *aGroup, EMError *aError) {
        NSLog(@"\n -------- sendError:   %@",aError);
        if (!aError) {
            self.group = aGroup;
            //是群主才可以发送阅读回执信息
            [self sendTextAction:str ext:@{MSG_EXT_READ_RECEIPT:@"receipt"}];
        } else {
            [EMAlertController showErrorAlert:@"获取群组失败"];
        }
    }];
}

#pragma mark - EMMessageCellDelegate

//阅读回执详情
- (void)messageReadReceiptDetil:(EMMessageCell *)aCell
{
    self.readReceiptControl = [[EMReadReceiptMsgViewController alloc] initWithMessageCell:aCell groupId:self.conversationModel.emModel.conversationId];
    self.readReceiptControl.modalPresentationStyle = 0;
    [self presentViewController:self.readReceiptControl animated:NO completion:nil];
}

#pragma mark - EMChatBarDelegate

//@群成员
- (void)_willInputAt:(EMTextView *)aInputView
{
    do {
        if (self.conversationModel.emModel.type != EMConversationTypeGroupChat) {
            break;
        }
        NSString *text = aInputView.text;
        EMGroup *group = [EMGroup groupWithId:self.conversationModel.emModel.conversationId];
        if (!group) {
            break;
        }
        
        [self.view endEditing:YES];
        //选择 @ 某群成员
        EMAtGroupMembersViewController *controller = [[EMAtGroupMembersViewController alloc] initWithGroup:group];
        [self.navigationController pushViewController:controller animated:NO];
        [controller setSelectedCompletion:^(NSString * _Nonnull aName) {
            NSString *newStr = [NSString stringWithFormat:@"%@%@ ", text, aName];
            aInputView.text = newStr;
            aInputView.selectedRange = NSMakeRange(newStr.length, 0);
            [aInputView becomeFirstResponder];
        }];
        
    } while (0);
}

- (BOOL)inputView:(EMTextView *)aInputView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    self.isWillInputAt = NO;
    if ([text isEqualToString:@"\n"]) {
        [self sendTextAction:aInputView.text ext:nil];
        return NO;
    }
    if ([text isEqualToString:@"@"]) {
        self.isWillInputAt = YES;
    }
    
    return YES;
}

- (void)inputViewDidChange:(EMTextView *)aInputView
{
    //@群成员
    if (self.isWillInputAt && self.conversationModel.emModel.type == EMConversationTypeGroupChat) {
        NSString *text = aInputView.text;
        if ([text hasSuffix:@"@"]) {
            self.isWillInputAt = NO;
            [self _willInputAt:aInputView];
        }
    }
}

#pragma mark - EMChatManagerDelegate

//收到群消息已读回执
- (void)groupMessageDidRead:(EMMessage *)aMessage groupAcks:(NSArray *)aGroupAcks
{
    EMMessageModel *msgModel;
    EMGroupMessageAck *msgAck = aGroupAcks[0];
    for (int i=0; i<[self.dataArray count]; i++) {
        if([self.dataArray[i] isKindOfClass:[EMMessageModel class]]){
            msgModel = (EMMessageModel *)self.dataArray[i];
        }else{
            continue;
        }
        if([msgModel.emModel.messageId isEqualToString:msgAck.messageId]){
            msgModel.readReceiptCount = [NSString stringWithFormat:@"阅读回执，已读用户（%d)",msgModel.emModel.groupAckCount];
            msgModel.emModel.isReadAcked = YES;
            [[EMClient sharedClient].chatManager sendMessageReadAck:msgModel.emModel.messageId toUser:msgModel.emModel.conversationId completion:nil];
            [self.dataArray setObject:msgModel atIndexedSubscript:i];
            __weak typeof(self) weakself = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakself refreshTableView];
            });
            break;
        }
    }
}

#pragma mark - EMGroupManagerDelegate

- (void)didLeaveGroup:(EMGroup *)aGroup
               reason:(EMGroupLeaveReason)aReason
{
    EMConversation *conversation = self.conversationModel.emModel;
    if (conversation.type == EMChatTypeGroupChat && [aGroup.groupId isEqualToString:conversation.conversationId]) {
        //[self.navigationController popToViewController:self animated:YES];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

//有用户加入群组
- (void)userDidJoinGroup:(EMGroup *)aGroup
                    user:(NSString *)aUsername
{
    [self tableViewDidTriggerHeaderRefresh];
    [self refreshTableView];
}

#pragma mark - Notification

- (void)handleGroupSubjectUpdated:(NSNotification *)aNotif
{
    EMGroup *group = aNotif.object;
    if (!group) return;
    
    NSString *groupId = group.groupId;
    if ([groupId isEqualToString:self.conversationModel.emModel.conversationId]) {
        self.conversationModel.name = group.groupName;
        self.titleLabel.text = group.groupName;
    }
}

@end
