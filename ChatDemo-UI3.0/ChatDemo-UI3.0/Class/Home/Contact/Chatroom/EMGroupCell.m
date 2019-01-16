//
//  EMGroupCell.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/8.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EMGroupCell.h"

@implementation EMGroupCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self _setupSubview];
    }
    
    return self;
}

#pragma mark - private layout subviews

- (void)_setupSubview
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    _avatarView = [[UIImageView alloc] init];
    [self.contentView addSubview:_avatarView];
    [_avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(5);
        make.left.equalTo(self.contentView).offset(15);
        make.bottom.equalTo(self.contentView).offset(-5);
        make.width.equalTo(self.avatarView.mas_height).multipliedBy(1);
    }];
    
    _nameLabel = [[UILabel alloc] init];
    _nameLabel.backgroundColor = [UIColor clearColor];
    _nameLabel.textColor = [UIColor blackColor];
    _nameLabel.font = [UIFont systemFontOfSize:18];
    [self.contentView addSubview:_nameLabel];
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(10);
        make.left.equalTo(self.avatarView.mas_right).offset(8);
        make.right.equalTo(self.contentView).offset(-10);
        make.bottom.equalTo(self.contentView).offset(-10);
    }];
    
//    _detailLabel = [[UILabel alloc] init];
//    _detailLabel.translatesAutoresizingMaskIntoConstraints = NO;
//    _detailLabel.backgroundColor = [UIColor clearColor];
//    _detailLabel.font = [UIFont systemFontOfSize:15];
//    _detailLabel.textColor = [UIColor grayColor];
//    [self.contentView addSubview:_detailLabel];
//    [_detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.nameLabel.mas_bottom);
//        make.left.equalTo(self.nameLabel);
//        make.right.equalTo(self.nameLabel);
//        make.bottom.equalTo(self.contentView).offset(-8);
//    }];
}

@end
