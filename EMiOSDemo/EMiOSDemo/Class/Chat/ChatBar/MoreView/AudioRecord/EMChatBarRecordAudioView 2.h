//
//  EMChatBarRecordAudioView.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/29.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol EMChatBarRecordAudioViewDelegate;
@interface EMChatBarRecordAudioView : UIView

@property (nonatomic, weak) id<EMChatBarRecordAudioViewDelegate> delegate;

- (instancetype)initWithRecordPath:(NSString *)aPath;

@end

@protocol EMChatBarRecordAudioViewDelegate <NSObject>

- (void)chatBarRecordAudioViewStartRecord;

- (void)chatBarRecordAudioViewStopRecord:(NSString *)aPath
                              timeLength:(NSInteger)aTimeLength;

- (void)chatBarRecordAudioViewCancelRecord;

@end

NS_ASSUME_NONNULL_END
