//
//  EMSearchBar.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/16.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol EMSearchBarDelegate;
@interface EMSearchBar : UIView

@property (nonatomic, weak) id<EMSearchBarDelegate> delegate;

@property (nonatomic, strong) UITextField *textField;

@end

@protocol EMSearchBarDelegate <NSObject>

@optional

- (void)searchBarShouldBeginEditing:(EMSearchBar *)searchBar;

- (void)searchBarCancelButtonAction:(EMSearchBar *)searchBar;

- (void)searchBarSearchButtonClicked:(NSString *)aString;

- (void)searchTextDidChangeWithString:(NSString *)aString;

@end

NS_ASSUME_NONNULL_END
