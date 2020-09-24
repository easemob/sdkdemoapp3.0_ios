//
//  EMAvatarNameModel.m
//  EaseIM
//
//  Created by 娜塔莎 on 2020/8/19.
//  Copyright © 2020 娜塔莎. All rights reserved.
//

#import "EMAvatarNameModel.h"

@implementation EMAvatarNameModel

- (instancetype)initWithInfo:(NSString *)keyWord img:(UIImage *)img msg:(EMMessage *)msg time:(NSString *)timestamp
{
    self = [super init];
    if (self) {
        _avatarImg = img;
        _from = msg.from;
        NSString *text = ((EMTextMessageBody *)msg.body).text;
        NSRange range = [text rangeOfString:keyWord options:NSCaseInsensitiveSearch];
        NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:text];
        [attributedStr setAttributes:@{NSForegroundColorAttributeName : [UIColor colorWithRed:4/255.0 green:174/255.0 blue:240/255.0 alpha:1.0]} range:NSMakeRange(range.location, keyWord.length)];
        _detail = attributedStr;
        _timestamp = timestamp;
    }
    return self;
}

@end
