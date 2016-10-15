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
    self.selectionStyle = UITableViewCellSelectionStyleNone;
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
    _avatarImageView.image = _model.defaultAvatarImage;
    if (_model.avatarURLPath.length > 0) {
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
            NSData *data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:weakSelf.model.avatarURLPath]];
            if (data.length > 0) {
                dispatch_async(dispatch_get_main_queue(), ^(){
                    weakSelf.avatarImageView.image = [UIImage imageWithData:data];
                });
            }
        });
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
