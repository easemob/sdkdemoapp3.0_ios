//
//  ChatViewController+ShareFile.m
//  ChatDemo-UI3.0
//
//  Created by 杜洁鹏 on 15/03/2017.
//  Copyright © 2017 杜洁鹏. All rights reserved.
//

#import "ChatViewController+ShareFile.h"
#import <objc/runtime.h>

@interface ChatViewController ()
@property (nonatomic, strong) UIDocumentInteractionController *documentController;
@end

@implementation ChatViewController (ShareFile)

- (NSObject *)documentController {
    
    return objc_getAssociatedObject(self, @selector(documentController));
}

- (void)setDocumentController:(NSObject *)documentController {
    
    objc_setAssociatedObject(self, @selector(documentController), documentController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)messageViewController:(EaseMessageViewController *)viewController
        didSelectMessageModel:(id<IMessageModel>)messageModel {
    if (messageModel.bodyType == EMMessageBodyTypeFile) {
        EMFileMessageBody *body = (EMFileMessageBody *)messageModel.message.body;
        if (body.downloadStatus != EMDownloadStatusSuccessed) {
            [self showHint:@"开始下载"];
            [[EMClient sharedClient].chatManager downloadMessageAttachment:messageModel.message progress:^(int progress) {
                
            } completion:^(EMMessage *message, EMError *error) {
                [self showHint:@"下载成功"];
                [self openFileWithFileBody:body];
            }];
        } else {
            [self openFileWithFileBody:body];
        }
        return YES;
    }
    return NO;
}

- (void)openFileWithFileBody:(EMFileMessageBody *)body {
    NSURL *fileURL = [NSURL fileURLWithPath:body.localPath];
    NSMutableArray *fileAry = [[body.localPath componentsSeparatedByString:@"/"] mutableCopy];
    [fileAry removeLastObject];
    NSString *toFile = [fileAry componentsJoinedByString:@"/"];
    toFile = [toFile stringByAppendingString:[NSString stringWithFormat:@"/%@",body.displayName]];
    NSFileManager *fm = [NSFileManager defaultManager];
    
    if ([fm fileExistsAtPath:toFile]) {
        self.documentController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:toFile]];
        [self.documentController presentOptionsMenuFromRect:self.view.bounds inView:self.view animated:YES];
        return;
    }
    
    NSError *error;
    [fm copyItemAtURL:fileURL toURL:[NSURL fileURLWithPath:toFile] error:&error];
    if (!error) {
        self.documentController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:toFile]];
        [self.documentController presentOptionsMenuFromRect:self.view.bounds inView:self.view animated:YES];
    }
}


@end
