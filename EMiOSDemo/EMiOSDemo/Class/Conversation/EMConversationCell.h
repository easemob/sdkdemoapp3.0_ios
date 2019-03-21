//
//  EMConversationCell.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/8.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EMBadgeLabel.h"

@class EMConversationModel;
@interface EMConversationCell : UITableViewCell

@property (nonatomic, strong) UIImageView *avatarView;

@property (nonatomic, strong) UILabel *nameLabel;

@property (nonatomic, strong) UILabel *detailLabel;

@property (nonatomic, strong) UILabel *timeLabel;

@property (nonatomic, strong) EMBadgeLabel *badgeLabel;

@property (nonatomic, strong) EMConversationModel *model;

@end
