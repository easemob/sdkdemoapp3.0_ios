//
//  EMGroupSharedFilesViewController.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/18.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "EMGroupSharedFilesViewController.h"

#import "EMAvatarNameCell.h"
#import "EMDateHelper.h"
#import "PellTableViewSelect.h"

@interface EMGroupSharedFilesViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, EMGroupManagerDelegate, UIDocumentPickerDelegate,UIDocumentInteractionControllerDelegate>

@property (nonatomic, strong) EMGroup *group;

@property (nonatomic, strong) UIImagePickerController *imagePicker;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end

@implementation EMGroupSharedFilesViewController

- (instancetype)initWithGroup:(EMGroup *)aGroup
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"yyyy-MM-dd"];
        self.group = aGroup;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self _setupSubviews];
    
    [[EMClient sharedClient].groupManager addDelegate:self delegateQueue:nil];
    
    self.page = 1;
    [self _fetchFilesWithPage:self.page isHeader:YES isShowHUD:YES];
}

- (void)dealloc
{
    [[EMClient sharedClient].groupManager removeDelegate:self];
}

#pragma mark - Subviews

- (void)_setupSubviews
{
    [self addPopBackLeftItem];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"上传" style:UIBarButtonItemStylePlain target:self action:@selector(moreAction)];
    self.title = @"共享文件";
    self.showRefreshHeader = YES;
    
    self.tableView.rowHeight = 75;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EMAvatarNameCell *cell = (EMAvatarNameCell *)[tableView dequeueReusableCellWithIdentifier:@"EMAvatarNameCell"];
    if (cell == nil) {
        cell = [[EMAvatarNameCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"EMAvatarNameCell"];
        
        cell.avatarView.contentMode = UIViewContentModeScaleAspectFit;
        [cell.avatarView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(cell.contentView).offset(5);
            make.left.equalTo(cell.contentView).offset(15);
            make.bottom.equalTo(cell.contentView).offset(-5);
            make.width.equalTo(cell.avatarView.mas_height).multipliedBy(0.6);
        }];
    }
    
    EMGroupSharedFile *file = [self.dataArray objectAtIndex:indexPath.row];
    cell.avatarView.image = [UIImage imageNamed:@"groupSharedFile"];
    if (file.fileName.length > 0) {
        cell.nameLabel.text = file.fileName;
    } else {
        cell.nameLabel.text = file.fileId;
    }
    
    NSString *fileCreateTime = [_dateFormatter stringFromDate:[EMDateHelper dateWithTimeIntervalInMilliSecondSince1970:file.createTime]];
    NSString *fileOwner = [file.fileOwner length] <= 10 ? file.fileOwner : [NSString stringWithFormat:@"%@...",[file.fileOwner substringWithRange:NSMakeRange(0, 10)]];
    cell.detailLabel.text = [NSString stringWithFormat:@"%@ 来自 %@ %.2lf MB",fileCreateTime,fileOwner,(float)file.fileSize / (1024 * 1024)];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //在iOS8.0上，必须加上这个方法才能出发左划操作
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self _deleteFileCellAction:indexPath];
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *filePath = NSHomeDirectory();
    filePath = [NSString stringWithFormat:@"%@/Library/appdata/download", filePath];
    NSFileManager *fm = [NSFileManager defaultManager];
    if(![fm fileExistsAtPath:filePath]) {
        [fm createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    EMGroupSharedFile *file = [self.dataArray objectAtIndex:indexPath.row];
    NSString *fileName = file.fileName.length > 0 ? file.fileName : file.fileId;
    filePath = [NSString stringWithFormat:@"%@/%@", filePath, fileName];
    
    if ([fm fileExistsAtPath:filePath]) {
        [self _openFileWithPath:filePath];
    } else {
        __weak typeof(self) weakself = self;
        [self showHudInView:self.view hint:@"下载共享文件..."];
        [[EMClient sharedClient].groupManager downloadGroupSharedFileWithId:self.group.groupId filePath:filePath sharedFileId:file.fileId progress:^(int progress) {
            // NSLog(@"%d",progress);
        } completion:^(EMGroup *aGroup, EMError *aError) {
            [weakself hideHud];
            if (aError) {
                [EMAlertController showErrorAlert:@"下载共享文件失败"];
            } else {
                [weakself _openFileWithPath:filePath];
            }
        }];
    }
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
        [self uploadAction:[mp4 path]];
    } else {
        NSURL *url = info[UIImagePickerControllerReferenceURL];
        if (url == nil) {
            UIImage *orgImage = info[UIImagePickerControllerOriginalImage];
            NSData *data = UIImageJPEGRepresentation(orgImage, 1);
            [self _uploadFileData:data fileName:nil];
        } else {
            if ([[UIDevice currentDevice].systemVersion doubleValue] >= 9.0f) {
                PHFetchResult *result = [PHAsset fetchAssetsWithALAssetURLs:@[url] options:nil];
                [result enumerateObjectsUsingBlock:^(PHAsset *asset , NSUInteger idx, BOOL *stop) {
                    if (asset) {
                        [[PHImageManager defaultManager] requestImageDataForAsset:asset options:nil resultHandler:^(NSData *data, NSString *uti, UIImageOrientation orientation, NSDictionary *dic){
                            if (data != nil) {
                                NSURL *path = [dic objectForKey:@"PHImageFileURLKey"];
                                NSString *fileName = nil;
                                if (path) {
                                    fileName = [[path absoluteString] lastPathComponent];
                                }
                                [self _uploadFileData:data fileName:fileName];
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
                        NSData* data = [NSData dataWithBytesNoCopy:buffer length:bufferSize freeWhenDone:YES];
                        [self _uploadFileData:data fileName:nil];
                    }
                } failureBlock:nil];
            }
        }
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - EMGroupManagerDelegate

- (void)groupFileListDidUpdate:(EMGroup *)aGroup
               addedSharedFile:(EMGroupSharedFile *)aSharedFile
{
    if ([aGroup.groupId isEqualToString:self.group.groupId]) {
        [self _reloadDataArrayAndView];
    }
}

- (void)groupFileListDidUpdate:(EMGroup *)aGroup
             removedSharedFile:(NSString *)aFileId
{
    if ([aGroup.groupId isEqualToString:self.group.groupId]) {
        [self _reloadDataArrayAndView];
    }
}

#pragma mark - Private

- (void)_uploadFileData:(NSData *)aData
               fileName:(NSString *)aFileName
{
    NSString *filePath = NSHomeDirectory();
    filePath = [NSString stringWithFormat:@"%@/Library/appdata/files", filePath];
    NSFileManager *fm = [NSFileManager defaultManager];
    if(![fm fileExistsAtPath:filePath]) {
        [fm createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    if ([aFileName length] > 0) {
        filePath = [NSString stringWithFormat:@"%@/%d%@", filePath, (int)[[NSDate date] timeIntervalSince1970], aFileName];
    } else {
        filePath = [NSString stringWithFormat:@"%@/%d%d.jpg", filePath, (int)[[NSDate date] timeIntervalSince1970], arc4random() % 100000];
    }
    
    [aData writeToFile:filePath atomically:YES];
    
    [self uploadAction:filePath];
}

//开始上传
- (void)uploadAction:(NSString *)filePath
{
    __weak typeof(self) weakself = self;
    [self showHudInView:self.view hint:@"上传共享文件..."];
    [[EMClient sharedClient].groupManager uploadGroupSharedFileWithId:self.group.groupId filePath:filePath progress:^(int progress){
        //code
    } completion:^(EMGroupSharedFile *aSharedFile, EMError *aError) {
        [weakself hideHud];
        if (!aError) {
            [weakself.dataArray insertObject:aSharedFile atIndex:0];
            [weakself.tableView reloadData];
        } else {
            [EMAlertController showErrorAlert:@"上传共享文件失败"];
        }
    }];
}

- (void)_deleteFileCellAction:(NSIndexPath *)aIndexPath
{
    EMGroupSharedFile *file = [self.dataArray objectAtIndex:aIndexPath.row];
    
    __weak typeof(self) weakself = self;
    [self showHudInView:self.view hint:@"删除共享文件..."];
    [[EMClient sharedClient].groupManager removeGroupSharedFileWithId:self.group.groupId sharedFileId:file.fileId completion:^(EMGroup *aGroup, EMError *aError) {
        [weakself hideHud];
        if (!aError) {
            [weakself.dataArray removeObject:file];
            [weakself.tableView reloadData];
        } else {
            [EMAlertController showErrorAlert:@"删除共享文件失败"];
        }
    }];
}

- (void)_openFileWithPath:(NSString *)aPath
{
    NSURL *url = [NSURL fileURLWithPath:aPath];
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:@[url] applicationActivities:nil];
    controller.excludedActivityTypes = @[UIActivityTypeMessage, UIActivityTypeMail, UIActivityTypeSaveToCameraRoll, UIActivityTypeAirDrop];
    [self presentViewController:controller animated:YES completion:nil];
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

- (NSString *)_getAudioOrVideoPath
{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    path = [path stringByAppendingPathComponent:@"groupShareRecord"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return path;
}

#pragma mark - Data

- (void)_reloadDataArrayAndView
{
    [self.dataArray removeAllObjects];
    [self.dataArray addObjectsFromArray:self.group.sharedFileList];
    [self.tableView reloadData];
}

- (void)_fetchFilesWithPage:(NSInteger)aPage
                   isHeader:(BOOL)aIsHeader
                  isShowHUD:(BOOL)aIsShowHUD
{
    NSInteger pageSize = 50;
    if (aIsShowHUD) {
        [self showHudInView:self.view hint:@"获取共享文件..."];
    }
    
    __weak typeof(self) weakself = self;
    [[EMClient sharedClient].groupManager getGroupFileListWithId:self.group.groupId pageNumber:self.page pageSize:pageSize completion:^(NSArray *aList, EMError *aError) {
        if (aIsShowHUD) {
            [weakself hideHud];
        }
        
        if (!aError) {
            if (aIsHeader) {
                [weakself.dataArray removeAllObjects];
            }
            [weakself.dataArray addObjectsFromArray:aList];
            [weakself.tableView reloadData];
        } else {
            [EMAlertController showErrorAlert:@"获取共享文件失败"];
        }
        
        if ([aList count] < pageSize) {
            weakself.showRefreshFooter = NO;
        } else {
            weakself.showRefreshFooter = YES;
        }
        [weakself tableViewDidFinishTriggerHeader:aIsHeader reload:NO];
    }];
}

- (void)tableViewDidTriggerHeaderRefresh
{
    self.page = 1;
    [self _fetchFilesWithPage:self.page isHeader:YES isShowHUD:NO];
}

- (void)tableViewDidTriggerFooterRefresh
{
    self.page += 1;
    [self _fetchFilesWithPage:self.page isHeader:YES isShowHUD:NO];
}

#pragma mark - Action

- (void)moreAction
{
    [PellTableViewSelect addPellTableViewSelectWithWindowFrame:CGRectMake(self.view.bounds.size.width-150, 44, 145, 156) selectData:@[@"上传图片",@"上传视频",@"上传文件"] images:@[@"icon-创建群组",@"icon-添加好友",@"icon-添加好友"] locationY:0 action:^(NSInteger index){
        if(index == 0) {
            [self uploadMediaAction:0];
        } else if (index == 1) {
            [self uploadMediaAction:1];
        } else if (index == 2) {
            [self uploadFileAction];
        }
    } animated:YES];
}

//上传图片/视频
- (void)uploadMediaAction:(NSInteger)tag
{
    if (_imagePicker == nil) {
        _imagePicker = [[UIImagePickerController alloc] init];
        _imagePicker.modalPresentationStyle = UIModalPresentationOverFullScreen;
        _imagePicker.delegate = self;
    }
    
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    if (tag == 0) {
        self.imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
    } else {
        self.imagePicker.mediaTypes = @[(NSString *)kUTTypeMovie];
    }
    [self presentViewController:self.imagePicker animated:YES completion:NULL];
}

//上传文件（icloud driver文件）
- (void)uploadFileAction
{
    NSArray *documentTypes = @[@"public.content", @"public.text", @"public.source-code", @"public.image", @"public.jpeg", @"public.png", @"com.adobe.pdf", @"com.apple.keynote.key", @"com.microsoft.word.doc", @"com.microsoft.excel.xls", @"com.microsoft.powerpoint.ppt"];
    UIDocumentPickerViewController *picker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:documentTypes inMode:UIDocumentPickerModeOpen];
    picker.delegate = self;
    picker.modalPresentationStyle = 0;
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - UIDocumentPickerDelegate
- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray <NSURL *>*)urls
{
    BOOL fileAuthorized = [urls.firstObject startAccessingSecurityScopedResource];
    if (fileAuthorized) {
        //[self selectedDocumentAtURLs:urls reName:nil];
        [urls.firstObject stopAccessingSecurityScopedResource];
    } else {
        [self showHint:@"授权失败!"];
    }
}
- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentAtURL:(NSURL *)url
{
    BOOL fileAuthorized = [url startAccessingSecurityScopedResource];
    if (fileAuthorized) {
        [self selectedDocumentAtURLs:url reName:nil];
        [url stopAccessingSecurityScopedResource];
    } else {
        [self showHint:@"授权失败!"];
    }
}

//icloud
- (void)selectedDocumentAtURLs:(NSURL *)url reName:(NSString *)rename
{
    NSFileCoordinator *fileCoordinator = [[NSFileCoordinator alloc]init];
    NSError *error;
    [fileCoordinator coordinateReadingItemAtURL:url options:0 error:&error byAccessor:^(NSURL * _Nonnull newURL) {
        //读取文件
        NSString *fileName = [newURL lastPathComponent];
        NSError *error = nil;
        NSData *fileData = [NSData dataWithContentsOfURL:newURL options:NSDataReadingMappedIfSafe error:&error];
        if (error) {
            [self showHint:@"文件读取失败!"];;
        }else {
            NSLog(@"fileName: %@\nfileUrl: %@", fileName, newURL);
            [self _uploadFileData:fileData fileName:fileName];
        };
    }];
}

@end
