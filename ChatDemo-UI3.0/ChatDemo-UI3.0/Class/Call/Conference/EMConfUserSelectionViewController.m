//
//  EMConfUserSelectionViewController.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 8/31/16.
//  Copyright © 2016 XieYajie. All rights reserved.
//

#import "EMConfUserSelectionViewController.h"

#import "DemoConfManager.h"

#import "EMConfAddUserCell.h"
#import "UIViewController+SearchController.h"

@implementation EMConfSelectionUserView

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deleteAction:)];
    [self addGestureRecognizer:tap];
}

#pragma mark - action

- (void)deleteAction:(UITapGestureRecognizer *)aTap
{
    if (aTap.state == UIGestureRecognizerStateEnded) {
        if (_delegate && [_delegate respondsToSelector:@selector(deselectUser:)]) {
            [_delegate deselectUser:self.nameLabel.text];
        }
    }
}

@end

@interface EMConfUserSelectionViewController()<UITableViewDelegate, UITableViewDataSource, EMSearchControllerDelegate, EMConfAddUserCellDelegate, EMConfSelectionUserViewDelegate>
{
    int _border;
    int _userViewSize;
}

@property (nonatomic, strong) UIScrollView *selectedView;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) NSArray *topShowArray;
@property (nonatomic, strong) NSMutableArray *selectedNames;
@property (nonatomic, strong) NSMutableArray *userViews;

@end

@implementation EMConfUserSelectionViewController

- (instancetype)initWithDataSource:(NSArray *)aDataSource
                     selectedUsers:(NSArray *)aSelectedUsers
{
    self = [super init];
    if (self) {
        self.dataArray = aDataSource;
        self.topShowArray = aSelectedUsers;
        self.selectedNames = [[NSMutableArray alloc] init];
        self.userViews = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        self.edgesForExtendedLayout =  UIRectEdgeNone;
    }
    
    self.title = NSLocalizedString(@"title.conference.addUser", @"Add User");
    
    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"down", @"Down") style:UIBarButtonItemStylePlain target:self action:@selector(doneAction)];
    self.navigationItem.rightBarButtonItem = doneItem;
    
    [self _setupSubviews];
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.tableView.tag != 1) {
        self.tableView.tag = 1;
        CGFloat oY = CGRectGetMaxY(self.selectedView.frame) + 13;
        self.tableView.frame = CGRectMake(0, oY, self.view.frame.size.width, self.view.frame.size.height - oY);
    }
}


#pragma mark - Subviewa

- (void)_setupSubviews
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    int oY = 0;
    _border = 10;
    _userViewSize = 70;
    
//    [self enableSearchController];
//    UISearchBar *searchBar = self.searchController.searchBar;
//    CGRect frame = searchBar.frame;
//    frame.origin.x = 0;
//    frame.origin.y = 0;
//    searchBar.frame = frame;
//    [self.view addSubview:searchBar];
    
//    oY = CGRectGetMaxY(searchBar.frame);
    
    self.selectedView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, oY, self.view.frame.size.width, _userViewSize + 10)];
    self.selectedView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.selectedView];
    oY = CGRectGetMaxY(self.selectedView.frame);
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, oY + 10, self.view.frame.size.width, 1)];
    lineView.backgroundColor = [UIColor colorWithRed:229 / 255.0 green:233 / 255.0 blue:236 / 255.0 alpha:1.0];
    [self.view addSubview:lineView];
    oY = CGRectGetMaxY(lineView.frame);
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, oY, self.view.frame.size.width, self.view.frame.size.height - oY) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorColor = [UIColor colorWithRed:173 / 255.0 green:185 / 255.0 blue:193 / 255.0 alpha:1.0];
    self.tableView.backgroundColor = [UIColor colorWithRed:229 / 255.0 green:233 / 255.0 blue:236 / 255.0 alpha:1.0];
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.rowHeight = 50;
    
    UINib *nib = [UINib nibWithNibName:@"EMConfAddUserCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"EMConfAddUserCell"];
    [self.view addSubview:self.tableView];
    
    for (NSString *username in self.topShowArray) {
        EMConfSelectionUserView *loginView = [self _setupUserView:username];
        loginView.deleteImgView.hidden = YES;
    }
}

- (EMConfSelectionUserView *)_setupUserView:(NSString *)aUserName
{
    int count = (int)[self.userViews count];
    float ox = _border + count * (_border + _userViewSize);
    
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"EMConfSelectionUserView" owner:self options:nil];
    EMConfSelectionUserView *userView = [nib objectAtIndex:0];
    userView.frame = CGRectMake(ox, _border, _userViewSize, _userViewSize);
    userView.delegate = self;
    userView.nameLabel.text = aUserName;
    [self.userViews addObject:userView];
    [self.selectedView addSubview:userView];
    
    ++count;
    self.selectedView.contentSize = CGSizeMake(count * (_border + _userViewSize) + _border, self.selectedView.frame.size.height);
    
    return userView;
}

- (void)_removeUserView:(NSString *)aUserName
{
    int count = (int)[self.userViews count];
    int i = 0;
    for (; i < count; i++) {
        EMConfSelectionUserView *userView = [self.userViews objectAtIndex:i];
        if ([userView.nameLabel.text isEqualToString:aUserName]) {
            [self.userViews removeObjectAtIndex:i];
            [userView removeFromSuperview];
            break;
        }
    }
    
    if (i < count) {
        --count;
        for (; i < count; i++) {
            float ox = _border + i * (_border + _userViewSize);
            EMConfSelectionUserView *userView = [self.userViews objectAtIndex:i];
            userView.frame = CGRectMake(ox, _border, _userViewSize, _userViewSize);
        }
    }
    
    self.selectedView.contentSize = CGSizeMake(count * (_border + _userViewSize) + _border, self.selectedView.frame.size.height);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"EMConfAddUserCell";
    EMConfAddUserCell *cell = (EMConfAddUserCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.delegate = self;
    
    NSString *username = [self.dataArray objectAtIndex:indexPath.row];
    cell.nameLabel.text = username;
//    cell.checkButton.selected = [self.selectedNames containsObject:username];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *username = [self.dataArray objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    BOOL isChecked = [self.selectedNames containsObject:username];
    if (isChecked) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        [self.selectedNames removeObject:username];
        [self _removeUserView:username];
    } else {
        if ([self.selectedNames count] == 6) {
            cell.accessoryType = UITableViewCellAccessoryNone;
            return;
        }
        
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [self.selectedNames addObject:username];
        [self _setupUserView:username];
    }
}

#pragma mark - EMSearchControllerDelegate

#pragma mark - EMConfAddUserCellDelegate

- (void)cell:(EMConfAddUserCell *)aCell checkUserAction:(NSString *)aUsername
{
//    if ([self.selectedNames containsObject:aUsername]) {
//        [self.selectedNames removeObject:aUsername];
//        [self _removeUserView:aUsername];
//    } else {
//        if ([self.selectedNames count] == 6) {
//            aCell.checkButton.selected = NO;
//            return;
//        }
//        [self.selectedNames addObject:aUsername];
//        [self _setupUserView:aUsername];
//    }
}

#pragma mark - EMConfSelectionUserViewDelegate

- (void)deselectUser:(NSString *)aUserName
{
    if (aUserName == [EMClient sharedClient].currentUsername) {
        return;
    }
    
    [self.selectedNames removeObject:aUserName];
    [self _removeUserView:aUserName];
    
    NSInteger index = [self.dataArray indexOfObject:aUserName];
    EMConfAddUserCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    cell.accessoryType = UITableViewCellAccessoryNone;
}

#pragma mark - action

- (void)doneAction
{
    [self.navigationController popViewControllerAnimated:NO];
    if (_selecteUserFinishedCompletion) {
        _selecteUserFinishedCompletion(self.selectedNames);
    }
}

@end
