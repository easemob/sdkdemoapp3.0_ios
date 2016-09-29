//
//  EMContactCell.m
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 16/9/29.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "EMContactCell.h"
#import "EMUserModel.h"

@interface EMContactCell()
@property (strong, nonatomic) IBOutlet UIImageView *avatarImage;
@property (strong, nonatomic) IBOutlet UILabel *nicknameLabel;

@end

@implementation EMContactCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setModel:(EMUserModel *)model {
    if (_model != model) {
        _model = model;
    }
    _nicknameLabel.text = _model.nickname;
    _avatarImage.image = _model.defaultAvatarImage;
    if (_model.avatarURLPath.length > 0) {
        NSData *data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:_model.avatarURLPath]];
        _avatarImage.image = [UIImage imageWithData:data];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
