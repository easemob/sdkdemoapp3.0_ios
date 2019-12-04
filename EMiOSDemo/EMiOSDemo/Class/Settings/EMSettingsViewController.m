//
//  EMSettingsViewController.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2018/12/24.
//  Copyright © 2018 XieYajie. All rights reserved.
//

#import "EMSettingsViewController.h"

#import "EMAvatarNameCell.h"

#import "EMAccountViewController.h"
#import "EMBlacklistViewController.h"
#import "EMDevicesViewController.h"
#import "EMMsgSettingViewController.h"
#import "EMPrivacyViewController.h"
#import "EMCallSettingsViewController.h"
#import "EMGeneralSettingViewController.h"

@interface EMSettingsViewController ()

@property (nonatomic, strong) EMAvatarNameCell *userCell;

@property (nonatomic, strong) UIButton *suspendCardBtn;

@property (nonatomic, strong) UIImageView *avatarView;

@property (nonatomic, strong) UILabel *nameLabel;

@property (nonatomic, strong) UILabel *detailLabel;

@property (nonatomic, strong) UIWindow *window;

@property (nonatomic, strong) UIView *backView;

@end

@implementation EMSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.showRefreshHeader = YES;
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self _setupSubviews];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{

    [super viewWillDisappear:animated];
    self.window = nil;
    self.backView = nil;
    self.navigationController.navigationBarHidden = NO;
}

#pragma mark - Subviews

- (void)_setupSubviews
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.userCell = [[EMAvatarNameCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"EMAvatarNameCell"];
    self.userCell.selectionStyle = UITableViewCellSelectionStyleNone;
    self.userCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    self.userCell.nameLabel.font = [UIFont systemFontOfSize:18];
    self.userCell.detailLabel.font = [UIFont systemFontOfSize:15];
    self.userCell.detailLabel.textColor = [UIColor grayColor];
    self.userCell.avatarView.image = [UIImage imageNamed:@"user_avatar_me"];
    self.userCell.nameLabel.text = [EMClient sharedClient].currentUsername;
    self.userCell.detailLabel.text = [EMClient sharedClient].pushOptions.displayName;
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.backgroundColor = kColor_LightGray;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] init];

    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    
    //延时加载window,注意我们需要在rootWindow创建完成之后再创建这个悬浮的视图
    [self performSelector:@selector(floatCard) withObject:nil afterDelay:0.1];
}

//漂浮名片
- (void)floatCard
{
    CAGradientLayer *gl = [CAGradientLayer layer];
    gl.frame = CGRectMake(0,0,[UIScreen mainScreen].bounds.size.width,70);
    gl.startPoint = CGPointMake(0.76, 0.84);
    gl.endPoint = CGPointMake(0.26, 0.14);
    gl.colors = @[(__bridge id)[UIColor colorWithRed:90/255.0 green:93/255.0 blue:208/255.0 alpha:1.0].CGColor, (__bridge id)[UIColor colorWithRed:4/255.0 green:174/255.0 blue:240/255.0 alpha:1.0].CGColor];
    gl.locations = @[@(0), @(1.0f)];
    self.backView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 70)];
    [self.backView.layer addSublayer:gl];
    
    UILabel *tabLabel = [[UILabel alloc]init];
    tabLabel.text = @"我";
    tabLabel.font = [UIFont systemFontOfSize:16.0];
    tabLabel.textAlignment = NSTextAlignmentCenter;
    tabLabel.textColor = [UIColor whiteColor];
    [self.backView addSubview:tabLabel];
    [tabLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.backView.mas_bottom).offset(-10);
        make.centerX.equalTo(self.backView);
        make.width.equalTo(@40);
        make.height.equalTo(@20);
    }];
    /*
    //悬浮按钮
    self.suspendCardBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_suspendCardBtn setBackgroundColor:[UIColor whiteColor]];
    _suspendCardBtn.layer.cornerRadius = 6;
    _suspendCardBtn.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.5].CGColor;
    _suspendCardBtn.layer.shadowOffset = CGSizeMake(0,2);
    _suspendCardBtn.layer.shadowOpacity = 1;
    _suspendCardBtn.layer.shadowRadius = 5;
    [_suspendCardBtn addTarget:self action:@selector(suspendBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.backView addSubview:_suspendCardBtn];
    [_suspendCardBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@71);
        make.top.equalTo(self.backView).offset(38);
        make.left.equalTo(self.backView).offset(16);
        make.right.equalTo(self.backView).offset(-16);
    }];
    [self _setupCardView];*/
    
    //悬浮按钮所处的顶端UIWindow
    self.window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 70)];
    //使得新建window在最顶端
    _window.windowLevel = UIWindowLevelAlert + 1;
    _window.backgroundColor = [UIColor clearColor];
    [_window addSubview:_backView];
    //显示window
    [_window makeKeyAndVisible];

}
/*
//名片
- (void)_setupCardView
{
    _avatarView = [[UIImageView alloc] init];
    [self.suspendCardBtn addSubview:_avatarView];
    [_avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.suspendCardBtn).offset(8);
        make.left.equalTo(self.suspendCardBtn).offset(15);
        make.bottom.equalTo(self.suspendCardBtn).offset(-8);
        make.width.equalTo(self.avatarView.mas_height).multipliedBy(1);
    }];
       
    _detailLabel = [[UILabel alloc] init];
    _detailLabel.backgroundColor = [UIColor clearColor];
    _detailLabel.font = [UIFont systemFontOfSize:15];
    _detailLabel.textColor = [UIColor grayColor];
    [self.suspendCardBtn addSubview:_detailLabel];
    [_detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.avatarView.mas_right).offset(8);
        make.right.equalTo(self.suspendCardBtn).offset(-15);
        make.bottom.equalTo(self.suspendCardBtn).offset(-8);
    }];
       
    _nameLabel = [[UILabel alloc] init];
    _nameLabel.numberOfLines = 2;
    _nameLabel.backgroundColor = [UIColor clearColor];
    _nameLabel.textColor = [UIColor blackColor];
    _nameLabel.font = [UIFont systemFontOfSize:18];
    [self.suspendCardBtn addSubview:_nameLabel];
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.suspendCardBtn).offset(8);
        make.left.equalTo(self.avatarView.mas_right).offset(8);
        make.right.equalTo(self.suspendCardBtn).offset(-15);
        make.bottom.equalTo(self.detailLabel.mas_top);
    }];
    
    self.nameLabel.font = [UIFont systemFontOfSize:18];
    self.detailLabel.font = [UIFont systemFontOfSize:15];
    self.detailLabel.textColor = [UIColor grayColor];
    self.avatarView.image = [UIImage imageNamed:@"user_avatar_me"];
    self.nameLabel.text = [EMClient sharedClient].currentUsername;
    self.detailLabel.text = [EMClient sharedClient].pushOptions.displayName;
}

- (void)suspendBtnClick
{
    EMAccountViewController *controller = [[EMAccountViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [self.navigationController pushViewController:controller animated:YES];
}*/

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = 0;
    switch (section) {
        case 0:
            count = 4;
            break;
        case 1:
            count = 2;
            break;
        case 2:
            count = 2;
            break;
        default:
            break;
    }
    
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    UIImageView *imgView = [[UIImageView alloc]init];
    [cell.contentView addSubview:imgView];
    [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(cell.contentView);
        make.left.equalTo(cell.contentView).offset(20);
    }];
    [cell.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(imgView.mas_right).offset(18);
        make.centerY.equalTo(cell.contentView);
    }];

    cell.textLabel.font = [UIFont systemFontOfSize:14.0];
    
    if (section == 0) {
        if (row == 0) {
            UITableViewCell *cellBlank = [[UITableViewCell alloc]init];
            cellBlank.separatorInset = UIEdgeInsetsMake(0, [UIScreen mainScreen].bounds.size.width, 0, 0);
            return cellBlank;
        } else if (row == 1){
            return self.userCell;
        } else if (row == 2) {
            imgView.image = [UIImage imageNamed:@"通用"];
            cell.textLabel.text = @"通用";
        } else if (row == 3) {
            imgView.image = [UIImage imageNamed:@"消息设置"];
            cell.textLabel.text = @"消息设置";
        }
    }
    if (section == 1) {
        if (row == 0) {
            imgView.image = [UIImage imageNamed:@"黑名单"];
            cell.textLabel.text = @"黑名单";
        } else if (row == 1) {
            imgView.image = [UIImage imageNamed:@"多端多设备管理"];
            cell.textLabel.text = @"多端多设备管理";
        }
    } else if (section == 2) {
        if (row == 0) {
            imgView.image = [UIImage imageNamed:@"自定义服务器"];
            cell.textLabel.text = @"服务诊断";
        } else if (row == 1) {
            imgView.image = [UIImage imageNamed:@"清除缓存"];
            cell.textLabel.text = @"清除本地缓存";
        }
    }
    cell.textLabel.textAlignment = NSTextAlignmentLeft;
    cell.separatorInset = UIEdgeInsetsMake(0, 16, 0, 16);
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0) {
        return 70 - 23;
    }
    return 66;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 23;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 2) {
        return 24;
    }
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (section == 0) {
        if (row == 1) {
            EMAccountViewController *controller = [[EMAccountViewController alloc] initWithStyle:UITableViewStyleGrouped];
            [self.navigationController pushViewController:controller animated:YES];
        } else if (row == 2) {
            EMGeneralSettingViewController *controller = [[EMGeneralSettingViewController alloc]init];
            [self.navigationController pushViewController:controller animated:YES];
        } else if (row == 3) {
            EMMsgSettingViewController *controller = [[EMMsgSettingViewController alloc] init];
            [self.navigationController pushViewController:controller animated:YES];
        }
    } else if (section == 1) {
        if (row == 0) {
            EMBlacklistViewController *controller = [[EMBlacklistViewController alloc] init];
            [self.navigationController pushViewController:controller animated:YES];
        } else if (row == 1) {
            EMDevicesViewController *controller = [[EMDevicesViewController alloc] initWithStyle:UITableViewStylePlain];
            [self.navigationController pushViewController:controller animated:YES];
        }
    } else if (section == 2) {
        if (row == 0) {
            //服务诊断
        } else if (row == 1) {
            //清除本地缓存
        }
    } /*else if (section == 3) {
        if (row == 0) {
            EMCallSettingsViewController *controller = [[EMCallSettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
            [self.navigationController pushViewController:controller animated:YES];
        }
    }*/
}

#pragma mark - scrollview delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.tableView) {
        NSIndexPath * indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
        CGRect rectInTableView = [self.tableView rectForRowAtIndexPath:indexPath];
        CGRect rectInSuperview = [self.tableView convertRect:rectInTableView toView:[self.tableView superview]];
        if (rectInSuperview.origin.y < 70) {
            self.backView.alpha = 0.7;
        } else {
            self.backView.alpha = 1.0;
        }
    }
}

@end
