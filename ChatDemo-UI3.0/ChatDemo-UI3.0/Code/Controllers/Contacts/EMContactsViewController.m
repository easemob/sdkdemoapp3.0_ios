//
//  EMContactsViewController.m
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 16/9/19.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "EMContactsViewController.h"
#import "EMContactListSectionHeader.h"
#import "EMSearchBar.h"
#import "EMAddContactViewController.h"
#import "EMContactInfoViewController.h"
#import "EMGroupTitleCell.h"
#import "EMContactCell.h"
#import "EMUserModel.h"
#import "EMContactListSectionHeader.h"

#define KEM_REFRESH_TINTCOLOR   [UIColor colorWithRed:82.0/255.0 green:210.0/255.0 blue:0.0/255.0 alpha:1.0]
#define KEM_REFRESH_ATTRIBUTES  @{NSForegroundColorAttributeName:KEM_REFRESH_TINTCOLOR}

#define KEM_CONTACT_SECTION_NUM  3 //tableView section 数量

@interface EMContactsViewController ()

@property (nonatomic, strong) NSMutableArray *contacts;
@property (nonatomic, strong) NSMutableArray *contactRequests;
@property (nonatomic, strong) NSMutableArray *groupNotifications;

@property (nonatomic, strong) EMSearchBar *searchBar;

@end

@implementation EMContactsViewController
{
    CGPoint _refreshOffset;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupRefreshControl];
    [self loadContactsFromServer];
}

- (void)setupNavigationItem:(UINavigationItem *)navigationItem {
    //设置titleView
    navigationItem.titleView = self.searchBar;
    //设置rightBarItems
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 20, 20);
    [btn setImage:[UIImage imageNamed:@"Icon_Add"] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"Icon_Add"] forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(addContactAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBar = [[UIBarButtonItem alloc] initWithCustomView:btn];
    //右移占位
    UIBarButtonItem *rightSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                target:nil
                                                                                action:nil];
    rightSpace.width = -2;
    [navigationItem setRightBarButtonItems:@[rightSpace,rightBar]];
}

- (void)setupRefreshControl {
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = KEM_REFRESH_TINTCOLOR;
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"下拉刷新联系人"
                                                                          attributes:@{NSForegroundColorAttributeName:KEM_REFRESH_TINTCOLOR}];
    [self.refreshControl addTarget:self action:@selector(refreshContactsFromServer) forControlEvents:UIControlEventValueChanged];
}


- (void)loadContactsFromServer {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
        EMError *error = nil;
        NSArray *bubbyList = [[EMClient sharedClient].contactManager getContactsFromServerWithError:&error];
        if (!error && bubbyList.count > 0) {
            NSArray *blockList = [[EMClient sharedClient].contactManager getBlackList];
            NSMutableArray *contacts = [NSMutableArray arrayWithArray:bubbyList];
            for (NSString *blockId in blockList) {
                [contacts removeObject:blockId];
            }
            [weakSelf.contacts removeAllObjects];
            for (NSString *contactName in contacts) {
                EMUserModel *model = [[EMUserModel alloc] initWithHyphenateId:contactName];
                [weakSelf.contacts addObject:model];
            }
            [weakSelf.contacts insertObject:NSLocalizedString(@"common.groups", @"Groups") atIndex:0];
            dispatch_async(dispatch_get_main_queue(), ^(){
                [weakSelf.tableView reloadData];
                [weakSelf.refreshControl endRefreshing];
            });
        }
    });
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (!self.refreshControl.refreshing) {
        self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"下拉刷新联系人"
                                                                              attributes:KEM_REFRESH_ATTRIBUTES];
    }
    if (scrollView.contentOffset.y < _refreshOffset.y) {
        self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"松开开始加载联系人"
                                                                              attributes:KEM_REFRESH_ATTRIBUTES];
    }
    else if (scrollView.contentOffset.y > _refreshOffset.y) {
        [self loadContactsFromServer];
    }
}


#pragma mark - Lazy Method 

- (NSMutableArray *)contacts {
    if (!_contacts) {
        _contacts = [NSMutableArray array];
    }
    return _contacts;
}

- (NSMutableArray *)contactRequests {
    if (!_contactRequests) {
        _contactRequests = [NSMutableArray array];
    }
    return _contactRequests;
}

- (NSMutableArray *)groupNotifications {
    if (!_groupNotifications) {
        _groupNotifications = [NSMutableArray array];
    }
    return _groupNotifications;
}

- (EMSearchBar *)searchBar {
    if (!_searchBar) {
        _searchBar = [[EMSearchBar alloc] initWithFrame:CGRectMake(0, 0, 313, 30)];
        [_searchBar setCancelButtonTitle:@"adadd"];
    }
    return _searchBar;
}

#pragma mark - Action Method

- (void)addContactAction {
    //弹出添加联系人页面
    EMAddContactViewController *addContactVc = [[EMAddContactViewController alloc] initWithNibName:@"EMAddContactViewController" bundle:nil];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:addContactVc];
    [self presentViewController:nav animated:YES completion:nil];

}

#pragma mark - Refresh Method

- (void)refreshContactsFromServer {
    if (self.refreshControl.refreshing) {
        self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"loading.loadContacts", @"Load contacts...")
                                                                              attributes:KEM_REFRESH_ATTRIBUTES];
        _refreshOffset = self.tableView.contentOffset;
        [self loadContactsFromServer];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return KEM_CONTACT_SECTION_NUM;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 2) {
        return _contacts.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 2) {
        NSObject *obj = _contacts[indexPath.row];
        NSString *cellIdentify = @"";
        if ([obj isKindOfClass:[NSString class]]) {
            cellIdentify = @"EMGroupTitle_Cell";
            EMGroupTitleCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentify];
            if (!cell) {
                cell = (EMGroupTitleCell *)[[[NSBundle mainBundle] loadNibNamed:@"EMGroupTitleCell" owner:self options:nil] lastObject];
            }
            cell.titleLabel.text = (NSString *)obj;
            return cell;
        }
        else {
            cellIdentify = @"EMContact_Cell";
            EMContactCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentify];
            if (!cell) {
                cell = (EMContactCell *)[[[NSBundle mainBundle] loadNibNamed:@"EMContactCell" owner:self options:nil] lastObject];
            }
            cell.model = (EMUserModel *)obj;
            return cell;
        }
    }
    NSString *cellIdentify = @"Contact_Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentify];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentify];
    }
    cell.textLabel.text = _contacts[indexPath.row];
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            //跳到群组列表
        }
        else {
            EMContactInfoViewController *contactInfoVc = [[EMContactInfoViewController alloc] initWithUserModel:_contacts[indexPath.row]];
            [self.navigationController pushViewController:contactInfoVc animated:YES];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section < KEM_CONTACT_SECTION_NUM - 1) {
        return 60.0f;
    }
    return 50.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    switch (section) {
        case 0:
            if (_groupNotifications.count > 0) {
                return 40.0f;
            }
            break;
        case 1:
            if (_contactRequests.count > 0) {
                return 40.0f;
            }
            break;
        case 2:
            if (!_contactRequests && !_groupNotifications) {
                return 0.0;
            }
            else {
                return 20.0;
            }
            break;
    }
    return 0.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    EMContactListSectionHeader *sectionHeader = [[[NSBundle mainBundle] loadNibNamed:@"EMContactListSectionHeader"
                                                                             owner:self
                                                                           options:nil] firstObject];
    NSUInteger unhandelCount = 0;
    switch (section) {
        case 0:
            unhandelCount = _groupNotifications.count;
            break;
        case 1:
            unhandelCount = _contactRequests.count;
            break;
        default:
            break;
    }
    [sectionHeader updateInfo:unhandelCount section:section];
    return sectionHeader;
}

@end
