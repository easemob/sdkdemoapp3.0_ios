//
//  EMChatVideoBubbleView.m
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 16/9/28.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "EMChatVideoBubbleView.h"

#import "EMMessageModel.h"

#define MAX_SIZE 250

@interface EMChatVideoBubbleView ()

@property (strong, nonatomic) UIButton *videoPlayButton;

@end

@implementation EMChatVideoBubbleView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.masksToBounds = YES;
        self.contentMode = UIViewContentModeScaleAspectFill;
        self.layer.cornerRadius = 10.f;
        
        self.videoPlayButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *backgroundImage = [UIImage imageNamed:@"Icon_Play"];
        [self.videoPlayButton setBackgroundImage:backgroundImage forState:UIControlStateNormal];
        [self addSubview:self.videoPlayButton];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat width = 50.0f;
    CGFloat height = 50.0f;
    CGFloat x = self.frame.size.width/2 - width/2;
    CGFloat y = self.frame.size.height/2 - height/2;
    [self.videoPlayButton setFrame:CGRectMake(x, y, width, height)];
}

- (CGSize)sizeThatFits:(CGSize)size
{
    CGSize retSize;
    EMVideoMessageBody *body = (EMVideoMessageBody*)self.model.message.body;
    if (self.model.message.ext) {
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
    if (self.model.message.ext) {
        retSize.height = MAX_SIZE / 4 * 3;
    }
    return retSize;
}

- (void)setModel:(EMMessageModel*)model;
{
    [super setModel:model];
    
    EMVideoMessageBody *videoBody = (EMVideoMessageBody *)model.message.body;
    if ([videoBody.thumbnailLocalPath length] > 0) {
        NSData *thumbnailImageData = [NSData dataWithContentsOfFile:videoBody.thumbnailLocalPath];
        if (thumbnailImageData.length) {
            self.backImageView.image = [UIImage imageWithData:thumbnailImageData];
        }
    } else {
        [self.backImageView sd_setImageWithURL:[NSURL URLWithString:videoBody.thumbnailRemotePath] placeholderImage:nil];
    }
}

+ (CGFloat)heightForBubbleWithMessageModel:(EMMessageModel *)model
{
    CGSize retSize;
    EMVideoMessageBody *body = (EMVideoMessageBody*)model.message.body;
    if (model.message.ext) {
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
    if (model.message.ext) {
        retSize.height = MAX_SIZE / 4 * 3;
    }
    
    return retSize.height;
}

@end
