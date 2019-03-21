//
//  EMMsgAudioBubbleView.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/2/14.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EMMsgAudioBubbleView.h"

#define kEMMsgAudioMinWidth 30
#define kEMMsgAudioMaxWidth 120

@implementation EMMsgAudioBubbleView

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
    [self setupBubbleBackgroundImage];
    
    self.imgView = [[UIImageView alloc] init];
    self.imgView.contentMode = UIViewContentModeScaleAspectFit;
    self.imgView.clipsToBounds = YES;
    [self addSubview:self.imgView];
    self.imgView.animationDuration = 1.0;
    [self addSubview:self.imgView];
    [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.top.equalTo(self).offset(10);
        make.right.equalTo(self).offset(-10);
        make.width.height.equalTo(@30);
    }];
    
    self.textLabel = [[UILabel alloc] init];
    self.textLabel.font = [UIFont systemFontOfSize:18];
    self.textLabel.numberOfLines = 0;
    [self addSubview:self.textLabel];
    [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(10);
        make.left.equalTo(self).offset(10);
        make.right.equalTo(self.imgView.mas_left).offset(-10);
        make.bottom.equalTo(self).offset(-10);
    }];
    
    if (self.direction == EMMessageDirectionSend) {
        self.imgView.image = [UIImage imageNamed:@"msg_send_audio"];
        self.imgView.animationImages = @[[UIImage imageNamed:@"msg_send_audio01"], [UIImage imageNamed:@"msg_send_audio02"], [UIImage imageNamed:@"msg_send_audio"]];
        self.textLabel.textColor = [UIColor whiteColor];
    } else {
        self.imgView.image = [UIImage imageNamed:@"msg_recv_audio"];
        self.imgView.animationImages = @[[UIImage imageNamed:@"msg_recv_audio01"], [UIImage imageNamed:@"msg_recv_audio02"], [UIImage imageNamed:@"msg_recv_audio"]];
        self.textLabel.textColor = [UIColor blackColor];
    }
}

#pragma mark - Setter

- (void)setModel:(EMMessageModel *)model
{
    EMMessageType type = model.type;
    if (type == EMMessageTypeVoice) {
        EMVoiceMessageBody *body = (EMVoiceMessageBody *)model.emModel.body;
        self.textLabel.text = [NSString stringWithFormat:@"%d\"",(int)body.duration];
        if (model.isPlaying) {
            [self.imgView startAnimating];
        } else {
            [self.imgView stopAnimating];
        }
        
        CGFloat width = kEMMsgAudioMinWidth * body.duration / 10;
        if (width > kEMMsgAudioMaxWidth) {
            width = kEMMsgAudioMaxWidth;
        } else if (width < kEMMsgAudioMinWidth) {
            width = kEMMsgAudioMinWidth;
        }
        [self.textLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(width);
        }];
    }
}

@end
