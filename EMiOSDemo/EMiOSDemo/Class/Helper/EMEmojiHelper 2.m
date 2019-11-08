//
//  EMEmojiHelper.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/31.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EMEmojiHelper.h"

#define EMOJI_CODE_TO_SYMBOL(x) ((((0x808080F0 | (x & 0x3F000) >> 4) | (x & 0xFC0) << 10) | (x & 0x1C0000) << 18) | (x & 0x3F) << 24);

static EMEmojiHelper *helper = nil;
@implementation EMEmojiHelper

- (instancetype)init
{
    self = [super init];
    if (self) {
        _convertEmojiDic = @{@"[):]":@"😊", @"[:D]":@"😃", @"[;)]":@"😉", @"[:-o]":@"😮", @"[:p]":@"😋", @"[(H)]":@"😎", @"[:@]":@"😡", @"[:s]":@"😖", @"[:$]":@"😳", @"[:(]":@"😞", @"[:'(]":@"😭", @"[:|]":@"😐", @"[(a)]":@"😇", @"[8o|]":@"😬", @"[8-|]":@"😆", @"[+o(]":@"😱", @"[<o)]":@"🎅", @"[|-)]":@"😴", @"[*-)]":@"😕", @"[:-#]":@"😷", @"[:-*]":@"😯", @"[^o)]":@"😏", @"[8-)]":@"😑", @"[(|)]":@"💖", @"[(u)]":@"💔", @"[(S)]":@"🌙", @"[(*)]":@"🌟", @"[(#)]":@"🌞", @"[(R)]":@"🌈", @"[(})]":@"😚", @"[({)]":@"😍", @"[(k)]":@"💋", @"[(F)]":@"🌹", @"[(W)]":@"🍂", @"[(D)]":@"👍"};
    }
    
    return self;
}

+ (instancetype)sharedHelper
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        helper = [[EMEmojiHelper alloc] init];
    });
    
    return helper;
}

+ (NSString *)emojiWithCode:(int)aCode
{
    int sym = EMOJI_CODE_TO_SYMBOL(aCode);
    return [[NSString alloc] initWithBytes:&sym length:sizeof(sym) encoding:NSUTF8StringEncoding];
}

+ (NSArray<NSString *> *)getAllEmojis
{
    NSArray *emojis = @[[EMEmojiHelper emojiWithCode:0x1F60a],
                        [EMEmojiHelper emojiWithCode:0x1F603],
                        [EMEmojiHelper emojiWithCode:0x1F609],
                        [EMEmojiHelper emojiWithCode:0x1F62e],
                        [EMEmojiHelper emojiWithCode:0x1F60b],
                        [EMEmojiHelper emojiWithCode:0x1F60e],
                        [EMEmojiHelper emojiWithCode:0x1F621],
                        [EMEmojiHelper emojiWithCode:0x1F616],
                        [EMEmojiHelper emojiWithCode:0x1F633],
                        [EMEmojiHelper emojiWithCode:0x1F61e],
                        [EMEmojiHelper emojiWithCode:0x1F62d],
                        [EMEmojiHelper emojiWithCode:0x1F610],
                        [EMEmojiHelper emojiWithCode:0x1F607],
                        [EMEmojiHelper emojiWithCode:0x1F62c],
                        [EMEmojiHelper emojiWithCode:0x1F606],
                        [EMEmojiHelper emojiWithCode:0x1F631],
                        [EMEmojiHelper emojiWithCode:0x1F385],
                        [EMEmojiHelper emojiWithCode:0x1F634],
                        [EMEmojiHelper emojiWithCode:0x1F615],
                        [EMEmojiHelper emojiWithCode:0x1F637],
                        [EMEmojiHelper emojiWithCode:0x1F62f],
                        [EMEmojiHelper emojiWithCode:0x1F60f],
                        [EMEmojiHelper emojiWithCode:0x1F611],
                        [EMEmojiHelper emojiWithCode:0x1F496],
                        [EMEmojiHelper emojiWithCode:0x1F494],
                        [EMEmojiHelper emojiWithCode:0x1F319],
                        [EMEmojiHelper emojiWithCode:0x1f31f],
                        [EMEmojiHelper emojiWithCode:0x1f31e],
                        [EMEmojiHelper emojiWithCode:0x1F308],
                        [EMEmojiHelper emojiWithCode:0x1F60d],
                        [EMEmojiHelper emojiWithCode:0x1F61a],
                        [EMEmojiHelper emojiWithCode:0x1F48b],
                        [EMEmojiHelper emojiWithCode:0x1F339],
                        [EMEmojiHelper emojiWithCode:0x1F342],
                        [EMEmojiHelper emojiWithCode:0x1F44d]];

    return emojis;
}

+ (BOOL)isStringContainsEmoji:(NSString *)aString
{
    __block BOOL ret = NO;
    [aString enumerateSubstringsInRange:NSMakeRange(0, [aString length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        const unichar hs = [substring characterAtIndex:0];
        if (0xd800 <= hs && hs <= 0xdbff) {
            if (substring.length > 1) {
                const unichar ls = [substring characterAtIndex:1];
                const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                if (0x1d000 <= uc && uc <= 0x1f77f) {
                    ret = YES;
                }
            }
        } else if (substring.length > 1) {
            const unichar ls = [substring characterAtIndex:1];
            if (ls == 0x20e3) {
                ret = YES;
            }
        } else {
            if (0x2100 <= hs && hs <= 0x27ff) {
                ret = YES;
            } else if (0x2B05 <= hs && hs <= 0x2b07) {
                ret = YES;
            } else if (0x2934 <= hs && hs <= 0x2935) {
                ret = YES;
            } else if (0x3297 <= hs && hs <= 0x3299) {
                ret = YES;
            } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
                ret = YES;
            }
        }
    }];
    
    return ret;
}

+ (NSString *)convertEmoji:(NSString *)aString
{
    NSDictionary *emojisDic = [EMEmojiHelper sharedHelper].convertEmojiDic;
    NSRange range;
    range.location = 0;
    
    NSMutableString *retStr = [NSMutableString stringWithString:aString];
    for (NSString *key in emojisDic) {
        range.length = retStr.length;
        NSString *value = emojisDic[key];
        [retStr replaceOccurrencesOfString:key withString:value options:NSLiteralSearch range:range];
    }
    
    return retStr;
}

@end
