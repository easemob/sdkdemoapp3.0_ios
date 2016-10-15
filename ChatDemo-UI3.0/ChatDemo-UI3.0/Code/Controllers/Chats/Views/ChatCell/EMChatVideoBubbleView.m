//
//  EMChatVideoBubbleView.m
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 16/9/28.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "EMChatVideoBubbleView.h"

#define MAX_SIZE 250

@implementation EMChatVideoBubbleView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.masksToBounds = YES;
        self.contentMode = UIViewContentModeScaleAspectFill;
        self.layer.cornerRadius = 10.f;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

- (CGSize)sizeThatFits:(CGSize)size
{
    CGSize retSize;
    EMVideoMessageBody *body = (EMVideoMessageBody*)self.message.body;
    if (self.message.ext) {
        retSize = CGSizeMake(0, 0);
    } else {
        retSize = body.thumbnailSize;
    }
    if (retSize.width == 0 || retSize.height == 0) {
        retSize.width = MAX_SIZE;
        retSize.height = MAX_SIZE;
    }
    if (retSize.width > retSize.height) {
        CGFloat height =  MAX_SIZE / retSize.width  *  retSize.height;
        retSize.height = height;
        retSize.width = MAX_SIZE;
    }else {
        CGFloat width = MAX_SIZE / retSize.height * retSize.width;
        retSize.width = width;
        retSize.height = MAX_SIZE;
    }
    if (self.message.ext) {
        retSize.height = MAX_SIZE / 4 * 3;
    }
    return retSize;
}

- (void)setMessage:(EMMessage *)message
{
    [super setMessage:message];
    
    EMVideoMessageBody *videoBody = (EMVideoMessageBody *)message.body;
    if ([videoBody.thumbnailLocalPath length] > 0) {
        NSData *thumbnailImageData = [NSData dataWithContentsOfFile:videoBody.thumbnailLocalPath];
        if (thumbnailImageData.length) {
            self.backImageView.image = [UIImage imageWithData:thumbnailImageData];
        }
    } else {
        [self.backImageView sd_setImageWithURL:[NSURL URLWithString:videoBody.thumbnailRemotePath] placeholderImage:nil];
    }
}

+ (CGFloat)heightForBubbleWithMessage:(EMMessage *)message
{
    CGSize retSize;
    EMVideoMessageBody *body = (EMVideoMessageBody*)message.body;
    if (message.ext) {
        retSize = CGSizeMake(0, 0);
    } else {
        retSize = body.thumbnailSize;
    }
    if (retSize.width == 0 || retSize.height == 0) {
        retSize.width = MAX_SIZE;
        retSize.height = MAX_SIZE;
    }
    if (retSize.width > retSize.height) {
        CGFloat height =  MAX_SIZE / retSize.width  *  retSize.height;
        retSize.height = height;
        retSize.width = MAX_SIZE;
    }else {
        CGFloat width = MAX_SIZE / retSize.height * retSize.width;
        retSize.width = width;
        retSize.height = MAX_SIZE;
    }
    if (message.ext) {
        retSize.height = MAX_SIZE / 4 * 3;
    }
    
    return retSize.height;
}

@end
