//
//  EMGroupsViewController.m
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 16/10/5.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "EMGroupsViewController.h"
#import "EMGroupCell.h"
#import "EMGroupModel.h"
#import "EMNotificationNames.h"
#import "EMGroupInfoViewController.h"
#import "EMCreateViewController.h"
#import "EMChatViewController.h"

@interface EMGroupsViewController ()

@property (nonatomic, strong) NSMutableArray *groups;

@end

@implementation EMGroupsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavBar];
    [self loadGroupsFromServer];
    [self addNotifications];
}

- (void)dealloc {
    [self removeNotifications];
}

- (void)setupNavBar {
    self.title = NSLocalizedString(@"common.groups", @"Groups");
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 20, 20);
    [btn setImage:[UIImage imageNamed:@"Icon_Add"] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"Icon_Add"] forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(addGroupAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBar = [[UIBarButtonItem alloc] initWithCustomView:btn];
    [self.navigationItem setRightBarButtonItem:rightBar];
    
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBtn.frame = CGRectMake(0, 0, 20, 20);
    [leftBtn setImage:[UIImage imageNamed:@"Icon_Back"] forState:UIControlStateNormal];
    [leftBtn setImage:[UIImage imageNamed:@"Icon_Back"] forState:UIControlStateHighlighted];
    [leftBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBar = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    [self.navigationItem setLeftBarButtonItem:leftBar];
}

- (void)loadGroupsFromServer {
    __weak typeof(self) weakSelf = self;
    [[EMClient sharedClient].groupManager getJoinedGroupsFromServerWithCompletion:^(NSArray *aList, EMError *aError) {
        if (!aError && aList.count > 0) {
            
            [weakSelf.groups removeAllObjects];
            for (EMGroup *group in aList) {
                EMGroupModel *model = [[EMGroupModel alloc] initWithObject:group];
                if (model) {
                    [weakSelf.groups addObject:model];
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^(){
                [weakSelf endHeaderRefresh];
                [weakSelf.tableView reloadData];
            });
        }
    }];
}

- (void)loadGroupsFromCache {
    NSArray *myGroups = [[EMClient sharedClient].groupManager getJoinedGroups];
    [self.groups removeAllObjects];
    for (EMGroup *group in myGroups) {
        EMGroupModel *model = [[EMGroupModel alloc] initWithObject:group];
        if (model) {
            [self.groups addObject:model];
        }
    }
    [self endHeaderRefresh];
    [self.tableView reloadData];
}

- (void)addNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshGroupList:) name:KEM_REFRESH_GROUPLIST_NOTIFICATION object:nil];
}

- (void)removeNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KEM_REFRESH_GROUPLIST_NOTIFICATION object:nil];
}

#pragma mark - Lazy Method

- (NSMutableArray *)groups {
    if (!_groups) {
        _groups = [NSMutableArray array];
    }
    return _groups;
}

#pragma mark - Action

- (void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)addGroupAction {

    EMCreateViewController *publicVc = [[EMCreateViewController alloc] initWithNibName:@"EMCreateViewController" bundle:nil];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:publicVc];
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark - Notification Method

- (void)refreshGroupList:(NSNotification *)notification {
    NSArray *groupList = [[EMClient sharedClient].groupManager getJoinedGroups];
    [self.groups removeAllObjects];
    for (EMGroup *group in groupList) {
        EMGroupModel *model = [[EMGroupModel alloc] initWithObject:group];
        if (model) {
            [self.groups addObject:model];
        }
    }
    [self.tableView reloadData];
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return _groups.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"EMGroupCell";
    EMGroupCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"EMGroupCell" owner:self options:nil] lastObject];
    }
    cell.model = _groups[indexPath.row];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    EMGroupModel *model = _groups[indexPath.row];
    EMChatViewController *chatViewController = [[EMChatViewController alloc] initWithConversationId:model.hyphenateId conversationType:EMConversationTypeGroupChat];
//    EMGroupInfoViewController *groupInfoVc = [[EMGroupInfoViewController alloc] initWithGroup:model.group];
    [self.navigationController pushViewController:chatViewController animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70.0f;
}

@end
