//
//  EMGroupMemberCell.m
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 16/10/11.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "EMGroupMemberCell.h"
#import "EMUserModel.h"

@interface EMGroupMemberCell()
@property (strong, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (strong, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (strong, nonatomic) IBOutlet UILabel *identityLabel;
@property (strong, nonatomic) IBOutlet UIButton *selectButton;

@end

@implementation EMGroupMemberCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.accessoryType = UITableViewCellAccessoryNone;
    _isEditing = NO;
    _isSelected = NO;
    _isGroupOwner = NO;
}

- (void)setIsGroupOwner:(BOOL)isGroupOwner {
    _isGroupOwner = isGroupOwner;
    if (_isGroupOwner) {
        _identityLabel.hidden = NO;
    }
    else {
        _identityLabel.hidden = YES;
    }
}

- (void)setIsEditing:(BOOL)isEditing {
    _isEditing = isEditing;
    if (_isGroupOwner) {
        _selectButton.hidden = YES;
        return;
    }
    _selectButton.hidden = !_isEditing;
}

- (void)setIsSelected:(BOOL)isSelected {
    _isSelected = isSelected;
    _selectButton.selected = _isSelected;
}

- (void)setModel:(EMUserModel *)model {
    _model = model;
    _nicknameLabel.text = _model.nickname;
    if (_model.avatarURLPath.length > 0) {
        NSURL *avatarUrl = [NSURL URLWithString:_model.avatarURLPath];
        [_avatarImageView sd_setImageWithURL:avatarUrl placeholderImage:_model.defaultAvatarImage];
    }
    else {
        _avatarImageView.image = _model.defaultAvatarImage;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)selectMemberAction:(UIButton *)sender {
    
    _selectButton.selected = !sender.isSelected;
    if (_delegate) {
        if (_selectButton.selected && [_delegate respondsToSelector:@selector(addSelectOccupants:)]) {
            [_delegate addSelectOccupants:@[_model]];
        }
        else if ([_delegate respondsToSelector:@selector(removeSelectOccupants:)]) {
            [_delegate removeSelectOccupants:@[_model]];
        }
    }
}


@end
