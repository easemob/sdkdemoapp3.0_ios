//
//  EMCustomAppkeyViewController.m
//  EaseIM
//
//  Created by 娜塔莎 on 2020/6/12.
//  Copyright © 2020 娜塔莎. All rights reserved.
//

#import "EMCustomAppkeyViewController.h"
#import "EMDemoOptions.h"
#import "EMPersonalAPPKeyViewController.h"

@interface EMCustomAppkeyViewController ()

@property (nonatomic, strong)UIButton *addAppkeyBtn;

@end

@implementation EMCustomAppkeyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.showRefreshHeader = NO;
    // Uncomment the following line to preserve selection between presentations.
    [self _setupSubviews];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

#pragma mark - Subviews

- (void)_setupSubviews
{
    [self addPopBackLeftItem];
    self.title = @"自定义APPKey";
    self.view.backgroundColor = [UIColor colorWithRed:249/255.0 green:249/255.0 blue:249/255.0 alpha:1.0];
    
    self.addAppkeyBtn = [[UIButton alloc]init];
    self.addAppkeyBtn.backgroundColor = [UIColor whiteColor];
    [self.addAppkeyBtn setTitle:@"添加自定义APPKey" forState:UIControlStateNormal];
    [self.addAppkeyBtn setTitleColor:[UIColor colorWithRed:4/255.0 green:174/255.0 blue:240/255.0 alpha:1.0] forState:UIControlStateNormal];
    [self.addAppkeyBtn.titleLabel setFont:[UIFont systemFontOfSize:14.0]];
    self.addAppkeyBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.addAppkeyBtn addTarget:self action:@selector(addCustomAPPKey) forControlEvents:UIControlEventTouchUpInside];
    [self.addAppkeyBtn.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.addAppkeyBtn).offset(16);
    }];
    [self.view addSubview:self.addAppkeyBtn];
    [self.addAppkeyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-16);
        make.height.equalTo(@50);
    }];
    
    self.tableView.rowHeight = 66;
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.backgroundColor = kColor_LightGray;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 20)];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.addAppkeyBtn.mas_top);
    }];

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [EMDemoOptions.sharedOptions.locationAppkeyArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSString *tempAppkey = (NSString *)[EMDemoOptions.sharedOptions.locationAppkeyArray objectAtIndex:indexPath.row];
    if ([tempAppkey isEqualToString:EMDemoOptions.sharedOptions.appkey]) {
        cell.imageView.image = [UIImage imageNamed:@"currentAppkey"];
    } else {
        cell.imageView.image = [UIImage imageNamed:@"optionalAppkey"];
    }
    cell.textLabel.text = tempAppkey;
    cell.textLabel.font = [UIFont systemFontOfSize:14.0];
    cell.textLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
    cell.separatorInset = UIEdgeInsetsMake(0, 16, 0, 16);
    cell.accessoryType = UITableViewCellAccessoryNone;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *appkey = [EMDemoOptions.sharedOptions.locationAppkeyArray objectAtIndex:indexPath.row];
    if (![appkey isEqualToString:EMDemoOptions.sharedOptions.appkey]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"(づ｡◕‿‿◕｡)づ" message:@"当前appkey以及环境配置已生效，更换当前正使用appkey需重启客户端" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            EMDemoOptions.sharedOptions.appkey = appkey;
            [EMDemoOptions.sharedOptions.locationAppkeyArray insertObject:appkey atIndex:0];
            [EMDemoOptions.sharedOptions.locationAppkeyArray removeObjectAtIndex:(indexPath.row + 1)];
            [EMDemoOptions.sharedOptions archive];
            exit(0);
        }];
        [alertController addAction:okAction];
        
        [alertController addAction: [UIAlertAction actionWithTitle:@"取消" style: UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }]];
        alertController.modalPresentationStyle = 0;
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.001;
}

- (nullable NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *userName = [EMDemoOptions.sharedOptions.locationAppkeyArray objectAtIndex:indexPath.row];
    __weak typeof(self) weakself = self;
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"移除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [weakself _deleteAppkey:userName];
    }];
    deleteAction.backgroundColor = [UIColor redColor];
    return @[deleteAction];
}

# pragma mark - Action
- (void)_deleteAppkey:(NSString *)appkey
{
    if ([EMDemoOptions.sharedOptions.locationAppkeyArray count] <= 1) {
        [self showHint:@"不可移除最后的appkey"];
        return;
    } else if ([appkey isEqualToString:EMDemoOptions.sharedOptions.appkey]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"(づ｡◕‿‿◕｡)づ" message:@"当前appkey以及环境配置已生效，移除当前正使用appkey需重启客户端" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            EMDemoOptions.sharedOptions.appkey = @"";
            [EMDemoOptions.sharedOptions.locationAppkeyArray removeObject:appkey];
            exit(0);
        }];
        [alertController addAction:okAction];
        
        [alertController addAction: [UIAlertAction actionWithTitle:@"取消" style: UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }]];
        alertController.modalPresentationStyle = 0;
        [self presentViewController:alertController animated:YES completion:nil];
    }
    [EMDemoOptions.sharedOptions.locationAppkeyArray removeObject:appkey];
    [EMDemoOptions.sharedOptions archive];
    [self.tableView reloadData];
}

- (void)addCustomAPPKey
{
    EMPersonalAPPKeyViewController *personalAppkeyController = [[EMPersonalAPPKeyViewController alloc]init];
    [self.navigationController pushViewController:personalAppkeyController animated:NO];
}

@end
