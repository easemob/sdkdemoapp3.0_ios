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
    EMError *error = nil;
    switch (_model.style) {
        case EMApplyStyle_contact:
            error = [[EMClient sharedClient].contactManager declineInvitationForUsername:_model.applyHyphenateId];
            break;
        case EMApplyStyle_joinGroup:
            error = [[EMClient sharedClient].groupManager declineJoinApplication:_model.groupId
                                                                       applicant:_model.applyHyphenateId
                                                                          reason:nil];
            break;
        default:
            error = [[EMClient sharedClient].groupManager declineInvitationFromGroup:_model.groupId
                                                                             inviter:_model.applyHyphenateId
                                                                              reason:nil];
            break;
    }
    [self declineApplyFinished:error];
}


- (IBAction)acceptAction:(id)sender {
    EMError *error = nil;
    switch (_model.style) {
        case EMApplyStyle_contact:
            error = [[EMClient sharedClient].contactManager acceptInvitationForUsername:_model.applyHyphenateId];
            break;
        case EMApplyStyle_joinGroup:
            error = [[EMClient sharedClient].groupManager acceptJoinApplication:_model.groupId
                                                                      applicant:_model.applyHyphenateId];
            break;
        default:
            [[EMClient sharedClient].groupManager acceptInvitationFromGroup:_model.groupId inviter:_model.applyHyphenateId error:&error];
            break;
    }
    [self acceptApplyFinished:error];
}

- (void)declineApplyFinished:(EMError *)error {
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
