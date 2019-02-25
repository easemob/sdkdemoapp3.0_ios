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

@interface EMGroupSharedFilesViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, EMGroupManagerDelegate>

@property (nonatomic, strong) EMGroup *group;

@property (nonatomic, strong) UIImagePickerController *imagePicker;

@end

@implementation EMGroupSharedFilesViewController

- (instancetype)initWithGroup:(EMGroup *)aGroup
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
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
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"上传" style:UIBarButtonItemStylePlain target:self action:@selector(uploadFileAction)];
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
    cell.avatarView.image = [UIImage imageNamed:@"file"];
    if (file.fileName.length > 0) {
        cell.nameLabel.text = file.fileName;
    } else {
        cell.nameLabel.text = file.fileId;
    }
    cell.detailLabel.text = [NSString stringWithFormat:@"%.2lf MB",(float)file.fileSize / (1024 * 1024)];
    
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
    NSURL *url = info[UIImagePickerControllerReferenceURL];
    if (url == nil) {
        UIImage *orgImage = info[UIImagePickerControllerOriginalImage];
        NSData *data = UIImageJPEGRepresentation(orgImage, 1.0f);
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

- (void)uploadFileAction
{
    if (_imagePicker == nil) {
        _imagePicker = [[UIImagePickerController alloc] init];
        _imagePicker.modalPresentationStyle = UIModalPresentationOverFullScreen;
        _imagePicker.delegate = self;
    }
    
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    self.imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
    [self presentViewController:self.imagePicker animated:YES completion:NULL];
}

@end
