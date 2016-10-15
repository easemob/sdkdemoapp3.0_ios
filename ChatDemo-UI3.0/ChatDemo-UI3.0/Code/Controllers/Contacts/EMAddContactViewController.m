//
//  EMAddContactViewController.m
//  Hyphenate_Demo
//
//  Created by EaseMob on 16/9/28.
//  Copyright © 2016年 EaseMob. All rights reserved.
//

#import "EMAddContactViewController.h"

@interface EMAddContactViewController ()<UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *textField;

@property (strong, nonatomic) IBOutlet UILabel *addStatusLabel;
@property (strong, nonatomic) IBOutlet UIButton *addButton;

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
}

- (void)setupNavBar {
    self.title = NSLocalizedString(@"title.addContact", @"Add Contact");
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelBtn.frame = CGRectMake(0, 0, 44, 44);
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
    if (contactName.length == 0) {
        _addStatusLabel.hidden = NO;
        _addStatusLabel.attributedText = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"contact.noinput", @"No input contact name") attributes:@{NSForegroundColorAttributeName:OrangeRedColor}];
        return;
    }
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
    NSString *requestMessage = [NSString stringWithFormat:NSLocalizedString(@"contact.somebodyAddWithName", @"%@ add you as a friend"),contactName];
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

#pragma mark - Action Method

- (IBAction)addContactAction:(id)sender {
    [self addContact];
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

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *imageName = @"addContact_disable.png";
    _addButton.userInteractionEnabled = NO;
    if (textField.text.length > 1 ||
        ((textField.text.length == 1 || textField.text.length == 0) && ![string isEqualToString:@""])) {
        imageName = @"addContact_enable.png";
        _addButton.userInteractionEnabled = YES;
    }
    [_addButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [_addButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateHighlighted];
    
    
    return YES;
}




@end
