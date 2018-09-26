//
//  EMCallFloatingView.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2018/9/26.
//  Copyright © 2018 XieYajie. All rights reserved.
//

#import "EMCallFloatingView.h"

@interface EMCallFloatingView()

@property (nonatomic) BOOL isOnlyVoice;

@end


@implementation EMCallFloatingView

- (instancetype)initWithIsOnlyVoice:(BOOL)aIsOnlyVoice
{
    self = [super init];
    if (self) {
        _isOnlyVoice = aIsOnlyVoice;
        
        [self _setupSubviews];
    }
    
    return self;
}

#pragma mark - Subviews

- (void)_setupSubviews
{
    if (self.isOnlyVoice) {
        [self setImage:[UIImage imageNamed:@"floating_voice"] forState:UIControlStateNormal];
    }
}

@end
