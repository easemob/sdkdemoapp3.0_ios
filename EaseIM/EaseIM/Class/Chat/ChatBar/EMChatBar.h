//
//  EMChatBar.h
//  ChatDemo-UI3.0
//
//  Updated by zhangchong on 2020/06/05.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EMTextView.h"
#import "EMChatBarEmoticonView.h"
#import "EMChatBarRecordAudioView.h"
#import "EMMoreFunctionView.h"

NS_ASSUME_NONNULL_BEGIN

@protocol EMChatBarDelegate;
@interface EMChatBar : UIView

@property (nonatomic, weak) id<EMChatBarDelegate> delegate;

@property (nonatomic, strong) EMTextView *textView;

@property (nonatomic, strong) UIButton *sendBtn;

@property (nonatomic, strong) EMChatBarRecordAudioView *recordAudioView;
@property (nonatomic, strong) EMChatBarEmoticonView *moreEmoticonView;
@property (nonatomic, strong) EMMoreFunctionView *moreFunctionView;

- (void)clearInputViewText;

- (void)inputViewAppendText:(NSString *)aText;

- (void)deleteTailText;

- (void)clearMoreViewAndSelectedButton;

- (void)textChangedExt;

@end


@protocol EMChatBarDelegate <NSObject>

@optional

- (BOOL)inputView:(EMTextView *)aInputView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;

- (void)inputViewDidChange:(EMTextView *)aInputView;

- (void)chatBarDidShowMoreViewAction;

@end

NS_ASSUME_NONNULL_END
