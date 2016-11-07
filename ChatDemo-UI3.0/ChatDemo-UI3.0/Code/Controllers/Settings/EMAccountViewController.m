//
//  EMAccountViewController.m
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 16/9/22.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "EMAccountViewController.h"
#import "EMNameViewController.h"
#import "EMUserProfileManager.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "UIImageView+HeadImage.h"
#import "UIViewController+HUD.h"


@interface EMAccountViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) UIImageView *avatarView;

@property (nonatomic, strong) UIButton *editButton;

@property (nonatomic, strong) UIButton *signOutButton;

@property (nonatomic, copy) NSString *myName;
@property (nonatomic, strong) UIImagePickerController *imagePicker;


@end

@implementation EMAccountViewController


- (UIImageView *)avatarView
{
    if (!_avatarView) {
        
        _avatarView = [[UIImageView alloc] init];
        _avatarView.layer.cornerRadius = 45/2;
        _avatarView.layer.masksToBounds = YES;
    }
    UserProfileEntity *user = [[EMUserProfileManager sharedInstance] getCurUserProfile];
    [_avatarView imageWithUsername:user.username placeholderImage:nil];
    return _avatarView;
}

- (UIButton *)editButton
{
    if (!_editButton) {
        
        _editButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_editButton setTitle:NSLocalizedString(@"setting.account.edit", @"Edit")   forState:UIControlStateNormal];
        [_editButton setTitleColor:RGBACOLOR(72, 184, 0, 1.0) forState:UIControlStateNormal];
        _editButton.titleLabel.font = [UIFont systemFontOfSize:13];
        _editButton.enabled = NO;
        [_editButton addTarget:self action:@selector(editAvatar) forControlEvents:UIControlEventTouchUpInside];
    }
    return _editButton;
}


- (UIButton *)signOutButton
{
    if (!_signOutButton) {
        
        _signOutButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_signOutButton setFrame:CGRectMake(0, self.view.frame.size.height - 44 - 45, KScreenWidth, 45)];
        [_signOutButton setBackgroundColor:RGBACOLOR(255, 59, 48, 1.0)];
        [_signOutButton setTitle:NSLocalizedString(@"setting.account.signout", @"Sign out") forState:UIControlStateNormal];
        [_signOutButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _signOutButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [_signOutButton addTarget:self action:@selector(signOut) forControlEvents:UIControlEventTouchUpInside];
    }
    return _signOutButton;
}

- (UIImagePickerController *)imagePicker
{
    if (_imagePicker == nil) {
        _imagePicker = [[UIImagePickerController alloc] init];
        _imagePicker.modalPresentationStyle= UIModalPresentationOverFullScreen;
        _imagePicker.allowsEditing = YES;
        _imagePicker.delegate = self;
    }
    
    return _imagePicker;
}


- (void)viewDidLoad
{
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]){
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }
    [super viewDidLoad];
    [self configBackButton];
    [self.view addSubview:self.signOutButton];
    NSString *currentUser = [[EMClient sharedClient] currentUsername];
    [[EMUserProfileManager sharedInstance] loadUserProfileInBackground:@[currentUser] saveToLoacal:YES completion:^(BOOL success, NSError *error) {
        if (!error && success) {
            [self.tableView reloadData];
        }
    }];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"AccountCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    
    if (indexPath.row == 0) {
        
        self.avatarView.frame = CGRectMake(15, 13, 45, 45);
        self.editButton.frame = CGRectMake(75, 29, 30, 13);
        [cell.contentView addSubview:self.avatarView];
        [cell.contentView addSubview:self.editButton];
    } else if (indexPath.row == 1) {
        
        cell.textLabel.text = NSLocalizedString(@"setting.account.name", @"Name");
        NSString *user = [[EMUserProfileManager sharedInstance] getNickNameWithUsername:[[EMClient sharedClient] currentUsername]];
        cell.detailTextLabel.text = _myName.length > 0 ? _myName : user;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        
        cell.textLabel.text = NSLocalizedString(@"setting.account.id", @"Hyphenate ID");
        cell.detailTextLabel.text = [[EMClient sharedClient] currentUsername];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        
        return 70;
    } else {
        
        return 45;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        [self editAvatar];
    } else if (indexPath.row == 1) {
        EMNameViewController *name = [[EMNameViewController alloc] init];
        name.title = NSLocalizedString(@"setting.account.name", @"Name");
        name.myName = _myName;
        [name getUpdatedMyName:^(NSString *newName) {
            
            _myName = newName;
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }];
        [self.navigationController pushViewController:name animated:YES];
    }
}

#pragma mark - Actions

- (void)editAvatar {
    
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    self.imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
    [self presentViewController:self.imagePicker animated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    [self hideHud];
    [self showHudInView:self.view hint:NSLocalizedString(@"setting.uploading", @"Uploading..")];
    WEAK_SELF
    UIImage *orgImage = info[UIImagePickerControllerOriginalImage];
    [picker dismissViewControllerAnimated:YES completion:nil];
    if (orgImage) {
        [[EMUserProfileManager sharedInstance] uploadUserHeadImageProfileInBackground:orgImage completion:^(BOOL success, NSError *error) {
            [weakSelf hideHud];
            if (success) {
                UserProfileEntity *user = [[EMUserProfileManager sharedInstance] getCurUserProfile];
                [weakSelf.avatarView imageWithUsername:user.username placeholderImage:orgImage];
                [self showHint:NSLocalizedString(@"setting.uploadSuccess", @"uploaded successfully")];
            } else {
                [self showHint:NSLocalizedString(@"setting.uploadFailed", @"Upload Failed")];
            }
        }];
    } else {
        [self hideHud];
        [self showHint:NSLocalizedString(@"setting.uploadFailed", @"Upload Failed")];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
}

- (void)signOut
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[EMClient sharedClient] logout:YES completion:^(EMError *aError) {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (!aError) {
            [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@NO];
        } else {
            
            NSString *alertString = [NSString stringWithFormat:@"%@:%u",NSLocalizedString(@"logout.failed", @"Logout failed"), aError.code];
            [self showHint:alertString];
        }
    }];
}



@end
