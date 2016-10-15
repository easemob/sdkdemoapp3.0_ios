//
//  EMGroupPermissionCell.m
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 16/10/6.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "EMGroupPermissionCell.h"

@interface EMGroupPermissionCell()

@property (strong, nonatomic) IBOutlet UILabel *permissionDescriptionLabel;

@end

@implementation EMGroupPermissionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.accessoryType = UITableViewCellAccessoryNone;
    _permissionSwitch.hidden = YES;
}

- (IBAction)permissionSelectAction:(UISwitch *)sender {
    if (self.ReturnSwitchState) {
        self.ReturnSwitchState(sender.isOn);
    }
}

- (void)setModel:(EMGroupPermissionModel *)model {
    _model = model;
    _permissionTitleLabel.text = _model.title;
    if (_model.isEdit) {
        _permissionDescriptionLabel.hidden = YES;
        _permissionSwitch.hidden = NO;
        [_permissionSwitch setOn:_model.switchState];
    }
    else {
        _permissionSwitch.hidden = YES;
        _permissionDescriptionLabel.hidden = NO;
        _permissionDescriptionLabel.text = _model.permissionDescription;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end


@implementation EMGroupPermissionModel



@end

