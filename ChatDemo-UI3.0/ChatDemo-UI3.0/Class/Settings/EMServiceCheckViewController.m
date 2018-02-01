//
//  EMServiceCheckViewController.m
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 2017/12/5.
//  Copyright © 2017年 EaseMob. All rights reserved.
//

#import "EMServiceCheckViewController.h"

@interface EMServiceCheckViewController ()

@property (nonatomic, strong) UITextView *textView;

@end

@implementation EMServiceCheckViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"setting.serviceDiagnose", @"Make a diagnose for service");
    [self.view addSubview:self.textView];
    [self showTextFieldAlertView];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"setting.serviceCheck", @"Check") style:UIBarButtonItemStylePlain target:self action:@selector(showTextFieldAlertView)];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - getter

- (UITextView*)textView
{
    if (_textView == nil) {
        _textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
        _textView.backgroundColor = [UIColor whiteColor];
        _textView.font = [UIFont systemFontOfSize:15.f];
        _textView.editable = NO;
    }
    return _textView;
}


#pragma mark - action

- (void)showTextFieldAlertView
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"getPermission", @"Get Permission") message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.text = [EMClient sharedClient].currentUsername;
        textField.placeholder = NSLocalizedString(@"username", @"Username");
    }];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = NSLocalizedString(@"password", @"Password");
        textField.secureTextEntry = YES;
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"Cancel") style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:cancelAction];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UITextField *usernameField = alertController.textFields.firstObject;
        
        UITextField *passwordField = alertController.textFields.lastObject;
        [self checkServiceWithUsername:usernameField.text password:passwordField.text];
    }];
    [alertController addAction:okAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)checkServiceWithUsername:(NSString*)aUsername password:(NSString*)aPassword
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *result = @"";
        __block NSString *_blockResult = result;
        __weak typeof(self) weakSelf = self;
        [[EMClient sharedClient] serviceCheckWithUsername:aUsername password:aPassword completion:^(EMServerCheckType aType, EMError *aError) {
            switch (aType) {
                case EMServerCheckAccountValidation:
                    _blockResult = [_blockResult stringByAppendingString:[NSString stringWithFormat:@"账号校验\t%@\n" ,aError == nil ? @"Ok" : aError.errorDescription]];
                    break;
                case EMServerCheckGetDNSListFromServer:
                    _blockResult = [_blockResult stringByAppendingString:[NSString stringWithFormat:@"获取服务DNS校验\t%@\n" ,aError == nil ? @"Ok" : aError.errorDescription]];
                    break;
                case EMServerCheckGetTokenFromServer:
                    _blockResult = [_blockResult stringByAppendingString:[NSString stringWithFormat:@"获取token校验\t%@\n" ,aError == nil ? @"Ok" : aError.errorDescription]];
                    break;
                case EMServerCheckDoLogin:
                    _blockResult = [_blockResult stringByAppendingString:[NSString stringWithFormat:@"登录校验\t%@\n" ,aError == nil ? @"Ok" : aError.errorDescription]];
                    break;
                case EMServerCheckDoLogout:
                    _blockResult = [_blockResult stringByAppendingString:[NSString stringWithFormat:@"登出校验\t%@\n" ,aError == nil ? @"Ok" : aError.errorDescription]];
                    break;
                default:
                    break;
            }
            weakSelf.textView.text = _blockResult;
        }];
    });
}

@end
