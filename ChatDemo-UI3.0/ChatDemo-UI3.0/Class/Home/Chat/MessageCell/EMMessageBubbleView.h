//
//  EMMessageBubbleView.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/25.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EMMessageModel;
@interface EMMessageBubbleView : UIImageView

@property (nonatomic, strong) EMMessageModel *model;

- (instancetype)initWithDirection:(EMMessageDirection)aDirection
                             type:(EMMessageBodyType)aType;

@end
