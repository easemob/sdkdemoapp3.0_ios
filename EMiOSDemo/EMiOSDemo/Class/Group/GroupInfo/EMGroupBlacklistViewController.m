//
//  EMGroupBlacklistViewController.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/2/19.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EMGroupBlacklistViewController.h"
#import "EMAvatarNameCell.h"
#import "EMAvatarNameCell.h"
#import "EMPersonalDataViewController.h"

@interface EMGroupBlacklistViewController ()

@property (nonatomic, strong) EMGroup *group;
@property (nonatomic) BOOL isUpdated;

@end

@implementation EMGroupBlacklistViewController

- (instancetype)initWithGroup:(EMGroup *)aGroup
{
    self = [super init];
    if (self) {
        self.group = aGroup;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.isUpdated = NO;
    self.searchBar.delegate = self;
    
    [self _setupSubviews];
    [self _fetchGroupBlacklistWithIsHeader:YES isShowHUD:YES];
}

#pragma mark - Subviews

- (void)_setupSubviews
{
    [self addPopBackLeftItemWithTarget:self action:@selector(backAction)];
    self.title = @"群黑名单";
    self.showRefreshHeader = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.tableView.rowHeight = 60;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.tableView) {
        return [self.dataArray count];
    } else {
        return [self.searchResults count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EMAvatarNameCell *cell = (EMAvatarNameCell *)[tableView dequeueReusableCellWithIdentifier:@"EMAvatarNameCell"];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[EMAvatarNameCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"EMAvatarNameCell"];
    }
    
    NSString *name = nil;
    if (tableView == self.tableView) {
        name = [self.dataArray objectAtIndex:indexPath.row];
    } else {
        name = [self.searchResults objectAtIndex:indexPath.row];
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.avatarView.image = [UIImage imageNamed:@"defaultAvatar"];
    cell.nameLabel.text = name;
    cell.indexPath = indexPath;
    
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self personalData:[self.dataArray objectAtIndex:indexPath.row]];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //在iOS8.0上，必须加上这个方法才能出发左划操作
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSString *userName = nil;
        if (tableView == self.tableView) {
            userName = [self.dataArray objectAtIndex:indexPath.row];
        } else {
            userName = [self.searchResults objectAtIndex:indexPath.row];
        }

        [self showHudInView:self.view hint:@"移出黑名单..."];
        __weak typeof(self) weakself = self;
        [[EMClient sharedClient].groupManager unblockMembers:@[userName] fromGroup:self.group.groupId completion:^(EMGroup *aGroup, EMError *aError) {
            [weakself hideHud];
            if (aError) {
                [EMAlertController showErrorAlert:@"移出黑名单失败"];
            } else {
                weakself.isUpdated = YES;
                [EMAlertController showSuccessAlert:@"移出黑名单成功"];
                [weakself.dataArray removeObject:userName];
                [weakself.tableView reloadData];
                [weakself.searchResults removeObject:userName];
                [weakself.searchResultTableView reloadData];
            }
        }];
    }
}

#pragma mark - EMSearchBarDelegate

- (void)searchTextDidChangeWithString:(NSString *)aString
{
    __weak typeof(self) weakself = self;
    [[EMRealtimeSearch shared] realtimeSearchWithSource:self.dataArray searchText:aString collationStringSelector:nil resultBlock:^(NSArray *results) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself.searchResults removeAllObjects];
            [weakself.searchResults addObjectsFromArray:results];
            [weakself.searchResultTableView reloadData];
        });
    }];
}

#pragma mark - Data

- (void)_fetchGroupBlacklistWithIsHeader:(BOOL)aIsHeader
                               isShowHUD:(BOOL)aIsShowHUD
{
    if (aIsShowHUD) {
        [self showHudInView:self.view hint:@"获取群组黑名单..."];
    }
    
    __weak typeof(self) weakself = self;
    [[EMClient sharedClient].groupManager getGroupBlacklistFromServerWithId:self.group.groupId pageNumber:self.page pageSize:50 completion:^(NSArray *aList, EMError *aError) {
        if (aIsShowHUD) {
            [weakself hideHud];
        }
        
        if (aError) {
            [EMAlertController showErrorAlert:aError.errorDescription];
        } else {
            if (aIsHeader) {
                [weakself.dataArray removeAllObjects];
            }
            [weakself.dataArray addObjectsFromArray:aList];
            
            if ([aList count] == 0) {
                weakself.showRefreshFooter = NO;
            } else {
                weakself.showRefreshFooter = YES;
            }
            
            [weakself.tableView reloadData];
        }
        
        [weakself tableViewDidFinishTriggerHeader:aIsHeader reload:NO];
    }];
}

- (void)tableViewDidTriggerHeaderRefresh
{
    self.page = 1;
    [self _fetchGroupBlacklistWithIsHeader:YES isShowHUD:NO];
}

- (void)tableViewDidTriggerFooterRefresh
{
    self.page += 1;
    [self _fetchGroupBlacklistWithIsHeader:NO isShowHUD:NO];
}

#pragma mark - Action

- (void)backAction
{
    if (self.isUpdated) {
        [[NSNotificationCenter defaultCenter] postNotificationName:GROUP_INFO_UPDATED object:self.group];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

//个人资料卡
- (void)personalData:(NSString *)nickName
{
    EMPersonalDataViewController *controller = [[EMPersonalDataViewController alloc]initWithNickName:nickName];
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    UIViewController *rootViewController = window.rootViewController;
    if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = (UINavigationController *)rootViewController;
        [nav pushViewController:controller animated:YES];
    }
}

@end
