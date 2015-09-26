//
//  EditNicknameViewController.m
//  ChatDemo-UI2.0
//
//  Created by EaseMob on 15/4/16.
//  Copyright (c) 2015年 EaseMob. All rights reserved.
//

#import "EditNicknameViewController.h"

#import "EaseMob.h"
#import <EaseUI/UIViewController+DismissKeyboard.h>

#define kTextFieldWidth 290.0
#define kTextFieldHeight 40.0
#define kButtonHeight 40.0

@interface EditNicknameViewController ()<UITextFieldDelegate>

@property (strong, nonatomic) UITextField *nickTextField;

@property (strong, nonatomic) UIButton *saveButton;

@property (strong, nonatomic) UILabel *tipLabel;

@end

@implementation EditNicknameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"setting.editName", @"Edit NickName");
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [backButton setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    [self.navigationItem setLeftBarButtonItem:backItem];
    
    // Do any additional setup after loading the view.
    [self setupTextField];
    [self setupButton];
    [self setupLabel];
    
    [self setupForDismissKeyboard];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - setup subviews

- (void)setupTextField
{
    _nickTextField = [[UITextField alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.view.bounds)-kTextFieldWidth)/2, 20.0, kTextFieldWidth, kTextFieldHeight)];
    _nickTextField.layer.cornerRadius = 5.0;
    _nickTextField.placeholder = NSLocalizedString(@"setting.inputName", @"Please input nickname");
    _nickTextField.font = [UIFont systemFontOfSize:15];
    _nickTextField.backgroundColor = [UIColor whiteColor];
    _nickTextField.returnKeyType = UIReturnKeyNext;
    _nickTextField.delegate = self;
    _nickTextField.enablesReturnKeyAutomatically = YES;
    _nickTextField.layer.borderWidth = 0.5;
    _nickTextField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [_nickTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:_nickTextField];
    
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, _nickTextField.frame.size.height)];
    leftView.backgroundColor = [UIColor clearColor];
    _nickTextField.leftView = leftView;
    _nickTextField.leftViewMode = UITextFieldViewModeAlways;
}

- (void)setupButton
{
    _saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _saveButton.frame = CGRectMake((CGRectGetWidth(self.view.bounds)-kTextFieldWidth)/2, CGRectGetMaxY(_nickTextField.frame) + 10.0, kTextFieldWidth, kButtonHeight);
    [_saveButton setBackgroundColor:[UIColor colorWithRed:0 green:172 / 255.0 blue:255 / 255.0 alpha:1.0]];
    [_saveButton setTitle:NSLocalizedString(@"setting.saveName", @"Save Nickname") forState:UIControlStateNormal];
    [_saveButton addTarget:self action:@selector(saveAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_saveButton];
}

- (void)setupLabel
{
    _tipLabel = [[UILabel alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.view.bounds)-kTextFieldWidth)/2, CGRectGetMaxY(_saveButton.frame) + 10.0, kTextFieldWidth, 60)];
    _tipLabel.textAlignment = NSTextAlignmentLeft;
    _tipLabel.font = [UIFont systemFontOfSize:14];
    _tipLabel.text = NSLocalizedString(@"setting.edittips", @"After setting this nickname, chat with the iOS client demo project, iOS will display this nickname is not a EaseMob ID, if the other party to use the Android client this setting is not effective");
    CGFloat height = 0;
    NSDictionary *attributes = @{NSFontAttributeName :[UIFont systemFontOfSize:14.0f]};
    CGRect rect = [_tipLabel.text boundingRectWithSize:CGSizeMake(kTextFieldWidth, MAXFLOAT)
                                             options:NSStringDrawingUsesLineFragmentOrigin
                                          attributes:attributes
                                             context:nil];
    height = CGRectGetHeight(rect);
    CGRect frame = _tipLabel.frame;
    frame.size.height = height;
    _tipLabel.frame = frame;
    _tipLabel.numberOfLines = height/14;
    _tipLabel.textColor = [UIColor lightGrayColor];
    [self.view addSubview:_tipLabel];
}

#pragma mark - action

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)textFieldDidChange:(id)sender
{
    UITextField *_field = (UITextField *)sender;
    if (_field.text.length >0) {
        _tipLabel.textColor = [UIColor redColor];
    } else {
        _tipLabel.textColor = [UIColor lightGrayColor];
    }
}

- (void)saveAction
{
    if(_nickTextField.text.length > 0)
    {
        //设置推送设置
        [[EaseMob sharedInstance].chatManager setApnsNickname:_nickTextField.text];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", @"Prompt") message:NSLocalizedString(@"setting.namenotempty", @"Name cannot be empty") delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
        [alertView show];
    }
}

@end
