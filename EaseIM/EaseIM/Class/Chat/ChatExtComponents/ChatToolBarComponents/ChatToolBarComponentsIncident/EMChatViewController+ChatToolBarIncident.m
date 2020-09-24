//
//  EMChatViewController+ChatToolBarIncident.m
//  EaseIM
//
//  Created by 娜塔莎 on 2020/7/13.
//  Copyright © 2020 娜塔莎. All rights reserved.
//

#import "EMChatViewController+ChatToolBarIncident.h"
#import <objc/runtime.h>
#import <Photos/Photos.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "EMLocationViewController.h"

@implementation EMChatViewController (ChatToolBarIncident)

- (void)chatToolBarComponentAction:(EMChatToolBarComponentType)toolBarComponentType
{
    if (toolBarComponentType == EMChatToolBarPhotoAlbum || toolBarComponentType == EMChatToolBarCamera)
        [self chatToolBarComponentIncidentAction:toolBarComponentType];
    if (toolBarComponentType == EMChatToolBarSealRtc)
        [self chatToolBarComponentSealRtcAction];
    if (toolBarComponentType == EMChatToolBarLocation)
        [self chatToolBarLocationAction];
    if (toolBarComponentType == EMChatToolBarFileOpen)
        [self chatToolBarFileOpenAction];
}

@end


/**
    媒体库
 */
static const void *imagePickerKey = &imagePickerKey;
@implementation EMChatViewController (ChatToolBarMeida)

@dynamic imagePicker;

- (void)chatToolBarComponentIncidentAction:(EMChatToolBarComponentType)componentType
{
    [self.view endEditing:YES];
    [self setterImagePicker];
    
    if (componentType == EMChatToolBarCamera) {
        #if TARGET_IPHONE_SIMULATOR
            [EMAlertController showErrorAlert:@"模拟器不支持照相机"];
        #elif TARGET_OS_IPHONE
            self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            self.imagePicker.mediaTypes = @[(NSString *)kUTTypeImage, (NSString *)kUTTypeMovie];
            [self presentViewController:self.imagePicker animated:YES completion:nil];
        #endif
        
        return;
    }
    
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            switch (status) {
                case PHAuthorizationStatusLimited:  //limit权限
                {
                    self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                    self.imagePicker.mediaTypes = @[(NSString *)kUTTypeImage, (NSString *)kUTTypeMovie];
                    [self presentViewController:self.imagePicker animated:YES completion:nil];
                }
                    break;
                case PHAuthorizationStatusAuthorized: //已获取权限
                {
                    self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                    self.imagePicker.mediaTypes = @[(NSString *)kUTTypeImage, (NSString *)kUTTypeMovie];
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

- (NSURL *)_videoConvert2Mp4:(NSURL *)movUrl
{
    NSURL *mp4Url = nil;
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:movUrl options:nil];
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    
    if ([compatiblePresets containsObject:AVAssetExportPresetHighestQuality]) {
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]initWithAsset:avAsset presetName:AVAssetExportPresetHighestQuality];
        NSString *mp4Path = [NSString stringWithFormat:@"%@/%d%d.mp4", [self getAudioOrVideoPath], (int)[[NSDate date] timeIntervalSince1970], arc4random() % 100000];
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

#pragma mark - Action

- (void)_sendImageDataAction:(NSData *)aImageData
{
    EMImageMessageBody *body = [[EMImageMessageBody alloc] initWithData:aImageData displayName:@"image"];
    [self sendMessageWithBody:body ext:nil isUpload:YES];
}
- (void)_sendVideoAction:(NSURL *)aUrl
{
    EMVideoMessageBody *body = [[EMVideoMessageBody alloc] initWithLocalPath:[aUrl path] displayName:@"video.mp4"];
    [self sendMessageWithBody:body ext:nil isUpload:YES];
}

#pragma mark - Getter

- (void)setterImagePicker
{
    if (self.imagePicker == nil) {
        self.imagePicker = [[UIImagePickerController alloc] init];
        self.imagePicker.modalPresentationStyle = UIModalPresentationOverFullScreen;
        self.imagePicker.delegate = self;
    }
}

- (UIImagePickerController *)imagePicker
{
    return objc_getAssociatedObject(self, imagePickerKey);
}

- (void)setImagePicker:(UIImagePickerController *)imagePicker
{
    objc_setAssociatedObject(self, imagePickerKey, imagePicker, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end


/**
    实时音视频
 */

@implementation EMChatViewController (ChatToolBarSealRtc)

- (void)chatToolBarComponentSealRtcAction
{
    self.alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    __weak typeof(self) weakself = self;
    if (self.conversationModel.emModel.type == EMConversationTypeChat) {
        [self.alertController addAction:[UIAlertAction actionWithTitle:@"视频通话" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakself.chatBar clearMoreViewAndSelectedButton];
            [[NSNotificationCenter defaultCenter] postNotificationName:CALL_MAKE1V1 object:@{CALL_CHATTER:weakself.conversationModel.emModel.conversationId, CALL_TYPE:@(EMCallTypeVideo)}];
        }]];
        [self.alertController addAction:[UIAlertAction actionWithTitle:@"语音通话" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakself.chatBar clearMoreViewAndSelectedButton];
            [[NSNotificationCenter defaultCenter] postNotificationName:CALL_MAKE1V1 object:@{CALL_CHATTER:weakself.conversationModel.emModel.conversationId, CALL_TYPE:@(EMCallTypeVoice)}];
        }]];
        [self.alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }]];
        for (UIAlertAction *alertAction in self.alertController.actions)
            [alertAction setValue:[UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1.0] forKey:@"_titleTextColor"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"didAlert" object:@{@"alert":self.alertController}];
        [self presentViewController:self.alertController animated:YES completion:nil];
        return;
    }
    [weakself.chatBar clearMoreViewAndSelectedButton];
    //群聊/聊天室 多人会议
    [[NSNotificationCenter defaultCenter] postNotificationName:CALL_MAKECONFERENCE object:@{CALL_TYPE:@(EMConferenceTypeCommunication), CALL_MODEL:weakself.conversationModel, NOTIF_NAVICONTROLLER:self.navigationController}];
}

@end


/**
    位置消息
 */

@implementation EMChatViewController (ChatToolBarLocation)

- (void)chatToolBarLocationAction
{
    EMLocationViewController *controller = [[EMLocationViewController alloc] init];
    [controller setSendCompletion:^(CLLocationCoordinate2D aCoordinate, NSString * _Nonnull aAddress) {
        [self _sendLocationAction:aCoordinate address:aAddress];
    }];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
    navController.modalPresentationStyle = 0;
    [self.navigationController presentViewController:navController animated:YES completion:nil];
}

- (void)_sendLocationAction:(CLLocationCoordinate2D)aCoord
                    address:(NSString *)aAddress
{
    EMLocationMessageBody *body = [[EMLocationMessageBody alloc] initWithLatitude:aCoord.latitude longitude:aCoord.longitude address:aAddress];
    [self sendMessageWithBody:body ext:nil isUpload:NO];
}

@end


/**
    选择文件
 */

@implementation EMChatViewController (ChatToolBarFileOpen)

- (void)chatToolBarFileOpenAction
{
    NSArray *documentTypes = @[@"public.content", @"public.text", @"public.source-code", @"public.image", @"public.jpeg", @"public.png", @"com.adobe.pdf", @"com.apple.keynote.key", @"com.microsoft.word.doc", @"com.microsoft.excel.xls", @"com.microsoft.powerpoint.ppt"];
    UIDocumentPickerViewController *picker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:documentTypes inMode:UIDocumentPickerModeOpen];
    picker.delegate = self;
    picker.modalPresentationStyle = 0;
    [self presentViewController:picker animated:YES completion:nil];
    
    /*
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[PAirSandbox sharedInstance] showSandboxBrowser];
        [[PAirSandbox sharedInstance] setSendCompletion:^(NSURL *url) {
            NSRange rage = [[url absoluteString] rangeOfString:@"/" options:NSBackwardsSearch];
            NSString *displayName;
            if (rage.location != NSNotFound) {
                displayName = [[url absoluteString] substringFromIndex:rage.location+1];
            }
            EMFileMessageBody *body = [[EMFileMessageBody alloc]initWithLocalPath:[url relativePath] displayName:displayName];
            [self sendMessageWithBody:body ext:nil isUpload:NO];
        }];
    });*/
    /*
    EMPickFileViewController *pickFileController = [[EMPickFileViewController alloc]init];
    [self.navigationController pushViewController:pickFileController animated:NO];*/
}

#pragma mark - UIDocumentPickerDelegate
- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray <NSURL *>*)urls
{
    BOOL fileAuthorized = [urls.firstObject startAccessingSecurityScopedResource];
    if (fileAuthorized) {
        [self selectedDocumentAtURLs:urls reName:nil];
        [urls.firstObject stopAccessingSecurityScopedResource];
        return;
    }
    [self showHint:@"授权失败!"];
}
- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentAtURL:(NSURL *)url
{
    BOOL fileAuthorized = [url startAccessingSecurityScopedResource];
    if (fileAuthorized) {
        [self selectedDocumentAtURLs:@[url] reName:nil];
        [url stopAccessingSecurityScopedResource];
        return;
    }
    [self showHint:@"授权失败!"];
}

//icloud
- (void)selectedDocumentAtURLs:(NSArray <NSURL *>*)urls reName:(NSString *)rename
{
    NSFileCoordinator *fileCoordinator = [[NSFileCoordinator alloc]init];
    for (NSURL *url in urls) {
        NSError *error;
        [fileCoordinator coordinateReadingItemAtURL:url options:0 error:&error byAccessor:^(NSURL * _Nonnull newURL) {
            //读取文件
            NSString *fileName = [newURL lastPathComponent];
            NSError *error = nil;
            NSData *fileData = [NSData dataWithContentsOfURL:newURL options:NSDataReadingMappedIfSafe error:&error];
            if (error) {
                [self showHint:@"文件读取失败!"];
                return;
            }
            NSLog(@"fileName: %@\nfileUrl: %@", fileName, newURL);
            EMFileMessageBody *body = [[EMFileMessageBody alloc]initWithData:fileData displayName:fileName];
            [self sendMessageWithBody:body ext:nil isUpload:NO];
        }];
    }
}

@end
