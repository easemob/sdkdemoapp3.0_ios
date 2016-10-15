//
//  EMEmoji.h
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 16/10/12.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MAKE_Q(x) @#x
#define MAKE_EM(x,y) MAKE_Q(x##y)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunicode"
#define MAKE_EMOJI(x) MAKE_EM(\U000,x)
#pragma clang diagnostic pop

#define EMOJI_METHOD(x,y) + (NSString *)x { return MAKE_EMOJI(y); }
#define EMOJI_HMETHOD(x) + (NSString *)x;
#define EMOJI_CODE_TO_SYMBOL(x) ((((0x808080F0 | (x & 0x3F000) >> 4) | (x & 0xFC0) << 10) | (x & 0x1C0000) << 18) | (x & 0x3F) << 24);

@interface EMEmoji : NSObject

+ (NSString *)emojiWithCode:(int)code;

+ (NSArray *)allEmoji;

+ (BOOL)stringContainsEmoji:(NSString *)string;

@end
