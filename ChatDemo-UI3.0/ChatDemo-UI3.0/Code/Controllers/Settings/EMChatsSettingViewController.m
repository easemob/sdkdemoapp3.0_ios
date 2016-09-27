//
//  EMChatsSettingViewController.m
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 16/9/22.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "EMChatsSettingViewController.h"

@interface EMChatsSettingViewController ()
@property (nonatomic, strong) UISwitch *autoAcceptSitch;
@property (nonatomic) BOOL autoAcceptInvitation;
@end

@implementation EMChatsSettingViewController

- (UISwitch *)autoAcceptSitch
{
    if (!_autoAcceptSitch) {
        _autoAcceptSitch = [[UISwitch alloc] init];
        [_autoAcceptSitch addTarget:self action:@selector(autoAcceptAction:) forControlEvents:UIControlEventValueChanged];
    }
    return _autoAcceptSitch;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configBackButton];
    [self loadOptions];
    
}

- (void)loadOptions
{
    EMOptions *options = [[EMClient sharedClient] options];
    _autoAcceptInvitation = options.isAutoAcceptGroupInvitation;
    [self.autoAcceptSitch setOn:_autoAcceptInvitation animated:YES];
    [self.tableView reloadData];
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"ChatsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text = @"Accept group invites automatically";
    self.autoAcceptSitch.frame = CGRectMake(tableView.frame.size.width - 50 - 16, 8, 50, 30);
    [cell.contentView addSubview:self.autoAcceptSitch];
    
    return cell;
}

- (void)autoAcceptAction:(UISwitch *)sender
{
    EMOptions *options = [[EMClient sharedClient] options];
    options.isAutoAcceptGroupInvitation = sender.isOn;
}

@end
