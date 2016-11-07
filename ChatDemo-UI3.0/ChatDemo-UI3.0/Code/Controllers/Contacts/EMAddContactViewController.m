//
//  EMAddContactViewController.m
//  Hyphenate_Demo
//
//  Created by EaseMob on 16/9/28.
//  Copyright © 2016年 EaseMob. All rights reserved.
//

#import "EMAddContactViewController.h"
#import "UIViewController+DismissKeyboard.h"

@interface EMAddContactViewController ()<UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *textField;

@property (strong, nonatomic) IBOutlet UIButton *addButton;

@property (strong, nonatomic) IBOutlet UIView *addView;

@end

@implementation EMAddContactViewController
{
    UIButton *_addButton;
    CGFloat _addViewY;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setupNavBar];
    [self setupTextField];
    [self setupForDismissKeyboard];
    [_addButton addObserver:self forKeyPath:@"userInteractionEnabled" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    _addViewY = _addView.frame.origin.y;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"userInteractionEnabled"]) {
        NSString *imageName = @"addContact_disable.png";
        if (_addButton.userInteractionEnabled) {
            imageName = @"addContact_enable.png";
        }
        [_addButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        [_addButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateHighlighted];
    }
}

- (void)dealloc {
    [_addButton removeObserver:self forKeyPath:@"userInteractionEnabled"];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
}


- (void)setupNavBar {
    self.title = NSLocalizedString(@"title.addContact", @"Add Contact");
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelBtn.frame = CGRectMake(0, 0, 44, 44);
    [cancelBtn setTitleColor:KermitGreenTwoColor forState:UIControlStateNormal];
    [cancelBtn setTitleColor:KermitGreenTwoColor forState:UIControlStateHighlighted];
    [cancelBtn setTitle:NSLocalizedString(@"common.cancel", @"Cancel") forState:UIControlStateNormal];
    [cancelBtn setTitle:NSLocalizedString(@"common.cancel", @"Cancel") forState:UIControlStateHighlighted];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [cancelBtn addTarget:self action:@selector(cancelAddContact) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *rightBar = [[UIBarButtonItem alloc] initWithCustomView:cancelBtn];
    [self.navigationItem setRightBarButtonItem:rightBar];
    
}

- (void)setupTextField {
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 28, 13)];
    UIImageView *leftImage = [[UIImageView alloc] initWithFrame:CGRectMake(15, 0, 13, 13)];
    leftImage.contentMode = UIViewContentModeScaleAspectFit;
    leftImage.image = [UIImage imageNamed:@"Icon_Search.png"];
    [leftView addSubview:leftImage];
    _textField.leftView = leftView;
    _textField.leftViewMode = UITextFieldViewModeAlways;
    
    _textField.placeholder = NSLocalizedString(@"contact.enterHyphenateID", @"Enter Hyphenate ID");
    [_textField setValue:CoolGrayColor  forKeyPath:@"_placeholderLabel.textColor"];
    [_textField setValue:[UIFont systemFontOfSize:15]  forKeyPath:@"_placeholderLabel.font"];
    
    _textField.clipsToBounds = YES;
    _textField.layer.borderColor = CoolGrayColor.CGColor;
    
    _textField.returnKeyType = UIReturnKeySearch;
}

- (void)cancelAddContact {
    [_textField resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)isContainInMyContacts:(NSString *)contactName {
    NSArray *contacts = [[EMClient sharedClient].contactManager getContacts];
    if ([contacts containsObject:contactName]) {
        return YES;
    }
    return NO;
}

- (void)addContact {
    NSString *contactName = _textField.text;
    if (contactName.length == 0) {
        [self showAlertWithMessage:NSLocalizedString(@"contact.noinput", @"No input contact name")];
        return;
    }
    if ([self isContainInMyContacts:contactName]) {
        self.textField.text = @"";
        _addButton.userInteractionEnabled = NO;
        [self showAlertWithMessage:NSLocalizedString(@"contact.repeatContact", @"This contact has been added")];
        return;
    }
    if ([contactName isEqualToString:[EMClient sharedClient].currentUsername]) {
        self.textField.text = @"";
        _addButton.userInteractionEnabled = NO;
        [self showAlertWithMessage:NSLocalizedString(@"contact.addOwner", @"Not allowed to send their own friends to apply for")];
        return;
    }
    [self sendAddContactRequest:contactName];
}

- (void)sendAddContactRequest:(NSString *)contactName {
    NSString *requestMessage = [NSString stringWithFormat:NSLocalizedString(@"contact.somebodyAddWithName", @"%@ add you as a friend"),contactName];
    WEAK_SELF
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[EMClient sharedClient].contactManager addContact:contactName
                                               message:requestMessage
                                            completion:^(NSString *aUsername, EMError *aError) {
                                                [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                                                if (!aError) {
                                                    weakSelf.textField.text = @"";
                                                    _addButton.userInteractionEnabled = NO;
                                                    NSString *msg = NSLocalizedString(@"contact.sendContactRequest", @"You request has been sent.");
                                                    [weakSelf showAlertWithMessage:msg];
                                                }
                                                else {
                                                    [weakSelf showAlertWithMessage:aError.errorDescription];
                                                }
                                            }];
}

#pragma mark - Action Method

- (IBAction)addContactAction:(id)sender {
    [_textField resignFirstResponder];
    [self addContact];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    _textField.layer.borderColor = FrogGreenColor.CGColor;
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [self addContact];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    BOOL userInteractionEnabled = NO;
    if (textField.text.length > 1 ||
        ((textField.text.length == 1 || textField.text.length == 0) && ![string isEqualToString:@""])) {
        userInteractionEnabled = YES;
    }
    if (_addButton.userInteractionEnabled != userInteractionEnabled) {
        _addButton.userInteractionEnabled = userInteractionEnabled;
    }
    
    return YES;
}

#pragma mark - notification

- (void)keyboardWillChangeFrame:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    NSValue *endValue = [userInfo objectForKey:@"UIKeyboardFrameEndUserInfoKey"];
    CGRect endRect;
    [endValue getValue:&endRect];
    
    CGRect addFrame = _addView.frame;
    CGFloat bottomOffset = addFrame.origin.y + addFrame.size.height + 64;
    if (bottomOffset > endRect.origin.y) {
        addFrame.origin.y -= (10 + bottomOffset - endRect.origin.y);
    }
    else if (endRect.origin.y >= KScreenHeight) {
        addFrame.origin.y = _addViewY;
    }
    [UIView animateWithDuration:0.3 animations:^{
        _addView.frame = addFrame;
    }];
}

@end
