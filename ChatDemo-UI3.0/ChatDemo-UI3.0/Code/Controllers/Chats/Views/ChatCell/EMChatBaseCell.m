//
//  EMChatBaseCell.m
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 16/9/27.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "EMChatBaseCell.h"

#import "EMChatBaseBubbleView.h"
#import "EMChatTextBubbleView.h"
#import "EMChatImageBubbleView.h"
#import "EMChatAudioBubbleView.h"
#import "EMChatVideoBubbleView.h"
#import "EMChatLocationBubbleView.h"
#import "EMMessageModel.h"
#import "UIImageView+HeadImage.h"

#define HEAD_PADDING 15.f
#define TIME_PADDING 45.f
#define BOTTOM_PADDING 16.f

#define kColorOrangeRed RGBACOLOR(255, 59, 58, 1)
#define kColorKermitGreenTwo RGBACOLOR(72, 184, 0, 1)

@interface EMChatBaseCell () <EMChatBaseBubbleViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *readLabel;
@property (weak, nonatomic) IBOutlet UILabel *notDeliveredLabel;
@property (weak, nonatomic) IBOutlet UIImageView *checkView;
@property (weak, nonatomic) IBOutlet UIButton *resendButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;

@property (strong, nonatomic) EMChatBaseBubbleView *bubbleView;

@property (strong, nonatomic) EMMessageModel *model;

- (IBAction)didResendButtonPressed:(id)sender;

@end

@implementation EMChatBaseCell

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        
    }
    return self;
}

- (instancetype)initWithMessageModel:(EMMessageModel *)model
{
    self = (EMChatBaseCell*)[[[NSBundle mainBundle]loadNibNamed:@"EMChatBaseCell" owner:nil options:nil] firstObject];
    if (self) {
        [self _setupBubbleView:model];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didHeadImageSelected:)];
        self.headImageView.userInteractionEnabled = YES;
        [self.headImageView addGestureRecognizer:tap];
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

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    _headImageView.left = _model.message.direction == EMMessageDirectionSend ? (self.width - _headImageView.width - HEAD_PADDING) : HEAD_PADDING;
    
    _timeLabel.left = _model.message.direction == EMMessageDirectionSend ? (self.width - _timeLabel.width - TIME_PADDING) : TIME_PADDING;
    _timeLabel.top = self.height - BOTTOM_PADDING;
    _timeLabel.textAlignment = _model.message.direction == EMMessageDirectionSend ? NSTextAlignmentRight : NSTextAlignmentLeft;
    
    _bubbleView.left = _model.message.direction == EMMessageDirectionSend ? (self.width - _bubbleView.width - TIME_PADDING) : TIME_PADDING;
    _bubbleView.top = 5;
    
    _readLabel.left = KScreenWidth - 135;
    _readLabel.top = self.height - BOTTOM_PADDING;
    _checkView.left = KScreenWidth - 151;
    _checkView.top = self.height - BOTTOM_PADDING;
    _resendButton.top = _bubbleView.top + (_bubbleView.height - _resendButton.height)/2;
    _resendButton.left = _bubbleView.left - 25.f;
    _activityView.top = _bubbleView.top + (_bubbleView.height - _resendButton.height)/2;
    _activityView.left = _bubbleView.left - 25.f;
    _notDeliveredLabel.top = self.height - BOTTOM_PADDING;
    _notDeliveredLabel.left = self.width - _notDeliveredLabel.width - 15.f;
    
    [self _setViewsDisplay];
}

#pragma mark - EMChatBaseBubbleViewDelegate

- (void)didBubbleViewPressed:(EMMessageModel *)model
{
    if (self.delegate) {
        switch (model.message.body.type) {
            case EMMessageBodyTypeText:
                if ([self.delegate respondsToSelector:@selector(didTextCellPressed:)]) {
                    [self.delegate didTextCellPressed:model];
                }
                break;
            case EMMessageBodyTypeImage:
                if ([self.delegate respondsToSelector:@selector(didImageCellPressed:)]) {
                    [self.delegate didImageCellPressed:model];
                }
                break;
            case EMMessageBodyTypeVoice:
                if ([self.delegate respondsToSelector:@selector(didAudioCellPressed:)]) {
                    [self.delegate didAudioCellPressed:model];
                }
                break;
            case EMMessageBodyTypeVideo:
                if ([self.delegate respondsToSelector:@selector(didVideoCellPressed:)]) {
                    [self.delegate didVideoCellPressed:model];
                }
                break;
            case EMMessageBodyTypeLocation:
                if ([self.delegate respondsToSelector:@selector(didLocationCellPressed:)]) {
                    [self.delegate didLocationCellPressed:model];
                }
                break;
            default:
                break;
        }
    }
}

- (void)didBubbleViewLongPressed
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didCellLongPressed:)]) {
        [self.delegate didCellLongPressed:self];
    }
}

#pragma mark - action

- (void)didHeadImageSelected:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didHeadImagePressed:)]) {
        [self.delegate didHeadImagePressed:self.model];
    }
}

- (IBAction)didResendButtonPressed:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didResendButtonPressed:)]) {
        [self.delegate didResendButtonPressed:self.model];
    }
}

#pragma mark - private

- (void)_setupBubbleView:(EMMessageModel*)model
{
    _model = model;
    switch (model.message.body.type) {
        case EMMessageBodyTypeText:
            _bubbleView = [[EMChatTextBubbleView alloc] init];
            break;
        case EMMessageBodyTypeImage:
            _bubbleView = [[EMChatImageBubbleView alloc] init];
            break;
        case EMMessageBodyTypeVoice:
            _bubbleView = [[EMChatAudioBubbleView alloc] init];
            break;
        case EMMessageBodyTypeVideo:
            _bubbleView = [[EMChatVideoBubbleView alloc] init];
            break;
        case EMMessageBodyTypeLocation:
            _bubbleView = [[EMChatLocationBubbleView alloc] init];
            break;
        default:
            _bubbleView = [[EMChatTextBubbleView alloc] init];
            break;
    }
    _bubbleView.delegate = self;
    [self.contentView addSubview:_bubbleView];
}

- (NSString *)_getMessageTime:(EMMessage*)message
{
    NSString *messageTime = @"";
    if (message) {
        double timeInterval = message.timestamp ;
        if(timeInterval > 140000000000) {
            timeInterval = timeInterval / 1000;
        }
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MM-dd HH:mm"];
        messageTime = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:timeInterval]];
    }
    return messageTime;
}

- (void)_setViewsDisplay
{
    _timeLabel.hidden = NO;
    if (_model.message.direction == EMMessageDirectionSend) {
        if (_model.message.status == EMMessageStatusFailed || _model.message.status == EMMessageStatusPending) {
            _notDeliveredLabel.text = NSLocalizedString(@"chat.not.delivered", @"Not Delivered");
            _checkView.hidden = YES;
            _readLabel.hidden = YES;
            _timeLabel.hidden = YES;
            _activityView.hidden = YES;
            _resendButton.hidden = NO;
            _notDeliveredLabel.hidden = NO;
            
        } else if (_model.message.status == EMMessageStatusSuccessed) {
            if (_model.message.isReadAcked) {
                _readLabel.text = NSLocalizedString(@"chat.read", @"Read");
                _checkView.hidden = NO;
            } else {
                _readLabel.text = NSLocalizedString(@"chat.sent", @"Sent");
                _checkView.hidden = YES;
            }
            _resendButton.hidden = YES;
            _notDeliveredLabel.hidden = YES;
            _activityView.hidden = YES;
            _readLabel.hidden = NO;
        } else if (_model.message.status == EMMessageStatusDelivering) {
            _activityView.hidden = YES;
            _readLabel.hidden = YES;
            _checkView.hidden = YES;
            _resendButton.hidden = YES;
            _notDeliveredLabel.hidden = YES;
            _activityView.hidden = NO;
            [_activityView startAnimating];
        }
    } else {
        _activityView.hidden = YES;
        _readLabel.hidden = YES;
        _checkView.hidden = YES;
        _resendButton.hidden = YES;
        _notDeliveredLabel.hidden = YES;
    }
}

#pragma mark - public

- (void)setMessageModel:(EMMessageModel *)model
{
    _model = model;
    
    [_bubbleView setModel:_model];
    [_bubbleView sizeToFit];
    
    [_headImageView imageWithUsername:model.message.from placeholderImage:[UIImage imageNamed:@"default_avatar"]];
    _timeLabel.text = [self _getMessageTime:model.message];
}

+ (CGFloat)heightForMessageModel:(EMMessageModel *)model
{
    CGFloat height = 100.f;
    switch (model.message.body.type) {
        case EMMessageBodyTypeText:
            height = [EMChatTextBubbleView heightForBubbleWithMessageModel:model] + 26.f;
            break;
        case EMMessageBodyTypeImage:
            height = [EMChatImageBubbleView heightForBubbleWithMessageModel:model] + 26.f;
            break;
        case EMMessageBodyTypeLocation:
            height = [EMChatLocationBubbleView heightForBubbleWithMessageModel:model] + 26.f;
            break;
        case EMMessageBodyTypeVoice:
            height = [EMChatAudioBubbleView heightForBubbleWithMessageModel:model] + 26.f;
            break;
        case EMMessageBodyTypeVideo:
            height = [EMChatVideoBubbleView heightForBubbleWithMessageModel:model] + 26.f;
            break;
        default:
            break;
    }
    return height;
}

+ (NSString *)cellIdentifierForMessageModel:(EMMessageModel *)model
{
    NSString *identifier = @"MessageCell";
    if (model.message.direction == EMMessageDirectionSend) {
        identifier = [identifier stringByAppendingString:@"Sender"];
    }
    else{
        identifier = [identifier stringByAppendingString:@"Receiver"];
    }
    
    switch (model.message.body.type) {
        case EMMessageBodyTypeText:
            identifier = [identifier stringByAppendingString:@"Text"];
            break;
        case EMMessageBodyTypeImage:
            identifier = [identifier stringByAppendingString:@"Image"];
            break;
        case EMMessageBodyTypeVoice:
            identifier = [identifier stringByAppendingString:@"Audio"];
            break;
        case EMMessageBodyTypeLocation:
            identifier = [identifier stringByAppendingString:@"Location"];
            break;
        case EMMessageBodyTypeVideo:
            identifier = [identifier stringByAppendingString:@"Video"];
            break;
        default:
            break;
    }
    
    return identifier;
}

@end
