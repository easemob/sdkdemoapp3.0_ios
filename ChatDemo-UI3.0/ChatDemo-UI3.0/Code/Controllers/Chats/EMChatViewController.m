//
//  EMChatViewController.m
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 16/9/22.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "EMChatViewController.h"

#import <MobileCoreServices/MobileCoreServices.h>
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MediaPlayer/MediaPlayer.h>
#import "EMChatToolBar.h"
#import "EMLocationViewController.h"
#import "EMChatBaseCell.h"
#import "EMMessageReadManager.h"
#import "EMCDDeviceManager.h"
#import "EMSDKHelper.h"
#import "EaseCallManager.h"
#import "EMGroupInfoViewController.h"
#import "EMConversationModel.h"
#import "EMMessageModel.h"
#import "EMNotificationNames.h"

@interface EMChatViewController () <EMChatToolBarDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,EMLocationViewDelegate,EMChatManagerDelegate,EMChatBaseCellDelegate,UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet EMChatToolBar *chatToolBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) UIImagePickerController *imagePickerController;

@property (strong, nonatomic) NSMutableArray *dataSource;
@property (strong, nonatomic) UIRefreshControl *refresh;
@property (strong, nonatomic) UIButton *backButton;
@property (strong, nonatomic) UIButton *camButton;
@property (strong, nonatomic) UIButton *photoButton;
@property (strong, nonatomic) UIButton *detailButton;
@property (strong, nonatomic) NSIndexPath *longPressIndexPath;

@property (strong, nonatomic) EMConversation *conversation;
@property (strong, nonatomic) EMMessageModel *prevAudioModel;

@end

@implementation EMChatViewController

- (instancetype)initWithConversationId:(NSString*)conversationId conversationType:(EMConversationType)type
{
    self = [super init];
    if (self) {
        _conversation = [[EMClient sharedClient].chatManager getConversation:conversationId type:type createIfNotExist:YES];
        [_conversation markAllMessagesAsRead:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if ([UIDevice currentDevice].systemVersion.floatValue >= 7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyBoardHidden:)];
    [self.view addGestureRecognizer:tap];
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self.tableView addSubview:self.refresh];
    
    self.chatToolBar.delegate = self;
    [self tableViewDidTriggerHeaderRefresh];
    
    [[EMClient sharedClient].chatManager addDelegate:self];
    
    if (_conversation.type == EMConversationTypeChat) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.backButton];
        self.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc] initWithCustomView:self.photoButton],[[UIBarButtonItem alloc] initWithCustomView:self.camButton]];
         self.title = self.conversation.conversationId;
    } else if (_conversation.type == EMConversationTypeGroupChat){
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.backButton];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.detailButton];
        self.title = [[EMConversationModel alloc] initWithConversation:self.conversation].title;
    } else if (_conversation.type == EMConversationTypeChatRoom){
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.backButton];
    }
    
    [self setupViewLayout];
}

- (void)viewDidAppear:(BOOL)animated
{
    NSMutableArray *unreadMessages = [NSMutableArray array];
    for (EMMessageModel *model in self.dataSource) {
        if ([self _shouldSendHasReadAckForMessage:model.message read:NO]) {
            [unreadMessages addObject:model.message];
        }
    }
    if ([unreadMessages count]) {
        [self _sendHasReadResponseForMessages:unreadMessages isRead:YES];
    }
    [_conversation markAllMessagesAsRead:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(removeGroupsNotification:)
                                                 name:KEM_REMOVEGROUP_NOTIFICATION
                                               object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[EMClient sharedClient].chatManager removeDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:KEM_REMOVEGROUP_NOTIFICATION
                                                  object:nil];
}

- (void)setupViewLayout
{
    self.tableView.width = KScreenWidth;
    self.tableView.height = KScreenHeight - self.chatToolBar.height - 64;
    
    self.chatToolBar.width = KScreenWidth;
    self.chatToolBar.top = KScreenHeight - self.chatToolBar.height - 64;
}

#pragma mark - getter

- (UIButton*)backButton
{
    if (_backButton == nil) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _backButton.frame = CGRectMake(0, 0, 8, 15);
        [_backButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
        [_backButton setImage:[UIImage imageNamed:@"Icon_Back"] forState:UIControlStateNormal];
    }
    return _backButton;
}

- (UIButton*)camButton
{
    if (_camButton == nil) {
        _camButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _camButton.frame = CGRectMake(0, 0, 20, 12);
        [_camButton setImage:[UIImage imageNamed:@"iconVideo"] forState:UIControlStateNormal];
        [_camButton addTarget:self action:@selector(makeVideoCall) forControlEvents:UIControlEventTouchUpInside];
    }
    return _camButton;
}

- (UIButton*)photoButton
{
    if (_photoButton == nil) {
        _photoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _photoButton.frame = CGRectMake(0, 0, 20, 15);
        [_photoButton setImage:[UIImage imageNamed:@"iconCall"] forState:UIControlStateNormal];
        [_photoButton addTarget:self action:@selector(makeAudioCall) forControlEvents:UIControlEventTouchUpInside];
    }
    return _photoButton;
}

- (UIButton*)detailButton
{
    if (_detailButton == nil) {
        _detailButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _detailButton.frame = CGRectMake(0, 0, 44, 44);
        [_detailButton setImage:[UIImage imageNamed:@"icon_info"] forState:UIControlStateNormal];
        [_detailButton addTarget:self action:@selector(enterDetailView) forControlEvents:UIControlEventTouchUpInside];
    }
    return _detailButton;
}

- (UIImagePickerController *)imagePickerController
{
    if (_imagePickerController == nil) {
        _imagePickerController = [[UIImagePickerController alloc] init];
        _imagePickerController.modalPresentationStyle= UIModalPresentationOverFullScreen;
        _imagePickerController.allowsEditing = NO;
        _imagePickerController.delegate = self;
    }
    return _imagePickerController;
}

- (NSMutableArray*)dataSource
{
    if (_dataSource == nil) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

- (UIRefreshControl*)refresh
{
    if (_refresh == nil) {
        _refresh = [[UIRefreshControl alloc] init];
        _refresh.tintColor = [UIColor lightGrayColor];
        [_refresh addTarget:self action:@selector(_loadMoreMessage) forControlEvents:UIControlEventValueChanged];
    }
    return _refresh;
}

#pragma mark - Notification Method

- (void)removeGroupsNotification:(NSNotification *)notification {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EMMessageModel *model = [self.dataSource objectAtIndex:indexPath.row];
    NSString *CellIdentifier = [EMChatBaseCell cellIdentifierForMessageModel:model];
    EMChatBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[EMChatBaseCell alloc] initWithMessageModel:model];
        cell.delegate = self;
    }
    [cell setMessageModel:model];
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EMMessageModel *model = [self.dataSource objectAtIndex:indexPath.row];
    return [EMChatBaseCell heightForMessageModel:model];
}

#pragma mark - EMChatToolBarDelegate

- (void)chatToolBarDidChangeFrameToHeight:(CGFloat)toHeight
{
    [UIView animateWithDuration:0.25 animations:^{
        self.tableView.top = 0.f;
        self.tableView.height = self.view.frame.size.height - toHeight;
    }];
    [self _scrollViewToBottom:NO];
}

- (void)didSendText:(NSString *)text
{
    EMMessage *message = [EMSDKHelper sendTextMessage:text
                                                   to:_conversation.conversationId
                                          messageType:[self _messageType]
                                           messageExt:nil];
    [self _sendMessage:message];
}

- (void)didSendAudio:(NSString *)recordPath duration:(NSInteger)duration
{
    EMMessage *message = [EMSDKHelper sendVoiceMessageWithLocalPath:recordPath
                                                           duration:duration
                                                                 to:_conversation.conversationId
                                                        messageType:[self _messageType]
                                                         messageExt:nil];
    [self _sendMessage:message];
}

- (void)didTakePhotos
{
    [self.chatToolBar endEditing:YES];
#if TARGET_IPHONE_SIMULATOR

#elif TARGET_OS_IPHONE
    self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    self.imagePickerController.mediaTypes = @[(NSString *)kUTTypeImage, (NSString *)kUTTypeMovie];
    [self presentViewController:self.imagePickerController animated:YES completion:NULL];
#endif

}

- (void)didSelectPhotos
{
    [self.chatToolBar endEditing:YES];
    self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    [self presentViewController:self.imagePickerController animated:YES completion:NULL];
}

- (void)didSelectLocation
{
    [self.chatToolBar endEditing:YES];
    EMLocationViewController *locationViewController = [[EMLocationViewController alloc] init];
    locationViewController.delegate = self;
    [self.navigationController pushViewController:locationViewController animated:YES];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {
        NSURL *videoURL = info[UIImagePickerControllerMediaURL];
        NSURL *mp4 = [self _convert2Mp4:videoURL];
        NSFileManager *fileman = [NSFileManager defaultManager];
        if ([fileman fileExistsAtPath:videoURL.path]) {
            NSError *error = nil;
            [fileman removeItemAtURL:videoURL error:&error];
            if (error) {
                NSLog(@"failed to remove file, error:%@.", error);
            }
        }
        EMMessage *message = [EMSDKHelper sendVideoMessageWithURL:mp4 to:_conversation.conversationId messageType:[self _messageType] messageExt:nil];
        [self _sendMessage:message];
        
    }else{
        NSURL *url = info[UIImagePickerControllerReferenceURL];
        if (url == nil) {
            UIImage *orgImage = info[UIImagePickerControllerOriginalImage];
            NSData *data = UIImageJPEGRepresentation(orgImage, 1);
            EMMessage *message = [EMSDKHelper sendImageMessageWithImageData:data
                                                                         to:_conversation.conversationId
                                                                messageType:[self _messageType]
                                                                 messageExt:nil];
            [self _sendMessage:message];
        } else {
            if ([[UIDevice currentDevice].systemVersion doubleValue] >= 9.0f) {
                PHFetchResult *result = [PHAsset fetchAssetsWithALAssetURLs:@[url] options:nil];
                [result enumerateObjectsUsingBlock:^(PHAsset *asset , NSUInteger idx, BOOL *stop){
                    if (asset) {
                        [[PHImageManager defaultManager] requestImageDataForAsset:asset options:nil resultHandler:^(NSData *data, NSString *uti, UIImageOrientation orientation, NSDictionary *dic){
                            if (data.length > 10 * 1000 * 1000) {
//                                [self showHint:NSEaseLocalizedString(@"message.smallerImage", @"The image size is too large, please choose another one")];
//                                return;
                            }
                            if (data != nil) {
                                EMMessage *message = [EMSDKHelper sendImageMessageWithImageData:data
                                                                                             to:_conversation.conversationId
                                                                                    messageType:[self _messageType]
                                                                                     messageExt:nil];
                                [self _sendMessage:message];
                            } else {
//                                [self showHint:NSEaseLocalizedString(@"message.smallerImage", @"The image size is too large, please choose another one")];
                            }
                        }];
                    }
                }];
            } else {
                ALAssetsLibrary *alasset = [[ALAssetsLibrary alloc] init];
                [alasset assetForURL:url resultBlock:^(ALAsset *asset) {
                    if (asset) {
                        ALAssetRepresentation* assetRepresentation = [asset defaultRepresentation];
                        Byte* buffer = (Byte*)malloc((size_t)[assetRepresentation size]);
                        NSUInteger bufferSize = [assetRepresentation getBytes:buffer fromOffset:0.0 length:(NSUInteger)[assetRepresentation size] error:nil];
                        NSData* fileData = [NSData dataWithBytesNoCopy:buffer length:bufferSize freeWhenDone:YES];
                        if (fileData.length > 10 * 1000 * 1000) {
//                            [self showHint:NSEaseLocalizedString(@"message.smallerImage", @"The image size is too large, please choose another one")];
                            return;
                        }
                        EMMessage *message = [EMSDKHelper sendImageMessageWithImageData:fileData
                                                                                     to:_conversation.conversationId
                                                                            messageType:[self _messageType]
                                                                             messageExt:nil];
                        [self _sendMessage:message];
                    }
                } failureBlock:NULL];
            }
        }
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.imagePickerController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - EMLocationViewDelegate

- (void)sendLocationLatitude:(double)latitude
                   longitude:(double)longitude
                  andAddress:(NSString *)address
{
    EMMessage *message = [EMSDKHelper sendLocationMessageWithLatitude:latitude
                                                            longitude:longitude
                                                              address:address
                                                                   to:_conversation.conversationId
                                                          messageType:[self _messageType]
                                                           messageExt:nil];
    [self _sendMessage:message];
}

#pragma mark - EMChatBaseCellDelegate

- (void)didHeadImagePressed:(EMMessageModel *)model
{
    
}

- (void)didImageCellPressed:(EMMessageModel *)model
{
    if ([self _shouldSendHasReadAckForMessage:model.message read:YES]) {
        [self _sendHasReadResponseForMessages:@[model.message] isRead:YES];
    }
    EMImageMessageBody *body = (EMImageMessageBody*)model.message.body;
    if (model.message.direction == EMMessageDirectionSend && body.localPath.length > 0) {
        UIImage *image = [UIImage imageWithContentsOfFile:body.localPath];
        [[EMMessageReadManager shareInstance] showBrowserWithImages:@[image]];
    } else {
        [[EMMessageReadManager shareInstance] showBrowserWithImages:@[[NSURL URLWithString:body.remotePath]]];
    }
}

- (void)didAudioCellPressed:(EMMessageModel *)model
{
    EMVoiceMessageBody *body = (EMVoiceMessageBody*)model.message.body;
    EMDownloadStatus downloadStatus = [body downloadStatus];
    if (downloadStatus == EMDownloadStatusDownloading) {
        return;
    } else if (downloadStatus == EMDownloadStatusFailed) {
        [[EMClient sharedClient].chatManager downloadMessageAttachment:model.message progress:nil completion:nil];
        return;
    }
    
    if (body.type == EMMessageBodyTypeVoice) {
        if ([self _shouldSendHasReadAckForMessage:model.message read:YES]) {
            [self _sendHasReadResponseForMessages:@[model.message] isRead:YES];
        }
        
        BOOL isPrepare = YES;
        if (_prevAudioModel == nil) {
            _prevAudioModel= model;
            model.isPlaying = YES;
        } else if (_prevAudioModel == model){
            model.isPlaying = NO;
            _prevAudioModel = nil;
            isPrepare = NO;
        } else {
            _prevAudioModel.isPlaying = NO;
            model.isPlaying = YES;
        }
        [self.tableView reloadData];
        
        if (isPrepare) {
            WEAK_SELF
            _prevAudioModel = model;
            [[EMCDDeviceManager sharedInstance] enableProximitySensor];
            [[EMCDDeviceManager sharedInstance] asyncPlayingWithPath:body.localPath completion:^(NSError *error) {
                [weakSelf.tableView reloadData];
                [[EMCDDeviceManager sharedInstance] disableProximitySensor];
                model.isPlaying = NO;
            }];
        }
        else{
            [[EMCDDeviceManager sharedInstance] disableProximitySensor];
//            _isPlayingAudio = NO;
        }
    }
}

- (void)didVideoCellPressed:(EMMessageModel*)model
{
    EMVideoMessageBody *videoBody = (EMVideoMessageBody *)model.message.body;
    if (videoBody.downloadStatus == EMDownloadStatusSuccessed) {
        if ([self _shouldSendHasReadAckForMessage:model.message read:YES]) {
            [self _sendHasReadResponseForMessages:@[model.message] isRead:YES];
        }
        NSURL *videoURL = [NSURL fileURLWithPath:videoBody.localPath];
        MPMoviePlayerViewController *moviePlayerController = [[MPMoviePlayerViewController alloc] initWithContentURL:videoURL];
        [moviePlayerController.moviePlayer prepareToPlay];
        moviePlayerController.moviePlayer.movieSourceType = MPMovieSourceTypeFile;
        [self presentMoviePlayerViewControllerAnimated:moviePlayerController];
    } else {
        [[EMClient sharedClient].chatManager downloadMessageAttachment:model.message progress:nil completion:^(EMMessage *message, EMError *error) {
        }];
    }
}

- (void)didLocationCellPressed:(EMMessageModel*)model
{
    EMLocationMessageBody *body = (EMLocationMessageBody*)model.message.body;
    EMLocationViewController *locationController = [[EMLocationViewController alloc] initWithLocation:CLLocationCoordinate2DMake(body.latitude, body.longitude)];
    [self.navigationController pushViewController:locationController animated:YES];
}

- (void)didCellLongPressed:(EMChatBaseCell *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    EMMessageModel *model = [self.dataSource objectAtIndex:indexPath.row];
    if (model.message.body.type == EMMessageBodyTypeText) {
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"chat.cancel", @"Cancel")
                                             destructiveButtonTitle:nil
                                                  otherButtonTitles:NSLocalizedString(@"chat.copy", @"Copy"),NSLocalizedString(@"chat.delete", @"Delete"), nil];
        sheet.tag = 1000;
        [sheet showInView:self.view];
        _longPressIndexPath = indexPath;
    } else {
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"chat.cancel", @"Cancel")
                                             destructiveButtonTitle:nil
                                                  otherButtonTitles:NSLocalizedString(@"chat.delete", @"Delete"), nil];
        sheet.tag = 1001;
        [sheet showInView:self.view];
        _longPressIndexPath = indexPath;
    }
}

- (void)didResendButtonPressed:(EMMessageModel*)model
{
    WEAK_SELF
    [self.tableView reloadData];
    [[EMClient sharedClient].chatManager resendMessage:model.message progress:nil completion:^(EMMessage *message, EMError *error) {
        NSLog(@"%@",error.errorDescription);
        [weakSelf.tableView reloadData];
    }];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 1000) {
        if (buttonIndex == 0) {
            if (_longPressIndexPath && _longPressIndexPath.row > 0) {
                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                if (_longPressIndexPath.row > 0) {
                    EMMessageModel *model = [self.dataSource objectAtIndex:_longPressIndexPath.row];
                    if (model.message.body.type == EMMessageBodyTypeText) {
                        EMTextMessageBody *body = (EMTextMessageBody*)model.message.body;
                        pasteboard.string = body.text;
                    }
                }
                _longPressIndexPath = nil;
            }
        } else if (buttonIndex == 1){
            if (_longPressIndexPath && _longPressIndexPath.row > 0) {
                EMMessageModel *model = [self.dataSource objectAtIndex:_longPressIndexPath.row];
                NSMutableIndexSet *indexs = [NSMutableIndexSet indexSetWithIndex:_longPressIndexPath.row];
                [self.conversation deleteMessageWithId:model.message.messageId error:nil];
                NSMutableArray *indexPaths = [NSMutableArray arrayWithObjects:_longPressIndexPath, nil];;
                if (_longPressIndexPath.row - 1 >= 0) {
                    id nextMessage = nil;
                    id prevMessage = [self.dataSource objectAtIndex:(_longPressIndexPath.row - 1)];
                    if (_longPressIndexPath.row + 1 < [self.dataSource count]) {
                        nextMessage = [self.dataSource objectAtIndex:(_longPressIndexPath.row + 1)];
                    }
                    if ((!nextMessage || [nextMessage isKindOfClass:[NSString class]]) && [prevMessage isKindOfClass:[NSString class]]) {
                        [indexs addIndex:_longPressIndexPath.row - 1];
                        [indexPaths addObject:[NSIndexPath indexPathForRow:(_longPressIndexPath.row - 1) inSection:0]];
                    }
                }
                [self.dataSource removeObjectsAtIndexes:indexs];
                [self.tableView beginUpdates];
                [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
                [self.tableView endUpdates];
            }
            _longPressIndexPath = nil;
        }
    } else if (actionSheet.tag == 1001) {
        if (buttonIndex == 0){
            if (_longPressIndexPath && _longPressIndexPath.row > 0) {
                EMMessageModel *model = [self.dataSource objectAtIndex:_longPressIndexPath.row];
                NSMutableIndexSet *indexs = [NSMutableIndexSet indexSetWithIndex:_longPressIndexPath.row];
                [self.conversation deleteMessageWithId:model.message.messageId error:nil];
                NSMutableArray *indexPaths = [NSMutableArray arrayWithObjects:_longPressIndexPath, nil];;
                if (_longPressIndexPath.row - 1 >= 0) {
                    id nextMessage = nil;
                    id prevMessage = [self.dataSource objectAtIndex:(_longPressIndexPath.row - 1)];
                    if (_longPressIndexPath.row + 1 < [self.dataSource count]) {
                        nextMessage = [self.dataSource objectAtIndex:(_longPressIndexPath.row + 1)];
                    }
                    if ((!nextMessage || [nextMessage isKindOfClass:[NSString class]]) && [prevMessage isKindOfClass:[NSString class]]) {
                        [indexs addIndex:_longPressIndexPath.row - 1];
                        [indexPaths addObject:[NSIndexPath indexPathForRow:(_longPressIndexPath.row - 1) inSection:0]];
                    }
                }
                [self.dataSource removeObjectsAtIndexes:indexs];
                [self.tableView beginUpdates];
                [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
                [self.tableView endUpdates];
            }
            _longPressIndexPath = nil;
        }
    }
}

- (void)actionSheetCancel:(UIActionSheet *)actionSheet
{
    _longPressIndexPath = nil;
}

#pragma mark - action

- (void)tableViewDidTriggerHeaderRefresh
{
    WEAK_SELF
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [_conversation loadMessagesStartFromId:nil
                                         count:20
                               searchDirection:EMMessageSearchDirectionUp
                                    completion:^(NSArray *aMessages, EMError *aError) {
                                        if (!aError) {
                                            [weakSelf.dataSource removeAllObjects];
                                            for (EMMessage * message in aMessages) {
                                                [weakSelf _addMessageToDataSource:message];
                                            }
                                            [weakSelf.refresh endRefreshing];
                                            [weakSelf.tableView reloadData];
                                            [weakSelf _scrollViewToBottom:NO];
                                        }
                                    }];
    });
}

- (void)makeVideoCall
{
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_CALL object:@{@"chatter":self.conversation.conversationId, @"type":[NSNumber numberWithInt:1]}];
}

- (void)makeAudioCall
{
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_CALL object:@{@"chatter":self.conversation.conversationId, @"type":[NSNumber numberWithInt:0]}];
}

- (void)enterDetailView
{
    EMGroup *group = [EMGroup groupWithId:_conversation.conversationId];
    EMGroupInfoViewController *groupInfoViewController = [[EMGroupInfoViewController alloc] initWithGroup:group];
    [self.navigationController pushViewController:groupInfoViewController animated:YES];
    
}

- (void)backAction
{
    if (_conversation.latestMessage == nil) {
        [[EMClient sharedClient].chatManager deleteConversation:_conversation.conversationId isDeleteMessages:YES completion:nil];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - GestureRecognizer

-(void)keyBoardHidden:(UITapGestureRecognizer *)tapRecognizer
{
    if (tapRecognizer.state == UIGestureRecognizerStateEnded) {
        [self.chatToolBar endEditing:YES];
    }
}

#pragma mark - private

- (void)_sendMessage:(EMMessage*)message
{
    [self _addMessageToDataSource:message];
    [self.tableView reloadData];
    WEAK_SELF
    [[EMClient sharedClient].chatManager sendMessage:message progress:nil completion:^(EMMessage *message, EMError *error) {
        [weakSelf.tableView reloadData];
    }];
    [self _scrollViewToBottom:YES];
}

- (void)_addMessageToDataSource:(EMMessage*)message
{
    EMMessageModel *model = [[EMMessageModel alloc] initWithMessage:message];
    [self.dataSource addObject:model];
}

- (void)_scrollViewToBottom:(BOOL)animated
{
    if (self.tableView.contentSize.height > self.tableView.frame.size.height) {
        CGPoint offset = CGPointMake(0, self.tableView.contentSize.height - self.tableView.frame.size.height);
        [self.tableView setContentOffset:offset animated:animated];
    }
}

- (void)_loadMoreMessage
{
    WEAK_SELF
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        EMMessageModel *model = [weakSelf.dataSource objectAtIndex:0];
        [_conversation loadMessagesStartFromId:model.message.messageId
                                         count:20
                               searchDirection:EMMessageSearchDirectionUp
                                    completion:^(NSArray *aMessages, EMError *aError) {
                                        if (!aError) {
                                            [weakSelf.dataSource insertObjects:aMessages atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [aMessages count])]];
                                            [weakSelf.refresh endRefreshing];
                                            [weakSelf.tableView reloadData];
                                        }
                                    }];
    });
}

- (NSURL *)_convert2Mp4:(NSURL *)movUrl
{
    NSURL *mp4Url = nil;
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:movUrl options:nil];
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    
    if ([compatiblePresets containsObject:AVAssetExportPresetHighestQuality]) {
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]initWithAsset:avAsset
                                                                              presetName:AVAssetExportPresetHighestQuality];
        NSString *dataPath = [NSString stringWithFormat:@"%@/Library/appdata/chatbuffer", NSHomeDirectory()];
        NSFileManager *fm = [NSFileManager defaultManager];
        if(![fm fileExistsAtPath:dataPath]){
            [fm createDirectoryAtPath:dataPath
          withIntermediateDirectories:YES
                           attributes:nil
                                error:nil];
        }
        NSString *mp4Path = [NSString stringWithFormat:@"%@/%d%d.mp4", dataPath, (int)[[NSDate date] timeIntervalSince1970], arc4random() % 100000];
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
            wait = nil;
        }
    }
    
    return mp4Url;
}

- (void)_sendHasReadResponseForMessages:(NSArray*)messages
                                 isRead:(BOOL)isRead
{
    NSMutableArray *unreadMessages = [NSMutableArray array];
    for (NSInteger i = 0; i < [messages count]; i++)
    {
        EMMessage *message = messages[i];
        BOOL isSend = [self _shouldSendHasReadAckForMessage:message
                                                      read:isRead];
        if (isSend) {
            [unreadMessages addObject:message];
        }
    }
    if ([unreadMessages count]) {
        for (EMMessage *message in unreadMessages) {
            [[EMClient sharedClient].chatManager sendMessageReadAck:message completion:nil];
        }
    }
}

- (BOOL)_shouldSendHasReadAckForMessage:(EMMessage *)message
                                  read:(BOOL)read
{
    NSString *account = [[EMClient sharedClient] currentUsername];
    if (message.chatType != EMChatTypeChat || message.isReadAcked || [account isEqualToString:message.from] || ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground)) {
        return NO;
    }
    
    EMMessageBody *body = message.body;
    if (((body.type == EMMessageBodyTypeVideo) ||
         (body.type == EMMessageBodyTypeVoice) ||
         (body.type == EMMessageBodyTypeImage)) &&
        !read) {
        return NO;
    } else {
        return YES;
    }
}

- (BOOL)_shouldMarkMessageAsRead
{
    BOOL isMark = YES;
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        isMark = NO;
    }
    return isMark;
}

- (EMChatType)_messageType
{
    EMChatType type = EMChatTypeChat;
    switch (_conversation.type) {
        case EMConversationTypeChat:
            type = EMChatTypeChat;
            break;
        case EMConversationTypeGroupChat:
            type = EMChatTypeGroupChat;
            break;
        case EMConversationTypeChatRoom:
            type = EMChatTypeChatRoom;
            break;
        default:
            break;
    }
    return type;
}

#pragma mark - EMChatManagerDelegate

- (void)messagesDidReceive:(NSArray *)aMessages
{
    for (EMMessage *message in aMessages) {
        if ([self.conversation.conversationId isEqualToString:message.conversationId]) {
            [self _addMessageToDataSource:message];
            [self _sendHasReadResponseForMessages:@[message]
                                           isRead:NO];
            if ([self _shouldMarkMessageAsRead]) {
                [self.conversation markMessageAsReadWithId:message.messageId error:nil];
            }
        }
    }
    [self.tableView reloadData];
    [self _scrollViewToBottom:YES];
}

- (void)messageAttachmentStatusDidChange:(EMMessage *)aMessage
                                   error:(EMError *)aError
{
    if ([self.conversation.conversationId isEqualToString:aMessage.conversationId]) {
        [self.tableView reloadData];
    }
}

- (void)messagesDidRead:(NSArray *)aMessages
{
    for (EMMessage *message in aMessages) {
        if ([self.conversation.conversationId isEqualToString:message.conversationId]) {
            [self.tableView reloadData];
            break;
        }
    }
}

@end
