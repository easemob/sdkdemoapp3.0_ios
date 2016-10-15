//
//  EMEmojiEmoticons.m
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 16/10/12.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "EMEmojiEmoticons.h"

#import "EMEmoji.h"

@implementation EMEmojiEmoticons

+ (NSArray *)allEmoticons {
    NSMutableArray *array = [NSMutableArray new];
    NSMutableArray * localAry = [[NSMutableArray alloc] initWithObjects:
                                 [EMEmoji emojiWithCode:0x1F60a],
                                 [EMEmoji emojiWithCode:0x1F603],
                                 [EMEmoji emojiWithCode:0x1F609],
                                 [EMEmoji emojiWithCode:0x1F62e],
                                 [EMEmoji emojiWithCode:0x1F60b],
                                 [EMEmoji emojiWithCode:0x1F60e],
                                 [EMEmoji emojiWithCode:0x1F621],
                                 [EMEmoji emojiWithCode:0x1F616],
                                 [EMEmoji emojiWithCode:0x1F633],
                                 [EMEmoji emojiWithCode:0x1F61e],
                                 [EMEmoji emojiWithCode:0x1F62d],
                                 [EMEmoji emojiWithCode:0x1F610],
                                 [EMEmoji emojiWithCode:0x1F607],
                                 [EMEmoji emojiWithCode:0x1F62c],
                                 [EMEmoji emojiWithCode:0x1F606],
                                 [EMEmoji emojiWithCode:0x1F631],
                                 [EMEmoji emojiWithCode:0x1F385],
                                 [EMEmoji emojiWithCode:0x1F634],
                                 [EMEmoji emojiWithCode:0x1F615],
                                 [EMEmoji emojiWithCode:0x1F637],
                                 [EMEmoji emojiWithCode:0x1F62f],
                                 [EMEmoji emojiWithCode:0x1F60f],
                                 [EMEmoji emojiWithCode:0x1F611],
                                 [EMEmoji emojiWithCode:0x1F496],
                                 [EMEmoji emojiWithCode:0x1F494],
                                 [EMEmoji emojiWithCode:0x1F319],
                                 [EMEmoji emojiWithCode:0x1f31f],
                                 [EMEmoji emojiWithCode:0x1f31e],
                                 [EMEmoji emojiWithCode:0x1F308],
                                 [EMEmoji emojiWithCode:0x1F60d],
                                 [EMEmoji emojiWithCode:0x1F61a],
                                 [EMEmoji emojiWithCode:0x1F48b],
                                 [EMEmoji emojiWithCode:0x1F339],
                                 [EMEmoji emojiWithCode:0x1F342],
                                 [EMEmoji emojiWithCode:0x1F44d],
                                 nil];
    [array addObjectsFromArray:localAry];
    return array;
}

@end
