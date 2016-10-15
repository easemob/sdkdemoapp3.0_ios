//
//  EMChatToolBar.h
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 16/9/23.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EMChatToolBarDelegate <NSObject>

@optional

- (void)didSendText:(NSString*)text;

- (void)didSendAudio:(NSString*)recordPath duration:(NSInteger)duration;

- (void)didTakePhotos;

- (void)didSelectPhotos;

- (void)didSelectLocation;

@required

- (void)chatToolBarDidChangeFrameToHeight:(CGFloat)toHeight;

@end

@interface EMChatToolBar : UIView

@property (weak, nonatomic) id<EMChatToolBarDelegate> delegate;

@end
