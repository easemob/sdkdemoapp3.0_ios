//
//  EMBaseSearchController.h
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 16/10/10.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>
@class EMSearchBar;

@protocol EMSearchRefreshProtocol <NSObject>

@optional
- (void)searchCancel;

- (void)searchFinished:(NSArray *)searchResults;

@end

@interface EMBaseSearchController : UIViewController<UISearchBarDelegate>

@property (nonatomic, strong) EMSearchBar *searchBar;
@property (nonatomic, strong) NSMutableArray *searchSource;
//@property (nonatomic, strong) NSMutableArray *searchResults;

@property (nonatomic, assign) id<EMSearchRefreshProtocol> delegate;

@end
