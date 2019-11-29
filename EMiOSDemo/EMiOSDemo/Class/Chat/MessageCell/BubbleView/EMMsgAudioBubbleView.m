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

@interface EMMsgAudioBubbleView()
@property (nonatomic) float maxWidth;
@end
 
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
    _maxWidth= [UIScreen mainScreen].bounds.size.width / 2 - 100;
    [self setupBubbleBackgroundImage];
    
    self.imgView = [[UIImageView alloc] init];
    self.imgView.contentMode = UIViewContentModeScaleAspectFit;
    self.imgView.clipsToBounds = YES;
    self.imgView.animationDuration = 1.0;
    [self addSubview:self.imgView];
    [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.top.equalTo(self).offset(8);
        make.width.height.equalTo(@30);
    }];
    
    self.textLabel = [[UILabel alloc] init];
    self.textLabel.font = [UIFont systemFontOfSize:14];
    self.textLabel.numberOfLines = 0;
    [self addSubview:self.textLabel];
    [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(8);
        make.bottom.equalTo(self).offset(-8);
    }];
    
    if (self.direction == EMMessageDirectionSend) {
        
        [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self).offset(-5);
        }];
        [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.imgView.mas_left).offset(-3);
            make.left.equalTo(self).offset(5);
        }];
        
        self.textLabel.textAlignment = NSTextAlignmentRight;
        
        self.imgView.image = [UIImage imageNamed:@"语音声波send"];
        self.imgView.animationImages = @[[UIImage imageNamed:@"语音声波-right-2"], [UIImage imageNamed:@"语音声波-right-1"], [UIImage imageNamed:@"语音声波send"]];
        self.textLabel.textColor = [UIColor whiteColor];
    } else {
        
        [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(5);
        }];
        [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.imgView.mas_right).offset(3);
            make.right.equalTo(self).offset(-5);
        }];
        
        self.textLabel.textAlignment = NSTextAlignmentLeft;
        
        self.imgView.image = [UIImage imageNamed:@"语音声波receive"];
        self.imgView.animationImages = @[[UIImage imageNamed:@"语音声波-left-2"], [UIImage imageNamed:@"语音声波-left-1"], [UIImage imageNamed:@"语音声波receive"]];
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
        
        float width = kEMMsgAudioMinWidth * body.duration / 10;
        if (width > _maxWidth) {
            width = _maxWidth;
        } else if (width < kEMMsgAudioMinWidth) {
            width = kEMMsgAudioMinWidth;
        }
        [self.textLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(width);
        }];
    }
}

@end
