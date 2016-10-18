//
//  EMConvertToCommonEmoticonsHelper.h
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 16/10/12.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EMConvertToCommonEmoticonsHelper : NSObject

+ (NSString *)convertToCommonEmoticons:(NSString *)text;

+ (NSString *)convertToSystemEmoticons:(NSString *)text;

@end
