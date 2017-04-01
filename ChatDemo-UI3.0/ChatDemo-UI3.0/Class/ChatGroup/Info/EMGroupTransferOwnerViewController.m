//
//  EMGroupTransferOwnerViewController.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 09/03/2017.
//  Copyright © 2017 XieYajie. All rights reserved.
//

#import "EMGroupTransferOwnerViewController.h"

#import "EMMemberCell.h"

@interface EMGroupTransferOwnerViewController ()

@property (nonatomic, strong) EMGroup *group;

@property (nonatomic, strong) NSString *cursor;

@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@property (nonatomic, strong) UIView *selectedView;

@end

@implementation EMGroupTransferOwnerViewController

- (instancetype)initWithGroup:(EMGroup *)aGroup
{
    self = [super init];
    if (self) {
        _group = aGroup;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _setupNavigationBar];
    
    self.showRefreshHeader = YES;
    self.showRefreshFooter = YES;
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.selectedView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"check"]];
    
    [self tableViewDidTriggerHeaderRefresh];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation Bar

- (void)_setupNavigationBar
{
    self.title = @"转让群主";
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    [backButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backItem;
    
    UIButton *doneButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 50)];
    [doneButton setTitle:@"保存" forState:UIControlStateNormal];
    [doneButton addTarget:self action:@selector(doneAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithCustomView:doneButton];
    self.navigationItem.rightBarButtonItem = doneItem;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EMMemberCell *cell = (EMMemberCell *)[tableView dequeueReusableCellWithIdentifier:@"EMMemberCell"];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"EMMemberCell" owner:self options:nil] lastObject];
    }
    
    cell.imgView.image = [UIImage imageNamed:@"default_avatar"];
    cell.leftLabel.text = [self.dataArray objectAtIndex:indexPath.row];
    
    if (indexPath == self.selectedIndexPath) {
        cell.accessoryView = self.selectedView;
    } else {
        cell.accessoryView = nil;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.selectedIndexPath) {
        EMMemberCell *oldCell = [tableView cellForRowAtIndexPath:self.selectedIndexPath];
        oldCell.accessoryView = nil;
    }
    
    if (self.selectedIndexPath == indexPath) {
        self.selectedIndexPath = nil;
        return;
    }
    
    self.selectedIndexPath = nil;
    if (self.selectedIndexPath != indexPath) {
        self.selectedIndexPath = indexPath;
        
        EMMemberCell *cell = [tableView cellForRowAtIndexPath:self.selectedIndexPath];
        cell.accessoryView = self.selectedView;
    }
}

#pragma mark - Action

- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)doneAction
{
    if (self.selectedIndexPath) {
        [self showHudInView:self.view hint:@"Hold on ..."];
        NSString *newOwner = [self.dataArray objectAtIndex:self.selectedIndexPath.row];
        
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
            EMError *error = nil;
            weakSelf.group = [[EMClient sharedClient].groupManager updateGroupOwner:self.group.groupId newOwner:newOwner error:&error];
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf hideHud];
                if (error) {
                    [weakSelf showHint:NSLocalizedString(@"group.changeOwnerFail", @"Failed to change owner")];
                } else {
                    [weakSelf backAction];
                }
            });
        });
    }
}

#pragma mark - Data

- (void)tableViewDidTriggerHeaderRefresh
{
    __weak typeof(self) weakSelf = self;
    [self showHudInView:self.view hint:NSLocalizedString(@"loadData", @"Load data...")];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
        EMError *error = nil;
        EMGroup *group = [[EMClient sharedClient].groupManager getGroupSpecificationFromServerWithId:weakSelf.group.groupId error:&error];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf hideHud];
            
            if (!error) {
                weakSelf.group = group;
                [weakSelf.dataArray removeAllObjects];
                [weakSelf.dataArray addObjectsFromArray:weakSelf.group.adminList];
                weakSelf.cursor = @"";
                [weakSelf fetchMembersWithPage:weakSelf.page isHeader:YES];
            }
            else{
                [weakSelf showHint:NSLocalizedString(@"group.fetchInfoFail", @"failed to get the group details, please try again later")];
            }
        });
    });
}

- (void)tableViewDidTriggerFooterRefresh
{
    [self fetchMembersWithPage:self.page isHeader:NO];
}

- (void)fetchMembersWithPage:(NSInteger)aPage
                    isHeader:(BOOL)aIsHeader
{
    NSInteger pageSize = 50;
    __weak typeof(self) weakSelf = self;
    [self showHudInView:self.view hint:NSLocalizedString(@"loadData", @"Load data...")];
    [[EMClient sharedClient].groupManager getGroupMemberListFromServerWithId:self.group.groupId cursor:self.cursor pageSize:pageSize completion:^(EMCursorResult *aResult, EMError *aError) {
        weakSelf.cursor = aResult.cursor;
        [weakSelf hideHud];
        [weakSelf tableViewDidFinishTriggerHeader:aIsHeader reload:NO];
        if (!aError) {
            [weakSelf.dataArray addObjectsFromArray:aResult.list];
            [weakSelf.tableView reloadData];
        } else {
            [weakSelf showHint:NSLocalizedString(@"group.fetchInfoFail", @"failed to get the group details, please try again later")];
        }
        
        if ([aResult.list count] == 0) {
            weakSelf.showRefreshFooter = NO;
        } else {
            weakSelf.showRefreshFooter = YES;
        }
    }];
}

@end
