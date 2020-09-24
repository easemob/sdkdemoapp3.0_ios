//
//  EMMsgPicMixTextBubbleView.m
//  EaseIM
//
//  Created by 娜塔莎 on 2019/11/22.
//  Copyright © 2019 娜塔莎. All rights reserved.
//

#import "EMMsgPicMixTextBubbleView.h"

@implementation EMMsgPicMixTextBubbleView
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
        make.centerY.equalTo(self.mas_centerY);
    }];
    
}

#pragma mark - Setter

- (void)setModel:(EMMessageModel *)model
{
    EMTextMessageBody *body = (EMTextMessageBody *)model.emModel.body;
    if ([body.text isEqualToString:EMCOMMUNICATE_CALLER_MISSEDCALL]) {
        if ([model.emModel.from isEqualToString:[EMClient sharedClient].currentUsername])
            self.textLabel.text = @"已取消";
        else self.textLabel.text = @"未接听，点击回拨";
    } else if ([body.text isEqualToString:EMCOMMUNICATE_CALLED_MISSEDCALL]) {
        if ([model.emModel.from isEqualToString:[EMClient sharedClient].currentUsername])
            self.textLabel.text = @"对方拒绝通话";
        else self.textLabel.text = @"对方已取消";
    } else
        self.textLabel.text = body.text;
    
    conversationId = model.emModel.conversationId;
    
    if (self.direction == EMMessageDirectionSend) {
        
        [self.textImgBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.mas_right).offset(-15);
        }];
        
        self.textLabel.textColor = [UIColor whiteColor];
        [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.textImgBtn.mas_left).offset(-5);
            make.left.equalTo(self.mas_left).offset(10);
        }];
        
    } else {
        [self.textImgBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left).offset(15);
        }];
        
        self.textLabel.textColor = [UIColor blackColor];
        [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.textImgBtn.mas_right).offset(5);
            make.right.equalTo(self.mas_right).offset(-10);
        }];
        
    }
    if ([[model.emModel.ext objectForKey:EMCOMMUNICATE_TYPE] isEqualToString:EMCOMMUNICATE_TYPE_VOICE]) {
        callType = EMCOMMUNICATE_TYPE_VOICE;
        [self.textImgBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@10);
        }];
        [self.textImgBtn setImage:[UIImage imageNamed:@"voice"] forState:UIControlStateNormal];
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
}

@end
