//
//  EMSearchBar.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/16.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EMSearchBar.h"

@interface EMSearchBar()<UITextFieldDelegate>

@property (nonatomic, strong) UIButton *cancelButton;

@end

@implementation EMSearchBar

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self _setupSubviews];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidChange) name:UITextFieldTextDidChangeNotification object:nil];
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Subviews

- (void)_setupSubviews
{
    self.backgroundColor = [UIColor whiteColor];
    
    self.textField = [[UITextField alloc] init];
    self.textField.delegate = self;
    self.textField.backgroundColor = kColor_textViewGray;
    self.textField.font = [UIFont systemFontOfSize:16];
    self.textField.placeholder = @"搜索";
    self.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.textField.leftViewMode = UITextFieldViewModeAlways;
    self.textField.returnKeyType = UIReturnKeySearch;
    self.textField.layer.cornerRadius = 8;
    [self addSubview:self.textField];
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.left.equalTo(self).offset(15);
        make.right.equalTo(self).offset(-15);
        make.height.equalTo(@35);
    }];
    
    UIImageView *leftView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 15)];
    leftView.contentMode = UIViewContentModeScaleAspectFit;
    leftView.image = [UIImage imageNamed:@"search_gray"];
    self.textField.leftView = leftView;
    
    
    self.cancelButton = [[UIButton alloc] init];
    self.cancelButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [self.cancelButton setTitleColor:kColor_Blue forState:UIControlStateNormal];
    [self.cancelButton addTarget:self action:@selector(searchCancelButtonClicked) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self addSubview:self.cancelButton];
    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.right.equalTo(self).offset(-5);
        make.width.equalTo(@50);
        make.height.equalTo(self);
    }];
    
    [self.textField mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-65);
    }];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(searchBarShouldBeginEditing:)]) {
        [self.delegate searchBarShouldBeginEditing:self];
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(searchBarSearchButtonClicked:)]) {
        [self.delegate searchBarSearchButtonClicked:textField.text];
    }
    
    return YES;
}

#pragma mark - Action

- (void)textFieldTextDidChange
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(searchTextDidChangeWithString:)]) {
        [self.delegate searchTextDidChangeWithString:self.textField.text];
    }
}

- (void)searchCancelButtonClicked
{
    [self.cancelButton removeFromSuperview];
    
    [self.textField resignFirstResponder];
    self.textField.text = nil;
    [self.textField mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-15);
    }];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(searchBarCancelButtonAction:)]) {
        [self.delegate searchBarCancelButtonAction:self];
    }
}

@end
