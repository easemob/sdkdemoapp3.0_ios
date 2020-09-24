//
//  EMChatBar.m
//  ChatDemo-UI3.0
//
//  Updated by zhangchong on 2020/06/05.
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

@property (nonatomic, strong) UIButton *ConversationToolBarBtn;//更多

@property (nonatomic, strong) UIButton *emojiButton;//表情

@property (nonatomic, strong) UIButton *audioButton;//语音

@property (nonatomic, strong) UIView *bottomLine;//下划线

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
    
    self.audioButton = [[UIButton alloc] init];
    [_audioButton setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"audio-unSelected" ofType:@"png"]] forState:UIControlStateNormal];
    [_audioButton setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"character" ofType:@"png"]] forState:UIControlStateSelected];
    [_audioButton addTarget:self action:@selector(audioButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.audioButton];
    [_audioButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(10);
        make.left.equalTo(self).offset(2);
        make.width.height.equalTo(@30);
    }];
    
    self.textView = [[EMTextView alloc] init];
    
    self.textView.delegate = self;
    self.textView.font = [UIFont systemFontOfSize:16];
    self.textView.textAlignment = NSTextAlignmentLeft;
    self.textView.textContainerInset = UIEdgeInsetsMake(10, 10, 12, 0);
    if (@available(iOS 11.1, *)) {
        self.textView.verticalScrollIndicatorInsets = UIEdgeInsetsMake(12, 20, 2, 0);
    } else {
        // Fallback on earlier versions
    }
    self.textView.returnKeyType = UIReturnKeyDone;
    self.textView.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0];
    self.textView.layer.cornerRadius = 20;
    [self addSubview:self.textView];
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(5);
        make.left.equalTo(self.audioButton.mas_right).offset(2);
        make.right.equalTo(self).offset(-65);
        make.height.mas_equalTo(ktextViewMinHeight);
    }];
    
    self.emojiButton = [[UIButton alloc] init];
    [_emojiButton setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"face" ofType:@"png"]] forState:UIControlStateNormal];
    [_emojiButton setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"face" ofType:@"png"]] forState:UIControlStateSelected];
    [_emojiButton addTarget:self action:@selector(emoticonButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_emojiButton];
    [_emojiButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(10);
        make.left.equalTo(self.textView.mas_right).offset(2);
        make.width.height.equalTo(@30);
    }];
    
    self.ConversationToolBarBtn = [[UIButton alloc] init];
    [_ConversationToolBarBtn setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"more-unselected" ofType:@"png"]] forState:UIControlStateNormal];
    [_ConversationToolBarBtn setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"more-selected" ofType:@"png"]] forState:UIControlStateSelected];
    [_ConversationToolBarBtn addTarget:self action:@selector(moreButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_ConversationToolBarBtn];
    [_ConversationToolBarBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(10);
        make.left.equalTo(_emojiButton.mas_right).offset(2);
        make.width.height.equalTo(@30);
    }];
    
    self.sendBtn = [[UIButton alloc]init];
    self.sendBtn.tag = 0;
    [self.sendBtn setTitle:@"发送" forState:UIControlStateNormal];
    self.sendBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.sendBtn.layer.cornerRadius = 3;
    [self addSubview:self.sendBtn];
    [self.sendBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(10);
        make.left.equalTo(_emojiButton.mas_right).offset(6);
        make.right.equalTo(self).offset(-10);
        make.height.mas_equalTo(@30);
    }];
    self.sendBtn.hidden = YES;
    
    self.bottomLine = [[UIView alloc] init];
    _bottomLine.backgroundColor = kColor_Gray;
    [self addSubview:self.bottomLine];
    [_bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.textView.mas_bottom).offset(5);
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.height.equalTo(@1);
        make.bottom.equalTo(self).offset(-EMVIEWBOTTOMMARGIN);
    }];
    self.currentMoreView.backgroundColor = [UIColor colorWithRed:248/255.0 green:248/255.0 blue:248/255.0 alpha:1.0];

}

- (void)textChangedExt
{
    if (self.textView.text.length > 0 && ![self.textView.text isEqualToString:@""]) {
        self.ConversationToolBarBtn.hidden = YES;
        self.sendBtn.hidden = NO;
        self.sendBtn.backgroundColor = [UIColor colorWithRed:4/255.0 green:174/255.0 blue:240/255.0 alpha:1.0];
        self.sendBtn.tag = 1;
        [self.textView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self).offset(-90);
        }];
    } else {
        self.sendBtn.backgroundColor = [UIColor lightGrayColor];
        self.sendBtn.tag = 0;
        self.sendBtn.hidden = YES;
        self.ConversationToolBarBtn.hidden = NO;
        [self.textView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self).offset(-65);
        }];
    }
}

#pragma mark - UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if (self.currentMoreView) {
        [self.currentMoreView removeFromSuperview];
        [self.bottomLine mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self).offset(-EMVIEWBOTTOMMARGIN);
        }];
    }
    
    self.emojiButton.selected = NO;
    self.ConversationToolBarBtn.selected = NO;
    self.audioButton.selected = NO;
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSLog(@"\n%@   %@",text,self.textView.text);
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(inputView:shouldChangeTextInRange:replacementText:)]) {
        return [self.delegate inputView:self.textView shouldChangeTextInRange:range replacementText:text];
    } 
    
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    [self textChangedExt];
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
        [self.bottomLine mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.textView.mas_bottom).offset(5);
            make.left.equalTo(self);
            make.right.equalTo(self);
            make.height.equalTo(@1);
            make.bottom.equalTo(self.currentMoreView.mas_top);
        }];
    } else {
        [self.bottomLine mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.textView.mas_bottom).offset(5);
            make.left.equalTo(self);
            make.right.equalTo(self);
            make.height.equalTo(@1);
            make.bottom.equalTo(self).offset(-EMVIEWBOTTOMMARGIN);
        }];
    }
}

#pragma mark - Public

- (void)clearInputViewText
{
    self.textView.text = @"";
    self.sendBtn.hidden = YES;
    self.ConversationToolBarBtn.hidden = NO;
    [self.textView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-65);
    }];
    [self textChangedExt];
    [self _updatetextViewHeight];
}

- (void)inputViewAppendText:(NSString *)aText
{
    if ([aText length] > 0) {
        self.textView.text = [NSString stringWithFormat:@"%@%@", self.textView.text, aText];
        [self textChangedExt];
        [self _updatetextViewHeight];
    }
}

- (void)deleteTailText
{
    if ([self.textView.text length] > 0) {
        NSRange range = [self.textView.text rangeOfComposedCharacterSequenceAtIndex:self.textView.text.length-1];
        self.textView.text = [self.textView.text substringToIndex:range.location];
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

//语音
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

//表情
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

@end
