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

#import "EMImageBrowser.h"
#import "EMDateHelper.h"
#import "EMAudioPlayerHelper.h"
#import "EMConversationHelper.h"
#import "EMMessageModel.h"

#import "EMChatBar.h"
#import "EMMessageCell.h"
#import "EMMessageTimeCell.h"
#import "EMLocationViewController.h"
#import "EMMsgTranspondViewController.h"
#import "EMAtGroupMembersViewController.h"

@interface EMChatViewController ()<UIScrollViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, EMMultiDevicesDelegate, EMChatManagerDelegate, EMGroupManagerDelegate, EMChatroomManagerDelegate, EMChatBarDelegate, EMMessageCellDelegate, EMChatBarEmoticonViewDelegate, EMChatBarRecordAudioViewDelegate>

@property (nonatomic, strong) dispatch_queue_t msgQueue;
@property (nonatomic) BOOL isFirstLoadMsg;
@property (nonatomic) BOOL isViewDidAppear;

@property (nonatomic, strong) EMConversationModel *conversationModel;
@property (nonatomic, strong) NSString *moreMsgId;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *titleDetailLabel;

@property (nonatomic, strong) EMChatBar *chatBar;
@property (nonatomic, strong) UIImagePickerController *imagePicker;

//长按操作栏
@property (strong, nonatomic) NSIndexPath *menuIndexPath;
@property (nonatomic, strong) UIMenuController *menuController;
@property (nonatomic, strong) UIMenuItem *deleteMenuItem;
@property (nonatomic, strong) UIMenuItem *copyMenuItem;
@property (nonatomic, strong) UIMenuItem *recallMenuItem;
@property (nonatomic, strong) UIMenuItem *transpondMenuItem;

//消息格式化
@property (nonatomic) NSTimeInterval msgTimelTag;

//@
@property (nonatomic) BOOL isWillInputAt;

//Typing
@property (nonatomic) BOOL isTyping;
@property (nonatomic) BOOL enableTyping;

@end

@implementation EMChatViewController

- (instancetype)initWithConversationId:(NSString *)aId
                                  type:(EMConversationType)aType
                      createIfNotExist:(BOOL)aIsCreate
{
    self = [super init];
    if (self) {
        EMConversation *conversation = [[EMClient sharedClient].chatManager getConversation:aId type:aType createIfNotExist:aIsCreate];
        _conversationModel = [[EMConversationModel alloc] initWithEMModel:conversation];
    }
    
    return self;
}

- (instancetype)initWithCoversationModel:(EMConversationModel *)aConversationModel
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
    self.msgTimelTag = -1;
    
    [self _setupChatSubviews];
    
    [[EMClient sharedClient] addMultiDevicesDelegate:self delegateQueue:nil];
    [[EMClient sharedClient].chatManager addDelegate:self delegateQueue:nil];
    [[EMClient sharedClient].groupManager addDelegate:self delegateQueue:nil];
    [[EMClient sharedClient].roomManager addDelegate:self delegateQueue:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleWillPushCallController:) name:CALL_PUSH_VIEWCONTROLLER object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCleanMessages:) name:CHAT_CLEANMESSAGES object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleGroupSubjectUpdated:) name:GROUP_SUBJECT_UPDATED object:nil];
    
    self.isTyping = NO;
    self.enableTyping = NO;
    if ([EMDemoOptions sharedOptions].isChatTyping && self.conversationModel.emModel.type == EMConversationTypeChat) {
        self.enableTyping = YES;
    }
    
    if (self.conversationModel.emModel.type == EMConversationTypeChatRoom) {
        [self _joinChatroom];
    } else {
        self.isFirstLoadMsg = YES;
        [self tableViewDidTriggerHeaderRefresh];
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapTableViewAction:)];
    [self.tableView addGestureRecognizer:tap];
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
    
    if (self.enableTyping && self.isTyping) {
        [self _sendEndTyping];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)dealloc
{
    self.isViewDidAppear = NO;
    [[EMClient sharedClient] removeMultiDevicesDelegate:self];
    [[EMClient sharedClient].chatManager removeDelegate:self];
    [[EMClient sharedClient].groupManager removeDelegate:self];
    [[EMClient sharedClient].roomManager removeDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

#pragma mark - Subviews

- (void)_setupChatSubviews
{
    [self addPopBackLeftItemWithTarget:self action:@selector(backAction)];
    [self _setupNavigationBarTitle];
    [self _setupNavigationBarRightItem];
    self.view.backgroundColor = [UIColor whiteColor];
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
        UIImage *image = [[UIImage imageNamed:@"chat_clear"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(deleteAllMessageAction)];
    } else {
        if (self.conversationModel.emModel.type == EMConversationTypeGroupChat && (NSClassFromString(@"EMGroupInfoViewController")) == nil) {
            return;
        }
        if (self.conversationModel.emModel.type == EMConversationTypeChatRoom && (NSClassFromString(@"EMChatroomInfoViewController")) == nil) {
            return;
        }
        
        UIImage *image = [[UIImage imageNamed:@"chat_info"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(groupOrChatroomInfoAction)];
    }
}

- (void)_setupChatBarMoreViews
{
    NSString *path = [self _getAudioOrVideoPath];
    EMChatBarRecordAudioView *recordView = [[EMChatBarRecordAudioView alloc] initWithRecordPath:path];
    recordView.delegate = self;
    self.chatBar.recordAudioView = recordView;
    
    EMChatBarEmoticonView *moreEmoticonView = [[EMChatBarEmoticonView alloc] init];
    moreEmoticonView.delegate = self;
    self.chatBar.moreEmoticonView = moreEmoticonView;
}

- (NSString *)_getAudioOrVideoPath
{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    path = [path stringByAppendingPathComponent:@"EMDemoRecord"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return path;
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
    id obj = [self.dataArray objectAtIndex:indexPath.row];
    NSLog(@"section:  %ld   row:  %ld",(long)indexPath.section,(long)indexPath.row);
    NSString *cellString = nil;
    if ([obj isKindOfClass:[NSString class]]) {
        cellString = (NSString *)obj;
    } else if ([obj isKindOfClass:[EMMessageModel class]]) {
        EMMessageModel *model = (EMMessageModel *)obj;
        if (model.type == EMMessageTypeExtRecall) {
            cellString = @"您撤回一条消息";
        }
    }
    
    if ([cellString length] > 0) {
        EMMessageTimeCell *cell = (EMMessageTimeCell *)[tableView dequeueReusableCellWithIdentifier:@"EMMessageTimeCell"];
        // Configure the cell...
        if (cell == nil) {
            cell = [[EMMessageTimeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"EMMessageTimeCell"];
        }
        
        cell.timeLabel.text = cellString;
        
        return cell;
    } else {
        EMMessageModel *model = (EMMessageModel *)obj;
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

#pragma mark - EMChatBarDelegate

- (void)_willInputAt:(EMTextView *)aInputView
{
    do {
        if (self.conversationModel.emModel.type != EMConversationTypeGroupChat) {
            break;
        }
        
        NSString *text = aInputView.text;
//        if (![text hasSuffix:@"@"]) {
//            break;
//        }
        
        EMGroup *group = [EMGroup groupWithId:self.conversationModel.emModel.conversationId];
        if (!group) {
            break;
        }
        
        [self.view endEditing:YES];
        EMAtGroupMembersViewController *controller = [[EMAtGroupMembersViewController alloc] initWithGroup:group];
        [self.navigationController pushViewController:controller animated:YES];
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
        [self _sendTextAction:aInputView.text ext:nil];
        return NO;
    } else if ([text isEqualToString:@"@"]) {
        self.isWillInputAt = YES;
    } else if ([text length] == 0) {
        
    }
    
    return YES;
}

- (void)inputViewDidChange:(EMTextView *)aInputView
{
    if (self.isWillInputAt && self.conversationModel.emModel.type == EMConversationTypeGroupChat) {
        NSString *text = aInputView.text;
        if ([text hasSuffix:@"@"]) {
            self.isWillInputAt = NO;
            [self _willInputAt:aInputView];
        }
    }
    
    if (self.enableTyping) {
        if (!self.isTyping) {
            self.isTyping = YES;
            [self _sendBeginTyping];
        }
    }
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
    
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            switch (status) {
                case PHAuthorizationStatusAuthorized: //已获取权限
                {
                    self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                    self.imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
                    [self presentViewController:self.imagePicker animated:YES completion:nil];
                }
                    break;
                case PHAuthorizationStatusDenied: //用户已经明确否认了这一照片数据的应用程序访问
                    [EMAlertController showErrorAlert:@"不允许访问相册"];
                    break;
                case PHAuthorizationStatusRestricted://此应用程序没有被授权访问的照片数据。可能是家长控制权限
                    [EMAlertController showErrorAlert:@"没有授权访问相册"];
                    break;
                    
                default:
                    [EMAlertController showErrorAlert:@"访问相册失败"];
                    break;
            }
        });
    }];
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

- (void)chatBarDidCallAction
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"实时通话类型" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    __weak typeof(self) weakself = self;
    if (self.conversationModel.emModel.type == EMConversationTypeChat) {
        [alertController addAction:[UIAlertAction actionWithTitle:@"语音通话" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakself.chatBar clearMoreViewAndSelectedButton];
            [[NSNotificationCenter defaultCenter] postNotificationName:CALL_MAKE1V1 object:@{CALL_CHATTER:weakself.conversationModel.emModel.conversationId, CALL_TYPE:@(EMCallTypeVoice)}];
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"视频通话" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakself.chatBar clearMoreViewAndSelectedButton];
            [[NSNotificationCenter defaultCenter] postNotificationName:CALL_MAKE1V1 object:@{CALL_CHATTER:weakself.conversationModel.emModel.conversationId, CALL_TYPE:@(EMCallTypeVideo)}];
        }]];
    } else {
        [alertController addAction:[UIAlertAction actionWithTitle:@"会议模式" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakself.chatBar clearMoreViewAndSelectedButton];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:CALL_MAKECONFERENCE object:@{CALL_TYPE:@(EMConferenceTypeLargeCommunication), CALL_MODEL:weakself.conversationModel, NOTIF_NAVICONTROLLER:self.navigationController}];
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"互动模式" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakself.chatBar clearMoreViewAndSelectedButton];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:CALL_MAKECONFERENCE object:@{CALL_TYPE:@(EMConferenceTypeLive), CALL_MODEL:weakself.conversationModel, NOTIF_NAVICONTROLLER:self.navigationController}];
        }]];
    }
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)chatBarDidShowMoreViewAction
{
    [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.chatBar.mas_top);
    }];
    
    [self performSelector:@selector(_scrollToBottomRow) withObject:nil afterDelay:0.1];
}

#pragma mark - EMChatBarRecordAudioViewDelegate

- (void)chatBarRecordAudioViewStartRecord
{
    
}

- (void)chatBarRecordAudioViewStopRecord:(NSString *)aPath
                              timeLength:(NSInteger)aTimeLength
{
    EMVoiceMessageBody *body = [[EMVoiceMessageBody alloc] initWithLocalPath:aPath displayName:@"audio"];
    body.duration = (int)aTimeLength;
    if(body.duration < 1){
        [self showHint:@"按键时间太短."];
        return;
    }
    [self _sendMessageWithBody:body ext:nil isUpload:YES];
}

- (void)chatBarRecordAudioViewCancelRecord
{
    
}

#pragma mark - EMChatBarEmoticonViewDelegate

- (void)didSelectedEmoticonModel:(EMEmoticonModel *)aModel
{
    if (aModel.type == EMEmotionTypeEmoji) {
        [self.chatBar inputViewAppendText:aModel.name];
    } if (aModel.type == EMEmotionTypeGif) {
        NSDictionary *ext = @{MSG_EXT_GIF:@(YES), MSG_EXT_GIF_ID:aModel.eId};
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
    if (aCell.model.type == EMMessageTypeImage) {
        [self _imageMessageCellDidSelected:aCell];
    } else if (aCell.model.type == EMMessageTypeLocation) {
        [self _locationMessageCellDidSelected:aCell];
    } else if (aCell.model.type == EMMessageTypeVoice) {
        [self _audioMessageCellDidSelected:aCell];
    } else if (aCell.model.type == EMMessageTypeVideo) {
        [self _videoMessageCellDidSelected:aCell];
    } else if (aCell.model.type == EMMessageTypeFile) {
        [self _fileMessageCellDidSelected:aCell];
    } else if (aCell.model.type == EMMessageTypeExtCall) {
        [self _callMessageCellDidSelected:aCell];
    }
}

- (void)_imageMessageCellDidSelected:(EMMessageCell *)aCell
{
    __weak typeof(self) weakself = self;
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
    
    [self showHudInView:self.view hint:@"下载语音..."];
    [[EMClient sharedClient].chatManager downloadMessageAttachment:aCell.model.emModel progress:nil completion:^(EMMessage *message, EMError *error) {
        [weakself hideHud];
        if (error) {
            [EMAlertController showErrorAlert:@"下载语音失败"];
        } else {
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
    
    __weak typeof(self) weakself = self;
    void (^playBlock)(NSString *aPath) = ^(NSString *aPathe) {
        NSURL *videoURL = [NSURL fileURLWithPath:aPathe];
        AVPlayerViewController *playerViewController = [[AVPlayerViewController alloc] init];
        playerViewController.player = [AVPlayer playerWithURL:videoURL];
        playerViewController.videoGravity = AVLayerVideoGravityResizeAspect;
        playerViewController.showsPlaybackControls = YES;
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
    } else {
        [self showHudInView:self.view hint:@"下载视频..."];
        __weak typeof(self) weakself = self;
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
}

- (void)_fileMessageCellDidSelected:(EMMessageCell *)aCell
{
    
}

- (void)_callMessageCellDidSelected:(EMMessageCell *)aCell
{
    [[NSNotificationCenter defaultCenter] postNotificationName:CALL_SELECTCONFERENCECELL object:aCell.model.emModel];
}

- (void)messageCellDidLongPress:(EMMessageCell *)aCell
{
    self.menuIndexPath = [self.tableView indexPathForCell:aCell];
    [self _showMenuViewController:aCell model:aCell.model];
}

- (void)messageCellDidResend:(EMMessageModel *)aModel
{
    if (aModel.emModel.status != EMMessageStatusFailed && aModel.emModel.status != EMMessageStatusPending) {
        return;
    }
    
    __weak typeof(self) weakself = self;
    [[[EMClient sharedClient] chatManager] resendMessage:aModel.emModel progress:nil completion:^(EMMessage *message, EMError *error) {
        [weakself.tableView reloadData];
    }];
    
    [self.tableView reloadData];
}

#pragma mark - EMMultiDevicesDelegate

- (void)multiDevicesGroupEventDidReceive:(EMMultiDevicesEvent)aEvent
                                 groupId:(NSString *)aGroupId
                                     ext:(id)aExt
{
    if (aEvent == EMMultiDevicesEventGroupDestroy || aEvent == EMMultiDevicesEventGroupLeave) {
        if ([self.conversationModel.emModel.conversationId isEqualToString:aGroupId]) {
            [self.navigationController popToViewController:self animated:YES];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

#pragma mark - EMChatManagerDelegate

- (BOOL)_isNeedSendReadAckForMessage:(EMMessage *)aMessage
                          isMarkRead:(BOOL)aIsMarkRead
{
    if (!self.isViewDidAppear || aMessage.direction == EMMessageDirectionSend || aMessage.isReadAcked || aMessage.chatType != EMChatTypeChat) {
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
        NSMutableArray *msgArray = [[NSMutableArray alloc] init];
        for (int i = 0; i < [aMessages count]; i++) {
            EMMessage *msg = aMessages[i];
            if (![msg.conversationId isEqualToString:conId]) {
                continue;
            }
            
            if ([weakself _isNeedSendReadAckForMessage:msg isMarkRead:NO]) {
                [[EMClient sharedClient].chatManager sendMessageReadAck:msg.messageId toUser:msg.conversationId completion:nil];
            }
            [weakself.conversationModel.emModel markMessageAsReadWithId:msg.messageId error:nil];
            [msgArray addObject:msg];
        }
        
        NSArray *formated = [weakself _formatMessages:msgArray];
        [weakself.dataArray addObjectsFromArray:formated];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself.tableView reloadData];
            [weakself _scrollToBottomRow];
        });
    });
}

- (void)messagesDidRecall:(NSArray *)aMessages {
    __block NSMutableArray *sameObject = [NSMutableArray array];
    [aMessages enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        EMMessage *msg = (EMMessage *)obj;
        [self.dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[EMMessageModel class]]) {
                EMMessageModel *model = (EMMessageModel *)obj;
                if ([model.emModel.messageId isEqualToString:msg.messageId]) {
                    // 如果上一行是时间，且下一行也是时间
                    if (idx - 1 >= 0) {
                        id nextMessage = nil;
                        id prevMessage = [self.dataArray objectAtIndex:(idx - 1)];
                        if (idx + 1 < [self.dataArray count]) {
                            nextMessage = [self.dataArray objectAtIndex:(idx + 1)];
                        }
                        if ((!nextMessage
                             || [nextMessage isKindOfClass:[NSString class]])
                            && [prevMessage isKindOfClass:[NSString class]]) {
                            [sameObject addObject:prevMessage];
                        }
                    }
                    
                    [sameObject addObject:model];
                    *stop = YES;
                }
            }
        }];
    }];
    
    if (sameObject.count > 0) {
        for (id obj in sameObject) {
            [self.dataArray removeObject:obj];
        }
        
        [self.tableView reloadData];
    }
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
            
            [weakself.dataArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if ([obj isKindOfClass:[EMMessageModel class]]) {
                    EMMessageModel *model = (EMMessageModel *)obj;
                    if ([model.emModel.messageId isEqualToString:message.messageId]) {
                        model.emModel.isReadAcked = YES;
                        isReladView = YES;
                        *stop = YES;
                    }
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
        [self.dataArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isKindOfClass:[EMMessageModel class]]) {
                EMMessageModel *model = (EMMessageModel *)obj;
                if ([model.emModel.messageId isEqualToString:aMessage.messageId]) {
                    reloadModel = model;
                    index = idx;
                    *stop = YES;
                }
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

- (void)cmdMessagesDidReceive:(NSArray *)aCmdMessages
{
    __weak typeof(self) weakself = self;
    dispatch_async(self.msgQueue, ^{
        NSString *conId = weakself.conversationModel.emModel.conversationId;
        for (EMMessage *message in aCmdMessages) {
            
            if (![conId isEqualToString:message.conversationId]) {
                continue;
            }
            
            EMCmdMessageBody *body = (EMCmdMessageBody *)message.body;
            NSString *str = @"";
            if ([body.action isEqualToString:MSG_TYPING_BEGIN]) {
                str = @"正在输入...";
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                self.titleDetailLabel.text = str;
            });
        }
    });
}

#pragma mark - EMGroupManagerDelegate

- (void)didLeaveGroup:(EMGroup *)aGroup
               reason:(EMGroupLeaveReason)aReason
{
    EMConversation *conversation = self.conversationModel.emModel;
    if (conversation.type == EMChatTypeGroupChat && [aGroup.groupId isEqualToString:conversation.conversationId]) {
        [self.navigationController popToViewController:self animated:YES];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - EMChatroomManagerDelegate

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
    
    if (self.enableTyping) {
        [self _sendEndTyping];
    }
}

#pragma mark - NSNotification

- (void)handleWillPushCallController:(NSNotification *)aNotif
{
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
    [[EMImageBrowser sharedBrowser] dismissViewController];
    [[EMAudioPlayerHelper sharedHelper] stopPlayer];
}

- (void)handleCleanMessages:(NSNotification *)aNotif
{
    NSString *chatId = aNotif.object;
    if (chatId && [chatId isEqualToString:self.conversationModel.emModel.conversationId]) {
        [self.conversationModel.emModel deleteAllMessages:nil];
        
        [self.dataArray removeAllObjects];
        [self.tableView reloadData];
    }
}

- (void)handleGroupSubjectUpdated:(NSNotification *)aNotif
{
    EMGroup *group = aNotif.object;
    if (!group) {
        return;
    }
    
    NSString *groupId = group.groupId;
    if ([groupId isEqualToString:self.conversationModel.emModel.conversationId]) {
        self.conversationModel.name = group.groupName;
        self.titleLabel.text = group.groupName;
    }
}

#pragma mark - Gesture Recognizer

- (void)handleTapTableViewAction:(UITapGestureRecognizer *)aTap
{
    if (aTap.state == UIGestureRecognizerStateEnded) {
        [self.view endEditing:YES];
        [self.chatBar clearMoreViewAndSelectedButton];
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
            weakself.isFirstLoadMsg = YES;
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
        NSString *mp4Path = [NSString stringWithFormat:@"%@/%d%d.mp4", [self _getAudioOrVideoPath], (int)[[NSDate date] timeIntervalSince1970], arc4random() % 100000];
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

#pragma mark - Menu Controller

- (UIMenuController *)menuController
{
    if (_menuController == nil) {
        _menuController = [UIMenuController sharedMenuController];
    }
    
    return _menuController;
}

- (UIMenuItem *)deleteMenuItem
{
    if (_deleteMenuItem == nil) {
        _deleteMenuItem = [[UIMenuItem alloc] initWithTitle:@"删除" action:@selector(deleteMenuItemAction:)];
    }
    
    return _deleteMenuItem;
}

- (UIMenuItem *)copyMenuItem
{
    if (_copyMenuItem == nil) {
        _copyMenuItem = [[UIMenuItem alloc] initWithTitle:@"复制" action:@selector(copyMenuItemAction:)];
    }
    
    return _copyMenuItem;
}

- (UIMenuItem *)transpondMenuItem
{
    if (_transpondMenuItem == nil) {
        _transpondMenuItem = [[UIMenuItem alloc] initWithTitle:@"转发" action:@selector(transpondMenuItemAction:)];
    }
    
    return _transpondMenuItem;
}

- (UIMenuItem *)recallMenuItem
{
    if (_recallMenuItem == nil) {
        _recallMenuItem = [[UIMenuItem alloc] initWithTitle:@"撤回" action:@selector(recallMenuItemAction:)];
    }
    
    return _recallMenuItem;
}

- (void)deleteMenuItemAction:(UIMenuItem *)aItem
{
    if (self.menuIndexPath == nil) {
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
    if (self.menuIndexPath == nil) {
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
    if (self.menuIndexPath == nil) {
        return;
    }
    
    EMMessageModel *model = [self.dataArray objectAtIndex:self.menuIndexPath.row];
    EMMsgTranspondViewController *controller = [[EMMsgTranspondViewController alloc] initWithModel:model];
    [self.navigationController pushViewController:controller animated:YES];
    
    __weak typeof(self) weakself = self;
    [controller setDoneCompletion:^(EMMessageModel * _Nonnull aModel, NSString * _Nonnull aUsername) {
        [weakself _transpondMsg:aModel toUser:aUsername];
    }];
    
    self.menuIndexPath = nil;
}

- (void)recallMenuItemAction:(UIMenuItem *)aItem
{
    if (self.menuIndexPath == nil) {
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

- (void)_showMenuViewController:(EMMessageCell *)aCell
                          model:(EMMessageModel *)aModel
{
    [self becomeFirstResponder];
    
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
    
    [self.menuController setMenuItems:items];
    [self.menuController setTargetRect:aCell.bubbleView.frame inView:aCell];
    [self.menuController setMenuVisible:YES animated:NO];
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
        }
    }];
}

- (void)_forwardImageMsg:(EMMessage *)aMsg
                  toUser:(NSString *)aUsername
{
    NSString *thumbnailLocalPath = [(EMImageMessageBody *)aMsg.body thumbnailLocalPath];
    
    __weak typeof(self) weakself = self;
    void (^block)(EMMessage *aMessage) = ^(EMMessage *aMessage) {
        EMImageMessageBody *oldBody = (EMImageMessageBody *)aMessage.body;
        EMImageMessageBody *newBody = [[EMImageMessageBody alloc] initWithData:nil thumbnailData:[NSData dataWithContentsOfFile:oldBody.thumbnailLocalPath]];
        newBody.thumbnailRemotePath = oldBody.thumbnailRemotePath;
        newBody.remotePath = oldBody.remotePath;
        
        [weakself _forwardMsgWithBody:newBody to:aUsername ext:aMsg.ext completion:^(EMMessage *message) {
            [(EMImageMessageBody *)message.body setLocalPath:oldBody.localPath];
            [[EMClient sharedClient].chatManager updateMessage:message completion:nil];
        }];
    };
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:thumbnailLocalPath]) {
        [[EMClient sharedClient].chatManager downloadMessageThumbnail:aMsg progress:nil completion:^(EMMessage *message, EMError *error) {
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
    if (type == EMMessageBodyTypeText || type == EMMessageBodyTypeLocation) {
        [self _forwardMsgWithBody:aModel.emModel.body to:aUsername ext:aModel.emModel.ext completion:nil];
    } else if (type == EMMessageBodyTypeImage) {
        [self _forwardImageMsg:aModel.emModel toUser:aUsername];
    } else if (type == EMMessageBodyTypeVideo) {
        [self _forwardVideoMsg:aModel.emModel toUser:aUsername];
    }
}

#pragma mark - Send Message

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
    
    if (self.enableTyping) {
        [self _sendEndTyping];
    }
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

- (void)_sendBeginTyping
{
    NSString *from = [[EMClient sharedClient] currentUsername];
    NSString *to = self.conversationModel.emModel.conversationId;
    EMCmdMessageBody *body = [[EMCmdMessageBody alloc] initWithAction:MSG_TYPING_BEGIN];
    body.isDeliverOnlineOnly = YES;
    EMMessage *message = [[EMMessage alloc] initWithConversationID:to from:from to:to body:body ext:nil];
    message.chatType = (EMChatType)self.conversationModel.emModel.type;
    [[EMClient sharedClient].chatManager sendMessage:message progress:nil completion:nil];
}

- (void)_sendEndTyping
{
    self.isTyping = NO;
    
    NSString *from = [[EMClient sharedClient] currentUsername];
    NSString *to = self.conversationModel.emModel.conversationId;
    EMCmdMessageBody *body = [[EMCmdMessageBody alloc] initWithAction:MSG_TYPING_END];
    body.isDeliverOnlineOnly = YES;
    EMMessage *message = [[EMMessage alloc] initWithConversationID:to from:from to:to body:body ext:nil];
    message.chatType = (EMChatType)self.conversationModel.emModel.type;
    [[EMClient sharedClient].chatManager sendMessage:message progress:nil completion:nil];
}

#pragma mark - Data

- (NSArray *)_formatMessages:(NSArray<EMMessage *> *)aMessages
{
    NSMutableArray *formated = [[NSMutableArray alloc] init];
    for (int i = 0; i < [aMessages count]; i++) {
        EMMessage *msg = aMessages[i];
        if (msg.chatType == EMChatTypeChat && !msg.isReadAcked && (msg.body.type == EMMessageBodyTypeText || msg.body.type == EMMessageBodyTypeLocation)) {
            [[EMClient sharedClient].chatManager sendMessageReadAck:msg.messageId toUser:msg.conversationId completion:nil];
        } else if (msg.chatType == EMChatTypeGroupChat && !msg.isReadAcked && (msg.body.type == EMMessageBodyTypeText || msg.body.type == EMMessageBodyTypeLocation)) {
        }
        
        CGFloat interval = (self.msgTimelTag - msg.timestamp) / 1000;
        if (self.msgTimelTag < 0 || interval > 60 || interval < -60) {
            NSString *timeStr = [EMDateHelper formattedTimeFromTimeInterval:msg.timestamp];
            [formated addObject:timeStr];
            self.msgTimelTag = msg.timestamp;
        }
        
        EMMessageModel *model = [[EMMessageModel alloc] initWithEMMessage:msg];
        [formated addObject:model];
    }
    
    return formated;
}

- (void)tableViewDidTriggerHeaderRefresh
{
    __weak typeof(self) weakself = self;
    void (^block)(NSArray *aMessages, EMError *aError) = ^(NSArray *aMessages, EMError *aError) {
        if (!aError && [aMessages count]) {
            EMMessage *msg = aMessages[0];
            weakself.moreMsgId = msg.messageId;
            
            dispatch_async(self.msgQueue, ^{
                NSArray *formated = [weakself _formatMessages:aMessages];
                [weakself.dataArray insertObjects:formated atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [formated count])]];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakself.tableView reloadData];
                    
                    if (weakself.isFirstLoadMsg) {
                        weakself.isFirstLoadMsg = NO;
                        [weakself _scrollToBottomRow];
                    }
                });
            });
        }
        
        [weakself tableViewDidFinishTriggerHeader:YES reload:NO];
    };
    
    if ([EMDemoOptions sharedOptions].isPriorityGetMsgFromServer) {
        EMConversation *conversation = self.conversationModel.emModel;
        [EMClient.sharedClient.chatManager asyncFetchHistoryMessagesFromServer:conversation.conversationId conversationType:conversation.type startMessageId:self.moreMsgId pageSize:50 completion:^(EMCursorResult *aResult, EMError *aError) {
            block(aResult.list, aError);
         }];
    } else {
        [self.conversationModel.emModel loadMessagesStartFromId:self.moreMsgId count:50 searchDirection:EMMessageSearchDirectionUp completion:block];
    }
}

#pragma mark - Action

- (void)backAction
{
    [[EMAudioPlayerHelper sharedHelper] stopPlayer];
    [EMConversationHelper resortConversationsLatestMessage];
    
    EMConversation *conversation = self.conversationModel.emModel;
    if (conversation.type == EMChatTypeChatRoom) {
        [[EMClient sharedClient].roomManager leaveChatroom:conversation.conversationId completion:nil];
    }
    
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
        [[NSNotificationCenter defaultCenter] postNotificationName:GROUP_INFO_PUSHVIEWCONTROLLER object:@{NOTIF_ID:self.conversationModel.emModel.conversationId, NOTIF_NAVICONTROLLER:self.navigationController}];
    } else if (self.conversationModel.emModel.type == EMConversationTypeChatRoom) {
        [[NSNotificationCenter defaultCenter] postNotificationName:CHATROOM_INFO_PUSHVIEWCONTROLLER object:@{NOTIF_ID:self.conversationModel.emModel.conversationId, NOTIF_NAVICONTROLLER:self.navigationController}];
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
    
    dispatch_async(self.msgQueue, ^{
        NSArray *formated = [weakself _formatMessages:@[message]];
        [weakself.dataArray addObjectsFromArray:formated];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself.tableView reloadData];
            [weakself _scrollToBottomRow];
        });
    });
}

@end
