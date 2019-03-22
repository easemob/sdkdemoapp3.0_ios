//
//  EMMsgVideoBubbleView.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/2/14.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EMMsgVideoBubbleView.h"

@implementation EMMsgVideoBubbleView

- (instancetype)initWithDirection:(EMMessageDirection)aDirection
                             type:(EMMessageType)aType
{
    self = [super initWithDirection:aDirection type:aType];
    if (self) {
        [self _setupSubviews];
    }
    
    return self;
}

#pragma mark - Subviews

- (void)_setupSubviews
{
    self.shadowView = [[UIView alloc] init];
    self.shadowView.backgroundColor = [UIColor colorWithWhite:0.7 alpha:0.5];
    [self addSubview:self.shadowView];
    [self.shadowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    self.playImgView = [[UIImageView alloc] init];
    self.playImgView.image = [UIImage imageNamed:@"msg_video_white"];
    self.playImgView.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:self.playImgView];
    [self.playImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.width.height.equalTo(@50);
    }];
}

#pragma mark - Setter

- (void)setModel:(EMMessageModel *)model
{
    EMMessageType type = model.type;
    if (type == EMMessageTypeVideo) {
        EMVideoMessageBody *body = (EMVideoMessageBody *)model.emModel.body;
        NSString *imgPath = body.thumbnailLocalPath;
        if ([imgPath length] == 0 && model.direction == EMMessageDirectionSend) {
            imgPath = body.localPath;
        }
        [self setThumbnailImageWithLocalPath:imgPath remotePath:body.thumbnailRemotePath thumbImgSize:body.thumbnailSize imgSize:body.thumbnailSize];
    }
}

@end
