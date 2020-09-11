//
//  EMInviteFriendViewController.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/10.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EMInviteFriendViewController.h"

#import "EMSearchBar.h"
#import "EMAvatarNameCell.h"

@interface EMInviteFriendViewController ()<UITextFieldDelegate, EMSearchBarDelegate, EMAvatarNameCellDelegate>

@property (nonatomic, strong) EMSearchBar *searchBar;

@property (nonatomic, strong) NSMutableArray *invitedUsers;

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
    [self addPopBackLeftItem];
    self.title = @"添加好友";
    
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
    EMAvatarNameCell *cell = (EMAvatarNameCell *)[tableView dequeueReusableCellWithIdentifier:@"UITableViewCellInviteFriend"];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[EMAvatarNameCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCellInviteFriend"];
        cell.delegate = self;
        
        UIButton *rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80, 35)];
        rightButton.clipsToBounds = YES;
        rightButton.backgroundColor = kColor_Blue;
        rightButton.titleLabel.font = [UIFont systemFontOfSize:16];
        rightButton.layer.cornerRadius = 5;
        [rightButton setTitle:@"添加好友" forState:UIControlStateNormal];
        [rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [rightButton setTitle:@"已申请" forState:UIControlStateDisabled];
        [rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
        cell.accessoryButton = rightButton;
    }
    
    NSString *name = [self.dataArray objectAtIndex:indexPath.row];
    cell.nameLabel.text = name;
    cell.avatarView.image = [UIImage imageNamed:@"defaultAvatar"];
    cell.indexPath = indexPath;
    
    NSArray *contacts = [[EMClient sharedClient].contactManager getContacts];
    NSArray *blacks = [[EMClient sharedClient].contactManager getBlackList];
    name = [name lowercaseString];
    if ([contacts containsObject:name] || [blacks containsObject:name]) {
        cell.accessoryButton.enabled = NO;
        [cell.accessoryButton setTitle:@"已添加" forState:UIControlStateDisabled];
        cell.accessoryButton.backgroundColor = kColor_Gray;
    } else if ([self.invitedUsers containsObject:name]) {
        [cell.accessoryButton setTitle:@"已申请" forState:UIControlStateDisabled];
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
    
    if([[name uppercaseString] isEqualToString:[EMClient.sharedClient.currentUsername uppercaseString]]) {
        [EMAlertController showErrorAlert:@"无法添加自己为好友"];
        return;
    }
    
    [self showHudInView:self.view hint:@"发送好友请求..."];
    __weak typeof(self) weakself = self;
    [[EMClient sharedClient].contactManager addContact:name message:nil completion:^(NSString *aUsername, EMError *aError) {
        [weakself hideHud];
        if (aError) {
            [EMAlertController showErrorAlert:@"添加失败"];
        } else {
            [weakself.invitedUsers addObject:name];
            
            aCell.accessoryButton.enabled = NO;
            [aCell.accessoryButton setTitle:@"已申请" forState:UIControlStateDisabled];
            aCell.accessoryButton.backgroundColor = kColor_Gray;
            
            [EMAlertController showSuccessAlert:@"已发出好友申请"];
        }
    }];
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
    
    [self.dataArray removeAllObjects];
    
    if ([aString length] > 0) {
        [self.dataArray addObject:aString];
    }
    [self.tableView reloadData];
}

@end
