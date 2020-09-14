//
//  EMConversationCell.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/8.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EMConversationCell.h"

#import "EMDateHelper.h"
#import "EMConversationHelper.h"


@interface EMConversationCell()<UIGestureRecognizerDelegate>

@end

@implementation EMConversationCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier
{
   self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
   if (self){
       self.selectionStyle = UITableViewCellSelectionStyleDefault;
       self.selectedBackgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height)];
       self.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:233/255.0 green:233/255.0 blue:233/255.0 alpha:1.0];
       self.backgroundColor = [UIColor whiteColor];
       [self _setupSubview];
   }
   return self;
}

#pragma mark - private layout subviews

- (void)_setupSubview
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    _avatarView = [[UIImageView alloc] init];
    [self.contentView addSubview:_avatarView];
    [_avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(14);
        make.left.equalTo(self.contentView).offset(16);
        make.bottom.equalTo(self.contentView).offset(-14);
        make.width.equalTo(self.avatarView.mas_height).multipliedBy(1);
    }];
    
    _timeLabel = [[UILabel alloc] init];
    _timeLabel.font = [UIFont systemFontOfSize:12];
    _timeLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
    _timeLabel.backgroundColor = [UIColor clearColor];
    [_timeLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.contentView addSubview:_timeLabel];
    [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.avatarView);
        make.right.equalTo(self.contentView).offset(-15);
    }];
    
    _nameLabel = [[UILabel alloc] init];
    _nameLabel.backgroundColor = [UIColor clearColor];
    _nameLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
    _nameLabel.font = [UIFont systemFontOfSize:16];
    [self.contentView addSubview:_nameLabel];
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.contentView.mas_centerY);
        make.left.equalTo(self.avatarView.mas_right).offset(8);
        make.right.equalTo(self.timeLabel.mas_left);
    }];
    
    _badgeLabel = [[EMBadgeLabel alloc] init];
    _badgeLabel.clipsToBounds = YES;
    _badgeLabel.layer.cornerRadius = 10;
    [self.contentView addSubview:_badgeLabel];
    [_badgeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_centerY).offset(3);
        make.right.equalTo(self.contentView).offset(-15);
        make.height.equalTo(@20);
        make.width.greaterThanOrEqualTo(@20);
    }];
    
    _detailLabel = [[UILabel alloc] init];
    _detailLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _detailLabel.backgroundColor = [UIColor clearColor];
    _detailLabel.font = [UIFont systemFontOfSize:16];
    _detailLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
    [self.contentView addSubview:_detailLabel];
    [_detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_centerY).offset(3);
        make.left.equalTo(self.nameLabel);
        make.right.equalTo(self.badgeLabel.mas_left).offset(-5);
        make.bottom.equalTo(self.contentView).offset(-8);
    }];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellTapAction:)];
    tap.delegate = self;
    [self addGestureRecognizer:tap];
    tap.delaysTouchesBegan = YES;
    tap.delaysTouchesEnded = YES;
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(cellLongPressAction:)];
    [self addGestureRecognizer:longPress];

    self.selectionStyle = UITableViewCellSelectionStyleGray;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {
        return NO;
    }
    return YES;
}

#pragma mark - Action

- (void)cellTapAction:(UITapGestureRecognizer *)aTap
{
    if(aTap.state == UIGestureRecognizerStateBegan) {
    }

}

- (void)cellLongPressAction:(UILongPressGestureRecognizer *)aLongPress
{
    if (aLongPress.state == UIGestureRecognizerStateBegan) {
        self.selected = YES;
        if (self.delegate && [self.delegate respondsToSelector:@selector(conversationCellDidLongPress:)]) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setSelectedStatus) name:UIMenuControllerDidHideMenuNotification object:nil];
            [self.delegate conversationCellDidLongPress:self];
        }
    }
}

- (void)setSelectedStatus
{
    if(![self.model.emModel.ext objectForKey:CONVERSATION_STICK] || ([self.model.emModel.ext objectForKey:CONVERSATION_STICK] && [(NSNumber *)[self.model.emModel.ext objectForKey:CONVERSATION_STICK] isEqualToNumber:[NSNumber numberWithLong:0]]) || (self.model.notiModel && (!self.model.notiModel.stickTime || [self.model.notiModel.stickTime isEqualToNumber:[NSNumber numberWithLong:0]]))) {
        self.selected = NO;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIMenuControllerDidHideMenuNotification object:nil];
}

#pragma mark - setter

- (NSAttributedString *)_getDetailWithModel:(EMConversation *)aConversation
{
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:@""];
    
    EMMessage *lastMessage = [aConversation latestMessage];
    if (!lastMessage) {
        return attributedStr;
    }
    
    NSString *latestMessageTitle = @"";
    EMMessageBody *messageBody = lastMessage.body;
    switch (messageBody.type) {
        case EMMessageBodyTypeText:
        {
            NSString *str = [EMEmojiHelper convertEmoji:((EMTextMessageBody *)messageBody).text];
            if ([str isEqualToString:EMCOMMUNICATE_CALLER_MISSEDCALL]) {
                str = @"未接听，点击回拨";
                if ([lastMessage.from isEqualToString:[EMClient sharedClient].currentUsername])
                    str = @"已取消";
            }
            if ([str isEqualToString:EMCOMMUNICATE_CALLED_MISSEDCALL]) {
                str = @"对方已取消";
                if ([lastMessage.from isEqualToString:[EMClient sharedClient].currentUsername])
                    str = @"对方拒绝通话";
            }
            latestMessageTitle = str;
            if (lastMessage.ext && [lastMessage.ext objectForKey:EMCOMMUNICATE_TYPE]) {
                NSString *communicateStr = @"";
                if ([[lastMessage.ext objectForKey:EMCOMMUNICATE_TYPE] isEqualToString:EMCOMMUNICATE_TYPE_VIDEO])
                    communicateStr = @"[视频通话]";
                if ([[lastMessage.ext objectForKey:EMCOMMUNICATE_TYPE] isEqualToString:EMCOMMUNICATE_TYPE_VOICE])
                    communicateStr = @"[语音通话]";
                latestMessageTitle = [NSString stringWithFormat:@"%@ %@", communicateStr, latestMessageTitle];
            }
        }
            break;
        case EMMessageBodyTypeImage:
            latestMessageTitle = @"[图片]";
            break;
        case EMMessageBodyTypeVoice:
            latestMessageTitle = @"[音频]";
            break;
        case EMMessageBodyTypeLocation:
            latestMessageTitle = @"[位置]";
            break;
        case EMMessageBodyTypeVideo:
            latestMessageTitle = @"[视频]";
            break;
        case EMMessageBodyTypeFile:
            latestMessageTitle = @"[文件]";
            break;
        default:
            break;
    }
    
//    if (lastMessage.direction == EMMessageDirectionReceive) {
//        NSString *from = lastMessage.from;
//        latestMessageTitle = [NSString stringWithFormat:@"%@: %@", from, latestMessageTitle];
//    }
    
    NSDictionary *ext = aConversation.ext;
    if (ext && [ext[kConversation_IsRead] isEqualToString:kConversation_AtAll]) {
        NSString *allMsg = @"[有全体消息]";
        latestMessageTitle = [NSString stringWithFormat:@"%@ %@", allMsg, latestMessageTitle];
        attributedStr = [[NSMutableAttributedString alloc] initWithString:latestMessageTitle];
        [attributedStr setAttributes:@{NSForegroundColorAttributeName : [UIColor colorWithRed:1.0 green:.0 blue:.0 alpha:0.5]} range:NSMakeRange(0, allMsg.length)];
    } else if (ext && [ext[kConversation_IsRead] isEqualToString:kConversation_AtYou]) {
        NSString *atStr = @"[有人@我]";
        latestMessageTitle = [NSString stringWithFormat:@"%@ %@", atStr, latestMessageTitle];
        attributedStr = [[NSMutableAttributedString alloc] initWithString:latestMessageTitle];
        [attributedStr setAttributes:@{NSForegroundColorAttributeName : [UIColor colorWithRed:255/255.0 green:43/255.0 blue:43/255.0 alpha:1.0]} range:NSMakeRange(0, atStr.length)];
    } else if (ext && [ext objectForKey:kConversation_Draft] && ![[ext objectForKey:kConversation_Draft] isEqualToString:@""]){
        NSString *draftStr = @"[草稿]";
        latestMessageTitle = [NSString stringWithFormat:@"%@ %@", draftStr, [ext objectForKey:kConversation_Draft]];
        attributedStr = [[NSMutableAttributedString alloc] initWithString:latestMessageTitle];
        [attributedStr setAttributes:@{NSForegroundColorAttributeName : [UIColor colorWithRed:255/255.0 green:43/255.0 blue:43/255.0 alpha:1.0]} range:NSMakeRange(0, draftStr.length)];
    } else {
        attributedStr = [[NSMutableAttributedString alloc] initWithString:latestMessageTitle];
    }
    
    return attributedStr;
}

- (NSString *)_getTimeWithModel:(EMConversation *)aConversation
{
    NSString *latestMessageTime = @"";
    EMMessage *lastMessage = [aConversation latestMessage];;
    if (lastMessage) {
        double timeInterval = lastMessage.timestamp ;
        if(timeInterval > 140000000000) {
            timeInterval = timeInterval / 1000;
        }
        NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        latestMessageTime = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:timeInterval]];
    }
    return latestMessageTime;
}

- (void)setModel:(EMConversationModel *)model
{
    _model = model;
    if (model.notiModel) {
        //系统通知
        [self _setNotiModel:_model.notiModel];
    } else {
        EMConversation *conversation = self.model.emModel;
        if (conversation.type == EMConversationTypeChat)
            self.avatarView.image = [UIImage imageNamed:@"defaultAvatar"];
        if (conversation.type == EMConversationTypeGroupChat)
            self.avatarView.image = [UIImage imageNamed:@"groupConversation"];
        if (conversation.type == EMConversationTypeChatRoom)
            self.avatarView.image = [UIImage imageNamed:@"chatroomConversation"];
        self.nameLabel.text = self.model.name;
        self.detailLabel.attributedText = [self _getDetailWithModel:conversation];
        self.timeLabel.text = [self _getTimeWithModel:conversation];
        
        if (conversation.unreadMessagesCount == 0) {
            self.badgeLabel.value = @"";
            self.badgeLabel.hidden = YES;
        } else {
            self.badgeLabel.value = [NSString stringWithFormat:@" %@ ", @(conversation.unreadMessagesCount)];
            self.badgeLabel.hidden = NO;
        }
    }
}

-(void)_setNotiModel:(EMNotificationModel *)notiModel
{
    self.avatarView.image = [UIImage imageNamed:@"systemNotify"];
    self.nameLabel.text = @"系统通知";
    if (notiModel.type == EMNotificationModelTypeContact)
        self.detailLabel.attributedText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"好友申请来自：%@",notiModel.sender]];
    if (notiModel.type == EMNotificationModelTypeGroupJoin)
        self.detailLabel.attributedText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"加群申请来自：%@",notiModel.sender]];
    if (notiModel.type == EMNotificationModelTypeGroupInvite)
        self.detailLabel.attributedText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"加群邀请来自：%@",notiModel.sender]];
    self.timeLabel.text = [notiModel.time substringToIndex:10];
    if (EMNotificationHelper.shared.unreadCount == 0) {
        self.badgeLabel.value = @"";
        self.badgeLabel.hidden = YES;
    } else {
        self.badgeLabel.value = [NSString stringWithFormat:@" %@ ", @(EMNotificationHelper.shared.unreadCount)];
        self.badgeLabel.hidden = NO;
    }

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
    {
        [super setSelected:selected animated:animated];
        self.badgeLabel.backgroundColor = [UIColor redColor];
    }
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
    {
        [super setHighlighted:highlighted animated:animated];
        self.badgeLabel.backgroundColor = [UIColor redColor];
    }

@end
