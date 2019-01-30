//
//  EMChatBar.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/25.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EMTextView.h"

NS_ASSUME_NONNULL_BEGIN

@protocol EMChatBarDelegate;
@interface EMChatBar : UIView

@property (nonatomic, weak) id<EMChatBarDelegate> delegate;

@property (nonatomic, strong) EMTextView *inputView;

@property (nonatomic, strong) UIView *buttonsView;

- (void)clearInputViewText;

@end


@protocol EMChatBarDelegate <NSObject>

@optional

- (BOOL)inputView:(EMTextView *)aInputView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;

- (void)inputViewDidChange:(EMTextView *)aInputView;

- (void)chatBarDidCameraAction;

- (void)chatBarDidPhotoAction;

- (void)chatBarDidLocationAction;

//- (void)chatBarHeightDidChanged;

- (void)chatBarDidAudioCallAction;
- (void)chatBarDidVideoCallAction;

@end

NS_ASSUME_NONNULL_END
