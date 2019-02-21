//
//  EMCreateChatroomViewController.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/16.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EMCreateChatroomViewController.h"

#import "EMTextFieldViewController.h"
#import "EMTextViewController.h"

@interface EMCreateChatroomViewController ()

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) UITableViewCell *nameCell;

@property (nonatomic, strong) NSString *detail;
@property (nonatomic, strong) UITableViewCell *detailCell;
@property (nonatomic, strong) UITableViewCell *contentCell;

@property (nonatomic) NSInteger maxMemNum;
@property (nonatomic, strong) UITableViewCell *memberNumCell;

@end

@implementation EMCreateChatroomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    self.maxMemNum = 200;
    [self _setupSubviews];
}

#pragma mark - Subviews

- (void)_setupSubviews
{
    [self addPopBackLeftItem];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"提交" style:UIBarButtonItemStylePlain target:self action:@selector(createChatroomAction)];
    self.title = @"创建聊天室";
    
    self.tableView.backgroundColor = kColor_LightGray;
    
    self.nameCell = [self _setupValue1CellWithName:@"名称" detail:@"请输入聊天室名称"];
    
    self.detailCell = [self _setupValue1CellWithName:@"简介" detail:@"请输入聊天室简介"];
    self.detailCell.separatorInset = UIEdgeInsetsMake(0, 0, 0, self.view.frame.size.width);
    self.contentCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCellStyleDefault"];
    self.contentCell.textLabel.numberOfLines = 5;
    self.contentCell.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentCell.textLabel.textColor = [UIColor grayColor];
    
    self.memberNumCell = [self _setupValue1CellWithName:@"聊天室人数" detail:@(self.maxMemNum).stringValue];
}

- (UITableViewCell *)_setupValue1CellWithName:(NSString *)aName
                                       detail:(NSString *)aDetail
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"UITableViewCellStyleValue1"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = aName;
    cell.detailTextLabel.textColor = [UIColor grayColor];
    cell.detailTextLabel.text = aDetail;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    
    // Configure the cell...
    NSInteger row = indexPath.row;
    if (row == 0) {
        cell = self.nameCell;
    } else if (row == 1) {
        cell = self.detailCell;
    } else if (row == 2) {
        cell = self.contentCell;
    } else if (row == 3) {
        cell = self.memberNumCell;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 2) {
        return 100;
    }
    
    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    __weak typeof(self) weakself = self;
    if (row == 0) {
        EMTextFieldViewController *controller = [[EMTextFieldViewController alloc] initWithString:self.name placeholder:@"请输入聊天室名称" isEditable:YES];
        controller.title = @"聊天室名称";
        [controller setDoneCompletion:^BOOL(NSString * _Nonnull aString) {
            weakself.name = aString;
            if ([aString length] > 0) {
                self.nameCell.detailTextLabel.text = aString;
            } else {
                self.nameCell.detailTextLabel.text = @"请输入聊天室名称";
            }
            
            return YES;
        }];
        [self.navigationController pushViewController:controller animated:YES];
    } else if (row == 1 || row == 2) {
        EMTextViewController *controller = [[EMTextViewController alloc] initWithString:self.detail placeholder:@"请输入聊天室简介" isEditable:YES];
        controller.title = @"聊天室简介";
        [controller setDoneCompletion:^BOOL(NSString * _Nonnull aString) {
            weakself.detail = aString;
            if ([aString length] > 0) {
                self.detailCell.detailTextLabel.text = nil;
                self.contentCell.textLabel.text = aString;
            } else {
                self.detailCell.detailTextLabel.text = @"请输入聊天室简介";
                self.contentCell.textLabel.text = nil;
            }
            return YES;
        }];
        [self.navigationController pushViewController:controller animated:YES];
    } else if (row == 3) {
        [self updateMaxMemberNum];
    }
}

#pragma mark - Action

- (void)createChatroomAction
{
    if ([self.name length] == 0) {
        [EMAlertController showErrorAlert:@"请输入聊天室名称"];
        return;
    }
    
    __weak typeof(self) weakself = self;
    [self showHudInView:self.view hint:@"创建聊天室..."];
    [[EMClient sharedClient].roomManager createChatroomWithSubject:self.name description:self.detail invitees:nil message:nil maxMembersCount:self.maxMemNum completion:^(EMChatroom *aChatroom, EMError *aError) {
        [weakself hideHud];
        if (aError) {
            [EMAlertController showErrorAlert:@"创建聊天室失败"];
        } else {
            if (weakself.successCompletion) {
                weakself.successCompletion(aChatroom);
            }
            [EMAlertController showSuccessAlert:@"创建聊天室成功"];
            [weakself.navigationController popViewControllerAnimated:YES];
        }
    }];
}

- (void)updateMaxMemberNum
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"聊天室人数" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"请输入聊天室人数 3-1000";
        textField.text = @(self.maxMemNum).stringValue;
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:cancelAction];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UITextField *textField = alertController.textFields.firstObject;
        NSInteger value = [textField.text integerValue];
        if (value > 2 && value < 1001) {
            self.maxMemNum = value;
            self.memberNumCell.detailTextLabel.text = @(value).stringValue;
        } else {
            [EMAlertController showErrorAlert:@"聊天室人数范围：3-1000"];
        }
    }];
    [alertController addAction:okAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
