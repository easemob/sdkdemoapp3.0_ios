//
//  EMMessageCell.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/25.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EMMessageCell.h"

#import "EMMessageModel.h"

#import "EMMessageBubbleView.h"
#import "EMMessageStatusView.h"

@interface EMMessageCell()

@property (nonatomic, strong) UIImageView *avatarView;

@property (nonatomic, strong) UILabel *nameLabel;

@property (nonatomic, strong) EMMessageBubbleView *bubbleView;

@property (nonatomic, strong) EMMessageStatusView *statusView;

@end

@implementation EMMessageCell

- (instancetype)initWithDirection:(EMMessageDirection)aDirection
                             type:(EMMessageBodyType)aType
{
    NSString *identifier = [EMMessageCell cellIdentifierWithDirection:aDirection type:aType];
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    if (self) {
        _direction = aDirection;
        [self _setupViewsWithType:aType];
    }
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Class Methods

+ (NSString *)cellIdentifierWithDirection:(EMMessageDirection)aDirection
                                     type:(EMMessageBodyType)aType
{
    NSString *identifier = @"EMMsgCellDirectionSend";
    if (aDirection == EMMessageDirectionReceive) {
        identifier = @"EMMsgCellDirectionRecv";
    }
    
    if (aType == EMMessageBodyTypeText) {
        identifier = [NSString stringWithFormat:@"%@Text", identifier];
    } else if (aType == EMMessageBodyTypeImage) {
        identifier = [NSString stringWithFormat:@"%@Image", identifier];
    } else if (aType == EMMessageBodyTypeVoice) {
        identifier = [NSString stringWithFormat:@"%@Voice", identifier];
    } else if (aType == EMMessageBodyTypeVideo) {
        identifier = [NSString stringWithFormat:@"%@Video", identifier];
    } else if (aType == EMMessageBodyTypeLocation) {
        identifier = [NSString stringWithFormat:@"%@Location", identifier];
    } else if (aType == EMMessageBodyTypeFile) {
        identifier = [NSString stringWithFormat:@"%@File", identifier];
    }
    
    return identifier;
}

#pragma mark - Subviews

- (void)_setupViewsWithType:(EMMessageBodyType)aType
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = kColor_LightGray;
    self.contentView.backgroundColor = kColor_LightGray;
    
    _avatarView = [[UIImageView alloc] init];
    _avatarView.contentMode = UIViewContentModeScaleAspectFit;
    _avatarView.backgroundColor = [UIColor clearColor];
    _avatarView.userInteractionEnabled = YES;
    [self.contentView addSubview:_avatarView];
    if (self.direction == EMMessageDirectionSend) {
        _avatarView.image = [UIImage imageNamed:@"user_1"];
        [_avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView).offset(15);
            make.right.equalTo(self.contentView).offset(-10);
            make.width.height.equalTo(@40);
        }];
    } else {
        _avatarView.image = [UIImage imageNamed:@"user_2"];
        [_avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView).offset(15);
            make.left.equalTo(self.contentView).offset(10);
            make.width.height.equalTo(@40);
        }];
    }
    
    _bubbleView = [[EMMessageBubbleView alloc] initWithDirection:self.direction type:aType];
    _bubbleView.userInteractionEnabled = YES;
    _bubbleView.clipsToBounds = YES;
    [self.contentView addSubview:_bubbleView];
    if (self.direction == EMMessageDirectionSend) {
        [_bubbleView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.avatarView);
            make.bottom.equalTo(self.contentView).offset(-15);
            make.left.greaterThanOrEqualTo(self.contentView).offset(70);
            make.right.equalTo(self.avatarView.mas_left).offset(-10);
        }];
    } else {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont systemFontOfSize:13];
        _nameLabel.textColor = [UIColor grayColor];
        [self.contentView addSubview:_nameLabel];
        [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.avatarView);
            make.left.equalTo(self.avatarView.mas_right).offset(8);
            make.right.equalTo(self.contentView).offset(-10);
            make.right.equalTo(@15);
        }];
        
        [_bubbleView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.nameLabel.mas_bottom).offset(3);
            make.bottom.equalTo(self.contentView).offset(-15);
            make.left.equalTo(self.avatarView.mas_right).offset(10);
            make.right.lessThanOrEqualTo(self.contentView).offset(-70);
        }];
    }

    _statusView = [[EMMessageStatusView alloc] init];
    [self.contentView addSubview:_statusView];
    if (self.direction == EMMessageDirectionSend) {
        [_statusView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.bubbleView.mas_centerY);
            make.right.equalTo(self.bubbleView.mas_left).offset(-8);
            make.height.equalTo(@20);
        }];
        __weak typeof(self) weakself = self;
        [_statusView setResendCompletion:^{
//            if (weakself.delegate && [weakself.delegate respondsToSelector:@selector(messageCell:didResendMessageAction:)]) {
//                [weakself.delegate messageCell:weakself didResendMessageAction:weakself.model];
//            }
        }];
    } else {
        _statusView.backgroundColor = [UIColor redColor];
        _statusView.clipsToBounds = YES;
        _statusView.layer.cornerRadius = 4;
        [_statusView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.bubbleView).offset(5);
            make.left.equalTo(self.bubbleView.mas_right).offset(5);
            make.width.height.equalTo(@8);
        }];
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bubbleViewTapAction:)];
    [self.bubbleView addGestureRecognizer:tap];
}

#pragma mark - Setter

- (void)setModel:(EMMessageModel *)model
{
    _model = model;
    self.bubbleView.model = model;
    if (model.direction == EMMessageDirectionSend) {
        [self.statusView setSenderStatus:model.emModel.status isReadAcked:model.emModel.isReadAcked];
    } else {
        self.nameLabel.text = model.emModel.from;
        if (model.type == EMMessageBodyTypeVoice) {
            self.statusView.hidden = model.emModel.isReadAcked;
        }
    }
}

#pragma mark - Action

- (void)bubbleViewTapAction:(UITapGestureRecognizer *)aTap
{
    if (aTap.state == UIGestureRecognizerStateEnded) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(messageCellDidSelected:)]) {
            [self.delegate messageCellDidSelected:self];
        }
    }
}

@end
