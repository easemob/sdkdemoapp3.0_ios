//
//  OccupantCell.m
//  ChatDemo-UI3.0
//
//  Created by WYZ on 16/2/16.
//  Copyright © 2016年 WYZ. All rights reserved.
//

#import "OccupantCell.h"

CGFloat const OccupantCellPadding = 10;

@implementation OccupantCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self _setupSubview];
    }
    
    return self;
}

- (void)_setupSubview
{
    if (!_avatarView)
    {
        _avatarView = [[UIImageView alloc] init];
        _avatarView.image = [UIImage imageNamed:@"EaseUIResource.bundle/user"];
        _avatarView.translatesAutoresizingMaskIntoConstraints = NO;
        _avatarView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_avatarView];
    }
    
    if (!_occupantLabel)
    {
        _occupantLabel = [[UILabel alloc] init];
        _occupantLabel.backgroundColor = [UIColor clearColor];
        _occupantLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:_occupantLabel];
    }
    
    [self _setupAvatarViewConstraints];
    [self _setupOccupantLabelConstraints];
}

- (void)_setupAvatarViewConstraints
{
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1.0 constant:OccupantCellPadding]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-OccupantCellPadding]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:OccupantCellPadding]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.avatarView attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0]];
}

- (void)_setupOccupantLabelConstraints
{
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.occupantLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1.0 constant:OccupantCellPadding]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.occupantLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-OccupantCellPadding]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.occupantLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.occupantLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1.0 constant:-OccupantCellPadding]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.occupantLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.avatarView attribute:NSLayoutAttributeRight multiplier:1.0 constant:OccupantCellPadding]];
}



@end
