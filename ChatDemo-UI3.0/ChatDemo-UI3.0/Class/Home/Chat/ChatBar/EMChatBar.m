//
//  EMChatBar.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/25.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EMChatBar.h"

#import "EMRecordAudioViewController.h"
#import "EMChatBarCallView.h"

#define kInputViewMinHeight 40
#define kInputViewMaxHeight 120

@interface EMChatBar()<UITextViewDelegate, EMChatBarCallViewDelegate>

@property (nonatomic) CGFloat version;

@property (nonatomic) CGFloat previousTextViewContentHeight;

@property (nonatomic, strong) NSMutableArray<UIButton *> *buttonArray;
@property (nonatomic, strong) UIButton *selectedButton;

@property (nonatomic, strong) EMRecordAudioViewController *recordAudioController;

@property (nonatomic, strong) UIView *currentMoreView;
@property (nonatomic, strong) EMChatBarCallView *moreCallView;

@end

@implementation EMChatBar

- (instancetype)init
{
    self = [super init];
    if (self) {
        _version = [[[UIDevice currentDevice] systemVersion] floatValue];
        _previousTextViewContentHeight = kInputViewMinHeight;
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
    
    self.inputView = [[EMTextView alloc] init];
    self.inputView.delegate = self;
    self.inputView.placeholder = @"请输入消息内容";
    self.inputView.font = [UIFont systemFontOfSize:16];
    self.inputView.returnKeyType = UIReturnKeySend;
    self.inputView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.inputView];
    [self.inputView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(5);
        make.left.equalTo(self).offset(8);
        make.right.equalTo(self).offset(-8);
        make.height.mas_equalTo(kInputViewMinHeight);
    }];
    
    self.buttonsView = [[UIView alloc] init];
    self.buttonsView.backgroundColor = [UIColor clearColor];
    [self _setupButtonsView];
    [self addSubview:self.buttonsView];
    [self.buttonsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.inputView.mas_bottom).offset(5);
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.height.equalTo(@50);
        make.bottom.equalTo(self);
    }];
}

- (void)_setupButtonsView
{
    NSInteger count = 7;
    CGFloat width = [UIScreen mainScreen].bounds.size.width / count;
    
    self.buttonArray = [[NSMutableArray alloc] init];
    
    UIButton *audioButton = [[UIButton alloc] init];
    [audioButton setImage:[UIImage imageNamed:@"tabbar_chat_gray"] forState:UIControlStateNormal];
    [audioButton setImage:[UIImage imageNamed:@"tabbar_chat_blue"] forState:UIControlStateSelected];
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
    [emojiButton setImage:[UIImage imageNamed:@"tabbar_chat_gray"] forState:UIControlStateNormal];
    [emojiButton setImage:[UIImage imageNamed:@"tabbar_chat_blue"] forState:UIControlStateSelected];
    [emojiButton addTarget:self action:@selector(emojiButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonsView addSubview:emojiButton];
    [emojiButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.buttonsView);
        make.left.equalTo(audioButton.mas_right);
        make.bottom.equalTo(audioButton);
        make.width.mas_equalTo(width);
    }];
    [self.buttonArray addObject:emojiButton];
    
    UIButton *cameraButton = [[UIButton alloc] init];
    [cameraButton setImage:[UIImage imageNamed:@"tabbar_chat_gray"] forState:UIControlStateNormal];
    [cameraButton setImage:[UIImage imageNamed:@"tabbar_chat_blue"] forState:UIControlStateHighlighted];
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
    [photoButton setImage:[UIImage imageNamed:@"tabbar_chat_gray"] forState:UIControlStateNormal];
    [photoButton setImage:[UIImage imageNamed:@"tabbar_chat_blue"] forState:UIControlStateHighlighted];
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
    [adressButton setImage:[UIImage imageNamed:@"tabbar_chat_gray"] forState:UIControlStateNormal];
    [adressButton setImage:[UIImage imageNamed:@"tabbar_chat_blue"] forState:UIControlStateHighlighted];
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
    [callButton setImage:[UIImage imageNamed:@"tabbar_chat_gray"] forState:UIControlStateNormal];
    [callButton setImage:[UIImage imageNamed:@"tabbar_chat_blue"] forState:UIControlStateSelected];
    [callButton addTarget:self action:@selector(callButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonsView addSubview:callButton];
    [callButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.buttonsView);
        make.left.equalTo(adressButton.mas_right);
        make.bottom.equalTo(adressButton);
        make.width.mas_equalTo(width);
    }];
    [self.buttonArray addObject:callButton];
    
    UIButton *moreButton = [[UIButton alloc] init];
    [moreButton setImage:[UIImage imageNamed:@"tabbar_chat_gray"] forState:UIControlStateNormal];
    [moreButton setImage:[UIImage imageNamed:@"tabbar_chat_blue"] forState:UIControlStateSelected];
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

- (EMRecordAudioViewController *)recordAudioController
{
    if (_recordAudioController == nil) {
        _recordAudioController = [[EMRecordAudioViewController alloc] init];
    }
    
    return _recordAudioController;
}

- (EMChatBarCallView *)moreCallView
{
    if (_moreCallView == nil) {
        _moreCallView = [[EMChatBarCallView alloc] init];
        _moreCallView.delegate = self;
    }
    
    return _moreCallView;
}

#pragma mark - UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if (self.currentMoreView) {
        [self.currentMoreView removeFromSuperview];
        [self.buttonsView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self);
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
        return [self.delegate inputView:self.inputView shouldChangeTextInRange:range replacementText:text];
    } 
    
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    [self _updateInputViewHeight];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(inputViewDidChange:)]) {
        [self.delegate inputViewDidChange:self.inputView];
    }
}

#pragma mark - EMChatBarCallViewDelegate

- (void)chatBarCallViewAudioDidSelected
{
    [self callButtonAction:self.selectedButton];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatBarDidAudioCallAction)]) {
        [self.delegate chatBarDidAudioCallAction];
    }
}

- (void)chatBarCallViewVideoDidSelected
{
    [self callButtonAction:self.selectedButton];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatBarDidVideoCallAction)]) {
        [self.delegate chatBarDidVideoCallAction];
    }
}

#pragma mark - Private

- (CGFloat)_getInputViewContontHeight
{
    if (self.version >= 7.0) {
        return ceilf([self.inputView sizeThatFits:self.inputView.frame.size].height);
    } else {
        return self.inputView.contentSize.height;
    }
}

- (void)_updateInputViewHeight
{
    CGFloat height = [self _getInputViewContontHeight];
    if (height < kInputViewMinHeight) {
        height = kInputViewMinHeight;
    }
    if (height > kInputViewMaxHeight) {
        height = kInputViewMaxHeight;
    }
    
    if (height == self.previousTextViewContentHeight) {
        return;
    }
    
    self.previousTextViewContentHeight = height;
    [self.inputView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(height);
    }];
}

- (void)_remakeButtonsViewConstraints
{
    if (self.currentMoreView) {
        [self.buttonsView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.inputView.mas_bottom).offset(5);
            make.left.equalTo(self);
            make.right.equalTo(self);
            make.height.equalTo(@55);
            make.bottom.equalTo(self.currentMoreView.mas_top);
        }];
    } else {
        [self.buttonsView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.inputView.mas_bottom).offset(5);
            make.left.equalTo(self);
            make.right.equalTo(self);
            make.height.equalTo(@55);
            make.bottom.equalTo(self);
        }];
    }
}

- (void)_clearMoreViewAndSelectedButton
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

#pragma mark - Public

- (void)clearInputViewText
{
    self.inputView.text = nil;
    [self _updateInputViewHeight];
}

#pragma mark - Action

- (void)audioButtonAction:(UIButton *)aButton
{
    aButton.selected = !aButton.selected;
    if (self.currentMoreView) {
        [self.currentMoreView removeFromSuperview];
    }
    
    if (aButton.selected) {
        self.selectedButton.selected = NO;
        self.selectedButton = aButton;
    }
}

- (void)emojiButtonAction:(UIButton *)aButton
{
    aButton.selected = !aButton.selected;
    if (self.currentMoreView) {
        [self.currentMoreView removeFromSuperview];
    }
    
    if (aButton.selected) {
        self.selectedButton.selected = NO;
        self.selectedButton = aButton;
    }
}

- (void)callButtonAction:(UIButton *)aButton
{
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
        self.currentMoreView = self.moreCallView;
        [self addSubview:self.moreCallView];
        [self.moreCallView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self);
            make.right.equalTo(self);
            make.bottom.equalTo(self).offset(-10);
        }];
        [self _remakeButtonsViewConstraints];
        
        //        if (self.delegate && [self.delegate respondsToSelector:@selector(chatBarHeightDidChanged)]) {
        //            [self.delegate chatBarHeightDidChanged];
        //        }
    }
}

- (void)moreButtonAction:(UIButton *)aButton
{
    aButton.selected = !aButton.selected;
    if (self.currentMoreView) {
        [self.currentMoreView removeFromSuperview];
    }

    if (aButton.selected) {
        self.selectedButton.selected = NO;
        self.selectedButton = aButton;
    }
}

- (void)cameraButtonAction:(UIButton *)aButton
{
    [self _clearMoreViewAndSelectedButton];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatBarDidCameraAction)]) {
        [self.delegate chatBarDidCameraAction];
    }
}

- (void)photoButtonAction:(UIButton *)aButton
{
    [self _clearMoreViewAndSelectedButton];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatBarDidPhotoAction)]) {
        [self.delegate chatBarDidPhotoAction];
    }
}

- (void)addressButtonAction:(UIButton *)aButton
{
    [self _clearMoreViewAndSelectedButton];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatBarDidLocationAction)]) {
        [self.delegate chatBarDidLocationAction];
    }
}

@end
