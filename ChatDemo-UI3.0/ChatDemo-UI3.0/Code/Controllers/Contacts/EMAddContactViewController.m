//
//  EMAddContactViewController.m
//  Hyphenate_Demo
//
//  Created by EaseMob on 16/9/28.
//  Copyright © 2016年 EaseMob. All rights reserved.
//

#import "EMAddContactViewController.h"
#import "EMColorUtils.h"

@interface EMAddContactViewController ()<UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *textField;

@property (strong, nonatomic) IBOutlet UILabel *addStatusLabel;

@end

@implementation EMAddContactViewController
{
    UIButton *_addButton;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    [self setupNavBar];
    [self setupTextField];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.hidesBottomBarWhenPushed = NO;
}

- (void)setupNavBar {
    self.title = NSLocalizedString(@"title.addContact", @"Add Contact");
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelBtn.frame = CGRectMake(0, 0, 50, 44);
    [cancelBtn setTitleColor:KermitGreenTwoColor forState:UIControlStateNormal];
    [cancelBtn setTitleColor:KermitGreenTwoColor forState:UIControlStateHighlighted];
    [cancelBtn setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelBtn setTitle:@"Cancel" forState:UIControlStateHighlighted];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [cancelBtn addTarget:self action:@selector(cancelAddContact) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *rightBar = [[UIBarButtonItem alloc] initWithCustomView:cancelBtn];
    [self.navigationItem setRightBarButtonItem:rightBar];
    
}

- (void)setupTextField {
    UIImageView *leftImage = [[UIImageView alloc] initWithFrame:CGRectMake(15, 18, 13, 13)];
    leftImage.contentMode = UIViewContentModeScaleAspectFit;
    leftImage.image = [UIImage imageNamed:@"Icon_Search"];
    _textField.leftView = leftImage;
    _textField.leftViewMode = UITextFieldViewModeUnlessEditing;
    
    //设置placeholder
    _textField.placeholder = NSLocalizedString(@"contact.enterHyphenateID", @"Enter Hyphenate ID");
    //只有placeholder有值且非空字符串，才能设置生效
    [_textField setValue:CoolGrayColor  forKeyPath:@"_placeholderLabel.textColor"];
    [_textField setValue:[UIFont systemFontOfSize:15]  forKeyPath:@"_placeholderLabel.font"];
    
//    _textField.background = nil;
    _textField.clipsToBounds = YES;
    _textField.layer.borderColor = CoolGrayColor.CGColor;
    
    _textField.returnKeyType = UIReturnKeyGo;

}

- (void)cancelAddContact {
    [self setEditing:NO];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)showMessageAlertView
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:NSLocalizedString(@"saySomething", @"say somthing")
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"cancel", @"Cancel")
                                          otherButtonTitles:NSLocalizedString(@"ok", @"OK"), nil];
    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [alert show];
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
    if ([self isContainInMyContacts:contactName]) {
        _addStatusLabel.hidden = NO;
        _addStatusLabel.attributedText = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"contact.repeatContact", @"This contact has been added") attributes:@{NSForegroundColorAttributeName:OrangeRedColor}];
        return;
    }
    if ([contactName isEqualToString:[EMClient sharedClient].currentUsername]) {
        _addStatusLabel.hidden = NO;
        _addStatusLabel.attributedText = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"contact.addOwner", @"Not allowed to send their own friends to apply for") attributes:@{NSForegroundColorAttributeName:OrangeRedColor}];
        return;
    }
    [self sendAddContactRequest:contactName];
}

- (void)sendAddContactRequest:(NSString *)contactName {
    NSString *requestMessage = [NSString stringWithFormat:@"%@申请加您为好友!",contactName];
    EMError *error = [[EMClient sharedClient].contactManager addContact:contactName
                                                                message:requestMessage];
    _addStatusLabel.hidden = NO;
    if (!error) {
        _addStatusLabel.attributedText = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"contact.sendApplySuccess", @"Requested") attributes:@{NSForegroundColorAttributeName:KermitGreenTwoColor}];
    }
    else {
        _addStatusLabel.attributedText = [[NSAttributedString alloc] initWithString:error.errorDescription attributes:@{NSForegroundColorAttributeName:OrangeRedColor}];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    _textField.layer.borderColor = FrogGreenColor.CGColor;
    _addStatusLabel.hidden = YES;
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [self addContact];
    return YES;
}


@end
