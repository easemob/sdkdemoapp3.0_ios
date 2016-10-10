//
//  EMAccountViewController.m
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 16/9/22.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "EMAccountViewController.h"

@interface EMAccountViewController ()

@property (nonatomic, strong) UIImageView *avatarView;

@property (nonatomic, strong) UIButton *editButton;

@property (nonatomic, strong) UIButton *signOutButton;

//@property (nonatomic, strong) UIView *footer;

@end

@implementation EMAccountViewController


- (UIImageView *)avatarView
{
    if (!_avatarView) {
        
        _avatarView = [[UIImageView alloc] init];
        _avatarView.layer.cornerRadius = 45/2;
        _avatarView.image = [UIImage imageNamed:@"123.jpg"];
    }
    return _avatarView;
}

- (UIButton *)editButton
{
    if (!_editButton) {
        
        _editButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_editButton setTitle:@"Edit" forState:UIControlStateNormal];
        [_editButton setTitleColor:RGBACOLOR(72, 184, 0, 1.0) forState:UIControlStateNormal];
        _editButton.titleLabel.font = [UIFont systemFontOfSize:13];
        /** 没有存储入口，先不允许编辑 */
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
        [_signOutButton setTitle:@"Sign Out" forState:UIControlStateNormal];
        [_signOutButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _signOutButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        
        [_signOutButton addTarget:self action:@selector(signOut) forControlEvents:UIControlEventTouchUpInside];
    }
    return _signOutButton;
}


- (void)viewDidLoad
{
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]){
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }
    
    [super viewDidLoad];
    [self configBackButton];
    [self.view addSubview:self.signOutButton];

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
        self.editButton.frame = CGRectMake(75, 29, 24, 13);
        [cell.contentView addSubview:self.avatarView];
        [cell.contentView addSubview:self.editButton];
    } else if (indexPath.row == 1) {
        
        cell.textLabel.text = @"Hyphenate ID";
        cell.detailTextLabel.text = [[EMClient sharedClient] currentUsername];
    } else {
        
        EMPushOptions *pushOptions = [[EMClient sharedClient] pushOptions];
        cell.textLabel.text = @"Name";
        cell.detailTextLabel.text = pushOptions.displayName;
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

#pragma mark - Actions

- (void)editAvatar {
    
    
    
}

- (void)signOut
{
    [[EMClient sharedClient] logout:YES completion:^(EMError *aError) {
        if (!aError) {
            [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@NO];
        }
    }];
}



@end
