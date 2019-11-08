//
//  EMReadReceiptTableViewCell.m
//  EMiOSDemo
//
//  Created by 娜塔莎 on 2019/10/30.
//  Copyright © 2019 娜塔莎. All rights reserved.
//

#import "EMReadReceiptTableViewCell.h"

@implementation EMReadReceiptTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self _setupSubviews];
    }
    
    return self;
}

//- (instancetype)initWithIdentity
//{
//    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"member"];
//    if(self){
//        [self _setupSubviews];
//    }
//    return self;
//}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)_setupSubviews {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    _avatarView = [[UIImageView alloc] init];
    [self.contentView addSubview:_avatarView];
    [_avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(8);
        make.left.equalTo(self.contentView).offset(15);
        make.bottom.equalTo(self.contentView).offset(-8);
        make.width.equalTo(self.avatarView.mas_height).multipliedBy(1);
    }];
    
    _nameLabel = [[UILabel alloc] init];
    _nameLabel.backgroundColor = [UIColor clearColor];
    _nameLabel.font = [UIFont systemFontOfSize:20];
    _nameLabel.textColor = [UIColor blackColor];
    [self.contentView addSubview:_nameLabel];
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.avatarView.mas_right).offset(8);
        make.right.equalTo(self.contentView).offset(-15);
        make.bottom.equalTo(self.contentView).offset(-8);
    }];
    
    _timeLable = [[UILabel alloc]init];
    _timeLable.backgroundColor = [UIColor clearColor];
    _timeLable.font = [UIFont systemFontOfSize:15];
    _timeLable.textColor = [UIColor grayColor];
    [self.contentView addSubview:_timeLable];
    [_timeLable mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).offset(-10);
        make.centerY.equalTo(self.nameLabel);
    }];
    
}

- (void)setModel:(EMReadReceiptMemberModel *)model
{
    _model = model;
    self.avatarView.image = _model.avatarImg;
    self.nameLabel.text = _model.nickName;
    self.timeLable.text = _model.readTime;
}

@end
