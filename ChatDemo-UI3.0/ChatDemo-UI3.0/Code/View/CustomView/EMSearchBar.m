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
    NSArray<__kindof UIView *> *_subViewArray;
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
    _searchFieldWidth = 0;
    _searchFieldHeight = 0;
    self.barTintColor = [UIColor clearColor];
    _subViewArray = self.subviews;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0) {
        NSArray *subviews = [[self.subviews firstObject] subviews];
        _subViewArray = subviews;
    }
    for (UIView *subView in _subViewArray) {
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
    if (![_cancelTitle isEqualToString:title]) {
        _cancelTitle = title;
    }
    if (!self.showsCancelButton) {
        return;
    }
    for (UIView *searchbuttons in _searchTextField.subviews)
    {
        if ([searchbuttons isKindOfClass:[UIButton class]])
        {
            UIButton *cancelButton = (UIButton*)searchbuttons;
            [cancelButton setTitleColor:KermitGreenTwoColor forState:UIControlStateNormal];
            [cancelButton setTitle:title forState:UIControlStateNormal];
            break;
        }
    }
}

- (void)setShowsCancelButton:(BOOL)showsCancelButton {
    [self setShowsCancelButton:showsCancelButton animated:NO];
}

- (void)setShowsCancelButton:(BOOL)showsCancelButton animated:(BOOL)animated {
    [super setShowsCancelButton:showsCancelButton animated:animated];
    if (showsCancelButton) {
        [self setCancelButtonTitle:_cancelTitle];
        CGRect frame = _searchTextField.frame;
        frame.size.width -= kCancelBtn_Width;
        _searchTextField.frame = frame;
    }
    else {
        CGRect frame = _searchTextField.frame;
        frame.size.width += kCancelBtn_Width;
        _searchTextField.frame = frame;
    }
}

@end
