//
//  EMChatLocationBubbleView.m
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 16/9/28.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "EMChatLocationBubbleView.h"

#define LABEL_FONT_SIZE 13.f
#define LOCATION_IMAGEVIEW_SIZE 95

@interface EMChatLocationBubbleView ()

@property (nonatomic, strong) UILabel *addressLabel;

@end

@implementation EMChatLocationBubbleView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _addressLabel = [[UILabel alloc] init];
        _addressLabel.font = [UIFont systemFontOfSize:LABEL_FONT_SIZE];
        _addressLabel.textColor = RGBACOLOR(12, 18, 24, 1);
        _addressLabel.numberOfLines = 0;
        _addressLabel.backgroundColor = [UIColor clearColor];
        [self.backImageView addSubview:_addressLabel];
    }
    return self;
}

-(CGSize)sizeThatFits:(CGSize)size
{
    CGSize textBlockMinSize = {130, 25};
    EMLocationMessageBody *body = (EMLocationMessageBody*)self.message.body;
    CGSize addressSize = [body.address boundingRectWithSize:textBlockMinSize
                                                    options:NSStringDrawingUsesLineFragmentOrigin
                                                 attributes:@{NSFontAttributeName:_addressLabel.font}
                                                    context:nil].size;
    CGFloat width = addressSize.width < LOCATION_IMAGEVIEW_SIZE ? LOCATION_IMAGEVIEW_SIZE : addressSize.width;
    return CGSizeMake(width, LOCATION_IMAGEVIEW_SIZE);
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    _addressLabel.frame = CGRectMake(5, self.backImageView.height - 30, self.backImageView.width - 10, 25);
}

- (void)setMessage:(EMMessage *)message
{
    [super setMessage:message];
    EMLocationMessageBody *body = (EMLocationMessageBody*)message.body;
    _addressLabel.text = body.address;
}

+ (CGFloat)heightForBubbleWithMessage:(EMMessage *)message
{
    return 100.f;
}

@end
