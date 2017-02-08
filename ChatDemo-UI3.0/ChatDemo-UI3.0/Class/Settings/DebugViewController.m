/************************************************************
 *  * EaseMob CONFIDENTIAL
 * __________________
 * Copyright (C) 2013-2014 EaseMob Technologies. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of EaseMob Technologies.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from EaseMob Technologies.
 */

#import "DebugViewController.h"

#import <MessageUI/MFMailComposeViewController.h>
#import <MessageUI/MessageUI.h>

@interface DebugViewController () <MFMailComposeViewControllerDelegate>

@property (nonatomic, copy) NSString *logPath;

@end

@implementation DebugViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"title.debug", @"Debug");
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    backButton.accessibilityIdentifier = @"back";
    [backButton setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    [self.navigationItem setLeftBarButtonItem:backItem];
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 80)];
    footerView.backgroundColor = [UIColor clearColor];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(10, 0, footerView.frame.size.width - 10, 0.5)];
        line.backgroundColor = [UIColor lightGrayColor];
        [footerView addSubview:line];
    }
    
    UIButton *uploadLogButton = [[UIButton alloc] initWithFrame:CGRectMake(40, 20, footerView.frame.size.width - 80, 40)];
    [uploadLogButton setBackgroundColor:[UIColor colorWithRed:87 / 255.0 green:186 / 255.0 blue:205 / 255.0 alpha:1.0]];
    [uploadLogButton setTitle:NSLocalizedString(@"setting.uploadLog", @"upload run log") forState:UIControlStateNormal];
    [uploadLogButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [uploadLogButton addTarget:self action:@selector(uploadLogAction) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:uploadLogButton];
    self.tableView.tableFooterView = footerView;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    
    if (indexPath.row == 0)
    {
        cell.textLabel.text = NSLocalizedString(@"setting.sdkVersion", @"SDK version");
        NSString *ver = [[EaseMob sharedInstance] sdkVersion];
        cell.detailTextLabel.text = ver;
    }
    
    return cell;
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(nullable NSError *)error
{
    NSString *msg = @"";
    
    switch (result)
    {
        case MFMailComposeResultCancelled:
            msg = NSLocalizedString(@"setting.emailCancel", @"Mail cancel");
            break;
        case MFMailComposeResultSaved:
            msg = NSLocalizedString(@"setting.emailSaved", @"Mail saved");
            break;
        case MFMailComposeResultSent:
            msg = NSLocalizedString(@"setting.emailSendSuccess", @"Mail send successfully");
            break;
        case MFMailComposeResultFailed:
            msg = NSLocalizedString(@"setting.emailSendFailed", @"Mail send failed");
            break;
        default:
            break;
    }
    
    if ([msg length] > 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }
    
    [[NSFileManager defaultManager] removeItemAtPath:self.logPath error:nil];
    self.logPath = nil;
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - action

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)uploadLogAction
{
    if ([MFMailComposeViewController canSendMail] == NO) {
        return;
    }
    
    [[EaseMob sharedInstance] getLogFilesPathWithCompletion:^(NSString *aPath, EMError *aError) {
        if (aError == nil) {
            self.logPath = aPath;
            MFMailComposeViewController *mailCompose = [[MFMailComposeViewController alloc] init];
            if(mailCompose) {
                [mailCompose setMailComposeDelegate:self];
                
                [mailCompose setSubject:NSLocalizedString(@"setting.emailSubject", @"Log file")];
                
                NSString *emailBody = NSLocalizedString(@"setting.emailBody", @"This is a log file for test");
                [mailCompose setMessageBody:emailBody isHTML:NO];
                
                NSData* pData = [[NSData alloc]initWithContentsOfFile:aPath];
                [mailCompose addAttachmentData:pData mimeType:@"" fileName:@"log.zip"];
                
                [self presentViewController:mailCompose animated:YES completion:nil];
            }
        }
    }];
//    __weak typeof(self) weakSelf = self;
//    [self showHudInView:self.view hint:NSLocalizedString(@"setting.uploading", @"uploading...")];
//    [[EaseMob sharedInstance] asyncUploadLogToServerWithCompletion:^(EMError *error) {
//        [weakSelf hideHud];
//        if (error) {
//            [weakSelf showHint:error.description];
//        }
//        else{
//            [weakSelf showHint:NSLocalizedString(@"setting.uploadSuccess", @"uploaded successfully")];
//        }
//    }];
}

@end
