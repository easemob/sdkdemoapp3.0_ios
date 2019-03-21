//
//  EMMsgLocationBubbleView.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/2/14.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EMMsgLocationBubbleView.h"

@implementation EMMsgLocationBubbleView

- (instancetype)initWithDirection:(EMMessageDirection)aDirection
                             type:(EMMessageType)aType
{
    self = [super initWithDirection:aDirection type:aType];
    if (self) {
        if (self.direction == EMMessageDirectionSend) {
            self.iconView.image = [UIImage imageNamed:@"msg_location_white"];
        } else {
            self.iconView.image = [UIImage imageNamed:@"msg_location"];
        }
    }
    
    return self;
}

#pragma mark - Setter

- (void)setModel:(EMMessageModel *)model
{
    EMMessageType type = model.type;
    if (type == EMMessageTypeLocation) {
        EMLocationMessageBody *body = (EMLocationMessageBody *)model.emModel.body;
        self.textLabel.text = body.address;
        self.detailLabel.text = [NSString stringWithFormat:@"纬度:%.2lf°, 经度:%.2lf°", body.latitude, body.longitude];
    }
}

@end
