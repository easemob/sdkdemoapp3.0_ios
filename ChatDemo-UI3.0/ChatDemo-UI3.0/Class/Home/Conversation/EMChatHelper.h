//
//  EMChatHelper.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/8.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EMChatHelper : NSObject

/*!
 @method
 @brief 系统emoji表情转换为表情编码
 @discussion
 @param text   待转换的文字
 @return  转换后的文字
 */
+ (NSString *)convertToCommonEmoticons:(NSString *)text;

/*!
 @method
 @brief 表情编码转换为系统emoji表情
 @discussion
 @param text   待转换的文字
 @return  转换后的文字
 */
+ (NSString *)convertToSystemEmoticons:(NSString *)text;

@end
