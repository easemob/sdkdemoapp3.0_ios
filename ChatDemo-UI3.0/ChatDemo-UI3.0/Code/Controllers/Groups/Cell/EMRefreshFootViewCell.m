//
//  EMRefreshFootViewCell.m
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 16/10/13.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "EMRefreshFootViewCell.h"

@implementation EMRefreshFootViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.accessoryType = UITableViewCellAccessoryNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
