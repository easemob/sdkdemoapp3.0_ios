//
//  ConfInviteUsersViewController.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2018/9/20.
//  Copyright © 2018 XieYajie. All rights reserved.
//

#import "ConfInviteUsersViewController.h"

#import "Masonry.h"

#import "RealtimeSearchUtil.h"
#import "DemoConfManager.h"
#import "ConfInviteUserCell.h"

@interface ConfInviteUsersViewController ()<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (nonatomic) EMConferenceType type;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UISearchBar *searchBar;

@property (nonatomic, strong) UITableView *searchTableView;
@property (nonatomic) BOOL isSearching;

@property (nonatomic, strong) NSMutableArray *searchDataArray;

@end

@implementation ConfInviteUsersViewController

- (instancetype)initWithType:(EMConferenceType)aType
{
    self = [super init];
    if (self) {
        _type = aType;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _dataArray = [[NSMutableArray alloc] init];
    self.searchDataArray = [[NSMutableArray alloc] init];
    self.inviteUsers = [[NSMutableArray alloc] init];
    
    [self _setupSubviews];
    
    UINib *nib = [UINib nibWithNibName:@"ConfInviteUserCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"ConfInviteUserCell"];
    [self.searchTableView registerNib:nib forCellReuseIdentifier:@"ConfInviteUserCell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    self.searchBar.delegate = nil;
}

#pragma mark - Subviews

- (void)_setupSubviews
{
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.textColor = [UIColor blackColor];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.font = [UIFont systemFontOfSize:18];
    self.titleLabel.text = @"邀请参加";
    [self.view addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(45);
        make.right.equalTo(self.view).offset(-45);
        make.top.equalTo(self.view).offset(20);
        make.height.equalTo(@45);
    }];
    
    UIButton *closeButton = [[UIButton alloc] init];
    closeButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [closeButton setTitle:@"关闭" forState:UIControlStateNormal];
    [closeButton setTitleColor:[UIColor colorWithRed:8 / 255.0 green:115 / 255.0 blue:222 / 255.0 alpha:1.0] forState:UIControlStateNormal];
    [closeButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [closeButton addTarget:self action:@selector(closeAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeButton];
    [closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLabel.mas_right);
        make.right.equalTo(self.view).offset(-10);
        make.top.equalTo(self.titleLabel);
        make.bottom.equalTo(self.titleLabel);
    }];
    
    self.searchBar = [[UISearchBar alloc] init];
    self.searchBar.delegate = self;
    self.searchBar.barTintColor = [UIColor whiteColor];
    self.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    UITextField *searchField = [self.searchBar valueForKey:@"searchField"];
    CGFloat color = 245 / 255.0;
    searchField.backgroundColor = [UIColor colorWithRed:color green:color blue:color alpha:1.0];
    self.searchBar.placeholder = @"搜索联系人";
    [self.view addSubview:self.searchBar];
    [self.view sendSubviewToBack:self.searchBar];
    [self.searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).offset(10);
        make.left.equalTo(self.view).offset(10);
        make.right.equalTo(self.view).offset(-10);
    }];
    
    UIButton *startButton = [[UIButton alloc] init];
    startButton.layer.cornerRadius = 24;
    startButton.layer.shadowColor = [UIColor grayColor].CGColor;
    startButton.layer.shadowOpacity = 0.8f;
    startButton.layer.shadowRadius = 4.0f;
    startButton.layer.shadowOffset = CGSizeMake(0, 0);
    startButton.backgroundColor = [UIColor colorWithRed:20 / 255.0 green:137 / 255.0 blue:71 / 255.0 alpha:1.0];
    [startButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [startButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [startButton setImage:[UIImage imageNamed:@"video_white"] forState:UIControlStateNormal];
    [startButton setTitle:@"  开始会议" forState:UIControlStateNormal];
    [startButton addTarget:self action:@selector(startConferenceAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:startButton];
    [startButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(-36);
        make.left.equalTo(self.view).offset(36);
        make.right.equalTo(self.view).offset(-36);
        make.height.equalTo(@48);
    }];
    
    self.searchTableView = [[UITableView alloc] init];
    self.searchTableView.delegate = self;
    self.searchTableView.dataSource = self;
    self.searchTableView.rowHeight = 60;
    
    _tableView = [[UITableView alloc] init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 60;
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.searchBar.mas_bottom);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(startButton.mas_top).offset(-20);
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.isSearching ? [self.searchDataArray count] : [self.dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"ConfInviteUserCell";
    ConfInviteUserCell *cell = (ConfInviteUserCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    NSString *username = self.isSearching ? [self.searchDataArray objectAtIndex:indexPath.row] : [self.dataArray objectAtIndex:indexPath.row];
    cell.nameLabel.text = username;
    cell.isChecked = [self.inviteUsers containsObject:username];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *username = self.isSearching ? [self.searchDataArray objectAtIndex:indexPath.row] : [self.dataArray objectAtIndex:indexPath.row];
    ConfInviteUserCell *cell = (ConfInviteUserCell *)[tableView cellForRowAtIndexPath:indexPath];
    BOOL isChecked = [self.inviteUsers containsObject:username];
    if (isChecked) {
        [self.inviteUsers removeObject:username];
    } else {
        [self.inviteUsers addObject:username];
    }
    cell.isChecked = !isChecked;
    
    NSInteger count = [self.inviteUsers count];
    self.titleLabel.text = count == 0 ? @"邀请参加" : [[NSString alloc] initWithFormat:@"邀请参加(%@)", @(count)];
}

#pragma mark - UISearchBarDelegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES];
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (!self.isSearching) {
        self.isSearching = YES;
        [self.view addSubview:self.searchTableView];
        [self.searchTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.tableView);
            make.left.equalTo(self.tableView);
            make.right.equalTo(self.tableView);
            make.bottom.equalTo(self.tableView);
        }];
    }
    
    __weak typeof(self) weakSelf = self;
    [[RealtimeSearchUtil currentUtil] realtimeSearchWithSource:self.dataArray searchText:searchBar.text collationStringSelector:nil resultBlock:^(NSArray *results) {
        if (results) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.searchDataArray removeAllObjects];
                [weakSelf.searchDataArray addObjectsFromArray:results];
                [self.searchTableView reloadData];
            });
        }
    }];
}

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [searchBar resignFirstResponder];

        return NO;
    }

    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [[RealtimeSearchUtil currentUtil] realtimeSearchStop];
    [searchBar setShowsCancelButton:NO];
    [searchBar resignFirstResponder];

    self.isSearching = NO;
    [self.searchDataArray removeAllObjects];
    [self.searchTableView removeFromSuperview];
    [self.searchTableView reloadData];
    [self.tableView reloadData];
}

#pragma mark - Action

- (void)closeAction
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)startConferenceAction
{
    __weak typeof(self) weakSelf = self;
    [self dismissViewControllerAnimated:YES completion:^{
        [[DemoConfManager sharedManager] startConferenceWithType:weakSelf.type password:@"" inviteUsers:weakSelf.inviteUsers];
    }];
}

@end
