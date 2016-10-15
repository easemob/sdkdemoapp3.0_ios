//
//  EMChatRecordView.h
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 16/9/24.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EMChatRecordViewDelegate <NSObject>

- (void)didFinishRecord:(NSString*)recordPath duration:(NSInteger)duration;

@end

@interface EMChatRecordView : UIView

@property (weak, nonatomic) id<EMChatRecordViewDelegate> delegate;

@end
