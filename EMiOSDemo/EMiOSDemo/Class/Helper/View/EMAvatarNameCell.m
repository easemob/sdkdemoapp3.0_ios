//
//  EMAvatarNameCell.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/9.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EMAvatarNameCell.h"

@implementation EMAvatarNameCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self _setupSubviews];
    }
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Subviews

- (void)_setupSubviews
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    _avatarView = [[UIImageView alloc] init];
    [self.contentView addSubview:_avatarView];
    [_avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(8);
        make.left.equalTo(self.contentView).offset(15);
        make.bottom.equalTo(self.contentView).offset(-8);
        make.width.equalTo(self.avatarView.mas_height).multipliedBy(1);
    }];
    
    _detailLabel = [[UILabel alloc] init];
    _detailLabel.backgroundColor = [UIColor clearColor];
    _detailLabel.font = [UIFont systemFontOfSize:15];
    _detailLabel.textColor = [UIColor grayColor];
    [self.contentView addSubview:_detailLabel];
    [_detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.avatarView.mas_right).offset(8);
        make.right.equalTo(self.contentView).offset(-15);
        make.bottom.equalTo(self.contentView).offset(-8);
    }];
    
    _nameLabel = [[UILabel alloc] init];
    _nameLabel.numberOfLines = 2;
    _nameLabel.backgroundColor = [UIColor clearColor];
    _nameLabel.textColor = [UIColor blackColor];
    _nameLabel.font = [UIFont systemFontOfSize:18];
    [self.contentView addSubview:_nameLabel];
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(8);
        make.left.equalTo(self.avatarView.mas_right).offset(8);
        make.right.equalTo(self.contentView).offset(-15);
        make.bottom.equalTo(self.detailLabel.mas_top);
    }];
}

#pragma mark - Public

- (void)setAccessoryButton:(UIButton *)accessoryButton
{
    _accessoryButton = accessoryButton;
    if (_accessoryButton) {
        [_accessoryButton addTarget:self action:@selector(accessoryButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    self.accessoryView = accessoryButton;
}

#pragma mark - Action

- (void)accessoryButtonAction
{
    if (_delegate && [_delegate respondsToSelector:@selector(cellAccessoryButtonAction:)]) {
        [_delegate cellAccessoryButtonAction:self];
    }
}

@end
