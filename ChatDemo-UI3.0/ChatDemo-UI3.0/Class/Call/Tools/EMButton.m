//
//  EMButton.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2018/9/19.
//  Copyright © 2018 XieYajie. All rights reserved.
//

#import "EMButton.h"

#import "Masonry.h"

#define EMButtonDefaultTitleColor [UIColor blackColor]

@implementation EMButtonState

@end

@interface EMButton()

@property (nonatomic, strong) UIImageView *imgView;

@property (nonatomic, strong) NSMutableDictionary *stateDict;

@end

@implementation EMButton

- (instancetype)initWithTitle:(NSString *)aTitle
                       target:(id)aTarget
                       action:(SEL)aAction
{
    self = [super init];
    if (self) {
        [self _setupSubviewsWithTitle:aTitle];
        
        [self addTarget:aTarget action:aAction forControlEvents:UIControlEventTouchUpInside];
        _stateDict = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (void)_setupSubviewsWithTitle:(NSString *)aTitle
{
    self.imgView = [[UIImageView alloc] init];
    self.imgView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:self.imgView];
    [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.height.equalTo(self).multipliedBy(0.6);
    }];
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.textColor = EMButtonDefaultTitleColor;
    self.titleLabel.font = [UIFont systemFontOfSize:13];
    self.titleLabel.text = aTitle;
    [self addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.imgView.mas_bottom);
        make.bottom.equalTo(self);
        make.left.equalTo(self);
        make.right.equalTo(self);
    }];
}

#pragma mark - Public

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    UIControlState state = UIControlStateNormal;
    if (selected) {
        state = UIControlStateSelected;
    }
    
    EMButtonState *buttonState = [self.stateDict objectForKey:@(state)];
    if (buttonState) {
        self.imgView.image = buttonState.image;
        self.titleLabel.textColor = buttonState.titleColor;
    }
}

- (void)setTitleColor:(nullable UIColor *)color
             forState:(UIControlState)state
{
    EMButtonState *buttonState = [self.stateDict objectForKey:@(state)];
    if (!buttonState) {
        buttonState = [[EMButtonState alloc] init];
        [self.stateDict setObject:buttonState forKey:@(state)];
    }
    buttonState.titleColor = color;
    
    if (self.state == state) {
        self.titleLabel.textColor = color;
    }
}

- (void)setImage:(nullable UIImage *)image
        forState:(UIControlState)state
{
    EMButtonState *buttonState = [self.stateDict objectForKey:@(state)];
    if (!buttonState) {
        buttonState = [[EMButtonState alloc] init];
        buttonState.titleColor = EMButtonDefaultTitleColor;
        [self.stateDict setObject:buttonState forKey:@(state)];
    }
    buttonState.image = image;
    
    if (self.state == state) {
        self.imgView.image = image;
    }
}

@end
