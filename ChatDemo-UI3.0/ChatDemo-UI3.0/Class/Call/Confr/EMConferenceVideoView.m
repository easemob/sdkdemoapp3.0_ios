//
//  EMConferenceVideoView.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2018/9/20.
//  Copyright © 2018 XieYajie. All rights reserved.
//

#import "EMConferenceVideoView.h"

#import "Masonry.h"

@interface EMConferenceVideoView()

@property (nonatomic, strong) UIImageView *statusView;

@end

@implementation EMConferenceVideoView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor yellowColor];
        
        self.bgView = [[UIImageView alloc] init];
        self.bgView.contentMode = UIViewContentModeScaleAspectFit;
        self.bgView.userInteractionEnabled = YES;
        self.bgView.layer.borderWidth = 0.5;
        self.bgView.layer.borderColor = [UIColor grayColor].CGColor;
        self.bgView.image = [UIImage imageNamed:@"bg_connecting"];
        [self addSubview:self.bgView];
        [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        self.statusView = [[UIImageView alloc] init];
        self.statusView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:self.statusView];
        [self.statusView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(5);
            make.right.equalTo(self).offset(-5);
            make.width.height.equalTo(@20);
        }];
        
        self.nameLabel = [[UILabel alloc] init];
        self.nameLabel.textColor = [UIColor whiteColor];
        self.nameLabel.font = [UIFont systemFontOfSize:13];
        [self addSubview:self.nameLabel];
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(5);
            make.left.equalTo(self).offset(5);
            make.right.equalTo(self.statusView.mas_left).offset(-5);
            make.height.equalTo(@20);
        }];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapAction:)];
        [self addGestureRecognizer:tap];
        
        self.isBig = NO;
    }
    
    return self;
}

- (void)setStatus:(StreamStatus)status
{
    if (_status == status) {
        return;
    }
    
    _status = status;
    switch (_status) {
        case StreamStatusConnecting:
            self.statusView.image = [UIImage imageNamed:@"ring_gray"];
            break;
        case StreamStatusConnected:
        {
            self.statusView.image = nil;
            if (!self.enableVideo) {
                self.bgView.image = [UIImage imageNamed:@"bg_micro"];
            }
        }
            break;
        case StreamStatusTalking:
            self.statusView.image = [UIImage imageNamed:@"talking_green"];
            break;
            
        default:
            self.statusView.image = nil;
            break;
    }
}

- (void)setEnableVoice:(BOOL)enableVoice
{
    _enableVoice = enableVoice;
    if (enableVoice) {
        self.statusView.image = nil;
    } else {
        self.statusView.image = [UIImage imageNamed:@"mute_red"];
    }
}

- (void)setEnableVideo:(BOOL)enableVideo
{
    _enableVideo = enableVideo;
    if (enableVideo) {
        [self sendSubviewToBack:self.bgView];
    } else {
        if (self.status < StreamStatusConnected) {
            self.bgView.image = [UIImage imageNamed:@"bg_connecting"];
        } else {
            self.bgView.image = [UIImage imageNamed:@"bg_micro"];
        }
        [self sendSubviewToBack:self.displayView];
    }
}

#pragma mark - UITapGestureRecognizer

- (void)handleTapAction:(UITapGestureRecognizer *)aTap
{
    if (aTap.state == UIGestureRecognizerStateEnded) {
        if (!self.enableVideo) {
            return;
        }
        
        if (_delegate && [_delegate respondsToSelector:@selector(conferenceVideoViewDidTap:)]) {
            self.isBig = !self.isBig;
            [_delegate conferenceVideoViewDidTap:self];
        }
    }
}

@end


@implementation EMConferenceVideoItem

@end
