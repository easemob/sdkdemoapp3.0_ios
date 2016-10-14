//
//  EMRefreshFootViewCell.h
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 16/10/13.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EMRefreshFootViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *loadMoreLabel;

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activity;

@end
