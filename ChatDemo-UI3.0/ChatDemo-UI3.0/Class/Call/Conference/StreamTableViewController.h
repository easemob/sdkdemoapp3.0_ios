//
//  StreamTableViewController.h
//  IosDemo
//
//  Created by XieYajie on 5/30/16.
//  Copyright © 2016 dxstudio.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EMCallStream.h"

@protocol StreamTableViewControllerDelegate;

@interface StreamTableViewController : UITableViewController

@property (nonatomic, weak) id<StreamTableViewControllerDelegate> delegate;

- (instancetype)initWithDataSource:(NSArray *)aDataSource;

@end

@protocol StreamTableViewControllerDelegate <NSObject>

- (void)streamController:(StreamTableViewController *)aController
       didSelectedStream:(EMCallStream *)aStream;

@end
