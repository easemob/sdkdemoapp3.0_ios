//
//  EMChineseToPinyin.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/2/11.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EMChineseToPinyin : NSObject

+ (NSString *)pinyinFromChineseString:(NSString *)string;

+ (char)sortSectionTitle:(NSString *)string; 

@end
