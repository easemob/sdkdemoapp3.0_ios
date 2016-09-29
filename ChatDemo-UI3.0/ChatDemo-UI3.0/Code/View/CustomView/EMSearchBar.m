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
#import "EMColorUtils.h"

@interface EMSearchBar()<UISearchBarDelegate>

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
        self.barTintColor = [UIColor clearColor];
        self.delegate = self;
        _subViewArray = self.subviews;
        if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0) {
            _subViewArray = [[self.subviews firstObject] subviews];
        }
        for (UIView *subView in _subViewArray) {
            if ([subView isKindOfClass:NSClassFromString(@"UISearchBarBackground")]) {
                [subView removeFromSuperview];
            }
            
            //只有设置barTintColor，才能获取到UISearchBarTextField
            if ([subView isKindOfClass:NSClassFromString(@"UISearchBarTextField")]) {
                _searchTextField = (UITextField *)subView;
                [_searchTextField setBorderStyle:UITextBorderStyleNone];
                _searchTextField.background = nil;
                _searchTextField.layer.cornerRadius = 3;
                _searchTextField.clipsToBounds = YES;
                _searchTextField.backgroundColor = PaleGrayColor;
                //设置placeholder
                _searchTextField.placeholder = NSLocalizedString(@"Search", @"Search");
                //只有placeholder有值且非空字符串，才能设置生效
                [_searchTextField setValue:CoolGrayColor  forKeyPath:@"_placeholderLabel.textColor"];
                [_searchTextField setValue:[UIFont systemFontOfSize:13]  forKeyPath:@"_placeholderLabel.font"];
                //修改leftView
                UIImageView *leftImage = [[UIImageView alloc] initWithFrame:_searchTextField.leftView.frame];
                leftImage.contentMode = UIViewContentModeScaleAspectFit;
                leftImage.image = [UIImage imageNamed:@"searchIcon"];
                _searchTextField.leftView = leftImage;
                
            }
        }
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat textFieldWidth = self.bounds.size.width < 313.0 ? (self.bounds.size.width - 2 * 8) : 313.0;
    _searchTextField.frame = CGRectMake((self.bounds.size.width - textFieldWidth) / 2, (self.bounds.size.height - 30) / 2, textFieldWidth, 30);
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    NSLog(@"--- %@",keyPath);
}

/**
 *  自定义控件自带的取消按钮的文字（默认为“取消”/“Cancel”）
 *
 *  @param title 自定义文字
 */
- (void)setCancelButtonTitle:(NSString *)title
{
    _cancelTitle = title;
    if (!self.showsCancelButton) {
        return;
    }
    for (UIView *searchbuttons in _subViewArray)
    {
        if ([searchbuttons isKindOfClass:[UIButton class]])
        {
            UIButton *cancelButton = (UIButton*)searchbuttons;
            [cancelButton setTitle:title forState:UIControlStateNormal];
            break;
        }
    }
}

#pragma mark - UISearchBarDelegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
    CGRect frame = _searchTextField.frame;
    frame.size.width -= 80;
    _searchTextField.frame = frame;
    return YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO animated:NO];
    [searchBar resignFirstResponder];
//    CGRect frame = _searchTextField.frame;
//    frame.size.width += 80;
//    _searchTextField.frame = frame;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    
//    CGRect frame = _searchTextField.frame;
//    frame.size.width += 80;
//    _searchTextField.frame = frame;
    [searchBar setShowsCancelButton:NO animated:NO];
    [searchBar resignFirstResponder];
}

@end
