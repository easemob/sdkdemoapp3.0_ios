//
//  EMEmojiHelper.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/31.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EMEmojiHelper : NSObject

+ (NSArray<NSString *> *)getAllEmojis;

+ (BOOL)isStringContainsEmoji:(NSString *)aString;

@end

NS_ASSUME_NONNULL_END
