//
//  XHSearchControllerDelegate.h
//  DXStudio
//
//  Created by XieYajie on 22/09/2017.
//  Copyright © 2017 dxstudio. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol XHSearchControllerDelegate <NSObject>

@optional

- (void)searchBarWillBeginEditing:(UISearchBar *)searchBar;

- (void)didSearchWithString:(NSString *)aString;

- (void)searchBarCancelButtonAction:(UISearchBar *)searchBar;

- (void)searchTextChangeWithString:(NSString *)aString;

@end
