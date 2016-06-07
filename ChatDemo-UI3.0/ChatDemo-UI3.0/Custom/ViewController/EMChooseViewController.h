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

#import <UIKit/UIKit.h>

@protocol EMChooseViewDelegate;

@interface EMChooseViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
{
    __weak id<EMChooseViewDelegate> _delegate;
    NSMutableArray *_dataSource;
}

@property (weak, nonatomic) id<EMChooseViewDelegate> delegate;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *dataSource;
@property (strong, nonatomic) UILocalizedIndexedCollation *indexCollation;

@property (nonatomic) BOOL mulChoice;
@property (nonatomic) BOOL defaultEditing;
@property (nonatomic) BOOL showAllIndex;
@property (copy) NSString *(^objectComparisonStringBlock)(id object);
@property (copy) NSComparisonResult (^comparisonObjectSelector)(id object1, id object2);

@property (copy) void (^viewDidLoadBlock)(EMChooseViewController *controller);
@property (copy) void (^loadDataSourceBlock)(EMChooseViewController *controller);
@property (copy) UITableViewCell * (^cellForRowAtIndexPath)(UITableView *tableView, NSIndexPath *indexPath);
@property (copy) CGFloat (^heightForRowAtIndexPathCompletion)(id object);
@property (copy) void (^didSelectRowAtIndexPathCompletion)(id object);


#pragma mark - overwrite methods

- (void)loadDataSource;
- (NSArray *)sortRecords:(NSArray *)recordArray;
- (NSInteger)sectionForString:(NSString *)string;
- (void)doneAction:(id)sender;

@end

@protocol EMChooseViewDelegate <NSObject>

@optional

- (NSComparisonResult)comparisonObjectSelector:(id)object1 andObject:(id)object2;
- (NSArray *)viewControllerLoadDataSource:(EMChooseViewController *)viewController;
- (BOOL)viewController:(EMChooseViewController *)viewController didFinishSelectedSources:(NSArray *)selectedSources;

@end
