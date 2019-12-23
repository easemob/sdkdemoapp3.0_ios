//
//  EMFileTransferDocument.m
//  EMiOSDemo
//
//  Created by 娜塔莎 on 2019/12/17.
//  Copyright © 2019 娜塔莎. All rights reserved.
//

#import "EMFileTransferDocument.h"

///iCloud文件上传使用
@interface WeDocument : UIDocument

@property (nonatomic, strong, nullable) NSData *data;
//文件名
@property (nonatomic, copy, nullable) NSString *fileName;
//文件类型
@property (nonatomic, copy, nullable) NSString *MIMEType;
//文件大小
@property (nonatomic, assign) NSUInteger length;

@end

@implementation WeDocument
@end

@implementation EMFileTransferDocument

/**
 *  iCloud文件上传
 *  documentsURL 文件地址；rename 文件重命名，文件名不需带文件类型后缀
 */
+ (void)updateFileWithUrl:(NSURL *)documentsURL
                         reName:(nullable NSString *)rename
                           data:(void(^)(NSData *fileData, NSString *fileName))documentData
{
    if (!documentsURL.isFileURL) {
        NSLog(@"\n is not file url");
        return;
    }
    
    WeDocument *document = [[WeDocument alloc] initWithFileURL:documentsURL];
    
    //打开文件
    [document openWithCompletionHandler:^(BOOL success) {
        if (success) {
            //文件类型获取失败，return，否则会闪退
            if (!document.MIMEType || document.MIMEType.length <= 0) {
                NSLog(@"\n 文件类型获取失败！");
                return;
            }
            //文件重命名
            if (rename && rename.length>0) {
                //server端从文件名中获取后缀，进行文档转化，因此文件名需要包含文件类型后缀
                document.fileName = [rename stringByAppendingString:document.MIMEType];
            } else {
                //如无文件名，生成时间戳作为文件名
                if (!rename || rename.length <= 0) {
                    document.fileName = [NSString stringWithFormat:@"%f%@",[[NSDate date] timeIntervalSince1970],document.MIMEType];
                }
            }
        } else {
            NSLog(@"\n 文件读取失败!");
        }
        [document closeWithCompletionHandler:^(BOOL success) {
            documentData(document.data,document.fileName);
        }];
    }];
}

@end
