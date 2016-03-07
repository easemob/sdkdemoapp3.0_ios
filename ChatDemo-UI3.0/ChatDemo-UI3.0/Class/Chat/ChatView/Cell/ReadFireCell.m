//
//  ReadFireCell.m
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 16/1/18.
//  Copyright © 2016年 EaseMob. All rights reserved.
//

#import "ReadFireCell.h"
#import "IMessageModel.h"

@interface ReadFireCell()

@property (nonatomic, strong) UIImageView *frontImageView;//上面遮罩

@end

@implementation ReadFireCell

+ (void)initialize
{
    // UIAppearance Proxy Defaults
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier
                        model:(id<IMessageModel>)model
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier model:model];
    if (self)
    {
    }
    return self;
}

- (void)_setupFrontImageViewConstraints
{
    [self.bubbleView addConstraint:[NSLayoutConstraint constraintWithItem:_frontImageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.bubbleView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
    
    [self.bubbleView addConstraint:[NSLayoutConstraint constraintWithItem:_frontImageView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.bubbleView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
    
    [self.bubbleView addConstraint:[NSLayoutConstraint constraintWithItem:_frontImageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.bubbleView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    
    [self.bubbleView addConstraint:[NSLayoutConstraint constraintWithItem:_frontImageView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.bubbleView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0]];
    
    [self.bubbleView addConstraint:[NSLayoutConstraint constraintWithItem:_frontImageView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.bubbleView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0]];
    
}

- (UIImageView *)frontImageView
{
    if (_frontImageView == nil)
    {
        _frontImageView = [[UIImageView alloc] init];
        _frontImageView.translatesAutoresizingMaskIntoConstraints = NO;
        _frontImageView.backgroundColor = [UIColor clearColor];
        [self.bubbleView addSubview:_frontImageView];
        [self.bubbleView bringSubviewToFront:_frontImageView];
        [self _setupFrontImageViewConstraints];
    }
    return _frontImageView;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.frontImageView.image = self.bubbleView.backgroundImageView.image;
}


#pragma mark - IModelCell

- (void)setModel:(id<IMessageModel>)model {
    [super setModel:model];
    self.hasRead.hidden = YES;
    self.frontImageView.hidden = NO;
    //语音
    if (model.bodyType == EMMessageBodyTypeVoice) {
        CGRect rect = self.bubbleView.frame;
        rect.origin.x = 0;
        rect.origin.y = 0;
        rect.size.width += 10;
        self.frontImageView.frame = rect;
    }
}

- (void)isReadMessage:(BOOL)isRead {
    self.frontImageView.hidden = isRead;
    //发送者本身不加遮罩
    if (self.model.isSender)
    {
        self.frontImageView.hidden = YES;
    }
}

- (BOOL)isCustomBubbleView:(id<IMessageModel>)model
{
    BOOL flag = NO;
    if ([model.message.ext objectForKey:MESSAGE_ATTR_IS_BIG_EXPRESSION]) {
        return YES;
    }
    return flag;
    
//    BOOL flag = NO;
//    switch (model.bodyType) {
//        case EMMessageBodyTypeText:
//        {
//            if ([model.message.ext objectForKey:@"em_emotion"]) {
//                flag = YES;
//            }
//        }
//            break;
//        default:
//            break;
//    }
//    return flag;
}

- (void)setCustomModel:(id<IMessageModel>)model
{
    
}

- (void)setCustomBubbleView:(id<IMessageModel>)model
{
    
}

- (void)updateCustomBubbleViewMargin:(UIEdgeInsets)bubbleMargin model:(id<IMessageModel>)model
{
    
}

+ (NSString *)cellIdentifierWithModel:(id<IMessageModel>)model 
{
    if ([model.message.ext objectForKey:@"em_emotion"]) {
        return model.isSender?@"EaseMessageCellSendGif":@"EaseMessageCellRecvGif";
    }
    else {
        return [ReadFireCell readBurnCellIdentifier:model];
    }
}

+ (CGFloat)cellHeightWithModel:(id<IMessageModel>)model
{
    if ([model.message.ext objectForKey:@"em_emotion"]) {
        return 100;
    } else {
        CGFloat height = [EaseBaseMessageCell cellHeightWithModel:model];
        return height;
    }
}

+ (NSString *)readBurnCellIdentifier:(id<IMessageModel>)model
{
    NSString *cellIdentifier = nil;
    NSString *cellSuffix = @"_BurnAfterRead";
    if (model.isSender) {
        switch (model.bodyType) {
            case EMMessageBodyTypeText:
                cellIdentifier = [EaseMessageCellIdentifierSendText stringByAppendingString:cellSuffix];
                break;
            case EMMessageBodyTypeImage:
                cellIdentifier = [EaseMessageCellIdentifierSendImage stringByAppendingString:cellSuffix];
                break;
            case EMMessageBodyTypeVideo:
                cellIdentifier = [EaseMessageCellIdentifierSendVideo stringByAppendingString:cellSuffix];
                break;
            case EMMessageBodyTypeLocation:
                cellIdentifier = [EaseMessageCellIdentifierSendLocation stringByAppendingString:cellSuffix];
                break;
            case EMMessageBodyTypeVoice:
                cellIdentifier = [EaseMessageCellIdentifierSendVoice stringByAppendingString:cellSuffix];
                break;
            case EMMessageBodyTypeFile:
                cellIdentifier = [EaseMessageCellIdentifierSendFile stringByAppendingString:cellSuffix];
                break;
            default:
                break;
        }
    }
    else{
        switch (model.bodyType) {
            case EMMessageBodyTypeText:
                cellIdentifier = [EaseMessageCellIdentifierRecvText stringByAppendingString:cellSuffix];
                break;
            case EMMessageBodyTypeImage:
                cellIdentifier = [EaseMessageCellIdentifierRecvImage stringByAppendingString:cellSuffix];
                break;
            case EMMessageBodyTypeVideo:
                cellIdentifier = [EaseMessageCellIdentifierRecvVideo stringByAppendingString:cellSuffix];
                break;
            case EMMessageBodyTypeLocation:
                cellIdentifier = [EaseMessageCellIdentifierRecvLocation stringByAppendingString:cellSuffix];
                break;
            case EMMessageBodyTypeVoice:
                cellIdentifier = [EaseMessageCellIdentifierRecvVoice stringByAppendingString:cellSuffix];
                break;
            case EMMessageBodyTypeFile:
                cellIdentifier = [EaseMessageCellIdentifierRecvFile stringByAppendingString:cellSuffix];
                break;
            default:
                break;
        }
    }
    return cellIdentifier;
}

@end
