//
//  EMChatsCell.m
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 16/9/21.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "EMChatsCell.h"

#import "EMConvertToCommonEmoticonsHelper.h"
#import "EMConversationModel.h"
#import "EMUserProfileManager.h"
#import "UIImageView+HeadImage.h"

@interface EMChatsCell ()

@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *unreadLabel;

@property (strong, nonatomic) EMConversationModel *model;

@end

@implementation EMChatsCell

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (_model.conversation.unreadMessagesCount == 0) {
        _unreadLabel.hidden = YES;
        _nameLabel.left = 75.f;
        _nameLabel.width = 170.f;
    } else {
        _unreadLabel.hidden = NO;
        _nameLabel.left = 95.f;
        _nameLabel.width = 150.f;
        _unreadLabel.text = [NSString stringWithFormat:@"%d",_model.conversation.unreadMessagesCount];
    }
}

- (void)setConversationModel:(EMConversationModel *)model
{
    _model = model;
    if (model.conversation.type == EMConversationTypeChat) {
        [_headImageView imageWithUsername:model.conversation.conversationId placeholderImage:[UIImage imageNamed:@"default_avatar"]];
    } else {
        _headImageView.image = [UIImage imageNamed:@"default_group_avatar"];
    }
    _nameLabel.text = model.title;
    _contentLabel.text = [self _latestMessageTitleWithConversation:model.conversation];
    _timeLabel.text = [self _latestMessageTimeWithConversation:model.conversation];
}

#pragma mark - private

- (NSString *)_latestMessageTitleWithConversation:(EMConversation *)conversation
{
    NSString *latestMessageTitle = @"";
    EMMessage *lastMessage = [conversation latestMessage];
    if (lastMessage) {
        EMMessageBody *messageBody = lastMessage.body;
        switch (messageBody.type) {
            case EMMessageBodyTypeImage:{
                latestMessageTitle = NSLocalizedString(@"chat.image1", @"[image]");
            } break;
            case EMMessageBodyTypeText:{
                latestMessageTitle = [EMConvertToCommonEmoticonsHelper convertToSystemEmoticons:((EMTextMessageBody *)messageBody).text];
            } break;
            case EMMessageBodyTypeVoice:{
                latestMessageTitle = NSLocalizedString(@"chat.voice1", @"[voice]");
            } break;
            case EMMessageBodyTypeLocation: {
                latestMessageTitle = NSLocalizedString(@"chat.location1", @"[location]");
            } break;
            case EMMessageBodyTypeVideo: {
                latestMessageTitle = NSLocalizedString(@"chat.video1", @"[video]");
            } break;
            case EMMessageBodyTypeFile: {
                latestMessageTitle = NSLocalizedString(@"chat.file1", @"[file]");
            } break;
            default: {
            } break;
        }
    }
    return latestMessageTitle;
}

- (NSString *)_latestMessageTimeWithConversation:(EMConversation*)conversation
{
    NSString *latestMessageTime = @"";
    EMMessage *lastMessage = [conversation latestMessage];;
    if (lastMessage) {
        double timeInterval = lastMessage.timestamp ;
        if(timeInterval > 140000000000) {
            timeInterval = timeInterval / 1000;
        }
        NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"YYYY-MM-dd"];
        latestMessageTime = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:timeInterval]];
    }
    return latestMessageTime;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
