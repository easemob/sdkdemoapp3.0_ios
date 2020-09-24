//
//  EMChatBarItem.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/30.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EMChatBarItem : UIControl

@property (nonatomic) CGFloat titleHeightRatio;

- (instancetype)initWithImage:(UIImage *)aImage
                        title:(NSString *)aTitle;

@end

NS_ASSUME_NONNULL_END
