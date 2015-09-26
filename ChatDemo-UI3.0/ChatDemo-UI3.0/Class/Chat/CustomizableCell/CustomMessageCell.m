//
//  CustomMessageCell.m
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 15/8/26.
//  Copyright (c) 2015年 easemob.com. All rights reserved.
//

#import "CustomMessageCell.h"
#import "EMBubbleView+ImageText.h"
#import "EMBubbleView+Gif.h"
#import "EMGifImage.h"

#import "EaseMob.h"

@interface CustomMessageCell ()
{
    NSDataDetector *_detector;
    NSArray *_urlMatches;
}
@end

@implementation CustomMessageCell

+ (void)initialize
{
    // UIAppearance Proxy Defaults
}

#pragma mark - IModelCell

- (BOOL)isCustomBubbleView:(id<IMessageModel>)model
{
    BOOL flag = NO;
    switch (model.bodyType) {
        case eMessageBodyType_Text:
        {
            if ([model.message.ext objectForKey:@"em_emotion"]) {
                flag = YES;
            } else {
                flag = YES;
            }
        }
//            break;
//        case eMessageBodyType_Image:
//        case eMessageBodyType_Video:
//        case eMessageBodyType_Location:
//        case eMessageBodyType_Voice:
//        case eMessageBodyType_File:
            break;
        default:
            break;
    }
    return flag;
}

- (void)setCustomModel:(id<IMessageModel>)model
{
    if ([model.message.ext objectForKey:@"em_emotion"]) {
        UIImage *image = [EMGifImage imageNamed:[model.message.ext objectForKey:@"em_emotion"]];
        if (!image) {
            image = model.image;
            if (!image) {
                image = [UIImage imageNamed:model.failImageName];
            }
        }
        _bubbleView.imageView.image = image;
    } else {
        _detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
        _urlMatches = [_detector matchesInString:model.text options:0 range:NSMakeRange(0, model.text.length)];
        NSMutableAttributedString * attributedString = [[NSMutableAttributedString alloc]
                                                        initWithString:model.text];
        NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineSpacing:0];
        [attributedString addAttribute:NSParagraphStyleAttributeName
                                 value:paragraphStyle
                                 range:NSMakeRange(0, [model.text length])];
        [_bubbleView.textLabel setAttributedText:attributedString];
        [self highlightLinksWithIndex:NSNotFound];
    }
}

- (void)setCustomBubbleView:(id<IMessageModel>)model
{
    if ([model.message.ext objectForKey:@"em_emotion"]) {
        [_bubbleView setupGifBubbleView];
        
        _bubbleView.imageView.image = [UIImage imageNamed:@"imageDownloadFail"];
    } else {
        [_bubbleView setupImageTextBubbleView];
        
        _bubbleView.textLabel.font = self.messageTextFont;
        _bubbleView.textLabel.textColor = [UIColor grayColor];
    }
}

- (void)updateCustomBubbleViewMargin:(UIEdgeInsets)bubbleMargin model:(id<IMessageModel>)model
{
    if ([model.message.ext objectForKey:@"em_emotion"]) {
        [_bubbleView updateGifMargin:bubbleMargin];
    } else {
        [_bubbleView updateImageTextMargin:bubbleMargin];
    }
}

+ (NSString *)cellIdentifierWithModel:(id<IMessageModel>)model
{
    if ([model.message.ext objectForKey:@"em_emotion"]) {
        return model.isSender?@"EMMessageCellSendGif":@"EMMessageCellRecvGif";
    } else {
        NSString *identifier = [EMSendMessageCell cellIdentifierWithModel:model];
        return identifier;
    }
}

+ (CGFloat)cellHeightWithModel:(id<IMessageModel>)model
{
    if ([model.message.ext objectForKey:@"em_emotion"]) {
        return 100;
    } else {
        CGFloat height = [EMSendMessageCell cellHeightWithModel:model];
        return height;
    }
}

#pragma mark - private

- (BOOL)isIndex:(CFIndex)index inRange:(NSRange)range
{
    return index > range.location && index < range.location+range.length;
}

- (void)highlightLinksWithIndex:(CFIndex)index {
    NSMutableAttributedString* attributedString = [_bubbleView.textLabel.attributedText mutableCopy];
    for (NSTextCheckingResult *match in _urlMatches) {
        if ([match resultType] == NSTextCheckingTypeLink || [match resultType] == NSTextCheckingTypeReplacement) {
            NSRange matchRange = [match range];
            if ([self isIndex:index inRange:matchRange]) {
                [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:matchRange];
            }
            else {
                [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:matchRange];
            }
            [attributedString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:matchRange];
        }
    }
    _bubbleView.textLabel.attributedText = attributedString;
}

@end
