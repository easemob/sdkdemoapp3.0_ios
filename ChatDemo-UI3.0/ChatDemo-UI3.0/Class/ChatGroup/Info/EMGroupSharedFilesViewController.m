//
//  EMGroupSharedFilesViewController.m
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 2017/4/26.
//  Copyright © 2017年 EaseMob. All rights reserved.
//

#import "EMGroupSharedFilesViewController.h"

#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import "EMMemberCell.h"

@interface EMGroupSharedFilesViewController () <UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property (nonatomic, strong) EMGroup *group;

@property (nonatomic, strong) UIImagePickerController *imagePicker;

@end

@implementation EMGroupSharedFilesViewController

- (instancetype)initWithGroup:(EMGroup *)aGroup
{
    self = [super init];
    if (self) {
        self.group = aGroup;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"group.sharedfiles", @"Share File");
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUI:) name:@"UpdateGroupSharedFile" object:nil];
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    backButton.accessibilityIdentifier = @"back";
    [backButton setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [backButton addTarget:self.navigationController action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    [self.navigationItem setLeftBarButtonItem:backItem];
    
    UIButton *uploadButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 64, 44)];
    [uploadButton setTitle:NSLocalizedString(@"group.upload", @"Upload") forState:UIControlStateNormal];
    [uploadButton addTarget:self action:@selector(uploadAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *uploadItem = [[UIBarButtonItem alloc] initWithCustomView:uploadButton];
    [self.navigationItem setRightBarButtonItem:uploadItem];
    
    self.showRefreshHeader = YES;
    [self tableViewDidTriggerHeaderRefresh];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - getter

- (UIImagePickerController *)imagePicker
{
    if (_imagePicker == nil) {
        _imagePicker = [[UIImagePickerController alloc] init];
        _imagePicker.modalPresentationStyle= UIModalPresentationOverFullScreen;
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
    EMMemberCell *cell = (EMMemberCell *)[tableView dequeueReusableCellWithIdentifier:@"EMMemberCell"];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"EMMemberCell" owner:self options:nil] lastObject];
        
        cell.showAccessoryViewInDelete = YES;
    }
    
    EMGroupSharedFile *file = [self.dataArray objectAtIndex:indexPath.row];
    cell.leftLabel.text = file.fileName;
    if (file.fileName.length == 0) {
        cell.leftLabel.text = file.fileId;
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"移除";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        EMGroupSharedFile *file = [self.dataArray objectAtIndex:indexPath.row];
        
        [self showHudInView:self.view hint:NSLocalizedString(@"wait", @"Pleae wait...")];
        
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            EMError *error = nil;
            weakSelf.group = [[EMClient sharedClient].groupManager removeGroupSharedFileWithId:weakSelf.group.groupId sharedFileId:file.fileId error:&error];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf hideHud];
                if (!error) {
                    [weakSelf.dataArray removeObject:file];
                    [weakSelf.tableView reloadData];
                }
                else {
                    [weakSelf showHint:error.errorDescription];
                }
            });
        });
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    EMGroupSharedFile *file = [self.dataArray objectAtIndex:indexPath.row];
    
    NSString *filePath = NSHomeDirectory();
    filePath = [NSString stringWithFormat:@"%@/Library/appdata/download",filePath];
    NSFileManager *fm = [NSFileManager defaultManager];
    if(![fm fileExistsAtPath:filePath]) {
        [fm createDirectoryAtPath:filePath
      withIntermediateDirectories:YES
                       attributes:nil
                            error:nil];
    }
    NSString *fileName = file.fileName.length > 0 ? file.fileName : file.fileId;
    filePath = [NSString stringWithFormat:@"%@/%@", filePath, fileName];
    
    if ([fm fileExistsAtPath:filePath]) {
        NSURL *url = [NSURL fileURLWithPath:filePath];
        UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[url] applicationActivities:nil];
        activityVC.excludedActivityTypes = @[UIActivityTypeMessage, UIActivityTypeMail, UIActivityTypeSaveToCameraRoll, UIActivityTypeAirDrop];
        [self presentViewController:activityVC animated:YES completion:nil];
    } else {
        __weak typeof(self) weakSelf = self;
        [self showHudInView:self.view hint:NSLocalizedString(@"group.download", @"Downloading ...")];
        [[EMClient sharedClient].groupManager downloadGroupSharedFileWithId:_group.groupId filePath:filePath sharedFileId:file.fileId progress:^(int progress) {
            // NSLog(@"%d",progress);
        } completion:^(EMGroup *aGroup, EMError *aError) {
            [weakSelf hideHud];
            if (aError) {
                [weakSelf showHint:[NSString stringWithFormat:@"%@%@",NSLocalizedString(@"group.downloadFail", @"fail to download share file"), aError.errorDescription]];
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
        [self _uploadData:data filename:nil];
    } else {
        if ([[UIDevice currentDevice].systemVersion doubleValue] >= 9.0f) {
            PHFetchResult *result = [PHAsset fetchAssetsWithALAssetURLs:@[url] options:nil];
            [result enumerateObjectsUsingBlock:^(PHAsset *asset , NSUInteger idx, BOOL *stop){
                if (asset) {
                    [[PHImageManager defaultManager] requestImageDataForAsset:asset options:nil resultHandler:^(NSData *data, NSString *uti, UIImageOrientation orientation, NSDictionary *dic){
                        if (data != nil) {
                            NSURL *path = [dic objectForKey:@"PHImageFileURLKey"];
                            NSString *fileName = nil;
                            if (path) {
                                fileName = [[path absoluteString] lastPathComponent];
                            }
                            [self _uploadData:data filename:fileName];
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
                    [self _uploadData:data filename:nil];
                }
            } failureBlock:NULL];
        }
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - private

- (void)_uploadData:(NSData *)data filename:(NSString *)filename
{
    NSString *filePath = NSHomeDirectory();
    filePath = [NSString stringWithFormat:@"%@/Library/appdata/files",filePath];
    NSFileManager *fm = [NSFileManager defaultManager];
    if(![fm fileExistsAtPath:filePath]) {
        [fm createDirectoryAtPath:filePath
      withIntermediateDirectories:YES
                       attributes:nil
                            error:nil];
    }
    
    if (filename.length > 0) {
        filePath = [NSString stringWithFormat:@"%@/%d%@", filePath, (int)[[NSDate date] timeIntervalSince1970], filename];
    } else {
        filePath = [NSString stringWithFormat:@"%@/%d%d.jpg", filePath, (int)[[NSDate date] timeIntervalSince1970], arc4random() % 100000];
    }
    
    [data writeToFile:filePath atomically:YES];
    __weak typeof(self) weakSelf = self;
    [self showHudInView:self.view hint:NSLocalizedString(@"setting.uploading", @"Uploading...")];
    [[EMClient sharedClient].groupManager uploadGroupSharedFileWithId:_group.groupId filePath:filePath progress:^(int progress){
        // NSLog(@"%d",progress);
    } completion:^(EMGroupSharedFile *aSharedFile, EMError *aError) {
        [weakSelf hideHud];
        if (!aError) {
            [weakSelf.dataArray insertObject:aSharedFile atIndex:0];
            [weakSelf.tableView reloadData];
        } else {
            [weakSelf showHint:[NSString stringWithFormat:@"%@%@",NSLocalizedString(@"setting.uploadFail", @"Failed to upload"), aError.errorDescription]];
        }
    }];
}

#pragma mark - action

- (void)uploadAction
{
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    self.imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
    [self presentViewController:self.imagePicker animated:YES completion:NULL];
}

- (void)updateUI:(NSNotification *)aNotif
{
    id obj = aNotif.object;
    if (obj && [obj isKindOfClass:[EMGroup class]]) {
        EMGroup *retGroup = (EMGroup *)obj;
        if ([retGroup.groupId isEqualToString:_group.groupId]) {
            [self.dataArray removeAllObjects];
            [self.dataArray addObjectsFromArray:retGroup.sharedFileList];
            [self.tableView reloadData];
        }
    }
}

#pragma mark - data

- (void)tableViewDidTriggerHeaderRefresh
{
    self.page = 1;
    [self fetchBansWithPage:self.page isHeader:YES];
}

- (void)tableViewDidTriggerFooterRefresh
{
    self.page += 1;
    [self fetchBansWithPage:self.page isHeader:NO];
}

- (void)fetchBansWithPage:(NSInteger)aPage
                 isHeader:(BOOL)aIsHeader
{
    NSInteger pageSize = 10;
    __weak typeof(self) weakSelf = self;
    [self showHudInView:self.view hint:NSLocalizedString(@"loadData", @"Load data...")];
    [[EMClient sharedClient].groupManager getGroupFileListWithId:self.group.groupId pageNumber:self.page pageSize:pageSize completion:^(NSArray *aList, EMError *aError) {
        [weakSelf hideHud];
        [weakSelf tableViewDidFinishTriggerHeader:aIsHeader reload:NO];
        if (!aError) {
            if (aIsHeader) {
                [weakSelf.dataArray removeAllObjects];
            }
            
            [weakSelf.dataArray addObjectsFromArray:aList];
            [weakSelf.tableView reloadData];
        } else {
            NSString *errorStr = [NSString stringWithFormat:NSLocalizedString(@"group.fetchSharedFileFail", @"fail to get share files: %@"), aError.errorDescription];
            [weakSelf showHint:errorStr];
        }
        
        if ([aList count] < pageSize) {
            self.showRefreshFooter = NO;
        } else {
            self.showRefreshFooter = YES;
        }
    }];
}

@end
