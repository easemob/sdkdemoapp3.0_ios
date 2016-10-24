//
//  EMChatImageBubbleView.m
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 16/9/28.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "EMChatImageBubbleView.h"

#import "EMMessageModel.h"

#define MAX_SIZE 250

@interface EMChatImageBubbleView ()

@end

@implementation EMChatImageBubbleView

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

- (CGSize)sizeThatFits:(CGSize)size
{
    CGSize retSize;
    EMImageMessageBody *body = (EMImageMessageBody*)self.model.message.body;
    if (self.model.message.ext) {
        retSize = CGSizeMake(0, 0);
    } else {
        retSize = body.size;
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
    if (self.model.message.ext) {
        retSize.height = MAX_SIZE / 4 * 3;
    }
    
    return CGSizeMake(retSize.width, retSize.height);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

#pragma mark - setter

- (void)setModel:(EMMessageModel *)model
{
    [super setModel:model];
    EMImageMessageBody *body = (EMImageMessageBody*)model.message.body;
    
    NSData *imageData = [NSData dataWithContentsOfFile:body.localPath];
    if (imageData.length) {
        self.backImageView.image = [UIImage imageWithData:imageData];
    }
    
    if ([body.thumbnailLocalPath length] > 0) {
        self.backImageView.image = [UIImage imageWithContentsOfFile:body.thumbnailLocalPath];
    }
}

+ (CGFloat)heightForBubbleWithMessageModel:(EMMessageModel *)model
{
    CGSize retSize;
    EMImageMessageBody *body = (EMImageMessageBody*)model.message.body;
    if (model.message.ext) {
        retSize = CGSizeMake(0, 0);
    } else {
        retSize = body.size;
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
    if (model.message.ext) {
        retSize.height = MAX_SIZE / 4 * 3;
    }
    
    return retSize.height;
}

@end
