//
//  EMContactInfoCell.m
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 16/9/29.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "EMContactInfoCell.h"

@interface EMContactInfoCell()

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *infoLabel;

@property (strong, nonatomic) IBOutlet UISwitch *blockSwitch;



@end

@implementation EMContactInfoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setInfoDic:(NSDictionary *)infoDic {
    if (_infoDic != infoDic) {
        _infoDic = infoDic;
    }
    if ([self.reuseIdentifier isEqualToString:@"EMContact_Info_Cell"]) {
        _titleLabel.text = [_infoDic.allKeys lastObject];
        _infoLabel.text = [_infoDic.allValues lastObject];
    }
    else {
        _blockSwitch.hidden = NO;
        _titleLabel.text = [_infoDic.allKeys lastObject];
        _titleLabel.textColor = (UIColor *)[_infoDic.allValues lastObject];
        if ([_titleLabel.text isEqualToString:NSLocalizedString(@"contact.delete", @"Delete Contact")]) {
            _blockSwitch.hidden = YES;
        }
    }
}
- (IBAction)blockContactAction:(id)sender {
    if (_hyphenateId.length == 0) {
        return;
    }
    EMError *error = [[EMClient sharedClient].contactManager addUserToBlackList:_hyphenateId relationshipBoth:NO];
    if (!error) {
        //向UI通知
    }
    else {
        //向UI通知
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
