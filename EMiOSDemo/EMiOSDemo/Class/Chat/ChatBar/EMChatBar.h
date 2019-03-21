//
//  EMChatBar.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/25.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EMTextView.h"
#import "EMChatBarEmoticonView.h"
#import "EMChatBarRecordAudioView.h"

NS_ASSUME_NONNULL_BEGIN

@protocol EMChatBarDelegate;
@interface EMChatBar : UIView

@property (nonatomic, weak) id<EMChatBarDelegate> delegate;

@property (nonatomic, strong) EMTextView *textView;

@property (nonatomic, strong) UIView *buttonsView;

@property (nonatomic, strong) EMChatBarRecordAudioView *recordAudioView;
@property (nonatomic, strong) EMChatBarEmoticonView *moreEmoticonView;

- (void)clearInputViewText;

- (void)inputViewAppendText:(NSString *)aText;

- (void)clearMoreViewAndSelectedButton;

@end


@protocol EMChatBarDelegate <NSObject>

@optional

- (BOOL)inputView:(EMTextView *)aInputView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;

- (void)inputViewDidChange:(EMTextView *)aInputView;

- (void)chatBarDidCameraAction;

- (void)chatBarDidPhotoAction;

- (void)chatBarDidLocationAction;

- (void)chatBarDidCallAction;

- (void)chatBarDidShowMoreViewAction;

//- (void)chatBarHeightDidChanged;

@end

NS_ASSUME_NONNULL_END
