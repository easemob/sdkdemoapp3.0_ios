//
//  EMChatBarItem.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/30.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EMChatBarItem.h"

@implementation EMChatBarItem

- (instancetype)initWithImage:(UIImage *)aImage
                        title:(NSString *)aTitle
{
    self = [super init];
    if (self) {
        [self _setupSubviewsWithImage:aImage title:aTitle];
    }
    
    return self;
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
    
    UILabel *label = [[UILabel alloc] init];
    label.textColor = [UIColor grayColor];
    label.font = [UIFont systemFontOfSize:13];
    label.text = aTitle;
    [self addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(imgView.mas_bottom);
        make.centerX.equalTo(self);
        make.bottom.equalTo(self);
        make.height.equalTo(self).multipliedBy(0.3);
    }];
}

@end
