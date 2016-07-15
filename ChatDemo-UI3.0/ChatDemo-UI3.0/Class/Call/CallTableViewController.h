//
//  CallTableViewController.h
//  IosDemo
//
//  Created by XieYajie on 5/30/16.
//  Copyright © 2016 dxstudio.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EMCallStream.h"

@protocol CallTableViewControllerDelegate;

@interface CallTableViewController : UITableViewController

@property (nonatomic, weak) id<CallTableViewControllerDelegate> delegate;

- (instancetype)initWithDataSource:(NSArray *)aDataSource;

@end

@protocol CallTableViewControllerDelegate <NSObject>

- (void)streamController:(CallTableViewController *)aController
       didSelectedStream:(EMCallStream *)aStream;

@end
