//
//  EMChatViewController+EMMsgLongPressIncident.m
//  EaseIM
//
//  Created by 娜塔莎 on 2020/7/9.
//  Copyright © 2020 娜塔莎. All rights reserved.
//

#import "EMChatViewController+EMMsgLongPressIncident.h"
#import "EMMsgTranspondViewController.h"
#import <objc/runtime.h>

static const void *menuIndexPathKey = &menuIndexPathKey;
static const void *deleteMenuItemKey = &deleteMenuItemKey;
static const void *copyMenuItemKey = &copyMenuItemKey;
static const void *recallMenuItemKey = &recallMenuItemKey;
static const void *transpondMenuItemKey = &transpondMenuItemKey;

@implementation EMChatViewController (EMMsgLongPressIncident)

@dynamic menuIndexPath;
@dynamic deleteMenuItem;
@dynamic copyMenuItem;
@dynamic recallMenuItem;
@dynamic transpondMenuItem;

- (NSMutableArray *)showMenuViewController:(EMMessageCell *)aCell
                          model:(EMMessageModel *)aModel
{
    [self _setAction];
    NSMutableArray *items = [[NSMutableArray alloc] init];
    if (aModel.type == EMMessageTypeText) {
        [items addObject:self.copyMenuItem];
        [items addObject:self.transpondMenuItem];
    } else if (aModel.type == EMMessageTypeLocation || aModel.type == EMMessageTypeImage || aModel.type == EMMessageTypeVideo) {
        [items addObject:self.transpondMenuItem];
    }

    [items addObject:self.deleteMenuItem];
    
    if (aModel.emModel.direction == EMMessageDirectionSend) {
        [items addObject:self.recallMenuItem];
    }

    return items;
}

- (void)_setAction
{
    if (self.recallMenuItem == nil) {
        self.recallMenuItem = [[UIMenuItem alloc]initWithTitle:@"撤回" action:@selector(recallMenuItemAction:)];
    }
    if (self.transpondMenuItem == nil) {
        self.transpondMenuItem = [[UIMenuItem alloc]initWithTitle:@"转发" action:@selector(transpondMenuItemAction:)];
    }
    if (self.copyMenuItem == nil) {
        self.copyMenuItem = [[UIMenuItem alloc]initWithTitle:@"复制" action:@selector(copyMenuItemAction:)];
    }
    if (self.deleteMenuItem == nil) {
        self.deleteMenuItem = [[UIMenuItem alloc]initWithTitle:@"删除" action:@selector(deleteMenuItemAction:)];
    }
}

- (void)deleteMenuItemAction:(UIMenuItem *)aItem
{
    if (self.menuIndexPath == nil || self.menuIndexPath.row < 0) {
        return;
    }
    
    EMMessageModel *model = [self.dataArray objectAtIndex:self.menuIndexPath.row];
    [self.conversationModel.emModel deleteMessageWithId:model.emModel.messageId error:nil];
    
    NSMutableIndexSet *indexs = [NSMutableIndexSet indexSetWithIndex:self.menuIndexPath.row];
    NSMutableArray *indexPaths = [NSMutableArray arrayWithObjects:self.menuIndexPath, nil];
    if (self.menuIndexPath.row - 1 >= 0) {
        id nextMessage = nil;
        id prevMessage = [self.dataArray objectAtIndex:(self.menuIndexPath.row - 1)];
        if (self.menuIndexPath.row + 1 < [self.dataArray count]) {
            nextMessage = [self.dataArray objectAtIndex:(self.menuIndexPath.row + 1)];
        }
        if ((!nextMessage || [nextMessage isKindOfClass:[NSString class]]) && [prevMessage isKindOfClass:[NSString class]]) {
            [indexs addIndex:self.menuIndexPath.row - 1];
            [indexPaths addObject:[NSIndexPath indexPathForRow:(self.menuIndexPath.row - 1) inSection:0]];
        }
    }
    
    [self.dataArray removeObjectsAtIndexes:indexs];
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
    
    if ([self.dataArray count] == 0) {
        self.msgTimelTag = -1;
    }
    
    self.menuIndexPath = nil;
}

- (void)copyMenuItemAction:(UIMenuItem *)aItem
{
    if (self.menuIndexPath == nil || self.menuIndexPath.row < 0) {
        return;
    }
    
    EMMessageModel *model = [self.dataArray objectAtIndex:self.menuIndexPath.row];
    EMTextMessageBody *body = (EMTextMessageBody *)model.emModel.body;
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = body.text;
    
    self.menuIndexPath = nil;
}

- (void)transpondMenuItemAction:(UIMenuItem *)aItem
{
    if (self.menuIndexPath == nil || self.menuIndexPath.row < 0) {
        return;
    }
    
    EMMessageModel *model = [self.dataArray objectAtIndex:self.menuIndexPath.row];
    EMMsgTranspondViewController *controller = [[EMMsgTranspondViewController alloc] initWithModel:model];
    [self.navigationController pushViewController:controller animated:NO];
    
    __weak typeof(self) weakself = self;
    [controller setDoneCompletion:^(EMMessageModel * _Nonnull aModel, NSString * _Nonnull aUsername) {
        [weakself _transpondMsg:aModel toUser:aUsername];
    }];
    
    self.menuIndexPath = [[NSIndexPath alloc]initWithIndex:-1];;
}

- (void)recallMenuItemAction:(UIMenuItem *)aItem
{
    if (self.menuIndexPath == nil || self.menuIndexPath.row < 0) {
        return;
    }
    
    NSIndexPath *indexPath = self.menuIndexPath;
    __weak typeof(self) weakself = self;
    EMMessageModel *model = [self.dataArray objectAtIndex:self.menuIndexPath.row];
    [[EMClient sharedClient].chatManager recallMessageWithMessageId:model.emModel.messageId completion:^(EMError *aError) {
        if (aError) {
            [EMAlertController showErrorAlert:aError.errorDescription];
        } else {
            EMTextMessageBody *body = [[EMTextMessageBody alloc] initWithText:@"您撤回一条消息"];
            NSString *from = [[EMClient sharedClient] currentUsername];
            NSString *to = self.conversationModel.emModel.conversationId;
            EMMessage *message = [[EMMessage alloc] initWithConversationID:to from:from to:to body:body ext:@{MSG_EXT_RECALL:@(YES)}];
            message.chatType = (EMChatType)self.conversationModel.emModel.type;
            message.isRead = YES;
            message.timestamp = model.emModel.timestamp;
            message.localTime = model.emModel.localTime;
            [weakself.conversationModel.emModel insertMessage:message error:nil];
            
            EMMessageModel *model = [[EMMessageModel alloc] initWithEMMessage:message];
            [weakself.dataArray replaceObjectAtIndex:indexPath.row withObject:model];
            [weakself.tableView reloadData];
        }
    }];
    
    self.menuIndexPath = nil;
}

#pragma mark - Transpond Message

- (void)_forwardMsgWithBody:(EMMessageBody *)aBody
                         to:(NSString *)aTo
                        ext:(NSDictionary *)aExt
                 completion:(void (^)(EMMessage *message))aCompletionBlock
{
    NSString *from = [[EMClient sharedClient] currentUsername];
    EMMessage *message = [[EMMessage alloc] initWithConversationID:aTo from:from to:aTo body:aBody ext:aExt];
    message.chatType = EMChatTypeChat;
    
    __weak typeof(self) weakself = self;
    [[EMClient sharedClient].chatManager sendMessage:message progress:nil completion:^(EMMessage *message, EMError *error) {
        if (error) {
            [weakself.conversationModel.emModel deleteMessageWithId:message.messageId error:nil];
            [EMAlertController showErrorAlert:@"转发消息失败"];
        } else {
            if (aCompletionBlock) {
                aCompletionBlock(message);
            }
            [EMAlertController showSuccessAlert:@"转发消息成功"];
            if ([aTo isEqualToString:weakself.conversationModel.emModel.conversationId]) {
                [weakself returnReadReceipt:message];
                [weakself.conversationModel.emModel markMessageAsReadWithId:message.messageId error:nil];
                NSArray *formated = [weakself formatMessages:@[message]];
                [weakself.dataArray addObjectsFromArray:formated];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakself refreshTableView];
                });
            }
        }
    }];
}

- (void)_forwardImageMsg:(EMMessage *)aMsg
                  toUser:(NSString *)aUsername
{
    EMImageMessageBody *newBody = nil;
    EMImageMessageBody *imgBody = (EMImageMessageBody *)aMsg.body;
    // 如果图片是己方发送，直接获取图片文件路径；若是对方发送，则需先查看原图（自动下载原图），再转发。
    if ([aMsg.from isEqualToString:EMClient.sharedClient.currentUsername]) {
        newBody = [[EMImageMessageBody alloc]initWithLocalPath:imgBody.localPath displayName:imgBody.displayName];
    } else {
        if (imgBody.downloadStatus != EMDownloadStatusSuccessed) {
            [EMAlertController showErrorAlert:@"请先下载原图"];
            return;
        }
        
        newBody = [[EMImageMessageBody alloc]initWithLocalPath:imgBody.localPath displayName:imgBody.displayName];
    }
    
    newBody.size = imgBody.size;
    __weak typeof(self) weakself = self;
    [weakself _forwardMsgWithBody:newBody to:aUsername ext:aMsg.ext completion:^(EMMessage *message) {
        
    }];
}

- (void)_forwardVideoMsg:(EMMessage *)aMsg
                  toUser:(NSString *)aUsername
{
    EMVideoMessageBody *oldBody = (EMVideoMessageBody *)aMsg.body;

    __weak typeof(self) weakself = self;
    void (^block)(EMMessage *aMessage) = ^(EMMessage *aMessage) {
        EMVideoMessageBody *newBody = [[EMVideoMessageBody alloc] initWithLocalPath:oldBody.localPath displayName:oldBody.displayName];
        newBody.thumbnailLocalPath = oldBody.thumbnailLocalPath;
        
        [weakself _forwardMsgWithBody:newBody to:aUsername ext:aMsg.ext completion:^(EMMessage *message) {
            [(EMVideoMessageBody *)message.body setLocalPath:[(EMVideoMessageBody *)aMessage.body localPath]];
            [[EMClient sharedClient].chatManager updateMessage:message completion:nil];
        }];
    };
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:oldBody.localPath]) {
        [[EMClient sharedClient].chatManager downloadMessageAttachment:aMsg progress:nil completion:^(EMMessage *message, EMError *error) {
            if (error) {
                [EMAlertController showErrorAlert:@"转发消息失败"];
            } else {
                block(aMsg);
            }
        }];
    } else {
        block(aMsg);
    }
}

- (void)_transpondMsg:(EMMessageModel *)aModel
               toUser:(NSString *)aUsername
{
    EMMessageBodyType type = aModel.emModel.body.type;
    if (type == EMMessageBodyTypeText || type == EMMessageBodyTypeLocation)
        [self _forwardMsgWithBody:aModel.emModel.body to:aUsername ext:aModel.emModel.ext completion:nil];
    if (type == EMMessageBodyTypeImage)
        [self _forwardImageMsg:aModel.emModel toUser:aUsername];
    if (type == EMMessageBodyTypeVideo)
        [self _forwardVideoMsg:aModel.emModel toUser:aUsername];
}

#pragma mark - getter & setter

- (NSIndexPath *)menuIndexPath
{
    return objc_getAssociatedObject(self, menuIndexPathKey);
}

- (void)setMenuIndexPath:(NSIndexPath *)menuIndexPath
{
    objc_setAssociatedObject(self, menuIndexPathKey, menuIndexPath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIMenuItem *)deleteMenuItem
{
    return objc_getAssociatedObject(self, deleteMenuItemKey);
}

- (void)setDeleteMenuItem:(UIMenuItem *)deleteMenuItem
{
    objc_setAssociatedObject(self, deleteMenuItemKey, deleteMenuItem, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIMenuItem *)copyMenuItem
{
    return objc_getAssociatedObject(self, copyMenuItemKey);
}

- (void)setCopyMenuItem:(UIMenuItem *)copyMenuItem
{
    objc_setAssociatedObject(self, copyMenuItemKey, copyMenuItem, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIMenuItem *)recallMenuItem
{
    return objc_getAssociatedObject(self, recallMenuItemKey);
}

- (void)setRecallMenuItem:(UIMenuItem *)recallMenuItem
{
    objc_setAssociatedObject(self, recallMenuItemKey, recallMenuItem, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIMenuItem *)transpondMenuItem
{
    return objc_getAssociatedObject(self, transpondMenuItemKey);
}

- (void)setTranspondMenuItem:(UIMenuItem *)transpondMenuItem
{
    objc_setAssociatedObject(self, transpondMenuItemKey, transpondMenuItem, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
