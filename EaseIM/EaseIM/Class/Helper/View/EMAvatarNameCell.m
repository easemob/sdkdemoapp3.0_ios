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
        make.top.equalTo(self.contentView).offset(14);
        make.left.equalTo(self.contentView).offset(16);
        make.bottom.equalTo(self.contentView).offset(-14);
        make.width.equalTo(self.avatarView.mas_height).multipliedBy(1);
    }];
    
    _detailLabel = [[UILabel alloc] init];
    _detailLabel.backgroundColor = [UIColor clearColor];
    _detailLabel.font = [UIFont systemFontOfSize:16];
    _detailLabel.numberOfLines = 1;
    _detailLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
    [self.contentView addSubview:_detailLabel];
    [_detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.avatarView.mas_right).offset(15);
        make.right.equalTo(self.contentView).offset(-15);
        make.bottom.equalTo(self.contentView).offset(-8);
    }];
    
    _nameLabel = [[UILabel alloc] init];
    _nameLabel.numberOfLines = 2;
    _nameLabel.backgroundColor = [UIColor clearColor];
    _nameLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
    _nameLabel.font = [UIFont systemFontOfSize:16];
    [self.contentView addSubview:_nameLabel];
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(8);
        make.left.equalTo(self.avatarView.mas_right).offset(15);
        make.right.equalTo(self.contentView).offset(-15);
        make.bottom.equalTo(self.detailLabel.mas_top);
    }];
    
    _timestampLabel = [[UILabel alloc] init];
    _timestampLabel.numberOfLines = 1;
    _timestampLabel.backgroundColor = [UIColor clearColor];
    _timestampLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
    _timestampLabel.font = [UIFont systemFontOfSize:12];
    [_timestampLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.contentView addSubview:_timestampLabel];
    [_timestampLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.avatarView);
        make.right.equalTo(self.contentView).offset(-15);
    }];
}

- (void)setModel:(EMAvatarNameModel *)model
{
    _model = model;
    _avatarView.image = model.avatarImg;
    _nameLabel.text = model.from;
    _detailLabel.attributedText = model.detail;
    _detailLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    _timestampLabel.text = model.timestamp;
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
