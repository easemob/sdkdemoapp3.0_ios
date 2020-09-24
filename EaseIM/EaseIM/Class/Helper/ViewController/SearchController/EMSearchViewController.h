//
//  EMSearchViewController.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/16.
//  Copyright © 2019 XieYajie. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "EMRefreshViewController.h"

#import "EMSearchBar.h"
#import "EMRealtimeSearch.h"

NS_ASSUME_NONNULL_BEGIN

@interface EMSearchViewController : EMRefreshViewController<EMSearchBarDelegate>

@property (nonatomic) BOOL isSearching;

@property (nonatomic, strong) EMSearchBar *searchBar;

@property (nonatomic, strong) NSMutableArray *searchResults;

@property (nonatomic, strong) UITableView *searchResultTableView;

- (void)keyBoardWillShow:(NSNotification *)note;

- (void)keyBoardWillHide:(NSNotification *)note;

@end

NS_ASSUME_NONNULL_END
