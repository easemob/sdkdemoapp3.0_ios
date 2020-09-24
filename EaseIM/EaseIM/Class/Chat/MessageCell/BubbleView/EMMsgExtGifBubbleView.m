//
//  EMMsgExtGifBubbleView.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/2/14.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EMMsgExtGifBubbleView.h"

#import "EMEmoticonGroup.h"

@implementation EMMsgExtGifBubbleView

- (instancetype)initWithDirection:(EMMessageDirection)aDirection
                             type:(EMMessageType)aType
{
    self = [super initWithDirection:aDirection type:aType];
    if (self) {
        self.gifView = [[FLAnimatedImageView alloc] init];
        [self addSubview:self.gifView];
        [self.gifView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
            make.width.height.lessThanOrEqualTo(@100);
        }];
    }
    
    return self;
}

#pragma mark - Setter

- (void)setModel:(EMMessageModel *)model
{
    EMMessageType type = model.type;
    if (type == EMMessageTypeExtGif) {
        NSString *name = [(EMTextMessageBody *)model.emModel.body text];
        EMEmoticonGroup *group = [EMEmoticonGroup getGifGroup];
        for (EMEmoticonModel *model in group.dataArray) {
            if ([model.name isEqualToString:name]) {
                NSString *path = [[NSBundle mainBundle] pathForResource:model.original ofType:@"gif"];
                NSData *imageData = [NSData dataWithContentsOfFile:path];
                self.gifView.animatedImage = [FLAnimatedImage animatedImageWithGIFData:imageData];;
                break;
            }
        }
    }
}

@end
