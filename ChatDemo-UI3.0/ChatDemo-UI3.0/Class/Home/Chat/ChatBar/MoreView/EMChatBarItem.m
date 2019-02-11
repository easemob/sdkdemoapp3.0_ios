//
//  EMChatBarItem.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/30.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EMChatBarItem.h"

@interface EMChatBarItem()

@property (nonatomic, strong) UILabel *label;

@end

@implementation EMChatBarItem

- (instancetype)initWithImage:(UIImage *)aImage
                        title:(NSString *)aTitle
{
    self = [super init];
    if (self) {
        _titleHeightRatio = 0.3;
        [self _setupSubviewsWithImage:aImage title:aTitle];
    }
    
    return self;
}

- (void)setTitleHeightRatio:(CGFloat)titleHeightRatio
{
    if (_titleHeightRatio != titleHeightRatio) {
        _titleHeightRatio = titleHeightRatio;
        
        [self.label mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(self).multipliedBy(titleHeightRatio);
        }];
    }
}

#pragma mark - Subviews

- (void)_setupSubviewsWithImage:(UIImage *)aImage
                          title:(NSString *)aTitle
{
    self.backgroundColor = [UIColor clearColor];
    
    UIImageView *imgView = [[UIImageView alloc] initWithImage:aImage];
    imgView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:imgView];
    [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self);
    }];
    
    self.label = [[UILabel alloc] init];
    self.label.textColor = [UIColor grayColor];
    self.label.font = [UIFont systemFontOfSize:13];
    self.label.text = aTitle;
    [self addSubview:self.label];
    [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(imgView.mas_bottom).offset(5);
        make.centerX.equalTo(self);
        make.bottom.equalTo(self);
//        make.height.equalTo(self).multipliedBy(self.titleHeightRatio);
    }];
}

@end
