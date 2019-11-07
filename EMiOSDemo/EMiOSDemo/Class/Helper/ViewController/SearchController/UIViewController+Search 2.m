//
//  UIViewController+Search.m
//  DXStudio
//
//  Created by XieYajie on 22/09/2017.
//  Copyright © 2017 dxstudio. All rights reserved.
//

#import "UIViewController+Search.h"
#import <objc/runtime.h>

static const void *SearchButtonKey = &SearchButtonKey;
static const void *ResultControllerKey = &ResultControllerKey;
static const void *ResultNavigationControllerKey = &ResultNavigationControllerKey;

@implementation UIViewController (Search)

@dynamic searchButton;
@dynamic resultController;
@dynamic resultNavigationController;

#pragma mark - getter & setter

- (UIButton *)searchButton
{
    return objc_getAssociatedObject(self, SearchButtonKey);
}

- (void)setSearchButton:(UIButton *)searchButton
{
    objc_setAssociatedObject(self, SearchButtonKey, searchButton, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (EMSearchResultController *)resultController
{
    return objc_getAssociatedObject(self, ResultControllerKey);
}

- (void)setResultController:(EMSearchResultController *)resultController
{
    objc_setAssociatedObject(self, ResultControllerKey, resultController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UINavigationController *)resultNavigationController
{
    return objc_getAssociatedObject(self, ResultNavigationControllerKey);
}

- (void)setResultNavigationController:(EMSearchResultController *)resultNavigationController
{
    objc_setAssociatedObject(self, ResultNavigationControllerKey, resultNavigationController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - enable

- (void)enableSearchController
{
    self.definesPresentationContext = YES;
    
    if (self.searchButton == nil) {
        self.searchButton = [[UIButton alloc] init];
        self.searchButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        self.searchButton.backgroundColor = kColor_LightGray;
        self.searchButton.titleLabel.font = [UIFont systemFontOfSize:15];
        self.searchButton.layer.cornerRadius = 8;
        self.searchButton.imageEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 0);
        self.searchButton.titleEdgeInsets = UIEdgeInsetsMake(0, 18, 0, 0);
        [self.searchButton setTitle:@"搜索" forState:UIControlStateNormal];
        [self.searchButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [self.searchButton setImage:[UIImage imageNamed:@"search_gray"] forState:UIControlStateNormal];
        [self.searchButton addTarget:self action:@selector(searchButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.searchButton];
        [self.searchButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view).offset(90);
            make.left.equalTo(self.view).offset(15);
            make.right.equalTo(self.view).offset(-15);
            make.height.equalTo(@35);
        }];
    }
    
    if (self.resultNavigationController == nil) {
        self.resultController = [[EMSearchResultController alloc] init];
        self.resultController.searchBar.delegate = self;
        
        self.resultNavigationController = [[UINavigationController alloc] initWithRootViewController:self.resultController];
        [self.resultNavigationController.navigationBar setBackgroundImage:[[UIImage imageNamed:@"navBarBg"] stretchableImageWithLeftCapWidth:10 topCapHeight:10] forBarMetrics:UIBarMetricsDefault];
    }
}

#pragma mark - disable

- (void)disableSearchController
{
    self.resultController.searchBar.delegate = nil;
    [self.searchButton removeFromSuperview];
}

#pragma mark - UISearchBarDelegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    if ([self conformsToProtocol:@protocol(EMSearchControllerDelegate)]
        && [self respondsToSelector:@selector(searchBarWillBeginEditing:)]) {
        [self performSelector:@selector(searchBarWillBeginEditing:)
                   withObject:searchBar];
    }
    
    return YES;
}

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [searchBar resignFirstResponder];
        if ([self conformsToProtocol:@protocol(EMSearchControllerDelegate)]
            && [self respondsToSelector:@selector(searchBarSearchButtonClicked:)]) {
            [self performSelector:@selector(searchBarSearchButtonClicked:)
                       withObject:searchBar];
        }
        return NO;
    }
    
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if ([self conformsToProtocol:@protocol(EMSearchControllerDelegate)]
        && [self respondsToSelector:@selector(searchTextDidChangeWithString:)]) {
        [self performSelector:@selector(searchTextDidChangeWithString:)
                   withObject:searchText];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self cancelSearch];
    
    if ([self conformsToProtocol:@protocol(EMSearchControllerDelegate)]
        && [self respondsToSelector:@selector(searchBarCancelButtonAction:)]) {
        [self performSelector:@selector(searchBarCancelButtonAction:)
                   withObject:searchBar];
    }
}

#pragma mark - Action

- (void)searchButtonAction
{
    [self.resultController.searchBar becomeFirstResponder];
    self.resultController.searchBar.showsCancelButton = YES;
    [self presentViewController:self.resultNavigationController animated:YES completion:nil];
//
//    [self.resultController.view mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(keyWindow.mas_top);
//        make.left.equalTo(keyWindow.mas_left);
//        make.right.equalTo(keyWindow.mas_right);
//        make.bottom.equalTo(keyWindow.mas_bottom);
//    }];
//
//    [UIView animateWithDuration:0.3 animations:^{
//    } completion:^(BOOL finished) {
//        [self.resultController.searchBar becomeFirstResponder];
//        self.resultController.searchBar.showsCancelButton = YES;
//    }];
}

#pragma mark - public

- (void)cancelSearch
{
//    if (self.resultController.view.superview == nil) {
//        return;
//    }
    
    self.resultController.searchBar.text = @"";
    [self.resultController.searchBar resignFirstResponder];
    self.resultController.searchBar.showsCancelButton = NO;
    [self.resultController dismissViewControllerAnimated:YES completion:nil];
    
//    [UIView animateWithDuration:0.3 animations:^{
//        self.resultController.view.alpha = 0;
//    } completion:^(BOOL finished) {
//        [self.resultController.view removeFromSuperview];
//        self.resultController.view.alpha = 1;
//    }];
}

@end

