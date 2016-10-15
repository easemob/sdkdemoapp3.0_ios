//
//  EMBaseSettingController.m
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 16/9/22.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "EMBaseSettingController.h"

@interface EMBaseSettingController ()

@end

@implementation EMBaseSettingController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.backgroundColor = RGBACOLOR(228, 233, 236, 1.0);
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorColor = RGBACOLOR(173, 185, 193, 0.5);
    self.tableView.scrollEnabled = NO;
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.textLabel.textColor = RGBACOLOR(12, 18, 24, 1.0);
    cell.textLabel.font = [UIFont systemFontOfSize:13];
    cell.detailTextLabel.textColor = RGBACOLOR(112, 126, 137, 1.0);
    cell.detailTextLabel.font = [UIFont systemFontOfSize:13];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45;
}

- (void)configBackButton
{
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 8, 15)];
    [backButton setImage:[UIImage imageNamed:@"Icon_Back"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
