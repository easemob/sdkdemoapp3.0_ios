//
//  EMMsgTouchIncident.m
//  EaseIM
//
//  Created by 娜塔莎 on 2020/7/7.
//  Copyright © 2020 娜塔莎. All rights reserved.
//

#import <AVKit/AVKit.h>
#import "EMMsgTouchIncident.h"

#import "EMMessageTimeCell.h"
#import "EMLocationViewController.h"
#import "EMMsgTranspondViewController.h"
#import "EMAtGroupMembersViewController.h"
#import "EMImageBrowser.h"
#import "EMDateHelper.h"
#import "EMAudioPlayerHelper.h"
#import "EMMsgRecordCell.h"

@implementation EMMessageEventStrategy

- (void)_showCustomTransferFileAlertView
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"(づ｡◕‿‿◕｡)づ" message:@"需要自定义实现上传附件方法" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:okAction];
    [self.chatController presentViewController:alertController animated:YES completion:nil];
}

- (void)messageCellEventOperation:(EMMessageCell *)aCell{}

@end

/**
   消息事件工厂
*/
@implementation EMMessageEventStrategyFactory

+ (EMMessageEventStrategy * _Nonnull)getStratrgyImplWithMsgCell:(EMMessageCell *)aCell
{
    if (aCell.model.type == EMMessageTypePictMixText)
        return [[CommunicateMsgEvent alloc]init];
    if (aCell.model.type == EMMessageTypeImage)
        return [[ImageMsgEvent alloc] init];
    if (aCell.model.type == EMMessageTypeLocation)
        return [[LocationMsgEvent alloc] init];
    if (aCell.model.type == EMMessageTypeVoice)
        return [[VoiceMsgEvent alloc]init];
    if (aCell.model.type == EMMessageTypeVideo)
        return [[VideoMsgEvent alloc]init];
    if (aCell.model.type == EMMessageTypeFile)
        return [[FileMsgEvent alloc]init];
    if (aCell.model.type == EMMessageTypeExtCall)
        return [[ConferenceMsgEvent alloc]init];
    
    return [[EMMessageEventStrategy alloc]init];
}

@end

/**
   单聊通话事件
*/
@implementation CommunicateMsgEvent

- (void)messageCellEventOperation:(EMMessageCell *)aCell
{
    NSLog(@"readack : %d",aCell.model.emModel.isReadAcked);
    if (!aCell.model.emModel.isReadAcked) {
        [[EMClient sharedClient].chatManager sendMessageReadAck:aCell.model.emModel.messageId toUser:aCell.model.emModel.conversationId completion:nil];
    }
    NSLog(@"conversationid : %@",aCell.model.emModel.conversationId);
    NSLog(@"msgid : %@",aCell.model.emModel.messageId);
    NSLog(@"msgext : %@",aCell.model.emModel.ext);
    NSString *callType = nil;
    NSDictionary *dic = aCell.model.emModel.ext;
    if ([[dic objectForKey:EMCOMMUNICATE_TYPE] isEqualToString:EMCOMMUNICATE_TYPE_VOICE])
        callType = EMCOMMUNICATE_TYPE_VOICE;
    if ([[dic objectForKey:EMCOMMUNICATE_TYPE] isEqualToString:EMCOMMUNICATE_TYPE_VIDEO])
        callType = EMCOMMUNICATE_TYPE_VIDEO;
    if ([callType isEqualToString:EMCOMMUNICATE_TYPE_VOICE])
        [[NSNotificationCenter defaultCenter] postNotificationName:CALL_MAKE1V1 object:@{CALL_CHATTER:aCell.model.emModel.conversationId, CALL_TYPE:@(EMCallTypeVoice)}];
    if ([callType isEqualToString:EMCOMMUNICATE_TYPE_VIDEO])
        [[NSNotificationCenter defaultCenter] postNotificationName:CALL_MAKE1V1 object:@{CALL_CHATTER:aCell.model.emModel.conversationId,   CALL_TYPE:@(EMCallTypeVideo)}];
}

@end

/**
    图片事件
 */
@implementation ImageMsgEvent

- (void)messageCellEventOperation:(EMMessageCell *)aCell
{
    __weak typeof(self.chatController) weakself = self.chatController;
    void (^downloadThumbBlock)(EMMessageModel *aModel) = ^(EMMessageModel *aModel) {
        [weakself showHint:@"获取缩略图..."];
        [[EMClient sharedClient].chatManager downloadMessageThumbnail:aModel.emModel progress:nil completion:^(EMMessage *message, EMError *error) {
            if (!error) {
                [weakself.tableView reloadData];
            }
        }];
    };
    
    EMImageMessageBody *body = (EMImageMessageBody*)aCell.model.emModel.body;
    BOOL isCustomDownload = !([EMClient sharedClient].options.isAutoTransferMessageAttachments);
    if (body.thumbnailDownloadStatus == EMDownloadStatusFailed) {
        if (isCustomDownload) {
            [self _showCustomTransferFileAlertView];
        } else {
            downloadThumbBlock(aCell.model);
        }
        
        return;
    }
    
    BOOL isAutoDownloadThumbnail = [EMClient sharedClient].options.isAutoDownloadThumbnail;
    if (body.thumbnailDownloadStatus == EMDownloadStatusPending && !isAutoDownloadThumbnail) {
        downloadThumbBlock(aCell.model);
        return;
    }
    
    if (body.downloadStatus == EMDownloadStatusSucceed) {
        UIImage *image = [UIImage imageWithContentsOfFile:body.localPath];
        if (image) {
            [[EMImageBrowser sharedBrowser] showImages:@[image] fromController:self.chatController];
            return;
        }
    }
    
    if (isCustomDownload) {
        [self _showCustomTransferFileAlertView];
        return;
    }
    
    [self.chatController showHudInView:self.chatController.view hint:@"下载原图..."];
    [[EMClient sharedClient].chatManager downloadMessageAttachment:aCell.model.emModel progress:nil completion:^(EMMessage *message, EMError *error) {
        [weakself hideHud];
        if (error) {
            [EMAlertController showErrorAlert:@"下载原图失败"];
        } else {
            if (message.direction == EMMessageDirectionReceive && !message.isReadAcked) {
                [[EMClient sharedClient].chatManager sendMessageReadAck:message.messageId toUser:message.conversationId completion:nil];
            }
            
            NSString *localPath = [(EMImageMessageBody *)message.body localPath];
            UIImage *image = [UIImage imageWithContentsOfFile:localPath];
            if (image) {
                [[EMImageBrowser sharedBrowser] showImages:@[image] fromController:weakself];
            } else {
                [EMAlertController showErrorAlert:@"获取原图失败"];
            }
        }
    }];
}

@end


/**
    位置消息事件
 */
@implementation LocationMsgEvent

- (void)messageCellEventOperation:(EMMessageCell *)aCell
{
    EMLocationMessageBody *body = (EMLocationMessageBody *)aCell.model.emModel.body;
    EMLocationViewController *controller = [[EMLocationViewController alloc] initWithLocation:CLLocationCoordinate2DMake(body.latitude, body.longitude)];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
    [self.chatController.navigationController presentViewController:navController animated:YES completion:nil];
}

@end

/**
    语音消息事件
 */
@implementation VoiceMsgEvent

- (void)messageCellEventOperation:(EMMessageCell *)aCell
{
    if (aCell.model.isPlaying) {
        [[EMAudioPlayerHelper sharedHelper] stopPlayer];
        aCell.model.isPlaying = NO;
        [self.chatController.tableView reloadData];
        return;
    }
    
    EMVoiceMessageBody *body = (EMVoiceMessageBody*)aCell.model.emModel.body;
    if (body.downloadStatus == EMDownloadStatusDownloading) {
        [EMAlertController showInfoAlert:@"正在下载语音,稍后点击"];
        return;
    }
    
    __weak typeof(self.chatController) weakself = self.chatController;
    void (^playBlock)(EMMessageModel *aModel) = ^(EMMessageModel *aModel) {
        id model = [EMAudioPlayerHelper sharedHelper].model;
        if (model && [model isKindOfClass:[EMMessageModel class]]) {
            EMMessageModel *oldModel = (EMMessageModel *)model;
            if (oldModel.isPlaying) {
                oldModel.isPlaying = NO;
            }
        }
        
        if (!aModel.emModel.isReadAcked) {
            [[EMClient sharedClient].chatManager sendMessageReadAck:aModel.emModel.messageId toUser:aModel.emModel.conversationId completion:nil];
        }
        
        aModel.isPlaying = YES;
        if (!aModel.emModel.isRead) {
            aModel.emModel.isRead = YES;
        }
        [weakself.tableView reloadData];
        
        [[EMAudioPlayerHelper sharedHelper] startPlayerWithPath:body.localPath model:aModel completion:^(NSError * _Nonnull error) {
            aModel.isPlaying = NO;
            [weakself.tableView reloadData];
        }];
    };
    
    if (body.downloadStatus == EMDownloadStatusSucceed) {
        playBlock(aCell.model);
        return;
    }
    
    if (![EMClient sharedClient].options.isAutoTransferMessageAttachments) {
        [self _showCustomTransferFileAlertView];
        return;
    }
    
    [self.chatController showHudInView:self.chatController.view hint:@"下载语音..."];
    [[EMClient sharedClient].chatManager downloadMessageAttachment:aCell.model.emModel progress:nil completion:^(EMMessage *message, EMError *error) {
        [weakself hideHud];
        if (error) {
            [EMAlertController showErrorAlert:@"下载语音失败"];
        } else {
            playBlock(aCell.model);
        }
    }];
}

@end

/**
    视频消息事件
 */
@implementation VideoMsgEvent

- (void)messageCellEventOperation:(EMMessageCell *)aCell
{
    EMVideoMessageBody *body = (EMVideoMessageBody*)aCell.model.emModel.body;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isCustomDownload = !([EMClient sharedClient].options.isAutoTransferMessageAttachments);
    if (body.thumbnailDownloadStatus == EMDownloadStatusFailed || ![fileManager fileExistsAtPath:body.thumbnailLocalPath]) {
        [self.chatController showHint:@"下载缩略图"];
        if (!isCustomDownload) {
            [[EMClient sharedClient].chatManager downloadMessageThumbnail:aCell.model.emModel progress:nil completion:nil];
        }
    }
    
    if (body.downloadStatus == EMDownloadStatusDownloading) {
        [EMAlertController showInfoAlert:@"正在下载视频,稍后点击"];
        return;
    }
    
    __weak typeof(self.chatController) weakself = self.chatController;
    void (^playBlock)(NSString *aPath) = ^(NSString *aPathe) {
        NSURL *videoURL = [NSURL fileURLWithPath:aPathe];
        AVPlayerViewController *playerViewController = [[AVPlayerViewController alloc] init];
        playerViewController.player = [AVPlayer playerWithURL:videoURL];
        playerViewController.videoGravity = AVLayerVideoGravityResizeAspect;
        playerViewController.showsPlaybackControls = YES;
        playerViewController.modalPresentationStyle = 0;
        [weakself presentViewController:playerViewController animated:YES completion:^{
            [playerViewController.player play];
        }];
    };
    
    if (body.downloadStatus == EMDownloadStatusSuccessed && [fileManager fileExistsAtPath:body.localPath]) {
        playBlock(body.localPath);
        return;
    }
    
    if (isCustomDownload) {
        [self _showCustomTransferFileAlertView];
        return;
    }
    [self.chatController showHudInView:self.chatController.view hint:@"下载视频..."];
    [[EMClient sharedClient].chatManager downloadMessageAttachment:aCell.model.emModel progress:nil completion:^(EMMessage *message, EMError *error) {
        [weakself hideHud];
        if (error) {
            [EMAlertController showErrorAlert:@"下载视频失败"];
        } else {
            if (!message.isReadAcked) {
                [[EMClient sharedClient].chatManager sendMessageReadAck:message.messageId toUser:message.conversationId completion:nil];
                
            }
            playBlock([(EMVideoMessageBody*)message.body localPath]);
        }
    }];
}

@end

/**
    文件消息事件
 */
@implementation FileMsgEvent

- (void)messageCellEventOperation:(EMMessageCell *)aCell
{
    EMFileMessageBody *body = (EMFileMessageBody *)aCell.model.emModel.body;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (body.downloadStatus == EMDownloadStatusDownloading) {
        [EMAlertController showInfoAlert:@"正在下载文件,稍后点击"];
        return;
    }
    __weak typeof(self.chatController) weakself = self.chatController;
    void (^checkFileBlock)(NSString *aPath) = ^(NSString *aPathe) {
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:aPathe];
        NSLog(@"\nfile  --    :%@",[fileHandle readDataToEndOfFile]);
        [fileHandle closeFile];
        UIDocumentInteractionController *docVc = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:aPathe]];
        docVc.delegate = weakself;
        [docVc presentPreviewAnimated:YES];
    };
    
    if (body.downloadStatus == EMDownloadStatusSuccessed && [fileManager fileExistsAtPath:body.localPath]) {
        checkFileBlock(body.localPath);
        return;
    }
    
    [[EMClient sharedClient].chatManager downloadMessageAttachment:aCell.model.emModel progress:nil completion:^(EMMessage *message, EMError *error) {
        [weakself hideHud];
        if (error) {
            [EMAlertController showErrorAlert:@"下载文件失败"];
        } else {
            if (!message.isReadAcked) {
                [[EMClient sharedClient].chatManager sendMessageReadAck:message.messageId toUser:message.conversationId completion:nil];
            }
            checkFileBlock([(EMFileMessageBody*)message.body localPath]);
        }
    }];
}

@end

/**
    会议消息事件
 */
@implementation ConferenceMsgEvent

- (void)messageCellEventOperation:(EMMessageCell *)aCell
{
    [[NSNotificationCenter defaultCenter] postNotificationName:CALL_SELECTCONFERENCECELL object:aCell.model.emModel];
}

@end
