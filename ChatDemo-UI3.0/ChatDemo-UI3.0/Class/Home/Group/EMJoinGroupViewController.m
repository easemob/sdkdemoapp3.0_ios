//
//  EMJoinGroupViewController.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/17.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EMJoinGroupViewController.h"

#import "EMSearchBar.h"
#import "EMAvatarNameCell.h"

@interface EMJoinGroupViewController ()<EMSearchBarDelegate, EMAvatarNameCellDelegate>

@property (nonatomic, strong) EMSearchBar *searchBar;

@property (nonatomic, strong) NSMutableArray *joinedIdArray;
@property (nonatomic, strong) NSMutableArray *applyedIdArray;

@end

@implementation EMJoinGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.joinedIdArray = [[NSMutableArray alloc] init];
    self.applyedIdArray = [[NSMutableArray alloc] init];
    
    [self _setupSubviews];
}

#pragma mark - Subviews

- (void)_setupSubviews
{
    [self addPopBackLeftItem];
    self.title = @"加入群组";
    
    self.searchBar = [[EMSearchBar alloc] init];
    self.searchBar.delegate = self;
    self.searchBar.textField.placeholder = @"搜索群组ID";
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    return [self.dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"EMAvatarNameCell";
    EMAvatarNameCell *cell = (EMAvatarNameCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[EMAvatarNameCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.delegate = self;
        
        UIButton *rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80, 35)];
        rightButton.clipsToBounds = YES;
        rightButton.backgroundColor = kColor_Blue;
        rightButton.titleLabel.font = [UIFont systemFontOfSize:16];
        rightButton.layer.cornerRadius = 5;
        [rightButton setTitle:@"加入" forState:UIControlStateNormal];
        [rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [rightButton setTitle:@"已申请" forState:UIControlStateDisabled];
        [rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
        cell.accessoryButton = rightButton;
    }
    
    EMGroup *group = [self.dataArray objectAtIndex:indexPath.row];
    cell.avatarView.image = [UIImage imageNamed:@"user_2"];
    if ([group.subject length]) {
        cell.nameLabel.text = group.subject;
    } else {
        cell.nameLabel.text = group.groupId;
    }
    cell.detailLabel.text = group.groupId;
    cell.indexPath = indexPath;
    
    if ([self.applyedIdArray containsObject:group.groupId]) {
        cell.accessoryButton.enabled = NO;
        [cell.accessoryButton setTitle:@"已申请" forState:UIControlStateDisabled];
        cell.accessoryButton.backgroundColor = kColor_Gray;
    } else if ([self.joinedIdArray containsObject:group.groupId]) {
        cell.accessoryButton.enabled = NO;
        [cell.accessoryButton setTitle:@"已加入" forState:UIControlStateDisabled];
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
    __weak typeof(self) weakself = self;
    
    EMGroup *group = [self.dataArray objectAtIndex:aCell.indexPath.row];
    if (group.setting.style == EMGroupStylePublicOpenJoin) {
        [self showHudInView:self.view hint:@"加入群组..."];
        [[EMClient sharedClient].groupManager joinPublicGroup:group.groupId completion:^(EMGroup *aGroup, EMError *aError) {
            [weakself hideHud];
            if (aError) {
                [EMAlertController showErrorAlert:@"加入群组失败"];
            } else {
                [weakself.joinedIdArray addObject:group.groupId];
                aCell.accessoryButton.enabled = NO;
                [aCell.accessoryButton setTitle:@"已加入" forState:UIControlStateDisabled];
                aCell.accessoryButton.backgroundColor = kColor_Gray;
            }
        }];
    } else if (group.setting.style == EMGroupStylePublicJoinNeedApproval) {
        [self showHudInView:self.view hint:@"发送入群申请..."];
        [[EMClient sharedClient].groupManager requestToJoinPublicGroup:group.groupId message:nil completion:^(EMGroup *aGroup, EMError *aError) {
            [weakself hideHud];
            if (aError) {
                [EMAlertController showErrorAlert:@"发送申请失败"];
            } else {
                [weakself.applyedIdArray addObject:group.groupId];
                aCell.accessoryButton.enabled = NO;
                [aCell.accessoryButton setTitle:@"已申请" forState:UIControlStateDisabled];
                aCell.accessoryButton.backgroundColor = kColor_Gray;
            }
        }];
    }
}

#pragma mark - EMSearchBarDelegate

- (void)searchBarCancelButtonAction:(EMSearchBar *)searchBar
{
    [self.dataArray removeAllObjects];
    [self.tableView reloadData];
}

- (void)searchBarSearchButtonClicked:(NSString *)aString
{
    [self.view endEditing:YES];
    [self _searchGroupWithId:aString];
}

#pragma mark - Action

- (BOOL)_isJoined:(EMGroup *)aGroup
{
    if (aGroup) {
        NSArray *groupList = [[EMClient sharedClient].groupManager getJoinedGroups];
        for (EMGroup *tmpGroup in groupList) {
            if (tmpGroup.isPublic == aGroup.isPublic && [aGroup.groupId isEqualToString:tmpGroup.groupId]) {
                return YES;
            }
        }
    }
    
    return NO;
}

- (void)_searchGroupWithId:(NSString *)aId
{
//    aId = @"71633990647809";
    __weak typeof(self) weakself = self;
    [self showHudInView:self.view hint:@"搜索群组..."];
    [[EMClient sharedClient].groupManager searchPublicGroupWithId:aId completion:^(EMGroup *aGroup, EMError *aError) {
        [weakself hideHud];
        if (!aError) {
            [weakself.dataArray removeAllObjects];
            [weakself.dataArray addObject:aGroup];
            
            [weakself.joinedIdArray removeAllObjects];
            if ([self _isJoined:aGroup]) {
                [weakself.joinedIdArray addObject:aGroup.groupId];
            }
            
            [weakself.tableView reloadData];
        } else {
            [EMAlertController showErrorAlert:@"未搜索到群组"];
        }
    }];
}

@end
