//
//  EMContactInfoViewController.h
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 16/9/28.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>
@class EMUserModel;

@interface EMContactInfoViewController : UITableViewController

- (instancetype)initWithUserModel:(EMUserModel *)model;

@end
