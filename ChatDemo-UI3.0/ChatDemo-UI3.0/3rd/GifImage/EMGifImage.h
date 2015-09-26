//
//  MIGifImage.h
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 15/9/7.
//  Copyright (c) 2015年 easemob.com. All rights reserved.


#import <UIKit/UIKit.h>
#import <ImageIO/ImageIO.h>

@interface EMGifImage : UIImage

@property (nonatomic, readonly) NSTimeInterval *frameDurations;
@property (nonatomic, readonly) NSTimeInterval totalDuration;
@property (nonatomic, readonly) NSUInteger loopCount;

- (NSTimeInterval)frameDurationWithIndex:(NSInteger)index;
@end
