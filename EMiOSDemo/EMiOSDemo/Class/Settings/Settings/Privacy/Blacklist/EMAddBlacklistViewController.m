//
//  EMAddBlacklistViewController.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/2/19.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EMAddBlacklistViewController.h"

#import "EMRealtimeSearch.h"

#import "EMSearchBar.h"
#import "EMAvatarNameCell.h"

@interface EMAddBlacklistViewController ()<EMSearchBarDelegate, EMAvatarNameCellDelegate>

@property (nonatomic, strong) NSArray *contacts;
@property (nonatomic, strong) NSArray *blacklist;

@property (nonatomic, strong) EMSearchBar *searchBar;

@end

@implementation EMAddBlacklistViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.contacts = [[EMClient sharedClient].contactManager getContacts];
    self.blacklist = [[EMClient sharedClient].contactManager getBlackList];
    
    [self _setupSubviews];
}

#pragma mark - Subviews

- (void)_setupSubviews
{
    [self addPopBackLeftItemWithTarget:self action:@selector(backAction)];
    self.title = @"添加至黑名单";
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.searchBar = [[EMSearchBar alloc] init];
    self.searchBar.delegate = self;
    self.searchBar.textField.placeholder = @"搜索用户ID";
    [self.view addSubview:self.searchBar];
    [self.searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.equalTo(@50);
    }];
    
    self.tableView.rowHeight = 60;
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.searchBar.mas_bottom);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EMAvatarNameCell *cell = (EMAvatarNameCell *)[tableView dequeueReusableCellWithIdentifier:@"UITableViewCellBlacklist"];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[EMAvatarNameCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCellBlacklist"];
        cell.delegate = self;
        
        UIButton *rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80, 35)];
        rightButton.clipsToBounds = YES;
        rightButton.backgroundColor = kColor_Blue;
        rightButton.titleLabel.font = [UIFont systemFontOfSize:16];
        rightButton.layer.cornerRadius = 5;
        [rightButton setTitle:@"拉黑用户" forState:UIControlStateNormal];
        [rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [rightButton setTitle:@"已拉黑" forState:UIControlStateDisabled];
        [rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
        cell.accessoryButton = rightButton;
    }
    
    NSString *name = [self.dataArray objectAtIndex:indexPath.row];
    cell.nameLabel.text = name;
    cell.avatarView.image = [UIImage imageNamed:@"defaultAvatar"];
    cell.indexPath = indexPath;
    
    if ([self.blacklist containsObject:name]) {
        cell.accessoryButton.enabled = NO;
        cell.accessoryButton.backgroundColor = kColor_Gray;
    } else {
        cell.accessoryButton.enabled = YES;
        cell.accessoryButton.backgroundColor = kColor_Blue;
    }
    
    return cell;
}

#pragma mark - EMAvatarNameCellDelegate

- (void)cellAccessoryButtonAction:(EMAvatarNameCell *)aCell
{
    NSString *name = [self.dataArray objectAtIndex:aCell.indexPath.row];
    
    [self showHudInView:self.view hint:@"拉黑用户..."];
    __weak typeof(self) weakself = self;
    [[EMClient sharedClient].contactManager addUserToBlackList:name completion:^(NSString *aUsername, EMError *aError) {
        [weakself hideHud];
        if (aError) {
            [EMAlertController showErrorAlert:@"拉黑用户失败"];
        } else {
            weakself.contacts = [[EMClient sharedClient].contactManager getContacts];
            weakself.blacklist = [[EMClient sharedClient].contactManager getBlackList];
            
            aCell.accessoryButton.enabled = NO;
            aCell.accessoryButton.backgroundColor = kColor_Gray;
            
            [EMAlertController showSuccessAlert:@"拉黑用户成功"];
        }
    }];
}

#pragma mark - EMSearchBarDelegate

- (void)searchBarCancelButtonAction:(EMSearchBar *)searchBar
{
    [[EMRealtimeSearch shared] realtimeSearchStop];
    
    [self.dataArray removeAllObjects];
    [self.tableView reloadData];
}

- (void)searchBarSearchButtonClicked:(NSString *)aString
{
    [self searchTextDidChangeWithString:aString];
}

- (void)searchTextDidChangeWithString:(NSString *)aString
{
    __weak typeof(self) weakself = self;
    [[EMRealtimeSearch shared] realtimeSearchWithSource:self.contacts searchText:aString collationStringSelector:nil resultBlock:^(NSArray *results) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself.dataArray removeAllObjects];
            [weakself.dataArray addObjectsFromArray:results];
            [weakself.tableView reloadData];
        });
    }];
}

#pragma mark - Action

- (void)backAction
{
    [[EMRealtimeSearch shared] realtimeSearchStop];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:CONTACT_BLACKLIST_RELOAD object:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
