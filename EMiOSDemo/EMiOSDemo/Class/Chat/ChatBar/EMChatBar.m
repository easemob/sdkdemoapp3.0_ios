//
//  EMChatBar.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/25.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EMChatBar.h"

#define ktextViewMinHeight 40
#define ktextViewMaxHeight 120

@interface EMChatBar()<UITextViewDelegate>

@property (nonatomic) CGFloat version;

@property (nonatomic) CGFloat previousTextViewContentHeight;

@property (nonatomic, strong) UIButton *selectedButton;

@property (nonatomic, strong) UIView *currentMoreView;

@end

@implementation EMChatBar

- (instancetype)init
{
    self = [super init];
    if (self) {
        _version = [[[UIDevice currentDevice] systemVersion] floatValue];
        _previousTextViewContentHeight = ktextViewMinHeight;
        [self _setupSubviews];
    }
    
    return self;
}

#pragma mark - Subviews

- (void)_setupSubviews
{
    self.backgroundColor = [UIColor whiteColor];
    
    UIView *line = [[UIView alloc] init];
    line.backgroundColor = kColor_Gray;
    [self addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.height.equalTo(@1);
    }];
    
    self.textView = [[EMTextView alloc] init];
    self.textView.delegate = self;
    self.textView.placeholder = @"请输入消息内容";
    self.textView.font = [UIFont systemFontOfSize:16];
    self.textView.returnKeyType = UIReturnKeySend;
    self.textView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.textView];
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(5);
        make.left.equalTo(self).offset(8);
        make.right.equalTo(self).offset(-8);
        make.height.mas_equalTo(ktextViewMinHeight);
    }];
    
    self.buttonsView = [[UIView alloc] init];
    self.buttonsView.backgroundColor = [UIColor clearColor];
    [self _setupButtonsView];
    [self addSubview:self.buttonsView];
    [self.buttonsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.textView.mas_bottom).offset(5);
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.height.equalTo(@50);
        make.bottom.equalTo(self).offset(-EMVIEWBOTTOMMARGIN);
    }];
}

- (void)_setupButtonsView
{
    NSInteger count = 7;
    //NSInteger count = 6;
    CGFloat width = [UIScreen mainScreen].bounds.size.width / count;
    
    self.buttonArray = [[NSMutableArray alloc] init];
    
    UIButton *audioButton = [[UIButton alloc] init];
    [audioButton setImage:[UIImage imageNamed:@"chatbar_audio"] forState:UIControlStateNormal];
    [audioButton setImage:[UIImage imageNamed:@"chatbar_audio_blue"] forState:UIControlStateSelected];
    [audioButton addTarget:self action:@selector(audioButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonsView addSubview:audioButton];
    [audioButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.buttonsView);
        make.left.equalTo(self.buttonsView);
        make.bottom.equalTo(self.buttonsView);
        make.width.mas_equalTo(width);
    }];
    [self.buttonArray addObject:audioButton];
    
    UIButton *emojiButton = [[UIButton alloc] init];
    [emojiButton setImage:[UIImage imageNamed:@"chatbar_face"] forState:UIControlStateNormal];
    [emojiButton setImage:[UIImage imageNamed:@"chatbar_face_blue"] forState:UIControlStateSelected];
    [emojiButton addTarget:self action:@selector(emoticonButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonsView addSubview:emojiButton];
    [emojiButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.buttonsView);
        make.left.equalTo(audioButton.mas_right);
        make.bottom.equalTo(audioButton);
        make.width.mas_equalTo(width);
    }];
    [self.buttonArray addObject:emojiButton];
    
    UIButton *cameraButton = [[UIButton alloc] init];
    [cameraButton setImage:[UIImage imageNamed:@"chatbar_camera"] forState:UIControlStateNormal];
    [cameraButton setImage:[UIImage imageNamed:@"chatbar_camera_blue"] forState:UIControlStateHighlighted];
    [cameraButton addTarget:self action:@selector(cameraButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonsView addSubview:cameraButton];
    [cameraButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.buttonsView);
        make.left.equalTo(emojiButton.mas_right);
        make.bottom.equalTo(emojiButton);
        make.width.mas_equalTo(width);
    }];
    [self.buttonArray addObject:cameraButton];
    
    UIButton *photoButton = [[UIButton alloc] init];
    [photoButton setImage:[UIImage imageNamed:@"chatbar_photo"] forState:UIControlStateNormal];
    [photoButton setImage:[UIImage imageNamed:@"chatbar_photo_blue"] forState:UIControlStateHighlighted];
    [photoButton addTarget:self action:@selector(photoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonsView addSubview:photoButton];
    [photoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.buttonsView);
        make.left.equalTo(cameraButton.mas_right);
        make.bottom.equalTo(cameraButton);
        make.width.mas_equalTo(width);
    }];
    [self.buttonArray addObject:photoButton];
    
    UIButton *adressButton = [[UIButton alloc] init];
    [adressButton setImage:[UIImage imageNamed:@"chatbar_map"] forState:UIControlStateNormal];
    [adressButton setImage:[UIImage imageNamed:@"chatbar_map_blue"] forState:UIControlStateHighlighted];
    [adressButton addTarget:self action:@selector(addressButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonsView addSubview:adressButton];
    [adressButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.buttonsView);
        make.left.equalTo(photoButton.mas_right);
        make.bottom.equalTo(photoButton);
        make.width.mas_equalTo(width);
    }];
    [self.buttonArray addObject:adressButton];
    
    UIButton *callButton = [[UIButton alloc] init];
    [callButton setImage:[UIImage imageNamed:@"chatbar_call"] forState:UIControlStateNormal];
    [callButton setImage:[UIImage imageNamed:@"chatbar_call_blue"] forState:UIControlStateSelected];
    [callButton addTarget:self action:@selector(callButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonsView addSubview:callButton];
    [callButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.buttonsView);
        make.left.equalTo(adressButton.mas_right);
        make.bottom.equalTo(adressButton);
        make.width.mas_equalTo(width);
        //make.right.equalTo(self.buttonsView);
    }];
    [self.buttonArray addObject:callButton];
    
    UIButton *moreButton = [[UIButton alloc] init];
    [moreButton setImage:[UIImage imageNamed:@"chatbar_extend"] forState:UIControlStateNormal];
    [moreButton setImage:[UIImage imageNamed:@"chatbar_extend_blue"] forState:UIControlStateSelected];
    [moreButton addTarget:self action:@selector(moreButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonsView addSubview:moreButton];
    [moreButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.buttonsView);
        make.left.equalTo(callButton.mas_right);
        make.bottom.equalTo(callButton);
        make.right.equalTo(self.buttonsView);
    }];
    [self.buttonArray addObject:moreButton];
}

#pragma mark - UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if (self.currentMoreView) {
        [self.currentMoreView removeFromSuperview];
        [self.buttonsView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self).offset(-EMVIEWBOTTOMMARGIN);
        }];
    }
    
    for (UIButton *button in self.buttonArray) {
        if (button.isSelected) {
            button.selected = NO;
            break;
        }
    }
    
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(inputView:shouldChangeTextInRange:replacementText:)]) {
        return [self.delegate inputView:self.textView shouldChangeTextInRange:range replacementText:text];
    } 
    
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    [self _updatetextViewHeight];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(inputViewDidChange:)]) {
        [self.delegate inputViewDidChange:self.textView];
    }
}

#pragma mark - Private

- (CGFloat)_gettextViewContontHeight
{
    if (self.version >= 7.0) {
        return ceilf([self.textView sizeThatFits:self.textView.frame.size].height);
    } else {
        return self.textView.contentSize.height;
    }
}

- (void)_updatetextViewHeight
{
    CGFloat height = [self _gettextViewContontHeight];
    if (height < ktextViewMinHeight) {
        height = ktextViewMinHeight;
    }
    if (height > ktextViewMaxHeight) {
        height = ktextViewMaxHeight;
    }
    
    if (height == self.previousTextViewContentHeight) {
        return;
    }
    
    self.previousTextViewContentHeight = height;
    [self.textView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(height);
    }];
}

- (void)_remakeButtonsViewConstraints
{
    if (self.currentMoreView) {
        [self.buttonsView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.textView.mas_bottom).offset(5);
            make.left.equalTo(self);
            make.right.equalTo(self);
            make.height.equalTo(@55);
            make.bottom.equalTo(self.currentMoreView.mas_top);
        }];
    } else {
        [self.buttonsView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.textView.mas_bottom).offset(5);
            make.left.equalTo(self);
            make.right.equalTo(self);
            make.height.equalTo(@55);
            make.bottom.equalTo(self).offset(-EMVIEWBOTTOMMARGIN);
        }];
    }
}

#pragma mark - Public

- (void)clearInputViewText
{
    self.textView.text = @"";
    [self _updatetextViewHeight];
}

- (void)inputViewAppendText:(NSString *)aText
{
    if ([aText length] > 0) {
        self.textView.text = [NSString stringWithFormat:@"%@%@", self.textView.text, aText];
        [self _updatetextViewHeight];
    }
}

- (void)clearMoreViewAndSelectedButton
{
    if (self.currentMoreView) {
        [self.currentMoreView removeFromSuperview];
        self.currentMoreView = nil;
        [self _remakeButtonsViewConstraints];
    }
    
    if (self.selectedButton) {
        self.selectedButton.selected = NO;
        self.selectedButton = nil;
    }
}

#pragma mark - Action

- (void)_buttonAction:(UIButton *)aButton
{
    [self.textView resignFirstResponder];
    
    aButton.selected = !aButton.selected;
    if (self.currentMoreView) {
        [self.currentMoreView removeFromSuperview];
        self.currentMoreView = nil;
        [self _remakeButtonsViewConstraints];
    }
    
    if (self.selectedButton != aButton) {
        self.selectedButton.selected = NO;
        self.selectedButton = nil;
        self.selectedButton = aButton;
    } else {
        self.selectedButton = nil;
    }
    
    if (aButton.selected) {
        self.selectedButton = aButton;
    }
}

- (void)audioButtonAction:(UIButton *)aButton
{
    [self _buttonAction:aButton];
    if (aButton.selected) {
        if (self.recordAudioView) {
            self.currentMoreView = self.recordAudioView;
            [self addSubview:self.recordAudioView];
            [self.recordAudioView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self);
                make.right.equalTo(self);
                make.bottom.equalTo(self).offset(-EMVIEWBOTTOMMARGIN);
            }];
            [self _remakeButtonsViewConstraints];
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(chatBarDidShowMoreViewAction)]) {
                [self.delegate chatBarDidShowMoreViewAction];
            }
        }
    }
}

- (void)emoticonButtonAction:(UIButton *)aButton
{
    [self _buttonAction:aButton];
    if (aButton.selected) {
        if (self.moreEmoticonView) {
            self.currentMoreView = self.moreEmoticonView;
            [self addSubview:self.moreEmoticonView];
            [self.moreEmoticonView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self);
                make.right.equalTo(self);
                make.bottom.equalTo(self).offset(-EMVIEWBOTTOMMARGIN);
                make.height.mas_equalTo(self.moreEmoticonView.viewHeight);
            }];
            [self _remakeButtonsViewConstraints];
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(chatBarDidShowMoreViewAction)]) {
                [self.delegate chatBarDidShowMoreViewAction];
            }
        }
    }
}
//更多
- (void)moreButtonAction:(UIButton *)aButton
{
    [self _buttonAction:aButton];
    if (aButton.selected){
        if(self.moreFunctionView) {
            self.currentMoreView = self.moreFunctionView;
            [self addSubview:self.moreFunctionView];
            [self.moreFunctionView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self);
                make.right.equalTo(self);
                make.bottom.equalTo(self).offset(-EMVIEWBOTTOMMARGIN);
                make.height.mas_equalTo(@150);
            }];
            [self _remakeButtonsViewConstraints];
            if (self.delegate && [self.delegate respondsToSelector:@selector(chatBarDidShowMoreViewAction)]) {
                [self.delegate chatBarDidShowMoreViewAction];
            }
        }
    }
}

- (void)callButtonAction:(UIButton *)aButton
{
    [self clearMoreViewAndSelectedButton];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatBarDidCallAction)]) {
        [self.delegate chatBarDidCallAction];
    }
}

- (void)cameraButtonAction:(UIButton *)aButton
{
    [self clearMoreViewAndSelectedButton];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatBarDidCameraAction)]) {
        [self.delegate chatBarDidCameraAction];
    }
}

- (void)photoButtonAction:(UIButton *)aButton
{
    [self clearMoreViewAndSelectedButton];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatBarDidPhotoAction)]) {
        [self.delegate chatBarDidPhotoAction];
    }
}

- (void)addressButtonAction:(UIButton *)aButton
{
    [self clearMoreViewAndSelectedButton];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatBarDidLocationAction)]) {
        [self.delegate chatBarDidLocationAction];
    }
}

@end
