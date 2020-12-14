//
//  EMMsgExtGifBubbleView.h
//  EMiOSDemo
//
//  Created by XieYajie on 2019/2/14.
//  Update © 2020 zhangchong. All rights reserved.
//

#import <FLAnimatedImage/FLAnimatedImage.h>
#import <FLAnimatedImage/FLAnimatedImageView.h>
#import "EMMessageBubbleView.h"

NS_ASSUME_NONNULL_BEGIN

@interface EMMsgExtGifBubbleView : EMMessageBubbleView

@property (nonatomic, strong) FLAnimatedImageView *gifView;

@end

NS_ASSUME_NONNULL_END
