//
//  EMBaseSearchController.m
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 16/10/10.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "EMBaseSearchController.h"
#import "EMSearchBar.h"
#import "EMRealtimeSearchUtils.h"

@interface EMBaseSearchController ()

@property (nonatomic, assign) BOOL isSearchState;
@property (nonatomic, strong) NSMutableArray *searchResults;

@end

@implementation EMBaseSearchController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (EMSearchBar *)searchBar {
    if (!_searchBar) {
        _searchBar = [[EMSearchBar alloc] initWithFrame:CGRectMake(0, 0, 313, 30)];
        _searchBar.searchFieldWidth = 313.0f;
        _searchBar.delegate = self;
    }
    return _searchBar;
}

#pragma mark - UISearchBarDelegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
    _isSearchState = YES;
    //    CGRect frame = _searchTextField.frame;
    //    frame.size.width -= 80;
    //    _searchTextField.frame = frame;
    return YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    _isSearchState = NO;
    if (_delegate && [_delegate respondsToSelector:@selector(searchFinished:)]) {
        [_delegate searchFinished:nil];
    }
//    [self.tableView reloadData];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    __weak typeof(self) weakSelf = self;
    [[EMRealtimeSearchUtils defaultUtil] realtimeSearchWithSource:_searchSource searchString:searchText resultBlock:^(NSArray *results) {
        if (results) {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.searchResults = [NSMutableArray arrayWithArray:results];
                if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(searchFinished:)]) {
                    [weakSelf.delegate searchFinished:results];
                }
//                [weakSelf.tableView reloadData];
            });
        }
    }];
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
    searchBar.text = @"";
    [searchBar setShowsCancelButton:NO animated:NO];
    [searchBar resignFirstResponder];
    [[EMRealtimeSearchUtils defaultUtil] realtimeSearchDidFinish];
    _isSearchState = NO;
    if (_delegate &&[_delegate respondsToSelector:@selector(searchCancel)]) {
        [_delegate searchCancel];
    }
//    [self.tableView reloadData];
}


@end
