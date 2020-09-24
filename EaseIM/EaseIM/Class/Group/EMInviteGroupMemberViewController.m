//
//  EMInviteGroupMemberViewController.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/17.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EMInviteGroupMemberViewController.h"

#import "EMAvatarNameCell.h"

@interface EMInviteGroupMemberViewController ()

@property (nonatomic, strong) NSArray *blocks;

@property (nonatomic, strong) NSMutableArray *selectedArray;

@end

@implementation EMInviteGroupMemberViewController

- (instancetype)initWithBlocks:(NSArray *)aBlocks
{
    self = [super init];
    if (self) {
        _blocks = aBlocks;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.selectedArray = [[NSMutableArray alloc] init];
    [self _setupSubviews];
    
    [self _fetchContactsWithIsShowHUD:YES];
}

#pragma mark - Subviews

- (void)_setupSubviews
{
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        [self setEdgesForExtendedLayout: UIRectEdgeNone];
    }
    
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navbar_white"] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar.layer setMasksToBounds:YES];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"close_gray"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(closeAction)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"完成( 0 )" style:UIBarButtonItemStylePlain target:self action:@selector(doneAction)];
    self.title = @"选择群组成员";
    
    self.view.backgroundColor = kColor_LightGray;
    self.tableView.backgroundColor = kColor_LightGray;
    self.showRefreshHeader = YES;

    [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.searchBar.mas_bottom);
        make.right.left.bottom.equalTo(self.view);
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
    NSInteger count = 0;
    if (tableView == self.tableView) {
        count = [self.dataArray count];
    } else {
        count = [self.searchResults count];
    }
    
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"EMAvatarNameCell";
    EMAvatarNameCell *cell = (EMAvatarNameCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[EMAvatarNameCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        UIButton *checkButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 45, 45)];
        checkButton.tag = 100;
        [checkButton setImage:[UIImage imageNamed:@"unCheck"] forState:UIControlStateNormal];
        [checkButton setImage:[UIImage imageNamed:@"check"] forState:UIControlStateSelected];
        checkButton.userInteractionEnabled = NO;
        cell.accessoryView = checkButton;
    }
    
    NSString *name = nil;
    if (tableView == self.tableView) {
        name = [self.dataArray objectAtIndex:indexPath.row];
    } else {
        name = [self.searchResults objectAtIndex:indexPath.row];
    }
    cell.avatarView.image = [UIImage imageNamed:@"defaultAvatar"];
    cell.nameLabel.text = name;
    
    UIButton *checkButton = (UIButton *)cell.accessoryView;
    checkButton.selected = [self.selectedArray containsObject:name];
    
    return cell;
}

#pragma mark - Table view delegate

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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *name = nil;
    if (tableView == self.tableView) {
        name = [self.dataArray objectAtIndex:indexPath.row];
    } else {
        name = [self.searchResults objectAtIndex:indexPath.row];
    }
    
    BOOL isChecked = [self.selectedArray containsObject:name];
    if (isChecked) {
        [self.selectedArray removeObject:name];
    } else {
        [self.selectedArray addObject:name];
    }
    
    EMAvatarNameCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UIButton *checkButton = (UIButton *)cell.accessoryView;
    checkButton.selected = !isChecked;
    [self.navigationItem.rightBarButtonItem setTitle:[NSString stringWithFormat:@"完成( %@ )", @([self.selectedArray count])]];
}

#pragma mark - EMSearchBarDelegate

- (void)searchBarCancelButtonAction:(EMSearchBar *)searchBar
{
    [super searchBarCancelButtonAction:searchBar];
    
    [self.tableView reloadData];
}

- (void)searchBarSearchButtonClicked:(NSString *)aString
{
    [self.view endEditing:YES];
}

- (void)searchTextDidChangeWithString:(NSString *)aString
{
    if (!self.isSearching) {
        return;
    }
    
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

- (void)_fetchContactsWithIsShowHUD:(BOOL)aIsShowHUD
{
    [self showHudInView:self.view hint:@"获取联系人..."];
    __weak typeof(self) weakself = self;
    [[EMClient sharedClient].contactManager getContactsFromServerWithCompletion:^(NSArray *aList, EMError *aError) {
        [weakself hideHud];
        if (!aError) {
            [weakself.dataArray removeAllObjects];
            NSMutableArray *ary = [NSMutableArray array];
            if ([weakself.blocks count] > 0) {
                NSMutableArray *array = [[NSMutableArray alloc] init];
                for (NSString *user in aList) {
                    if (![weakself.blocks containsObject:user]) {
                        [array addObject:user];
                    }
                }
                [ary addObjectsFromArray:array];
            }else {
                if (aList) {
                    [ary addObjectsFromArray:aList];
                }
            }
            [self.dataArray addObjectsFromArray:ary];
            [weakself.tableView reloadData];
        }
        [weakself tableViewDidFinishTriggerHeader:YES reload:NO];
    }];
}

- (void)tableViewDidTriggerHeaderRefresh
{
    [self _fetchContactsWithIsShowHUD:NO];
}

#pragma mark - Action

- (void)closeAction
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)doneAction
{
    if (_doneCompletion) {
        _doneCompletion(self.selectedArray);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
