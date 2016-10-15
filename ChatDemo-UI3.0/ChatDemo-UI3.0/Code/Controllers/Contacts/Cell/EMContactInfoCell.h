//
//  EMContactInfoCell.h
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 16/9/29.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EMContactsUIProtocol.h"


@interface EMContactInfoCell : UITableViewCell

@property (nonatomic, strong) NSDictionary *infoDic;

//为了执行加黑名单用
@property (nonatomic, strong) NSString *hyphenateId;

@property (nonatomic, assign) id<EMContactsUIProtocol> delegate;

@end
