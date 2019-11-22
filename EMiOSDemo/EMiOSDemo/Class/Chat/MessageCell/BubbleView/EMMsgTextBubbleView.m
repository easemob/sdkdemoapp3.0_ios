//
//  EMMsgTextBubbleView.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/2/14.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EMMsgTextBubbleView.h"

@implementation EMMsgTextBubbleView
{
    NSString *callType;
    NSString *conversationId;
}
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
    
    self.textLabel = [[UILabel alloc] init];
    self.textLabel.font = [UIFont systemFontOfSize:16];
    self.textLabel.numberOfLines = 0;
    [self addSubview:self.textLabel];
    [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(10);
        make.bottom.equalTo(self.mas_bottom).offset(-10);
    }];
    
    self.textImgBtn = [[UIButton alloc]init];
    [self addSubview:self.textImgBtn];
    [self.textImgBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@25);
        make.centerY.equalTo(self);
    }];
    
}

#pragma mark - Setter

- (void)setModel:(EMMessageModel *)model
{
    EMTextMessageBody *body = (EMTextMessageBody *)model.emModel.body;
    self.textLabel.text = [EMEmojiHelper convertEmoji:body.text];
    conversationId = model.emModel.conversationId;
    
    if ([model.emModel.ext objectForKey:EMCOMMUNICATE_TYPE]) {
        self.textImgBtn.hidden = NO;
        if (self.direction == EMMessageDirectionSend) {
            
            [self.textImgBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self).offset(-15);
            }];
            
            self.textLabel.textColor = [UIColor whiteColor];
            [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self.textImgBtn.mas_left).offset(-5);
                make.left.equalTo(self).offset(10);
            }];
            
        } else {
            [self.textImgBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self).offset(15);
            }];
            
            self.textLabel.textColor = [UIColor blackColor];
            [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.textImgBtn.mas_right).offset(5);
                make.right.equalTo(self).offset(-10);
            }];
            
        }
        if ([[model.emModel.ext objectForKey:EMCOMMUNICATE_TYPE] isEqualToString:EMCOMMUNICATE_TYPE_VOICE]) {
            callType = EMCOMMUNICATE_TYPE_VOICE;
            [self.textImgBtn mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.equalTo(@10);
            }];
            [self.textImgBtn setImage:[UIImage imageNamed:@"语音通话"] forState:UIControlStateNormal];
        } else if ([[model.emModel.ext objectForKey:EMCOMMUNICATE_TYPE] isEqualToString:EMCOMMUNICATE_TYPE_VIDEO]) {
            callType = EMCOMMUNICATE_TYPE_VIDEO;
            [self.textImgBtn mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.equalTo(@35);
            }];
            if (self.direction == EMMessageDirectionSend) { 
                [self.textImgBtn setImage:[UIImage imageNamed:@"video-me"] forState:UIControlStateNormal];
            } else {
                [self.textImgBtn setImage:[UIImage imageNamed:@"video-opposite"] forState:UIControlStateNormal];
            }
        }
        [self.textImgBtn addTarget:self action:@selector(communicate) forControlEvents:UIControlEventTouchUpInside];
    } else {
        self.textImgBtn.hidden = YES;
        if (self.direction == EMMessageDirectionSend) {
            self.textLabel.textColor = [UIColor whiteColor];
            [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self).offset(10);
                make.right.equalTo(self).offset(-15);
            }];
        } else {
            self.textLabel.textColor = [UIColor blackColor];
            [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self).offset(-10);
                make.left.equalTo(self).offset(15);
            }];
        }
    }
}

- (void)communicate
{
    if ([callType isEqualToString:EMCOMMUNICATE_TYPE_VOICE]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:CALL_MAKE1V1 object:@{CALL_CHATTER:conversationId, CALL_TYPE:@(EMCallTypeVoice)}];
    } else if ([callType isEqualToString:EMCOMMUNICATE_TYPE_VIDEO]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:CALL_MAKE1V1 object:@{CALL_CHATTER:conversationId,   CALL_TYPE:@(EMCallTypeVideo)}];
    }
   
}

@end
