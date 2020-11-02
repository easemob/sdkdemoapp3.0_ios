//
//  EMMsgImageBubbleView.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/2/14.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import <SDWebImage/UIImageView+WebCache.h>
#import "EMMsgImageBubbleView.h"

#define kEMMsgImageDefaultSize 120
#define kEMMsgImageMinWidth 50
#define kEMMsgImageMaxWidth 120
#define kEMMsgImageMaxHeight 260

@implementation EMMsgImageBubbleView

- (instancetype)initWithDirection:(EMMessageDirection)aDirection
                             type:(EMMessageType)aType
{
    self = [super initWithDirection:aDirection type:aType];
    if (self) {
//        self.layer.borderColor = [UIColor lightGrayColor].CGColor;
//        self.layer.borderWidth = 1;
        self.layer.cornerRadius = 2;
        self.contentMode = UIViewContentModeScaleAspectFill;
    }
    
    return self;
}

#pragma mark - Private

- (CGSize)_getImageSize:(CGSize)aSize
{
    CGSize retSize = CGSizeZero;
    do {
        if (aSize.width == 0 || aSize.height == 0) {
            break;
        }
        CGFloat maxWidth = [UIScreen mainScreen].bounds.size.width / 2 - 60.0;
        NSInteger tmpWidth = aSize.width;
        if (aSize.width < kEMMsgImageMinWidth) {
            tmpWidth = kEMMsgImageMinWidth;
        }
        if (aSize.width > kEMMsgImageMaxWidth) {
            tmpWidth = kEMMsgImageMaxWidth;
        }
        
        NSInteger tmpHeight = tmpWidth / aSize.width * aSize.height;
        if (tmpHeight > kEMMsgImageMaxHeight) {
            tmpHeight = kEMMsgImageMaxHeight;
        }
        retSize = CGSizeMake(tmpWidth, tmpHeight);
        
    } while (0);
    
    return retSize;
}

- (void)setThumbnailImageWithLocalPath:(NSString *)aLocalPath
                            remotePath:(NSString *)aRemotePath
                          thumbImgSize:(CGSize)aThumbSize
                               imgSize:(CGSize)aSize
{
    UIImage *img = nil;
    if ([aLocalPath length] > 0) {
        img = [UIImage imageWithContentsOfFile:aLocalPath];
    }
    
    __weak typeof(self) weakself = self;
    void (^block)(CGSize aSize) = ^(CGSize aSize) {
        CGSize layoutSize = [weakself _getImageSize:aSize];
        [weakself mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(layoutSize.width);
            make.height.mas_equalTo(layoutSize.height);
        }];
    };
    
    CGSize size = aThumbSize;
    if (aThumbSize.width == 0 || aThumbSize.height == 0) {
        size = aSize;
    }
    
    if (img) {
        self.image = img;
        size = img.size;
        block(size);
    } else {
        BOOL isAutoDownloadThumbnail = ([EMClient sharedClient].options.isAutoDownloadThumbnail);
        if (isAutoDownloadThumbnail) {
            [self sd_setImageWithURL:[NSURL URLWithString:aRemotePath] placeholderImage:[UIImage imageNamed:@"msg_img_broken"] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                    if (!error) {
                        weakself.image = image;
                        block(image.size);
                    } else {
                        weakself.image = [UIImage imageNamed:@"msg_img_broken"];
                        block(weakself.image.size);
                    }
            }];
        } else {
            self.image = [UIImage imageNamed:@"msg_img_broken"];
        }
    }
}

#pragma mark - Setter

- (void)setModel:(EMMessageModel *)model
{
    EMMessageType type = model.type;
    if (type == EMMessageTypeImage) {
        EMImageMessageBody *body = (EMImageMessageBody *)model.emModel.body;
        NSString *imgPath = body.thumbnailLocalPath;
        if ([imgPath length] == 0 && model.direction == EMMessageDirectionSend) {
            imgPath = body.localPath;
        }
        [self setThumbnailImageWithLocalPath:imgPath remotePath:body.thumbnailRemotePath thumbImgSize:body.thumbnailSize imgSize:body.size];
    }
}

@end
