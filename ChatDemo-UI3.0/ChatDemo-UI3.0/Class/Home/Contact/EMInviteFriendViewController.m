//
//  EMInviteFriendViewController.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/10.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EMInviteFriendViewController.h"

#import "EMAlertController.h"
#import "EMAvatarNameCell.h"

@interface EMInviteFriendViewController ()<UITextFieldDelegate>

@property (nonatomic, strong) NSString *searchUsername;
@property (nonatomic, strong) NSMutableArray *invitedUsers;

@property (nonatomic, strong) UIView *tableHeaderView;
@property (nonatomic, strong) UITextField *searchField;
@property (nonatomic, strong) UIButton *cancelButton;

@end

@implementation EMInviteFriendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    self.invitedUsers = [[NSMutableArray alloc] init];
    
    [self _setupViews];
}

#pragma mark - Subviews

- (void)_setupViews
{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"back_gary"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(backAction)];
    self.title = @"添加好友";
    
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.rowHeight = 60;
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    self.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 60)];
    self.tableHeaderView.backgroundColor = [UIColor whiteColor];
    self.tableView.tableHeaderView = self.tableHeaderView;
    
    self.searchField = [[UITextField alloc] init];
    self.searchField.delegate = self;
    self.searchField.backgroundColor = kColor_LightGray;
    self.searchField.font = [UIFont systemFontOfSize:16];
    self.searchField.placeholder = @"搜索用户ID";
    self.searchField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.searchField.leftViewMode = UITextFieldViewModeAlways;
    self.searchField.returnKeyType = UIReturnKeySearch;
    self.searchField.layer.cornerRadius = 8;
    [self.tableHeaderView addSubview:self.searchField];
    [self.searchField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.tableHeaderView);
        make.left.equalTo(self.tableHeaderView).offset(15);
        make.right.equalTo(self.tableHeaderView).offset(-15);
        make.height.equalTo(@35);
    }];
    
    UIImageView *leftView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 15)];
    leftView.contentMode = UIViewContentModeScaleAspectFit;
    leftView.image = [UIImage imageNamed:@"search_gray"];
    self.searchField.leftView = leftView;
    
    self.cancelButton = [[UIButton alloc] init];
    self.cancelButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [self.cancelButton setTitleColor:kColor_Blue forState:UIControlStateNormal];
    [self.cancelButton addTarget:self action:@selector(searchCancelButtonClicked) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.searchUsername length] > 0 ? 1 : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EMAvatarNameCell *cell = (EMAvatarNameCell *)[tableView dequeueReusableCellWithIdentifier:@"UITableViewCellInviteFriend"];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[EMAvatarNameCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCellInviteFriend"];
        
        UIButton *rightButton = [[UIButton alloc] init];
        rightButton.tag = 100;
        rightButton.clipsToBounds = YES;
        rightButton.backgroundColor = kColor_Blue;
        rightButton.titleLabel.font = [UIFont systemFontOfSize:16];
        rightButton.layer.cornerRadius = 5;
        [rightButton setTitle:@"添加好友" forState:UIControlStateNormal];
        [rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [rightButton setTitle:@"已申请" forState:UIControlStateSelected];
        [rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [rightButton addTarget:self action:@selector(inviteButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:rightButton];
        [rightButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(cell.contentView);            make.right.equalTo(cell.contentView).offset(-10);
            make.height.equalTo(@35);
            make.width.equalTo(@80);
        }];
        
        [cell.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(cell.contentView).offset(5);
            make.left.equalTo(cell.avatarView.mas_right).offset(8);
            make.right.equalTo(rightButton.mas_left).offset(-5);
            make.bottom.equalTo(cell.contentView).offset(-5);
        }];
    }
    
    cell.avatarView.image = [UIImage imageNamed:@"user_4"];
    cell.nameLabel.text = self.searchUsername;
    
    UIButton *rightButton = [cell.contentView viewWithTag:100];
    if (rightButton) {
        NSArray *contacts = [[EMClient sharedClient].contactManager getContacts];
        NSArray *blacks = [[EMClient sharedClient].contactManager getBlackList];
        if ([contacts containsObject:self.searchUsername] || [blacks containsObject:self.searchUsername]) {
            rightButton.selected = YES;
            [rightButton setTitle:@"已添加" forState:UIControlStateSelected];
            rightButton.backgroundColor = kColor_Gray;
        } else {
            BOOL isInvited = [self.invitedUsers containsObject:self.searchUsername];
            rightButton.selected = isInvited;
            if (isInvited) {
                [rightButton setTitle:@"已申请" forState:UIControlStateSelected];
                rightButton.backgroundColor = kColor_Gray;
            } else {
                rightButton.backgroundColor = kColor_Blue;
            }
        }
    }
    
    return cell;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self.tableHeaderView addSubview:self.cancelButton];
    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.tableHeaderView);
        make.right.equalTo(self.tableHeaderView).offset(-5);
        make.width.equalTo(@50);
        make.height.equalTo(self.tableHeaderView);
    }];
    
    [self.searchField mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.tableHeaderView).offset(-65);
    }];
    
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    self.searchUsername = textField.text;
    if ([textField.text length] > 0) {
        [self.tableView reloadData];
    }
    
    return YES;
}

#pragma mark - Action

- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)searchCancelButtonClicked
{
    [self.cancelButton removeFromSuperview];
    
    [self.searchField resignFirstResponder];
    self.searchField.text = nil;
    [self.searchField mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.tableHeaderView).offset(-15);
    }];
    
    self.searchUsername = nil;
    [self.tableView reloadData];
}

- (void)inviteButtonAction:(UIButton *)aButton
{
    if (aButton.isSelected) {
        return;
    }
    
    [self showHudInView:self.view hint:@"发送好友请求..."];
    __weak typeof(self) weakself = self;
    [[EMClient sharedClient].contactManager addContact:self.searchUsername message:nil completion:^(NSString *aUsername, EMError *aError) {
        [weakself hideHud];
        if (aError) {
            [EMAlertController showErrorAlert:@"添加失败"];
        } else {
            aButton.selected = YES;
            aButton.backgroundColor = kColor_Gray;
            [weakself.invitedUsers addObject:self.searchUsername];
            
            [EMAlertController showSuccessAlert:@"已发出好友申请"];
        }
    }];
}

@end
