//
//  EMChatToolBar.m
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 16/9/23.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "EMChatToolBar.h"

#import "EMChatRecordView.h"
#import "EMMessageTextView.h"
#import "EMConvertToCommonEmoticonsHelper.h"
#import "EMFaceView.h"

#define kDefaultToolBarHeight 83
#define kDefaultTextViewWidth KScreenWidth - 30.f

@interface EMChatToolBar () <UITextViewDelegate,EMChatRecordViewDelegate,EMFaceDelegate>

@property (strong, nonatomic) UIView *activityButtomView;
@property (nonatomic) BOOL isShowButtomView;

@property (weak, nonatomic) IBOutlet EMMessageTextView *inputTextView;

@property (weak, nonatomic) IBOutlet UIButton *cameraButton;
@property (weak, nonatomic) IBOutlet UIButton *photoButton;
@property (weak, nonatomic) IBOutlet UIButton *emotionButton;
@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (weak, nonatomic) IBOutlet UIButton *locationButton;
@property (weak, nonatomic) IBOutlet UIButton *fileButton;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UIView *line;

@property (strong, nonatomic) EMChatRecordView *recordView;
@property (strong, nonatomic) EMFaceView *faceView;

@property (strong, nonatomic) NSMutableArray *moreItems;

- (IBAction)cameraAction:(id)sender;
- (IBAction)photoAction:(id)sender;
- (IBAction)locationAction:(id)sender;
- (IBAction)recordAction:(id)sender;
- (IBAction)emotionAction:(id)sender;
- (IBAction)sendAction:(id)sender;

@end

@implementation EMChatToolBar

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chatKeyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
        
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _inputTextView.layer.borderColor = RGBACOLOR(189, 189, 189, 1).CGColor;
    _inputTextView.layer.borderWidth = 0.5;
    
    _cameraButton.left = (KScreenWidth/5 - _cameraButton.width)/2;
    _photoButton.left = (KScreenWidth/5 - _photoButton.width)/2 + KScreenWidth/5 * 1;
    _emotionButton.left = (KScreenWidth/5 - _emotionButton.width)/2 + KScreenWidth/5 * 2;
    _recordButton.left = (KScreenWidth/5 - _recordButton.width)/2 + KScreenWidth/5 * 3;
    _locationButton.left = (KScreenWidth/5 - _locationButton.width)/2 + KScreenWidth/5 * 4;
    
    _inputTextView.placeHolder = NSLocalizedString(@"chat.placeHolder", @"Send Message");
    _inputTextView.placeHolderTextColor = RGBACOLOR(173, 185, 193, 1);
    _line.width = KScreenWidth;
    
    _sendButton.left = KScreenWidth - _sendButton.width - 15.f;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    CGContextFillRect(context, rect);

//    CGContextSetStrokeColorWithColor(context, RGBACOLOR(189, 189, 189, 1).CGColor);
//    CGContextStrokeRect(context, CGRectMake(0, 0, rect.size.width, 0.5));

//    CGContextSetStrokeColorWithColor(context, RGBACOLOR(0xe5, 0xe5, 0xe5, 1).CGColor);
//    CGContextStrokeRect(context, CGRectMake(0, rect.size.height - 0.5, rect.size.width, 0.5));
    
    _inputTextView.width = kDefaultTextViewWidth;
}
#pragma mark - getter

- (EMChatRecordView*)recordView
{
    if (_recordView == nil) {
        _recordView = (EMChatRecordView*)[[[NSBundle mainBundle]loadNibNamed:@"EMChatRecordView" owner:nil options:nil] firstObject];
        _recordView.delegate = self;
    }
    return _recordView;
}

- (EMFaceView*)faceView
{
    if (_faceView == nil) {
        _faceView = [[EMFaceView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 180)];
        [_faceView setDelegate:self];
        _faceView.backgroundColor = [UIColor colorWithRed:240 / 255.0 green:242 / 255.0 blue:247 / 255.0 alpha:1.0];
        _faceView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    }
    return _faceView;
}

- (NSMutableArray*)moreItems
{
    if (_moreItems == nil) {
        _moreItems = [NSMutableArray arrayWithArray:@[self.cameraButton,self.photoButton,self.emotionButton,self.recordButton,self.locationButton,self.fileButton]];
    }
    return _moreItems;
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    return YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    for (UIButton *btn in self.moreItems) {
        btn.selected = NO;
    }
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    _sendButton.hidden = NO;
    [UIView animateWithDuration:0.25 animations:^{
        [_inputTextView setNeedsDisplay];
        _inputTextView.width = kDefaultTextViewWidth - _sendButton.width - 15.f;
    }];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    _sendButton.hidden = YES;
    [UIView animateWithDuration:0.25 animations:^{
        [_inputTextView setNeedsDisplay];
        _inputTextView.width = kDefaultTextViewWidth;
    }];
}

- (void)textViewDidChange:(UITextView *)textView
{
    [textView setNeedsDisplay];
}

#pragma mark - EMFaceDelegate

- (void)selectedFacialView:(NSString *)str isDelete:(BOOL)isDelete
{
    NSString *chatText = self.inputTextView.text;
    
    if (!isDelete && str.length > 0) {
        self.inputTextView.text = [NSString stringWithFormat:@"%@%@",chatText,str];
    } else {
        if (chatText.length >= 2) {
            NSString *subStr = [chatText substringFromIndex:chatText.length-2];
            if ([self.faceView stringIsFace:subStr]) {
                self.inputTextView.text = [chatText substringToIndex:chatText.length-2];
                [self textViewDidChange:self.inputTextView];
                return;
            }
        }
        if (chatText.length > 0) {
            self.inputTextView.text = [chatText substringToIndex:chatText.length-1];
        }
    }
    
    [self textViewDidChange:self.inputTextView];
}

-(NSMutableAttributedString*)backspaceText:(NSMutableAttributedString*) attr length:(NSInteger)length
{
    NSRange range = [self.inputTextView selectedRange];
    if (range.location == 0) {
        return attr;
    }
    [attr deleteCharactersInRange:NSMakeRange(range.location - length, length)];
    return attr;
}

- (void)sendFace
{
    NSString *chatText = self.inputTextView.text;
    if (chatText.length > 0) {
        if ([self.delegate respondsToSelector:@selector(didSendText:)]) {
            if (![_inputTextView.text isEqualToString:@""]) {
                NSMutableString *attStr = [[NSMutableString alloc] initWithString:self.inputTextView.attributedText.string];
                [self.delegate didSendText:attStr];
                self.inputTextView.text = @"";
            }
        }
    }
}

#pragma mark - EMChatRecordViewDelegate

- (void)didFinishRecord:(NSString *)recordPath duration:(NSInteger)duration
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSendAudio:duration:)]) {
        [self.delegate didSendAudio:recordPath duration:duration];
    }
}

#pragma mark - UIKeyboardNotification

- (void)chatKeyboardWillChangeFrame:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    CGRect endFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect beginFrame = [userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGFloat duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    void(^animations)() = ^{
        [self _willShowKeyboardFromFrame:beginFrame toFrame:endFrame];
    };
    
    [UIView animateWithDuration:duration delay:0.0f options:(curve << 16 | UIViewAnimationOptionBeginFromCurrentState) animations:animations completion:nil];
}

#pragma mark - action

- (IBAction)cameraAction:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTakePhotos)]) {
        [self.delegate didTakePhotos];
    }
}

- (IBAction)photoAction:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectPhotos)]) {
        [self.delegate didSelectPhotos];
    }
}

- (IBAction)emotionAction:(id)sender
{
    UIButton *button = (UIButton*)sender;
    button.selected = !button.selected;
    for (UIButton *btn in self.moreItems) {
        if (button != btn) {
            btn.selected = NO;
        }
    }
    if (button.selected) {
        [self.inputTextView resignFirstResponder];
        [self _willShowBottomView:self.faceView];
    } else {
        [self _willShowBottomView:nil];
    }
}

- (IBAction)locationAction:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectLocation)]) {
        [self.delegate didSelectLocation];
    }
}

- (IBAction)recordAction:(id)sender
{
    UIButton *button = (UIButton*)sender;
    button.selected = !button.selected;
    for (UIButton *btn in self.moreItems) {
        if (button != btn) {
            btn.selected = NO;
        }
    }
    
    if (button.selected) {
        [self.recordView setHeight:187.f];
        [self.inputTextView resignFirstResponder];
        [self _willShowBottomView:self.recordView];
    } else {
        [self _willShowBottomView:nil];
    }
}

- (IBAction)sendAction:(id)sender
{
    if (_inputTextView.text.length > 0) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didSendText:)]) {
            [self.delegate didSendText:[EMConvertToCommonEmoticonsHelper convertToCommonEmoticons:_inputTextView.text]];
        }
        _inputTextView.text = @"";
    }
}

#pragma mark - public

- (BOOL)endEditing:(BOOL)force
{
    BOOL result = [super endEditing:force];
    for (UIButton *button in self.moreItems) {
        button.selected = NO;
    }
    [self _willShowBottomView:nil];
    return result;
}


#pragma mark - private

- (void)_willShowKeyboardFromFrame:(CGRect)beginFrame toFrame:(CGRect)toFrame
{
    if (beginFrame.origin.y == KScreenHeight) {
        [self _willShowBottomHeight:toFrame.size.height];
        if (self.activityButtomView) {
            [self.activityButtomView removeFromSuperview];
        }
        self.activityButtomView = nil;
    }
    else if (toFrame.origin.y == KScreenHeight) {
        [self _willShowBottomHeight:0];
    } else{
        [self _willShowBottomHeight:toFrame.size.height];
    }
}

- (void)_willShowBottomView:(UIView *)bottomView
{
    if (![self.activityButtomView isEqual:bottomView]) {
        CGFloat bottomHeight = bottomView ? bottomView.height : 0;
        [self _willShowBottomHeight:bottomHeight];
        
        if (bottomView) {
            bottomView.top = kDefaultToolBarHeight;
            [self addSubview:bottomView];
        }
        
        if (self.activityButtomView) {
            [self.activityButtomView removeFromSuperview];
        }
        self.activityButtomView = bottomView;
    }
}

- (void)_willShowBottomHeight:(CGFloat)bottomHeight
{
    CGRect fromFrame = self.frame;
    CGFloat toHeight = kDefaultToolBarHeight + bottomHeight;
    CGRect toFrame = CGRectMake(fromFrame.origin.x, fromFrame.origin.y + (fromFrame.size.height - toHeight), fromFrame.size.width, toHeight);
    
    if(bottomHeight == 0 && self.frame.size.height == kDefaultToolBarHeight) {
        return;
    }
    
    if (bottomHeight == 0) {
        self.isShowButtomView = NO;
    }
    else{
        self.isShowButtomView = YES;
    }
    
    [UIView animateWithDuration:0.25 animations:^{
       self.frame = toFrame;
    }];
    [self _willShowViewFromHeight:toHeight];
}

- (void)_willShowViewFromHeight:(CGFloat)toHeight
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatToolBarDidChangeFrameToHeight:)]) {
        [self.delegate chatToolBarDidChangeFrameToHeight:toHeight];
    }
}

@end
