//
//  EMApplyRequestCell.m
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 16/10/9.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "EMApplyRequestCell.h"
#import "EMApplyModel.h"
#import "EMApplyManager.h"

@interface EMApplyRequestCell()

@property (strong, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (strong, nonatomic) IBOutlet UILabel *tiitleLabel;

@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) IBOutlet UIButton *acceptButton;

@end

@implementation EMApplyRequestCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.accessoryType = UITableViewCellAccessoryNone;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setModel:(EMApplyModel *)model {
    _model = model;
    if (_model.style == EMApplyStyle_contact) {
        _descriptionLabel.hidden = YES;
        _tiitleLabel.text = _model.applyNickName;
    }
    else {
        _descriptionLabel.hidden = NO;
        _tiitleLabel.text = _model.groupSubject.length > 0 ? _model.groupSubject : _model.groupId;
        _descriptionLabel.text = [NSString stringWithFormat:@"%ld %@",(long)_model.groupMemberCount,NSLocalizedString(@"title.members", @"Members")];
        if (_model.style == EMApplyStyle_joinGroup) {
            _descriptionLabel.text = [NSString stringWithFormat:@"%@ wants to join",_model.applyNickName];
        }
    }
    if (_model.style > EMApplyStyle_joinGroup) {
        [_acceptButton setImage:[UIImage imageNamed:@"Button_Join.png"] forState:UIControlStateNormal];
        [_acceptButton setImage:[UIImage imageNamed:@"Button_Join.png"] forState:UIControlStateNormal];
    }
    else {
        [_acceptButton setImage:[UIImage imageNamed:@"Button_Accept.png"] forState:UIControlStateNormal];
        [_acceptButton setImage:[UIImage imageNamed:@"Button_Accept.png"] forState:UIControlStateNormal];
    }
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)declineAction:(UIButton *)sender {
    WEAK_SELF
    [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    switch (_model.style) {
        case EMApplyStyle_contact:
        {
            [[EMClient sharedClient].contactManager declineFriendRequestFromUser:_model.applyHyphenateId completion:^(NSString *aUsername, EMError *aError) {
                [weakSelf declineApplyFinished:aError];
            }];

            break;
        }
        case EMApplyStyle_joinGroup:
        {
            [[EMClient sharedClient].groupManager declineJoinGroupRequest:_model.groupId sender:_model.applyHyphenateId reason:nil completion:^(EMGroup *aGroup, EMError *aError) {
                [weakSelf declineApplyFinished:aError];
            }];
            break;
        }
        default:
        {
            [[EMClient sharedClient].groupManager declineGroupInvitation:_model.groupId inviter:_model.applyHyphenateId reason:nil completion:^(EMError *aError) {
                [weakSelf declineApplyFinished:aError];
            }];
            break;
        }
    }
}


- (IBAction)acceptAction:(id)sender {
    WEAK_SELF
    [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    switch (_model.style) {
        case EMApplyStyle_contact:
        {
            [[EMClient sharedClient].contactManager approveFriendRequestFromUser:_model.applyHyphenateId completion:^(NSString *aUsername, EMError *aError) {
                [weakSelf acceptApplyFinished:aError];
            }];
            break;
        }
        case EMApplyStyle_joinGroup:
        {
            [[EMClient sharedClient].groupManager approveJoinGroupRequest:_model.groupId sender:_model.applyHyphenateId completion:^(EMGroup *aGroup, EMError *aError) {
                [weakSelf acceptApplyFinished:aError];
            }];
            break;
        }
        default:
        {
            [[EMClient sharedClient].groupManager acceptInvitationFromGroup:_model.groupId inviter:_model.applyHyphenateId completion:^(EMGroup *aGroup, EMError *aError) {
                [weakSelf acceptApplyFinished:aError];
            }];
            break;
        }
    }
}

- (void)declineApplyFinished:(EMError *)error {
    [MBProgressHUD hideAllHUDsForView:[UIApplication sharedApplication].keyWindow animated:YES];
    if (!error) {
        [[EMApplyManager defaultManager] removeApplyRequest:_model];
        if (self.declineApply) {
            self.declineApply(_model);
        }
    }
    else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"contact.refusedFailure", @"Refused to apply for failure") delegate:nil cancelButtonTitle:NSLocalizedString(@"common.ok", @"OK") otherButtonTitles:nil, nil];
        [alertView show];
    }
}

- (void)acceptApplyFinished:(EMError *)error {
    [MBProgressHUD hideAllHUDsForView:[UIApplication sharedApplication].keyWindow animated:YES];
    if (!error) {
        [[EMApplyManager defaultManager] removeApplyRequest:_model];
        if (self.acceptApply) {
            self.acceptApply(_model);
        }
    }
    else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"contact.agreeFailure", @"Failed to agree to apply") delegate:nil cancelButtonTitle:NSLocalizedString(@"common.ok", @"OK") otherButtonTitles:nil, nil];
        [alertView show];
    }
}

@end
