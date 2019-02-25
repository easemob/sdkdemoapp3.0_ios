//
//  EMMsgFileBubbleView.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/2/14.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EMMsgFileBubbleView.h"

@implementation EMMsgFileBubbleView

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
    
    self.iconView = [[UIImageView alloc] init];
    self.iconView.contentMode = UIViewContentModeScaleAspectFit;
    self.iconView.clipsToBounds = YES;
    [self addSubview:self.iconView];
    
    self.textLabel = [[UILabel alloc] init];
    self.textLabel.font = [UIFont systemFontOfSize:18];
    self.textLabel.numberOfLines = 0;
    [self addSubview:self.textLabel];
    
    self.detailLabel = [[UILabel alloc] init];
    self.detailLabel.font = [UIFont systemFontOfSize:15];
    self.detailLabel.numberOfLines = 0;
    [self addSubview:self.detailLabel];
    [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.textLabel.mas_bottom);
        make.bottom.equalTo(self).offset(-10);
        make.left.equalTo(self.textLabel);
        make.right.equalTo(self.textLabel);
    }];
    
    if (self.direction == EMMessageDirectionSend) {
        self.iconView.image = [UIImage imageNamed:@"msg_file_white"];
        [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(10);
            make.left.equalTo(self).offset(5);
            make.centerY.equalTo(self);
            make.width.equalTo(@40);
        }];
        
        self.textLabel.textColor = [UIColor whiteColor];
        [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(10);
            make.left.equalTo(self.iconView.mas_right).offset(5);
            make.right.equalTo(self).offset(-15);
        }];
        
        self.detailLabel.textColor = [UIColor colorWithWhite:0.8 alpha:1.0];
    } else {
        self.iconView.image = [UIImage imageNamed:@"msg_file"];
        [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(10);
            make.left.equalTo(self).offset(8);
            make.centerY.equalTo(self);
            make.width.equalTo(@40);
        }];
        
        self.textLabel.textColor = [UIColor blackColor];
        [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(10);
            make.left.equalTo(self.iconView.mas_right).offset(5);
            make.right.equalTo(self).offset(-10);
        }];
        
        self.detailLabel.textColor = [UIColor grayColor];
    }
}

#pragma mark - Setter

- (void)setModel:(EMMessageModel *)model
{
    EMMessageType type = model.type;
    if (type == EMMessageTypeFile) {
        EMFileMessageBody *body = (EMFileMessageBody *)model.emModel.body;
        self.textLabel.text = body.displayName;
        self.detailLabel.text = [NSString stringWithFormat:@"%.2lf MB",(float)body.fileLength / (1024 * 1024)];
    }
}

@end
