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
@property (strong, nonatomic) IBOutlet UIButton *selectButton;

@end

@implementation EMContactCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.accessoryType = UITableViewCellAccessoryNone;
}

- (void)setModel:(EMUserModel *)model {
    if (_model != model) {
        _model = model;
    }
    _nicknameLabel.text = _model.nickname;
    _avatarImage.image = _model.defaultAvatarImage;
    if (_model.avatarURLPath.length > 0) {
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
            NSData *data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:weakSelf.model.avatarURLPath]];
            if (data.length > 0) {
                dispatch_async(dispatch_get_main_queue(), ^(){
                    weakSelf.avatarImage.image = [UIImage imageWithData:data];
                });
            }
        });
    }
}

- (void)setIsSelected:(BOOL)isSelected {
    _isSelected = isSelected;
    _selectButton.selected = _isSelected;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
