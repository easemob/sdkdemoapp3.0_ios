//
//  EMNameViewController.m
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 2016/11/4.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "EMNameViewController.h"
#import "EMUserProfileManager.h"

@interface EMNameViewController ()<UITextFieldDelegate>

@property (nonatomic, strong) UITextField *nameTextField;
@end

@implementation EMNameViewController

- (UITextField *)nameTextField
{
    if (!_nameTextField) {
        _nameTextField = [[UITextField alloc] init];
        _nameTextField.textColor = RGBACOLOR(12, 18, 24, 1.0);
        _nameTextField.textAlignment = NSTextAlignmentLeft;
        _nameTextField.font = [UIFont systemFontOfSize:13];
        _nameTextField.borderStyle = UITextBorderStyleNone;
        NSString *user = [[EMUserProfileManager sharedInstance] getNickNameWithUsername:[[EMClient sharedClient] currentUsername]];
        _nameTextField.text = _myName.length > 0 ? _myName : user;
        _nameTextField.returnKeyType = UIReturnKeyDone;
        _nameTextField.delegate = self;
    }
    return _nameTextField;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 8, 15)];
    [backButton setImage:[UIImage imageNamed:@"Icon_Back"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
}

- (void)getUpdatedMyName:(UpdatedMyName)callBack
{
    self.callBack = callBack;
}

- (void)back {
    
    [self updateMyName:self.nameTextField.text];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self updateMyName:textField.text];
    return YES;
}

- (void)updateMyName:(NSString *)newName
{
    if (newName.length > 0 && ![_myName isEqualToString:newName])
    {
        _myName = newName;
        [[EMUserProfileManager sharedInstance] updateUserProfileInBackground:@{kPARSE_HXUSER_NICKNAME:newName} completion:^(BOOL success, NSError *error) {}];
        [[EMClient sharedClient] updatePushNotifiationDisplayName:newName completion:^(NSString *aDisplayName, EMError *aError) {}];
        if (self.callBack) {
            self.callBack(newName);
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIndentifier = @"NameCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier];
    }
    
    self.nameTextField.frame = CGRectMake(15, 0, self.tableView.frame.size.width, cell.contentView.frame.size.height);
    [cell.contentView addSubview:self.nameTextField];
    
    return cell;
}



@end
