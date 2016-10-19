/************************************************************
  *  * Hyphenate CONFIDENTIAL 
  * __________________ 
  * Copyright (C) 2016 Hyphenate Inc. All rights reserved. 
  *  
  * NOTICE: All information contained herein is, and remains 
  * the property of Hyphenate Inc.
  * Dissemination of this information or reproduction of this material 
  * is strictly forbidden unless prior written permission is obtained
  * from Hyphenate Inc.
  */

#import "EMSearchBar.h"

#define kCancelBtn_Width       40

@interface EMSearchBar()
@end
@implementation EMSearchBar {
    UITextField *_searchTextField;
    NSString *_cancelTitle;
    CGFloat _cancelWidth;
    BOOL _isEnable;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initSearchBarStyle];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initSearchBarStyle];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (_searchFieldWidth > 0 && _searchFieldHeight > 0) {
        CGFloat x = (self.bounds.size.width - _searchFieldWidth) / 2;
        CGFloat y = (self.bounds.size.height - _searchFieldHeight) / 2;
        _searchTextField.frame = CGRectMake(x, y, _searchFieldWidth, _searchFieldHeight);
    }
    else {
        _searchTextField.frame = self.bounds;
    }
}

#pragma mark - setter
- (void)setCancelEnable:(BOOL)isEnable {
    _isEnable = isEnable;
}

- (BOOL)isCancelEnable {
    return _isEnable;
}

- (void)setSearchFieldWidth:(CGFloat)searchFieldWidth {
    if (_searchFieldWidth == searchFieldWidth) {
        return;
    }
    _searchFieldWidth = searchFieldWidth;
    if (_searchFieldWidth > 0) {
        CGRect frame = _searchTextField.frame;
        frame.size.width = _searchFieldWidth;
        frame.origin.x = (self.bounds.size.width - _searchFieldWidth) / 2;
        _searchTextField.frame = frame;
    }
}

- (void)setSearchFieldHeight:(CGFloat)searchFieldHeight {
    if (_searchFieldHeight == searchFieldHeight) {
        return;
    }
    _searchFieldHeight = searchFieldHeight;
    if (_searchFieldHeight > 0) {
        CGRect frame = _searchTextField.frame;
        frame.size.height = _searchFieldHeight;
        frame.origin.y = (self.bounds.size.height - _searchFieldHeight) / 2;
        _searchTextField.frame = frame;
    }
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    if (_searchTextField) {
        CGRect currentFrame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        if (_searchFieldWidth > 0) {
            currentFrame.size.width = _searchFieldWidth;
            currentFrame.origin.x = (self.bounds.size.width - _searchFieldWidth) / 2;
        }
        if (_searchFieldHeight > 0) {
            currentFrame.size.height = _searchFieldHeight;
            currentFrame.origin.y = (self.bounds.size.height - _searchFieldHeight) / 2;
        }
        _searchTextField.frame = currentFrame;
    }
}

- (void)initSearchBarStyle {
    _isEnable = YES;
    _searchFieldWidth = 0;
    _searchFieldHeight = 0;
    _cancelTitle = NSLocalizedString(@"common.cancel", @"Cancel");
    self.barTintColor = [UIColor clearColor];
    NSArray *subViewArray = self.subviews;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0) {
        NSArray *subviews = [[self.subviews firstObject] subviews];
        subViewArray = subviews;
    }
    for (UIView *subView in subViewArray) {
        if ([subView isKindOfClass:NSClassFromString(@"UISearchBarBackground")]) {
            [subView removeFromSuperview];
        }
        
        if ([subView isKindOfClass:NSClassFromString(@"UISearchBarTextField")]) {
            _searchTextField = (UITextField *)subView;
            [_searchTextField setBorderStyle:UITextBorderStyleNone];
            _searchTextField.background = nil;
            _searchTextField.layer.cornerRadius = 3;
            _searchTextField.clipsToBounds = YES;
            _searchTextField.backgroundColor = PaleGrayColor;
            
            _searchTextField.placeholder = NSLocalizedString(@"common.search", @"Search");
            
            [_searchTextField setValue:CoolGrayColor  forKeyPath:@"_placeholderLabel.textColor"];
            [_searchTextField setValue:[UIFont systemFontOfSize:13]  forKeyPath:@"_placeholderLabel.font"];
            
            UIImageView *leftImage = [[UIImageView alloc] initWithFrame:_searchTextField.leftView.frame];
            leftImage.contentMode = UIViewContentModeScaleAspectFit;
            leftImage.image = [UIImage imageNamed:@"Icon_Search"];
            _searchTextField.leftView = leftImage;
            _searchTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        }
    }
}

- (void)setCancelButtonTitle:(NSString *)title
{
    if (!_isEnable) {
        return;
    }
    if (![_cancelTitle isEqualToString:title]) {
        _cancelTitle = title;
    }
    if (!self.showsCancelButton) {
        return;
    }
    
    NSArray *subArray = self.subviews;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0) {
        NSArray *subviews = [[self.subviews firstObject] subviews];
        subArray = subviews;
    }
    UIButton *_cancelButton;
    for (UIView *subView in subArray)
    {
        if ([subView isKindOfClass:NSClassFromString(@"UINavigationButton")])
        {
            _cancelButton = (UIButton*)subView;
            break;
        }
    }
    [_cancelButton setTitleColor:CoolGrayColor forState:UIControlStateNormal];
    [_cancelButton setTitleColor:CoolGrayColor forState:UIControlStateHighlighted];
    [_cancelButton setTitleColor:CoolGrayColor forState:UIControlStateSelected];
    [_cancelButton setTitle:_cancelTitle forState:UIControlStateNormal];
    [_cancelButton setTintColor:CoolGrayColor];
    _cancelButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    _cancelButton.titleLabel.font = [UIFont systemFontOfSize:13];
    CGRect frame = _cancelButton.frame;
    frame.size.width += 2 * 15;
    frame.origin.x -= 2 * 15;
    _cancelButton.frame = frame;
    _cancelWidth = _cancelButton.bounds.size.width;
}

#pragma mark - rideover

- (void)setShowsCancelButton:(BOOL)showsCancelButton {
    [self setShowsCancelButton:showsCancelButton animated:NO];
}

- (void)setShowsCancelButton:(BOOL)showsCancelButton animated:(BOOL)animated {
    [super setShowsCancelButton:showsCancelButton animated:animated];

    if (showsCancelButton) {
        [self setCancelButtonTitle:_cancelTitle];
        CGRect frame = _searchTextField.frame;
        frame.size.width -= _cancelWidth;
        _searchTextField.frame = frame;
    }
    else {
        CGRect frame = _searchTextField.frame;
        frame.size.width += _cancelWidth;
        _searchTextField.frame = frame;
    }
}

@end
