//
//  EMChatViewController.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/18.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import <AVKit/AVKit.h>
#import <Photos/Photos.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "EMChatViewController.h"

#import "DemoConfManager.h"
#import "EMAudioHelper.h"
#import "EMImageBrowser.h"
#import "EMConversationHelper.h"
#import "EMCDDeviceManager.h"
#import "EMMessageModel.h"

#import "EMChatBar.h"
#import "EMMessageCell.h"
#import "EMGroupInfoViewController.h"
#import "EMChatroomInfoViewController.h"
#import "EMLocationViewController.h"

@interface EMChatViewController ()<UIScrollViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, EMChatManagerDelegate, EMChatBarDelegate, EMMessageCellDelegate, EMChatBarCallViewDelegate, EMChatBarEmoticonViewDelegate>

@property (nonatomic, strong) dispatch_queue_t msgQueue;
@property (nonatomic) BOOL isFirstLoadFromDB;
@property (nonatomic) BOOL isViewDidAppear;

@property (nonatomic, strong) EMConversationModel *conversationModel;
@property (nonatomic, strong) NSString *moreMsgId;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *titleDetailLabel;

@property (nonatomic, strong) EMChatBar *chatBar;
@property (strong, nonatomic) UIImagePickerController *imagePicker;

@end

@implementation EMChatViewController

- (instancetype)initWithCoversation:(EMConversationModel *)aConversationModel
{
    self = [super init];
    if (self) {
        _conversationModel = aConversationModel;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.msgQueue = dispatch_queue_create("emmessage.com", NULL);
    
    [self _setupChatSubviews];
    
    [[EMClient sharedClient].chatManager addDelegate:self delegateQueue:nil];
    
    if (self.conversationModel.emModel.type == EMConversationTypeChatRoom) {
        [self _joinChatroom];
    } else {
        self.isFirstLoadFromDB = YES;
        [self tableViewDidTriggerHeaderRefresh];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.isViewDidAppear = YES;
    [EMConversationHelper markAllAsRead:self.conversationModel];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.isViewDidAppear = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc
{
    self.isViewDidAppear = NO;
    [[EMClient sharedClient].chatManager removeDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Subviews

- (void)_setupChatSubviews
{
    [self addPopBackLeftItemWithTarget:self action:@selector(backAction)];
    [self _setupNavigationBarTitle];
    [self _setupNavigationBarRightItem];
    self.view.backgroundColor = kColor_LightGray;
    self.showRefreshHeader = YES;
    
    self.chatBar = [[EMChatBar alloc] init];
    self.chatBar.delegate = self;
    [self.view addSubview:self.chatBar];
    [self.chatBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    
    [self _setupChatBarMoreViews];
    
    self.tableView.backgroundColor = kColor_LightGray;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 130;
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.chatBar.mas_top);
    }];
}

- (void)_setupNavigationBarTitle
{
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width * 06, 40)];
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.font = [UIFont systemFontOfSize:18];
    self.titleLabel.textColor = [UIColor blackColor];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.text = self.conversationModel.name;
    [titleView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleView);
        make.left.equalTo(titleView).offset(5);
        make.right.equalTo(titleView).offset(-5);
    }];
    
    self.titleDetailLabel = [[UILabel alloc] init];
    self.titleDetailLabel.font = [UIFont systemFontOfSize:15];
    self.titleDetailLabel.textColor = [UIColor grayColor];
    self.titleDetailLabel.textAlignment = NSTextAlignmentCenter;
    [titleView addSubview:self.titleDetailLabel];
    [self.titleDetailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom);
        make.left.equalTo(self.titleLabel);
        make.right.equalTo(self.titleLabel);
        make.bottom.equalTo(titleView);
    }];
    
    self.navigationItem.titleView = titleView;
    
    if (self.conversationModel.emModel.type != EMConversationTypeChat) {
        self.titleDetailLabel.text = self.conversationModel.emModel.conversationId;
    }
}

- (void)_setupNavigationBarRightItem
{
    if (self.conversationModel.emModel.type == EMConversationTypeChat) {
        UIImage *image = [[UIImage imageNamed:@"close_gray"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(deleteAllMessageAction)];
    } else {
        UIImage *image = [[UIImage imageNamed:@"search_gray"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(groupOrChatroomInfoAction)];
    }
}

- (void)_setupChatBarMoreViews
{
    EMChatBarRecordAudioView *recordView = [[EMChatBarRecordAudioView alloc] init];
    self.chatBar.recordAudioView = recordView;
    
    EMChatBarEmoticonView *moreEmoticonView = [[EMChatBarEmoticonView alloc] init];
    moreEmoticonView.delegate = self;
    self.chatBar.moreEmoticonView = moreEmoticonView;
    
    EMChatBarCallView *moreCallView = [[EMChatBarCallView alloc] initWithChatType:self.conversationModel.emModel.type];
    moreCallView.delegate = self;
    self.chatBar.moreCallView = moreCallView;
}

#pragma mark - Getter

- (UIImagePickerController *)imagePicker
{
    if (_imagePicker == nil) {
        _imagePicker = [[UIImagePickerController alloc] init];
        _imagePicker.modalPresentationStyle = UIModalPresentationOverFullScreen;
        _imagePicker.delegate = self;
    }
    
    return _imagePicker;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EMMessageModel *model = [self.dataArray objectAtIndex:indexPath.row];
    NSString *identifier = [EMMessageCell cellIdentifierWithDirection:model.direction type:model.type];
    EMMessageCell *cell = (EMMessageCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[EMMessageCell alloc] initWithDirection:model.direction type:model.type];
        cell.delegate = self;
    }
    
    cell.model = model;
    
    return cell;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
    [self.chatBar clearMoreViewAndSelectedButton];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {
        NSURL *videoURL = info[UIImagePickerControllerMediaURL];
        // we will convert it to mp4 format
        NSURL *mp4 = [self _videoConvert2Mp4:videoURL];
        NSFileManager *fileman = [NSFileManager defaultManager];
        if ([fileman fileExistsAtPath:videoURL.path]) {
            NSError *error = nil;
            [fileman removeItemAtURL:videoURL error:&error];
            if (error) {
                NSLog(@"failed to remove file, error:%@.", error);
            }
        }
        [self _sendVideoAction:mp4];
    } else {
        NSURL *url = info[UIImagePickerControllerReferenceURL];
        if (url == nil) {
            UIImage *orgImage = info[UIImagePickerControllerOriginalImage];
            NSData *data = UIImageJPEGRepresentation(orgImage, 1);
            [self _sendImageDataAction:data];
        } else {
            if ([[UIDevice currentDevice].systemVersion doubleValue] >= 9.0f) {
                PHFetchResult *result = [PHAsset fetchAssetsWithALAssetURLs:@[url] options:nil];
                [result enumerateObjectsUsingBlock:^(PHAsset *asset , NSUInteger idx, BOOL *stop){
                    if (asset) {
                        [[PHImageManager defaultManager] requestImageDataForAsset:asset options:nil resultHandler:^(NSData *data, NSString *uti, UIImageOrientation orientation, NSDictionary *dic){
                            if (data != nil) {
                                [self _sendImageDataAction:data];
                            } else {
                                [EMAlertController showErrorAlert:@"图片太大，请选择其他图片"];
                            }
                        }];
                    }
                }];
            } else {
                ALAssetsLibrary *alasset = [[ALAssetsLibrary alloc] init];
                [alasset assetForURL:url resultBlock:^(ALAsset *asset) {
                    if (asset) {
                        ALAssetRepresentation* assetRepresentation = [asset defaultRepresentation];
                        Byte *buffer = (Byte*)malloc((size_t)[assetRepresentation size]);
                        NSUInteger bufferSize = [assetRepresentation getBytes:buffer fromOffset:0.0 length:(NSUInteger)[assetRepresentation size] error:nil];
                        NSData *fileData = [NSData dataWithBytesNoCopy:buffer length:bufferSize freeWhenDone:YES];
                        [self _sendImageDataAction:fileData];
                    }
                } failureBlock:NULL];
            }
        }
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    //TODO: 当弹出call页面时，与imagePicker冲突
    //    self.isViewDidAppear = YES;
    //    [[EaseSDKHelper shareHelper] setIsShowingimagePicker:NO];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
    
    //    self.isViewDidAppear = YES;
    //    [[EaseSDKHelper shareHelper] setIsShowingimagePicker:NO];
}

#pragma mark - EMChatManagerDelegate

- (BOOL)_isNeedSendReadAckForMessage:(EMMessage *)aMessage
                          isMarkRead:(BOOL)aIsMarkRead
{
    if (!self.isViewDidAppear || aMessage.direction == EMMessageDirectionSend || aMessage.isReadAcked || aMessage.chatType != EMChatTypeChat || [UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        return NO;
    }
    
    EMMessageBody *body = aMessage.body;
    if (!aIsMarkRead && (body.type == EMMessageBodyTypeVideo || body.type == EMMessageBodyTypeVoice || body.type == EMMessageBodyTypeImage)) {
        return NO;
    }
    
    return YES;
}

- (void)messagesDidReceive:(NSArray *)aMessages
{
    __weak typeof(self) weakself = self;
    dispatch_async(self.msgQueue, ^{
        NSString *conId = weakself.conversationModel.emModel.conversationId;
        NSMutableArray *sorted = [[NSMutableArray alloc] init];
        for (int i = 0; i < [aMessages count]; i++) {
            EMMessage *msg = aMessages[i];
            if (![msg.conversationId isEqualToString:conId]) {
                continue;
            }
            
            EMMessageModel *model = [[EMMessageModel alloc] initWithEMMessage:msg];
            [sorted addObject:model];
            
            if ([weakself _isNeedSendReadAckForMessage:msg isMarkRead:NO]) {
                [[EMClient sharedClient].chatManager sendMessageReadAck:msg completion:nil];
            }
            [weakself.conversationModel.emModel markMessageAsReadWithId:msg.messageId error:nil];
        }
        [weakself.dataArray addObjectsFromArray:sorted];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself.tableView reloadData];
            [weakself _scrollToBottomRow];
        });
    });
}

- (void)messagesDidRead:(NSArray *)aMessages
{
    __weak typeof(self) weakself = self;
    dispatch_async(self.msgQueue, ^{
        NSString *conId = weakself.conversationModel.emModel.conversationId;
        __block BOOL isReladView = NO;
        for (EMMessage *message in aMessages) {
            if (![conId isEqualToString:message.conversationId]){
                continue;
            }
            
            [weakself.dataArray enumerateObjectsUsingBlock:^(EMMessageModel *model, NSUInteger idx, BOOL *stop) {
                if ([model.emModel.messageId isEqualToString:message.messageId]) {
                    model.emModel.isReadAcked = YES;
                    isReladView = YES;
                    *stop = YES;
                }
            }];
        }
        
        if (isReladView) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakself.tableView reloadData];
            });
        }
    });
}

- (void)messageStatusDidChange:(EMMessage *)aMessage
                         error:(EMError *)aError
{
    __weak typeof(self) weakself = self;
    dispatch_async(self.msgQueue, ^{
        NSString *conId = weakself.conversationModel.emModel.conversationId;
        if (![conId isEqualToString:aMessage.conversationId]){
            return ;
        }
        
        __block NSUInteger index = NSNotFound;
        __block EMMessageModel *reloadModel = nil;
        [self.dataArray enumerateObjectsUsingBlock:^(EMMessageModel *model, NSUInteger idx, BOOL *stop) {
            if ([model.emModel.messageId isEqualToString:aMessage.messageId]) {
                reloadModel = model;
                index = idx;
                *stop = YES;
            }
        }];
        
        if (index != NSNotFound) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakself.dataArray replaceObjectAtIndex:index withObject:reloadModel];
                [weakself.tableView beginUpdates];
                [weakself.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                [weakself.tableView endUpdates];
            });
        }
        
    });
}

#pragma mark - EMChatBarDelegate

- (BOOL)inputView:(EMTextView *)aInputView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [self _sendTextAction:aInputView.text ext:nil];
        
        return NO;
    }
    
    return YES;
}

- (void)inputViewDidChange:(EMTextView *)aInputView
{
//    NSString *text = aInputView.text;
//    if ([text hasSuffix:@"@"]) {
//        if ([self.delegate respondsToSelector:@selector(didInputAtInLocation:)]) {
//            if ([self.delegate didInputAtInLocation:(text.length - 1)]) {
//                [self _willShowInputTextViewToHeight:[self _getTextViewContentH:self.inputTextView]];
//            }
//        }
//    }
}

- (void)chatBarDidCameraAction
{
    [self.view endEditing:YES];
    
#if TARGET_IPHONE_SIMULATOR
    [EMAlertController showErrorAlert:@"模拟器不支持照相机"];
#elif TARGET_OS_IPHONE
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    self.imagePicker.mediaTypes = @[(NSString *)kUTTypeImage, (NSString *)kUTTypeMovie];
    [self presentViewController:self.imagePicker animated:YES completion:nil];
#endif
}

- (void)chatBarDidPhotoAction
{
    [self.view endEditing:YES];
    
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    self.imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
    [self presentViewController:self.imagePicker animated:YES completion:nil];
}

- (void)chatBarDidLocationAction
{
    EMLocationViewController *controller = [[EMLocationViewController alloc] init];
    [controller setSendCompletion:^(CLLocationCoordinate2D aCoordinate, NSString * _Nonnull aAddress) {
        [self _sendLocationAction:aCoordinate address:aAddress];
    }];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
    [self.navigationController presentViewController:navController animated:YES completion:nil];
}

#pragma mark - EMChatBarCallViewDelegate

- (void)chatBarCallViewAudioDidSelected
{
    [self.chatBar clearMoreViewAndSelectedButton];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:CALL_1V1 object:@{CALL_CHATTER:self.conversationModel.emModel.conversationId, CALL_TYPE:@(EMCallTypeVoice)}];
}

- (void)chatBarCallViewVideoDidSelected
{
    [self.chatBar clearMoreViewAndSelectedButton];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:CALL_1V1 object:@{CALL_CHATTER:self.conversationModel.emModel.conversationId, CALL_TYPE:@(EMCallTypeVideo)}];
}

- (void)chatBarCallViewConferenceDidSelected
{
    [self.chatBar clearMoreViewAndSelectedButton];
    
    ConfInviteType inviteType = ConfInviteTypeUser;
    if (self.conversationModel.emModel.type == EMChatTypeGroupChat) {
        inviteType = ConfInviteTypeGroup;
    } else if (self.conversationModel.emModel.type == EMChatTypeChatRoom) {
        inviteType = ConfInviteTypeChatroom;
    }
    [[DemoConfManager sharedManager] inviteMemberWithConfType:EMConferenceTypeLargeCommunication inviteType:inviteType conversationId:self.conversationModel.emModel.conversationId chatType:(EMChatType)self.conversationModel.emModel.type popFromController:self.navigationController];
}

- (void)chatBarCallViewLiveDidSelected
{
    [self.chatBar clearMoreViewAndSelectedButton];
    
    ConfInviteType inviteType = ConfInviteTypeUser;
    if (self.conversationModel.emModel.type == EMChatTypeGroupChat) {
        inviteType = ConfInviteTypeGroup;
    } else if (self.conversationModel.emModel.type == EMChatTypeChatRoom) {
        inviteType = ConfInviteTypeChatroom;
    }
    [[DemoConfManager sharedManager] inviteMemberWithConfType:EMConferenceTypeLive inviteType:inviteType conversationId:self.conversationModel.emModel.conversationId chatType:(EMChatType)self.conversationModel.emModel.type popFromController:self.navigationController];
}

#pragma mark - EMChatBarEmoticonViewDelegate

- (void)didSelectedEmoticonModel:(EMEmoticonModel *)aModel
{
    if (aModel.type == EMEmotionTypeEmoji) {
        [self.chatBar inputViewAppendText:aModel.name];
    } if (aModel.type == EMEmotionTypeGif) {
        NSDictionary *ext = @{MSG_EXT_GIF:@(YES), MSG_EXT_GIF_ID:aModel.name};
        [self _sendTextAction:aModel.name ext:ext];
    }
}

- (void)didChatBarEmoticonViewSendAction
{
    [self _sendTextAction:self.chatBar.textView.text ext:nil];
}

#pragma mark - EMMessageCellDelegate

- (void)messageCellDidSelected:(EMMessageCell *)aCell
{
    if (aCell.model.type == EMMessageBodyTypeImage) {
        [self _imageMessageCellDidSelected:aCell];
    } else if (aCell.model.type == EMMessageBodyTypeLocation) {
        [self _locationMessageCellDidSelected:aCell];
    } else if (aCell.model.type == EMMessageBodyTypeVoice) {
        [self _audioMessageCellDidSelected:aCell];
    } else if (aCell.model.type == EMMessageBodyTypeVideo) {
        [self _videoMessageCellDidSelected:aCell];
    } else if (aCell.model.type == EMMessageBodyTypeFile) {
        [self _fileMessageCellDidSelected:aCell];
    }
}

- (void)_imageMessageCellDidSelected:(EMMessageCell *)aCell
{
    EMImageMessageBody *body = (EMImageMessageBody*)aCell.model.emModel.body;
     BOOL isCustomDownload = !([EMClient sharedClient].options.isAutoTransferMessageAttachments);
    
    __weak typeof(self) weakself = self;
    if (body.thumbnailDownloadStatus == EMDownloadStatusFailed) {
        if (isCustomDownload) {
            [self _showCustomTransferFileAlertView];
        } else {
            [self showHint:@"获取缩略图..."];
            [[EMClient sharedClient].chatManager downloadMessageThumbnail:aCell.model.emModel progress:nil completion:^(EMMessage *message, EMError *error) {
                if (!error) {
                    [weakself.tableView reloadData];
                }
            }];
        }
        return;
    }
    
    if (body.downloadStatus == EMDownloadStatusSucceed) {
        UIImage *image = [UIImage imageWithContentsOfFile:body.localPath];
        if (image) {
            [[EMImageBrowser sharedBrowser] showImages:@[image] fromController:self];
            return;
        }
    }
    
    if (isCustomDownload) {
        [self _showCustomTransferFileAlertView];
        return;
    }
    
    [self showHudInView:self.view hint:@"下载原图..."];
    [[EMClient sharedClient].chatManager downloadMessageAttachment:aCell.model.emModel progress:nil completion:^(EMMessage *message, EMError *error) {
        [weakself hideHud];
        if (error) {
            [EMAlertController showErrorAlert:@"下载原图失败"];
        } else {
            if (!message.isReadAcked) {
                [[EMClient sharedClient].chatManager sendMessageReadAck:message completion:nil];
            }
            
            NSString *localPath = [(EMImageMessageBody *)message.body localPath];
            UIImage *image = [UIImage imageWithContentsOfFile:localPath];
            if (image) {
                [[EMImageBrowser sharedBrowser] showImages:@[image] fromController:self];
            } else {
                [EMAlertController showErrorAlert:@"获取本地原图失败"];
            }
        }
    }];
}

- (void)_locationMessageCellDidSelected:(EMMessageCell *)aCell
{
    EMLocationMessageBody *body = (EMLocationMessageBody *)aCell.model.emModel.body;
    EMLocationViewController *controller = [[EMLocationViewController alloc] initWithLocation:CLLocationCoordinate2DMake(body.latitude, body.longitude)];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
    [self.navigationController presentViewController:navController animated:YES completion:nil];
}

- (void)_audioMessageCellDidSelected:(EMMessageCell *)aCell
{
    if (aCell.model.isPlaying) {
        [[EMAudioPlayerHelper sharedHelper] stopPlayer];
        aCell.model.isPlaying = NO;
        [self.tableView reloadData];
        return;
    }
    
    EMVoiceMessageBody *body = (EMVoiceMessageBody*)aCell.model.emModel.body;
    if (body.downloadStatus == EMDownloadStatusDownloading) {
        [EMAlertController showInfoAlert:@"正在下载语音,稍后点击"];
        return;
    }
    
    __weak typeof(self) weakself = self;
    void (^playBlock)(EMMessageModel *aModel) = ^(EMMessageModel *aModel) {
        id model = [EMAudioPlayerHelper sharedHelper].model;
        if (model && [model isKindOfClass:[EMMessageModel class]]) {
            EMMessageModel *oldModel = (EMMessageModel *)model;
            if (oldModel.isPlaying) {
                oldModel.isPlaying = NO;
            }
        }
        aModel.isPlaying = YES;
        [weakself.tableView reloadData];
        
        [[EMCDDeviceManager sharedInstance] enableProximitySensor];
        [[EMAudioPlayerHelper sharedHelper] startPlayerWithPath:body.localPath model:aModel completion:^(NSError * _Nonnull error) {
            [[EMCDDeviceManager sharedInstance] disableProximitySensor];
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
    
    [self showHudInView:self.view hint:@"下载语音..."];
    
    [[EMClient sharedClient].chatManager downloadMessageAttachment:aCell.model.emModel progress:nil completion:^(EMMessage *message, EMError *error) {
        [weakself hideHud];
        if (error) {
            [EMAlertController showErrorAlert:@"下载语音失败"];
        } else {
            if (!message.isReadAcked) {
                [[EMClient sharedClient].chatManager sendMessageReadAck:message completion:nil];
            }
            
            playBlock(aCell.model);
        }
    }];
}

- (void)_videoMessageCellDidSelected:(EMMessageCell *)aCell
{
    EMVideoMessageBody *body = (EMVideoMessageBody*)aCell.model.emModel.body;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isCustomDownload = !([EMClient sharedClient].options.isAutoTransferMessageAttachments);
    if (body.thumbnailDownloadStatus == EMDownloadStatusFailed || ![fileManager fileExistsAtPath:body.thumbnailLocalPath]) {
        [self showHint:@"下载缩略图"];
        if (!isCustomDownload) {
            [[EMClient sharedClient].chatManager downloadMessageThumbnail:aCell.model.emModel progress:nil completion:nil];
        }
    }
    
    if (body.downloadStatus == EMDownloadStatusDownloading) {
        [EMAlertController showInfoAlert:@"正在下载视频,稍后点击"];
        return;
    }
    
    void (^playBlock)(NSString *aPath) = ^(NSString *aPathe) {
        NSURL *videoURL = [NSURL fileURLWithPath:aPathe];
        AVPlayerViewController *playerViewController = [[AVPlayerViewController alloc] init];
        playerViewController.player = [AVPlayer playerWithURL:videoURL];
        playerViewController.videoGravity = AVLayerVideoGravityResizeAspect;
        playerViewController.showsPlaybackControls = YES;
        [self presentViewController:playerViewController animated:YES completion:^{
            [playerViewController.player play];
        }];
    };
    
    if (body.downloadStatus == EMDownloadStatusSuccessed && [fileManager fileExistsAtPath:body.localPath]) {
        playBlock(body.localPath);
        return;
    }
    
    if (isCustomDownload) {
        [self _showCustomTransferFileAlertView];
    } else {
        [self showHudInView:self.view hint:@"下载视频..."];
        __weak typeof(self) weakself = self;
        [[EMClient sharedClient].chatManager downloadMessageAttachment:aCell.model.emModel progress:nil completion:^(EMMessage *message, EMError *error) {
            [weakself hideHud];
            if (error) {
                [EMAlertController showErrorAlert:@"下载视频失败"];
            } else {
                if (!message.isReadAcked) {
                    [[EMClient sharedClient].chatManager sendMessageReadAck:message completion:nil];
                }
                playBlock([(EMVideoMessageBody*)message.body localPath]);
            }
        }];
    }
}

- (void)_fileMessageCellDidSelected:(EMMessageCell *)aCell
{
    
}

#pragma mark - KeyBoard

- (void)keyBoardWillShow:(NSNotification *)note
{
    // 获取用户信息
    NSDictionary *userInfo = [NSDictionary dictionaryWithDictionary:note.userInfo];
    // 获取键盘高度
    CGRect keyBoardBounds  = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyBoardHeight = keyBoardBounds.size.height;
    // 获取键盘动画时间
    CGFloat animationTime  = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    // 定义好动作
    void (^animation)(void) = ^void(void) {
        [self.chatBar mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.view).offset(-keyBoardHeight);
        }];
    };
    
    if (animationTime > 0) {
        [UIView animateWithDuration:animationTime animations:animation completion:^(BOOL finished) {
            [self _scrollToBottomRow];
        }];
    } else {
        animation();
    }
}

- (void)keyBoardWillHide:(NSNotification *)note
{
    // 获取用户信息
    NSDictionary *userInfo = [NSDictionary dictionaryWithDictionary:note.userInfo];
    // 获取键盘动画时间
    CGFloat animationTime  = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    // 定义好动作
    void (^animation)(void) = ^void(void) {
        [self.chatBar mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.view);
        }];
    };
    
    if (animationTime > 0) {
        [UIView animateWithDuration:animationTime animations:animation];
    } else {
        animation();
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
            weakself.isFirstLoadFromDB = YES;
            [weakself tableViewDidTriggerHeaderRefresh];
        }
    }];
}

- (void)_scrollToBottomRow
{
    if ([self.dataArray count] > 0) {
        NSInteger toRow = self.dataArray.count - 1;
        NSIndexPath *toIndexPath = [NSIndexPath indexPathForRow:toRow inSection:0];
        [self.tableView scrollToRowAtIndexPath:toIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
}

- (void)_showCustomTransferFileAlertView
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"(づ｡◕‿‿◕｡)づ" message:@"需要自定义实现上传附件方法" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (NSURL *)_videoConvert2Mp4:(NSURL *)movUrl
{
    NSURL *mp4Url = nil;
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:movUrl options:nil];
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    
    if ([compatiblePresets containsObject:AVAssetExportPresetHighestQuality]) {
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]initWithAsset:avAsset presetName:AVAssetExportPresetHighestQuality];
        NSString *mp4Path = [NSString stringWithFormat:@"%@/%d%d.mp4", [EMCDDeviceManager dataPath], (int)[[NSDate date] timeIntervalSince1970], arc4random() % 100000];
        mp4Url = [NSURL fileURLWithPath:mp4Path];
        exportSession.outputURL = mp4Url;
        exportSession.shouldOptimizeForNetworkUse = YES;
        exportSession.outputFileType = AVFileTypeMPEG4;
        dispatch_semaphore_t wait = dispatch_semaphore_create(0l);
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            switch ([exportSession status]) {
                case AVAssetExportSessionStatusFailed: {
                    NSLog(@"failed, error:%@.", exportSession.error);
                } break;
                case AVAssetExportSessionStatusCancelled: {
                    NSLog(@"cancelled.");
                } break;
                case AVAssetExportSessionStatusCompleted: {
                    NSLog(@"completed.");
                } break;
                default: {
                    NSLog(@"others.");
                } break;
            }
            dispatch_semaphore_signal(wait);
        }];
        long timeout = dispatch_semaphore_wait(wait, DISPATCH_TIME_FOREVER);
        if (timeout) {
            NSLog(@"timeout.");
        }
        
        if (wait) {
            //dispatch_release(wait);
            wait = nil;
        }
    }
    
    return mp4Url;
}


#pragma mark - Data

- (void)_sortedMessages:(NSArray<EMMessage *> *)aMessages
          isInsertFirst:(BOOL)aIsInsertFirst
{
    NSMutableArray *sorted = [[NSMutableArray alloc] init];
    for (int i = 0; i < [aMessages count]; i++) {
        EMMessage *msg = aMessages[i];
        EMMessageModel *model = [[EMMessageModel alloc] initWithEMMessage:msg];
        if (!model.emModel.isReadAcked && (model.type == EMMessageBodyTypeText || model.type == EMMessageBodyTypeLocation)) {
            [[EMClient sharedClient].chatManager sendMessageReadAck:msg completion:nil];
        }
        [sorted addObject:model];
    }
    if (aIsInsertFirst) {
        [self.dataArray insertObjects:sorted atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [sorted count])]];
    } else {
        [self.dataArray addObjectsFromArray:sorted];
    }
}

- (void)tableViewDidTriggerHeaderRefresh
{
    __weak typeof(self) weakself = self;
    [self.conversationModel.emModel loadMessagesStartFromId:self.moreMsgId count:50 searchDirection:EMMessageSearchDirectionUp completion:^(NSArray *aMessages, EMError *aError) {
        if (!aError && [aMessages count]) {
            EMMessage *msg = aMessages[0];
            weakself.moreMsgId = msg.messageId;
            
            dispatch_async(self.msgQueue, ^{
                [weakself _sortedMessages:aMessages isInsertFirst:YES];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakself.tableView reloadData];
                    
                    if (weakself.isFirstLoadFromDB) {
                        weakself.isFirstLoadFromDB = NO;
                        [weakself _scrollToBottomRow];
                    }
                });
            });
        }
        
        [weakself tableViewDidFinishTriggerHeader:YES reload:NO];
    }];
}

#pragma mark - Action

- (void)backAction
{
    [EMConversationHelper resortConversationsLatestMessage];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)deleteAllMessageAction
{
    EMError *error = nil;
    [self.conversationModel.emModel deleteAllMessages:&error];
    if (!error) {
        [self.dataArray removeAllObjects];
        [self.tableView reloadData];
    }
}

- (void)groupOrChatroomInfoAction
{
    if (self.conversationModel.emModel.type == EMConversationTypeGroupChat) {
        EMGroupInfoViewController *controller = [[EMGroupInfoViewController alloc] initWithGroupId:self.conversationModel.emModel.conversationId];
        [self.navigationController pushViewController:controller animated:YES];
    } else if (self.conversationModel.emModel.type == EMConversationTypeChatRoom) {
        EMChatroomInfoViewController *controller = [[EMChatroomInfoViewController alloc] initWithChatroomId:self.conversationModel.emModel.conversationId];
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (void)_sendMessageWithBody:(EMMessageBody *)aBody
                         ext:(NSDictionary *)aExt
                    isUpload:(BOOL)aIsUpload
{
    if (!([EMClient sharedClient].options.isAutoTransferMessageAttachments) && aIsUpload) {
        [self _showCustomTransferFileAlertView];
        return;
    }
    
    NSString *from = [[EMClient sharedClient] currentUsername];
    NSString *to = self.conversationModel.emModel.conversationId;
    EMMessage *message = [[EMMessage alloc] initWithConversationID:to from:from to:to body:aBody ext:aExt];
    message.chatType = (EMChatType)self.conversationModel.emModel.type;
    
    __weak typeof(self) weakself = self;
    [[EMClient sharedClient].chatManager sendMessage:message progress:nil completion:^(EMMessage *message, EMError *error) {
        [weakself.tableView reloadData];
    }];
    
    EMMessageModel *model = [[EMMessageModel alloc] initWithEMMessage:message];
    [self.dataArray addObject:model];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(self.dataArray.count - 1) inSection:0];
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
    [self.tableView endUpdates];
    
    [self _scrollToBottomRow];
}

- (void)_sendTextAction:(NSString *)aText
                    ext:(NSDictionary *)aExt
{
    [self.chatBar clearInputViewText];
    if ([aText length] == 0) {
        return;
    }
    
    //TODO: 处理@
    //messageExt
    
    //TODO: 处理表情
//    NSString *sendText = [EaseConvertToCommonEmoticonsHelper convertToCommonEmoticons:aText];
    
    EMTextMessageBody *body = [[EMTextMessageBody alloc] initWithText:aText];
    [self _sendMessageWithBody:body ext:aExt isUpload:NO];
}

- (void)_sendImageDataAction:(NSData *)aImageData
{
    EMImageMessageBody *body = [[EMImageMessageBody alloc] initWithData:aImageData displayName:@"image"];
    [self _sendMessageWithBody:body ext:nil isUpload:YES];
}

- (void)_sendLocationAction:(CLLocationCoordinate2D)aCoord
                    address:(NSString *)aAddress
{
    EMLocationMessageBody *body = [[EMLocationMessageBody alloc] initWithLatitude:aCoord.latitude longitude:aCoord.longitude address:aAddress];
    [self _sendMessageWithBody:body ext:nil isUpload:NO];
}

- (void)_sendVideoAction:(NSURL *)aUrl
{
    EMVideoMessageBody *body = [[EMVideoMessageBody alloc] initWithLocalPath:[aUrl path] displayName:@"video.mp4"];
    [self _sendMessageWithBody:body ext:nil isUpload:YES];
}

@end
