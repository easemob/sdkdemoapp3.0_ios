//
//  EMLoginViewController.m
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 16/9/20.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "EMLoginViewController.h"

#import "UIViewController+DismissKeyboard.h"

@interface EMLoginViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *signupButton;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (weak, nonatomic) IBOutlet UIButton *changeButton;

- (IBAction)doLogin:(id)sender;
- (IBAction)doSignUp:(id)sender;
- (IBAction)doChangeState:(id)sender;

@end

@implementation EMLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setBackgroundColor];
    [self setupForDismissKeyboard];
    
    _usernameTextField.delegate = self;
    _passwordTextField.delegate = self;
}

- (void)setBackgroundColor
{
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = [UIScreen mainScreen].bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)RGBACOLOR(62, 92, 120, 1).CGColor,(id)RGBACOLOR(36, 62, 85, 1).CGColor,nil];
    [gradient setStartPoint:CGPointMake(0.0, 0.0)];
    [gradient setEndPoint:CGPointMake(0.0, 1.0)];
    [self.view.layer insertSublayer:gradient atIndex:0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - action

- (IBAction)doLogin:(id)sender
{
    __weak typeof(self) weakSelf = self;
    [[EMClient sharedClient] loginWithUsername:_usernameTextField.text
                                      password:_passwordTextField.text
                                    completion:^(NSString *aUsername, EMError *aError) {
                                        if (!aError) {
                                            [[EMClient sharedClient].options setIsAutoLogin:YES];
                                            [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@YES];
                                        } else {
                                            NSString *alertStr = NSLocalizedString(@"login.failure", @"Login failure");
                                            switch (aError.code)
                                            {
                                                case EMErrorUserNotFound:
                                                    alertStr = aError.errorDescription;
                                                    weakSelf.errorLabel.text = aError.errorDescription;
                                                    break;
                                                case EMErrorNetworkUnavailable:
                                                    alertStr = NSLocalizedString(@"error.connectNetworkFail", @"No network connection!");
                                                    weakSelf.errorLabel.text = NSLocalizedString(@"error.connectNetworkFail", @"No network connection!");
                                                    break;
                                                case EMErrorServerNotReachable:
                                                    alertStr = NSLocalizedString(@"error.connectServerFail", @"Connect to the server failed!");
                                                    weakSelf.errorLabel.text = NSLocalizedString(@"error.connectServerFail", @"Connect to the server failed!");
                                                    break;
                                                case EMErrorUserAuthenticationFailed:
                                                    alertStr = NSLocalizedString(@"login.failure.password.notmatch", @"Password does not match username");
                                                    weakSelf.errorLabel.text = NSLocalizedString(@"login.failure.password.notmatch", @"Password does not match username");
                                                    break;
                                                case EMErrorServerTimeout:
                                                    alertStr = NSLocalizedString(@"error.connectServerTimeout", @"Connect to the server timed out!");
                                                    weakSelf.errorLabel.text = NSLocalizedString(@"error.connectServerTimeout", @"Connect to the server timed out!");
                                                    break;
                                                default:
                                                    alertStr = NSLocalizedString(@"login.failure", @"Login failure");
                                                    weakSelf.errorLabel.text = NSLocalizedString(@"login.failure", @"Login failure");
                                                    break;
                                            }
                                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:alertStr delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"login.ok", @"Ok"), nil];
                                            [alert show];
                                        }
                                    }];
}

- (IBAction)doSignUp:(id)sender
{
    if (_usernameTextField.text.length == 0 || _passwordTextField.text.length == 0) {
    
    }
    WEAK_SELF
    [[EMClient sharedClient] registerWithUsername:_usernameTextField.text
                                         password:_passwordTextField.text
                                       completion:^(NSString *aUsername, EMError *aError) {
                                           if (!aError) {
                                           } else {
                                               NSString *alertStr = NSLocalizedString(@"login.signup.failure", @"Sign up failure");
                                               switch (aError.code)
                                               {
                                                   case EMErrorServerNotReachable:
                                                       alertStr = NSLocalizedString(@"error.connectServerFail", @"Connect to the server failed!");
                                                       weakSelf.errorLabel.text = NSLocalizedString(@"error.connectServerFail", @"Connect to the server failed!");
                                                       break;
                                                   case EMErrorNetworkUnavailable:
                                                       alertStr = NSLocalizedString(@"error.connectNetworkFail", @"No network connection!");
                                                       weakSelf.errorLabel.text = NSLocalizedString(@"error.connectNetworkFail", @"No network connection!");
                                                       break;
                                                   case EMErrorServerTimeout:
                                                       alertStr = NSLocalizedString(@"error.connectServerTimeout", @"Connect to the server timed out!");
                                                       weakSelf.errorLabel.text = NSLocalizedString(@"error.connectServerTimeout", @"Connect to the server timed out!");
                                                       break;
                                                   case EMErrorUserAlreadyExist:
                                                       alertStr = NSLocalizedString(@"login.taken", @"Username taken");
                                                       weakSelf.errorLabel.text = NSLocalizedString(@"login.taken", @"Username taken");
                                                       break;
                                                   default:
                                                       alertStr = NSLocalizedString(@"login.signup.failure", @"Sign up failure");
                                                       weakSelf.errorLabel.text = NSLocalizedString(@"login.signup.failure", @"Sign up failure");
                                                       break;
                                               }
                                               UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:alertStr delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"login.ok", @"Ok"), nil];
                                               [alert show];
                                           }
                                       }];
}

- (IBAction)doChangeState:(id)sender
{
    [self setEditing:YES];
    if (_signupButton.hidden == YES) {
        _loginButton.hidden = YES;
        _signupButton.hidden = NO;
        [_changeButton setTitle:NSLocalizedString(@"login.changebutton.login", @"Log in") forState:UIControlStateNormal];
        _tipLabel.text = NSLocalizedString(@"login.signup.tips", @"Have an account?");
    } else {
        _loginButton.hidden = NO;
        _signupButton.hidden = YES;
        [_changeButton setTitle:NSLocalizedString(@"login.changebutton.signup", @"Sign up") forState:UIControlStateNormal];
        _tipLabel.text = NSLocalizedString(@"login.tips", @"Yay! New to Hyphenate?");
    }
}

#pragma mark - UITextFieldDelegate

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (textField == _usernameTextField) {
        _passwordTextField.text = @"";
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _usernameTextField) {
        [_passwordTextField becomeFirstResponder];
    } else if (textField == _passwordTextField) {
        [_passwordTextField resignFirstResponder];
        if (_signupButton.hidden == YES) {
            [self doLogin:nil];
        } else {
            [self doSignUp:nil];
        }
    }
    return YES;
}

#pragma mark - notification

- (void)keyboardWillChangeFrame:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    NSValue *beginValue = [userInfo objectForKey:@"UIKeyboardFrameBeginUserInfoKey"];
    NSValue *endValue = [userInfo objectForKey:@"UIKeyboardFrameEndUserInfoKey"];
    CGRect beginRect;
    [beginValue getValue:&beginRect];
    CGRect endRect;
    [endValue getValue:&endRect];
    
    CGRect buttonFrame;
    if (_signupButton.hidden) {
        buttonFrame = _loginButton.frame;
    } else {
        buttonFrame = _signupButton.frame;
    }
    if (endRect.origin.y == self.view.frame.size.height) {
        buttonFrame.origin.y = KScreenHeight - CGRectGetHeight(buttonFrame);
    } else if(beginRect.origin.y == self.view.frame.size.height){
        buttonFrame.origin.y = KScreenHeight - CGRectGetHeight(buttonFrame) - CGRectGetHeight(endRect);
    } else {
        buttonFrame.origin.y = KScreenHeight - CGRectGetHeight(buttonFrame) - CGRectGetHeight(endRect);
    }
    [UIView animateWithDuration:0.3 animations:^{
        if (_signupButton.hidden) {
            _loginButton.frame = buttonFrame;
        } else {
            _signupButton.frame = buttonFrame;
        }
    }];
}

@end
