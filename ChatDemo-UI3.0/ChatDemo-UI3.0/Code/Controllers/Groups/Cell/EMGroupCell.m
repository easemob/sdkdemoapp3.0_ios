//
//  EMGroupCell.m
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 16/10/6.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "EMGroupCell.h"
#import "EMGroupModel.h"

#define KJOINBUTTON_IMAGE   [UIImage imageNamed:@"Button_Join.png"]
#define KJOINBUTTON_TITLE   NSLocalizedString(@"group.requested", @"Requested")

@interface EMGroupCell()<UIAlertViewDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *avatarImageVIew;
@property (strong, nonatomic) IBOutlet UILabel *groupSubjectLabel;
@property (strong, nonatomic) IBOutlet UILabel *numbersLabel;

@property (strong, nonatomic) IBOutlet UIButton *joinButton;

@end

@implementation EMGroupCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.accessoryType = UITableViewCellAccessoryNone;
}

- (void)setIsRequestedToJoinPublicGroup:(BOOL)isRequestedToJoinPublicGroup {
    _isRequestedToJoinPublicGroup = isRequestedToJoinPublicGroup;
    _joinButton.userInteractionEnabled = !_isRequestedToJoinPublicGroup;
    [self updateJoinButton];
}

- (void)setModel:(EMGroupModel *)model {
    if (_model != model) {
        _model = model;
    }
    _groupSubjectLabel.text = _model.subject;
    _numbersLabel.text = [NSString stringWithFormat:@"%d members",_model.group.occupants.count];
    if (_model.avatarURLPath.length > 0) {
        NSURL *avatarUrl = [NSURL URLWithString:_model.avatarURLPath];
        [_avatarImageVIew sd_setImageWithURL:avatarUrl placeholderImage:_model.defaultAvatarImage];
    }
    else {
        _avatarImageVIew.image = _model.defaultAvatarImage;
    }
}

- (void)updateJoinButton {
    if (!_joinButton) {
        return;
    }
    if (_joinButton.userInteractionEnabled) {
        [_joinButton setTitle:@"" forState:UIControlStateNormal];
        [_joinButton setTitle:@"" forState:UIControlStateHighlighted];
        
        [_joinButton setImage:KJOINBUTTON_IMAGE forState:UIControlStateNormal];
        [_joinButton setImage:KJOINBUTTON_IMAGE forState:UIControlStateHighlighted];
    }
    else {
        [_joinButton setTitle:KJOINBUTTON_TITLE forState:UIControlStateNormal];
        [_joinButton setTitle:KJOINBUTTON_TITLE forState:UIControlStateHighlighted];
        
        [_joinButton setImage:nil forState:UIControlStateNormal];
        [_joinButton setImage:nil forState:UIControlStateHighlighted];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Action Method

- (IBAction)sendJoinRequestAction:(UIButton *)sender {
    
    if (_delegate && [_delegate respondsToSelector:@selector(joinPublicGroup:)]) {
        [_delegate joinPublicGroup:_model];
    }
}

@end
