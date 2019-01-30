//
//  EMMessageBubbleView.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/25.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import <SDWebImage/UIImageView+WebCache.h>
#import "EMMessageBubbleView.h"

#import "EMMessageModel.h"

#define kEMMessageImageSize 120

#define kEMMessageAudioMinWidth 30
#define kEMMessageAudioMaxWidth 120

@interface EMMessageBubbleView()

@property (nonatomic, strong) UILabel *textLabel;

@property (nonatomic, strong) UILabel *detailLabel;

@property (nonatomic, strong) UIImageView *imgView;

@end

@implementation EMMessageBubbleView

- (instancetype)initWithDirection:(EMMessageDirection)aDirection
                             type:(EMMessageBodyType)aType
{
    self = [super init];
    if (self) {
        [self _initViewsWithDirection:aDirection type:aType];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

#pragma mark - Getter

- (UILabel *)textLabel
{
    if (_textLabel == nil) {
        _textLabel = [[UILabel alloc] init];
        _textLabel.font = [UIFont systemFontOfSize:17];
        _textLabel.numberOfLines = 0;
        _textLabel.textColor = [UIColor blackColor];
    }
    
    return _textLabel;
}

- (UILabel *)detailLabel
{
    if (_detailLabel == nil) {
        _detailLabel = [[UILabel alloc] init];
        _detailLabel.font = [UIFont systemFontOfSize:15];
        _detailLabel.numberOfLines = 0;
        _detailLabel.textColor = [UIColor grayColor];
    }
    
    return _detailLabel;
}


- (UIImageView *)imgView
{
    if (_imgView == nil) {
        _imgView = [[UIImageView alloc] init];
        _imgView.contentMode = UIViewContentModeScaleAspectFit;
        _imgView.clipsToBounds = YES;
        //        _imgView.hidden = YES;
    }
    
    return _imgView;
}

#pragma mark - Subviews

- (void)_initViewsWithDirection:(EMMessageDirection)aDirection
                           type:(EMMessageBodyType)aType
{
    BOOL isNeedBg = YES;
    if (aType == EMMessageBodyTypeText) {
        [self addSubview:self.textLabel];
        [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_top).offset(10);
            make.bottom.equalTo(self.mas_bottom).offset(-10);
            make.left.equalTo(self.mas_left).offset(15);
            make.right.equalTo(self.mas_right).offset(-15);
        }];
        
        if (aDirection == EMMessageDirectionSend) {
            self.textLabel.textColor = [UIColor whiteColor];
        }
    } else if (aType == EMMessageBodyTypeImage) {
        isNeedBg = NO;
        self.layer.borderColor = [UIColor grayColor].CGColor;
        self.layer.borderWidth = 2;
//        [self addSubview:self.imgView];
//        [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
////            make.top.equalTo(self.mas_top).offset(10);
////            make.bottom.equalTo(self.mas_bottom).offset(-10);
////            make.left.equalTo(self.mas_left).offset(10);
////            make.right.equalTo(self.mas_right).offset(-10);
//            make.edges.equalTo(self);
//        }];
    } else if (aType == EMMessageBodyTypeVoice) {
        if (aDirection == EMMessageDirectionSend) {
            self.imgView.image = [UIImage imageNamed:@"msg_send_audio"];
            self.imgView.animationImages = @[[UIImage imageNamed:@"msg_send_audio01"], [UIImage imageNamed:@"msg_send_audio02"], [UIImage imageNamed:@"msg_send_audio"]];
        } else {
            self.imgView.image = [UIImage imageNamed:@"msg_recv_audio"];
            self.imgView.animationImages = @[[UIImage imageNamed:@"msg_recv_audio01"], [UIImage imageNamed:@"msg_recv_audio02"], [UIImage imageNamed:@"msg_recv_audio"]];
        }
        self.imgView.animationDuration = 1.0;
        [self addSubview:self.imgView];
        [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.top.equalTo(self).offset(10);
            make.right.equalTo(self).offset(-10);
            make.width.height.equalTo(@30);
        }];
        
        [self addSubview:self.textLabel];
        [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(10);
            make.left.equalTo(self).offset(10);
            make.right.equalTo(self.imgView.mas_left).offset(-10);
            make.bottom.equalTo(self).offset(-10);
        }];
    } else if (aType == EMMessageBodyTypeVideo) {
        isNeedBg = NO;
        self.layer.borderColor = [UIColor grayColor].CGColor;
        self.layer.borderWidth = 2;
        self.imgView.image = [UIImage imageNamed:@"msg_video"];
        [self addSubview:self.imgView];
        [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
        }];
    } else if (aType == EMMessageBodyTypeLocation || aType == EMMessageBodyTypeFile) {
        if (aType == EMMessageBodyTypeLocation) {
            self.imgView.image = [UIImage imageNamed:@"image"];
        } else if (aType == EMMessageBodyTypeFile) {
            self.imgView.image = [UIImage imageNamed:@"file"];
        }
        [self addSubview:self.imgView];
        [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(10);
            make.left.equalTo(self).offset(10);
            make.centerY.equalTo(self);
            make.width.equalTo(@40);
        }];
        
        [self addSubview:self.textLabel];
        [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(10);
            make.left.equalTo(self.imgView.mas_right).offset(8);
            make.right.equalTo(self).offset(-10);
        }];
        
        [self addSubview:self.detailLabel];
        [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.textLabel.mas_bottom).offset(5);
            make.bottom.equalTo(self).offset(-10);
            make.left.equalTo(self.textLabel);
            make.right.equalTo(self.textLabel);
        }];
    }
    
    if (isNeedBg) {
        if (aDirection == EMMessageDirectionSend) {
            self.image = [[UIImage imageNamed:@"msg_send"] stretchableImageWithLeftCapWidth:15 topCapHeight:15];
        } else if (aDirection == EMMessageDirectionReceive) {
            self.image = [[UIImage imageNamed:@"msg_recv"] stretchableImageWithLeftCapWidth:15 topCapHeight:15];
        }
    }
}

#pragma mark - Setter

- (void)_setThumbnailImageWithLocalPath:(NSString *)aLocalPath
                             remotePath:(NSString *)aRemotePath
                                imgSize:(CGSize)aSize
{
    UIImage *img = nil;
    if ([aLocalPath length] > 0) {
        img = [UIImage imageWithContentsOfFile:aLocalPath];
    }
    
    __weak typeof(self) weakself = self;
    void (^block)(CGSize aSize) = ^(CGSize aSize) {
        if (aSize.width == 0 || aSize.height == 0) {
            aSize.width = kEMMessageImageSize;
            aSize.height = kEMMessageImageSize;
        } else if (aSize.width > aSize.height) {
            CGFloat height =  kEMMessageImageSize / aSize.width * aSize.height;
            aSize.height = height;
            aSize.width = kEMMessageImageSize;
        } else {
            CGFloat width = kEMMessageImageSize / aSize.height * aSize.width;
            aSize.width = width;
            aSize.height = kEMMessageImageSize;
        }
        [weakself mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(aSize.width);
            make.height.mas_equalTo(aSize.height);
        }];
    };
    
    if (img) {
        self.image = img;
        if (aSize.width == 0 || aSize.height == 0) {
            aSize = img.size;
        }
    } else {
        [self sd_setImageWithURL:[NSURL URLWithString:aRemotePath] placeholderImage:[UIImage imageNamed:@"image"] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            if (aSize.width == 0 || aSize.height == 0) {
                block(image.size);
            }
        }];
    }
    
    block(aSize);
}

- (void)_setImageModel:(EMMessageModel *)aModel
{
    EMImageMessageBody *body = (EMImageMessageBody *)aModel.emModel.body;
    CGSize imgSize = body.thumbnailSize;
    NSString *imgPath = body.thumbnailLocalPath;
    if ([imgPath length] == 0 && aModel.direction == EMMessageDirectionSend) {
        imgPath = body.localPath;
    }
    [self _setThumbnailImageWithLocalPath:imgPath remotePath:body.thumbnailRemotePath imgSize:imgSize];
}

- (void)_setAudioModel:(EMMessageModel *)aModel
{
    EMVoiceMessageBody *body = (EMVoiceMessageBody *)aModel.emModel.body;
    self.textLabel.text = [NSString stringWithFormat:@"%d\"",(int)body.duration];
    if (aModel.isPlaying) {
        [self.imgView startAnimating];
    } else {
        [self.imgView stopAnimating];
    }
    
    CGFloat width = kEMMessageAudioMinWidth * body.duration / 10;
    if (width > kEMMessageAudioMaxWidth) {
        width = kEMMessageAudioMaxWidth;
    } else if (width < kEMMessageAudioMinWidth) {
        width = kEMMessageAudioMinWidth;
    }
    [self.textLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(width);
    }];
}

- (void)_setVideoModel:(EMMessageModel *)aModel
{
    EMVideoMessageBody *body = (EMVideoMessageBody *)aModel.emModel.body;
    CGSize imgSize = body.thumbnailSize;
    NSString *imgPath = body.thumbnailLocalPath;
    if ([imgPath length] == 0 && aModel.direction == EMMessageDirectionSend) {
        imgPath = body.localPath;
    }
    [self _setThumbnailImageWithLocalPath:imgPath remotePath:body.thumbnailRemotePath imgSize:imgSize];
}

- (void)setModel:(EMMessageModel *)model
{
    EMMessageBodyType type = model.type;
    if (type == EMMessageBodyTypeText) {
        EMTextMessageBody *body = (EMTextMessageBody *)model.emModel.body;
        self.textLabel.text = body.text;
    } else if (type == EMMessageBodyTypeImage) {
        [self _setImageModel:model];
    } else if (type == EMMessageBodyTypeVoice) {
        [self _setAudioModel:model];
    }  else if (type == EMMessageBodyTypeVideo) {
        [self _setVideoModel:model];
    } else if (type == EMMessageBodyTypeLocation) {
        EMLocationMessageBody *body = (EMLocationMessageBody *)model.emModel.body;
        self.textLabel.text = body.address;
        self.detailLabel.text = [NSString stringWithFormat:@"纬度:%.2lf°, 经度:%.2lf°", body.latitude, body.longitude];
    } else if (type == EMMessageBodyTypeFile) {
        EMFileMessageBody *body = (EMFileMessageBody *)model.emModel.body;
        self.textLabel.text = body.displayName;
        self.detailLabel.text = [NSString stringWithFormat:@"%.2lf MB",(float)body.fileLength / (1024 * 1024)];
    }
}

#pragma mark - Public

@end
