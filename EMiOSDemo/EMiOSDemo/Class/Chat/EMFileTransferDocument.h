//
//  EMFileTransferDocument.h
//  EMiOSDemo
//
//  Created by 娜塔莎 on 2019/12/17.
//  Copyright © 2019 娜塔莎. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EMFileTransferDocument : NSObject

/**
 *  iCloud文件上传
 *  documentsURL 文件地址；rename 文件重命名，文件名不需带文件类型后缀
 */
+ (void)updateFileWithUrl:(NSURL *)documentsURL
                         reName:(nullable NSString *)rename
                     data:(void(^)(NSData *fileData, NSString *fileName))documentData;

@end

NS_ASSUME_NONNULL_END
